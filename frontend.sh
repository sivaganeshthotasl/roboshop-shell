#!/bin/bash

###################################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Frontend
# Description: Frontend Service Set Up Script
# Version : 1.0
# Date: 18/05/26
###################################################################

# Colour Variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Log Folder Configuration
LOG_FOLDER="/var/log/shellscript-logs"

# Script Metadata Variables
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"

# Log File Set Up
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Creating Script Dir
SCRIPT_DIR=$(pwd)

# Create Log Folder
mkdir -p "$LOG_FOLDER"
echo -e "$Y Script started executing at $(date) $N" | tee -a $LOG_FILE

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Run This Script With Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are Runnnig with Root $Y User $N" | tee -a $LOG_FILE
fi

# Validation Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is...SUCCESS $N" | tee -a $LOG_FILE
    else
         echo -e "$R $2 is...FAILED $N" | tee -a $LOG_FILE
         exit 1
    fi

}

# Disable & Enable Nginx

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disable Nginx"
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx"

# Install Nginx
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

# Enable & Start Nginx
systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling Nginx"
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting Nginx"

# Remove Default Nginx web content
rm -rf /usr/share/nginx/html/*
VALIDATE $? " Removing Default Nginx Content"

# Download Front Application Code
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Frontend Content to /tmp"

# Extract Frontend Application Files
cd /usr/share/nginx/html
unzip -o /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting frontend files"

# Copy Roboshop Nginx conf file 
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying updated nginx.conf file"

# Validating nginx conf
nginx -t &>>$LOG_FILE
VALIDATE $? "Validating Nginx"

# Restart Nginx 
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting Nginx"








