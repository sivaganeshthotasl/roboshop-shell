#!/bin/bash

########################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Rabbitmq
# Discription: Rabbitmq script Automated
# Version: 1.0
# Date: 20/05/26
########################################

# Colours Formate
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Log Folder Set Up
LOG_FOLDER="/var/log/shellscript-logs"

# Script Name Metadata & Log File Set Up
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Script Dir
SCRIPT_DIR="$(pwd)"

# Create Log Folder
mkdir -p $LOG_FOLDER

# Script Start Time
START_TIME="$(date +%s)"
echo -e "$Y The script Execution started at $START_TIME $N" | tee -a $LOG_FILE

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Proceed with Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are Running With Root User $N" | tee -a $LOG_FILE
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

## Rabbitmq Repository Configuration
# 1. Create rabbitmq.repo locally inside project/repo
# 2. Add repository content > Refer rabbitmq doc
# 3. Copy file to /etc/yum.repos.d/rabbitmq.repo
cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copying rabbitmq repo file"

# Install RabbitMQ
dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing Rabbitmq"

# Enable and Start RabbitMQ 
systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq-server"
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq-server"

# RabbitMQ provides a default login but it cannot be used by the application
# Creating a new User for RabbitMQ
rabbitmqctl list_users | grep roboshop
if [ $? -ne 0 ]
then
     rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE # this will be used by your application to connect rabbitmq
     VALIDATE $? "Add roboshop user to rabitmq"
else
     echo -e "$Y roboshop user is already created....$B Skipping $N" | tee -a $LOG_FILE
fi

# Give full access permission to the user
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Giving Full Permission"

END_TIME="$(date +%s)"
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$Y The Script Execution completed successfully. Time Taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
