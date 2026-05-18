#!/bin/bash

####################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Autmation
# Component: Redis
# Description: Redis Service Set Up script
# Version: 1.0
# Date: 18/05/26
#####################################################


# Colours Formating
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

START_TIME=$(date +%s)
echo -e "The Script is started executing at $Y $START_TIME"

# Log Folder Configurations
LOG_FOLDER="/var/log/shellscript-logs"

# Scripting Metadta Configuration and Log File Set up
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log

# Creating Log Folder and Set Time Stamp
mkdir -p $LOG_FOLDER


# Script Directory
SCRIPT_DIR="$(pwd)"

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Run This Script with Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$B You are Running with Root User $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is.. Sucess $N" | tee -a $LOG_FILE
    else
         echo -e "$R $2 is ... Failed $N" | tee -a $LOG_FILE
         exit 1
    fi
}

# Disable and Enable Redis 
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling and Enabling Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

# Installing Redis
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

# Update bind IP and Protect Mode as NO
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf

# Enable and Start Redis Service
systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis Service"
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting Redis Service"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "The script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FOLDER











































