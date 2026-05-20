#!/bin/bash

#########################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Dispatch
# Discription: Dispatch script automated
# Version: 1.0
# Date: 20/5/26
#########################################

# Colours Formate
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Log Folder Set Up
LOG_FOLDER="/var/log/shellscript-logs"

# Script Name Metadata & Log File Set Up
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Script Dir
SCRIPT_DIR="$(pwd)"

# Create Log Folder
mkdir -p $LOG_FOLDER

# Script Start Time
START_TIME="$(date +%s)"
echo -e "$Y The Script execution started at $START_TIME $N" | tee -a $LOG_FILE

# Root User Validation 
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then 
     echo -e "$R ERROR:: Please Proceed with Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are Running with Root User $N" | tee -a $LOG_FILE
fi

# Validate Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is...SUCCESS $N" | tee -a $LOG_FILE
    else
         echo -e "$R $2 is....FAILED $N" | tee -a $LOG_FILE
         exit 1
    fi
}

# Install the required Go because dispatch built by Go Lang
dnf install golang -y &>>$LOG_FILE
VALIDATE $? "Installing Golang"

###Configure the application###

# Create a user to run dispatch application
id roboshop 
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATE $? "Creating roboshop user"
else
     echo -e "$Y The roboshop user is already Created...$B Skipping $N" | tee -a $LOG_FILE
fi

# Create /app dir to store dispatch content
mkdir -p /app

#Download the application source code into the application directory
curl -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading the application source code"

# Extract the dispatch content to /app
cd /app
unzip -o /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "Extracting Dispatch"

# install the required dependencies 
cd /app
if [ -f go.mod ]
then
     echo -e "$Y go.mod already exists...Skipping $N" | tee -a $LOG_FILE
else
     go mod init dispatch &>>$LOG_FILE
     VALIDATE $? "Initializing Dispatch"
fi

# Dowload the Libraries and build the application
go get &>>$LOG_FILE
VALIDATE $? "Dowloading Libraries"
go build &>>$LOG_FILE
VALIDATE $? "Creating executables"

## dispatch service Configuration
# 1. Create dispatch.service locally inside project/repo
# 2. Add repository content > Refer dispatch doc
# 3. Copy file to /etc/systemd/system/dispatch.service
cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service &>>$LOG_FILE
VALIDATE $? "Copying dispatch service file"

# Reload the Systemd
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading Systemd"

# Enable & Start Dispatch Service
systemctl enable dispatch &>>$LOG_FILE
VALIDATE $? "Enbaling dispatch"
systemctl start dispatch &>>$LOG_FILE
VALIDATE $? "Starting Dispatch Service"

END_TIME="$(date +%s)"
TOTAL_TIME=$(( $END_TIME - $START_TIME))
echo -e "$G The Script is Executed Successfully. Time Taken: $B $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

