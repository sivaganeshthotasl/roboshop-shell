#!/bin/bash
##########################################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Mongodb Setup
# Description: Automated Mongodb installation and configuration Script
# Version: MongoDB 7.0
# Date: 17-05-26
###########################################################################

# Colours and Formatting
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Log Folder configuration
LOG_FOLDER="/var/log/shellscript-logs"

# Script Metadata Variables
SCRIPT_NAME="$(echo "$0" | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Create Log Folder
mkdir -p "$LOG_FOLDER"
# Set the Time stamp
echo -e " Script is started executing at $B $(date) $N " | tee -a $LOG_FILE

# Root User Validation
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Run This Script With Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are Running With Root User $N"  | tee -a $LOG_FILE
fi

# Validation Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo " $G $2 is SUCCESS $N "  | tee -a $LOG_FILE
    else
         echo " $R $2 is FAILED $N "   | tee -a $LOG_FILE
         exit 1
    fi

}

## MongoDB Repository Configuration
# 1. Create mongodb.repo locally inside project/repo
# 2. Add repository content > Refer Mongodb doc
# 3. Copy file to /etc/yum.repos.d/
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying MongoDB repo"


# MongoDB Package Installation 
echo -e " $Y Installing MongoDB package $N " | tee -a $LOG_FILE
dnf install mongodb-org -y &>>$LOG_FILE 
VALIDATE $? "Installing MongoDB Instance"

# Enable and Start MongoDB
echo -e "$Y Enabling MongoDB $N" | tee -a $LOG_FILE
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enable MongoDB"

echo -e "Y Starting MongoDB Instance $N" | tee -a $LOG_FILE
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

# Update MongoDB Listen Address bindIp: 127.0.0.1 > bindIp: 0.0.0.0
echo -e "$Y Updating MongoDB configuration $N " | tee -a $LOG_FILE
sed -i 's/127.0.0.1/0.0.0.0 ' /etc/mongod.conf
VALIDATE $? "Updating MongoDB Remote Connection"

# Restart Mongodb Service
echo -e " $Y Restarting MongoDB Service $N"  | tee -a $LOG_FILE
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"






