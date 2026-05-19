#!/bin/bash
#####################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Mysqldb Setup
# Description: Mysqldb automated script
# Version: 1.0
# Date: 19/05/26
#####################################################

# Colours Formatting
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Script Start Time
START_TIME=$(date +%S)
echo -e "$Y The Script execution started at: $B $START_TIME $N"

# Log Folder Set Up
LOG_FOLDER="/var/log/shellscript-logs"

# Script Name Metadata & Log file set up
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Create Log Folder
mkdir -p $LOG_FOLDER

# Root User Validation
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Proceed with Root User $N"
     exit 1
else
     echo -e "$G You Running With Root User $N"
fi

# Validation Function
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is...SUCCESS $N"
    else
         echo "$R $2 is ...FAILED $N"
    fi

}

##MysqlDB configuration##
# Install Mysql server
dnf install mysql-server -y
VALIDATE $? "Installing mysql-server"

# Enable and Start Mysql Service
systemctl enable mysqld
VALIDATE $? "Enabling mysqld"
systemctl start mysqld
VALIDATE $? "Starting mysqld"

#change the default root password in order to start using the database service. Use password RoboShop@1
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Changing default Password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$G The Script executed Successfully. Time Taken: $TOTAL_TIME seconds $N"
