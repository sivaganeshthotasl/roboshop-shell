#!/bin/bash

################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Cart Set UP
# Description: Automated Cart Installation & Configuration
# Verstion: 1.0
# Date: 19/05/26
################################################

# Colours Formating
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Script Start Time
START_TIME=$(date +%s)
echo -e "$Y The Script Execution started at: $B $START_TIME" | tee -a $LOG_FILE

# Log Folder Set Up
LOG_FOLDER="/var/log/shellscript-logs"

# Script Name Metadata (Script name & Log file)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Script Present Dir
SCRIPT_DIR="$(pwd)"

# Create a Log Folder
mkdir -p $LOG_FOLDER

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Proceed with Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$Y You are Running with Root User $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is...SUCCESS $N" | tee -a $LOG_FILE
    else 
         echo -e "$R $2 is...FAILED $N" | tee -a $LOG_FILE
    fi
}

# Disable default NodeJS & Enable NodeJS:20
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling the Default NodeJS"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabing NodeJs:20 Version"

# Install Nodejs
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

# Create a Appliction User (roboshop)
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     echo -e "$G roboshop user is create $N" | tee -a $LOG_FILE
else
     echo -e "$Y User already Created... $B Skipping $N" &>>$LOG_FILE
fi

# Create /app dirctory to store cart contenct files
mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "Creating Application Home Dir"

# Downloading Cart content to /tmp
curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading Cart Content to /tmp"
cd /app
unzip -o /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Extracting Cart Files in the /app"

# Install NodeJS Dependencies
cd /app
npm install  &>>$LOG_FILE
VALIDATE $? "Installing NodeJS Dependencies"

# # Cart Service Configuration
# 1. Create cart.service locally inside project/repo
# 2. Add repository content > Refer cart doc
# 3. Copy file to /etc/systemd/system/cart.service
cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service 
VALIDATE $? "Copying cart.service file"

# Reloading Systed Manager
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading Systemd"

# Enable & Start Cart Service
systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enabling Cart Service"
systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting Cart Service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$Y The Script execution completed $G Successfully. Time Taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE


