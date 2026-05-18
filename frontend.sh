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

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Run This Script With Root User $N"
     exit 1
else
     echo -e "$G You are Runnnig with Root $Y User $N"
fi

# Validation Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is...SUCCESS $N"
    else
         echo -e "$R $2 is...FAILED $N"
         exit 1
    fi

}

# Disable & Enable Nginx

dnf module disable nginx -y
VALIDATE $? "Disable Nginx"
dnf module enable nginx:1.24 -y
VALIDATE $? "Enabling Nginx"

# Install Nginx
dnf install nginx -y
VALIDATE $? "Installing Nginx"

# Enable & Start Nginx
systemctl enable nginx
VALIDATE $? "Enabling Nginx"
systemctl start nginx
VALIDATE $? "Starting Nginx"

# Remove Default Nginx web content
rm -rf /usr/share/nginx/html/*
VALIDATE $? " Removing Default Nginx Content"

# Download Front Application Code
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading Frontend Content to /tmp"

# Extract Frontend Application Files
cd /usr/share/nginx/html
unzip -o /tmp/frontend.zip
VALIDATE $? "Extracting frontend files"

# Copy Roboshop Nginx conf file 
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying updated nginx.conf file"

# Validating nginx conf
nginx -t
VALIDATE $? "Validating Nginx"

# Restart Nginx 
systemctl restart nginx
VALIDATE $? "Restarting Nginx"








