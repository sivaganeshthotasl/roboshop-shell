#!/bin/bash

###########################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Payment
# Description: Payment script automated
# Version: 1.0
# Date: 20/05/26
###########################################

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

# Create Log Folder
mkdir -p $LOG_FOLDER

# Script Start Time
START_TIME="$(date +%s)"
echo -e "$Y The Script execution started at $START_TIME $N"

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Proceed with Root User $N"
     exit 1
else
     echo -e "$G You are Running with Root User $N"
fi

# Validate Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo "$G $2 is....SUCCESS $N"
    else
         echo "$R $2 is....FAILED $N"
         exit 1
    fi
}


# Install Python 3 and required build tools
dnf install python3 gcc python3-devel -y
VALIDATE $? "Installing Python3 & Build Tools"

##Configure the Application##

# Create a user to run the pyment application
id roboshop
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
     VALIDATE $? "Creating User to Run applicaion"
else
     echo -e "$Y User is already Created....$B Skipping $N"
fi

# Create a directory to store and run payment app files
mkdir -p /app
VALIDATE $? "Creating /app Dir"

# Downloading Payment file in /tmp
curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading Payment files"

# Extracting Content of Payment in /app
cd /app
unzip -o /tmp/payment.zip
VALIDATE $? "Extracting Payment files"

# Install all required application dependencies
cd /app
pip3 install -r requirements.txt
VALIDATE $? "Install Requirement Dependencies"

## payment service Configuration
# 1. Create payment.service locally inside project/repo
# 2. Add repository content > Refer payment doc
# 3. Copy file to /etc/systemd/system/payment.service
cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying payment.service file"

# Reload the Systemd Manager
systemctl daemon-reload
VALIDATE $? "Reloading Systemd Service"

# Enable & Start Payment Service
systemctl enable payment
VALIDATE $? "Enabling Payment Service"
systemctl start payment
VALIDATE $? "Starting Payment Service"

END_TIME="$(date +%s)"
TOTAL_TIME="$(( $END_TIME - $START_TIME ))"
echo -e "$Y The script execution is completed successfull. Time Taken: $B $TOTAL_TIME seconds $N"

