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

# Log Folder Configurations
LOG_FOLDER="/var/log/shellscript-logs"

# Scripting Metadta Configuration and Log File Set up
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log

# Creating Log Folder and Set Time Stamp
mkdir -p $LOG_FOLDER
echo -e "$Y The Script is started executing at $(date) $N"

# Script Directory
SCRIPT_DIR="$(pwd)"

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Run This Script with Root User $N"
     exit 1
else
     echo -e "$B You are Running with Root User $N"
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is.. Sucess $N"
    else
         echo -e "$R $2 is ... Failed $N"
         exit 1
    fi
}

# Disable and Enable Redis 
dnf modlue disable redis -y
VALIDATE $? "Disabling and Enabling Redis"

dnf module enable redis










































