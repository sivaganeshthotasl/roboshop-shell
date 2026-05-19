#!/bin/bash
################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: User Set UP
# Description: Automated User Installation & Configuration
# Verstion: 1.0
# Date: 19/05/26
################################################

# Colours Formate
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Start Time
START_TIME=$(date +%s)
echo -e "The Script is started executing at $Y $START_TIME"

# Log Folder Set Up
LOG_FOLDER="/var/log/shellscript-logs"

# Script Name Metadata (Script name & Log file)
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Script Dir
SCRIPT_DIR="$(pwd)"

# Create Log Folder
mkdir -p $LOG_FOLDER &>>LOG_FILE

# Root User Validation
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Proceed with Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are Running With ROOT User $N" | tee -a $LOG_FILE
fi

# Validate Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is...SUCCESS $N" | tee -a $LOG_FILE
    else
         echo -e "$R $2 is...FAILED $N" | tee -a $LOG_FILE
         exit 1
    fi
    
}



# Disable & Enable NodeJS
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS"

#Install NodeJS
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

#####Application Configuration#####
# Creating Application User
echo -e "$Y Creating roboshop application User $N" | tee -a $LOG_FILE
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
else
     echo -e "$B User already existed.. $Y Skipping $N"  | tee -a $LOG_FILE
fi

# Create /app folder
mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating Application home folder"

# Download the user content to /tmp folder
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading User Content"
cd /app
unzip -o /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Extracting User content files"

# Installing NodeJS Dependencies
cd /app
npm install &>>$LOG_FILE
VALIDATE $? "Installing NodeJS Dependencies"

# User Service Configuration
# 1. Create user.service locally inside project/repo
# 2. Add repository content > Refer user doc
# 3. Copy file to /etc/systemd/system/user.service

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "Copying User systemd service"

# Reload the Systemd Manager
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading Systemd Manager"

# Enable & Start the User Service
systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enabling User Service"
systemctl start user &>>$LOG_FILE
VALIDATE $? "Starting User Service"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$B The script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
