#!/bin/bash

###################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Shipping
# Description: Shipping Automated Script
# Version: 1.0
# Date: 19/05/26
####################################################

# Colours Formate
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"



# Script Dir
SCRIPT_DIR=$(pwd)

# Log Folder Set Up
LOG_FOLDER="/var/log/shellscript-logs"

# Script Name Metadata & Log File Set Up
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Create a Log Folder Dir
mkdir -p $LOG_FOLDER

#Start Time
START_TIME=$(date +%s)
echo -e "$Y The Script is execution started at: $START_TIME $N" | tee -a $LOG_FILE

# Root User Validation
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:: Please Proceed with Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are Running With Root User $N" | tee -a $LOG_FILE
fi

# Validatation Function Set Up
VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is....SUCCESS $N" | tee -a $LOG_FILE
    else
         echo -e "$R $2 is...FAILED $N" | tee -a $LOG_FILE
         exit 1
    fi
}

###Shipping Service Configuration###
# Installing Maven or Java
dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

# Creat Application user to run shpping Service
id roboshop 
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATE $? "Creating roboshop User"
else
     echo -e "$B roboshop User is Already Created...$Y Skipping $N" | tee -a $LOG_FILE
fi

# Set Up /app Dir to store shipping content
mkdir -p /app &>>$LOG_FILE

# Downloading shipping Content to /tmp
curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading shipping content"

# Extract Shipping Files to /app
cd /app
unzip -o /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Extracting Shipping Content"

# Install Dependencies & Build the application
cd /app
maven clean package &>>$LOG_FILE
VALIDATE $? "Clear the Old dependencies and Installing new dependencies"
mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "rename the shipping.jar file and store in the /app"

# # Shipping Service Configuration
# 1. Create shipping.service locally inside project/repo
# 2. Add repository content > Refer shipping doc
# 3. Copy file to /etc/systemd/system/shipping.service
cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying shipping.service to systemd"

# Reload SystemD Manager
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading Systemd"

# Enable and Start shipping Service
systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping"

# For this application to work fully functional we need to load schema to the Database.
# We need to load the schema. To load schema we need to install mysql client.
dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Install mysql client"

# Load the Schema, app-user and masterdata
## Check whether shipping schema already exists
SCHEMA_CHECK=$(mysql -h mysql.robossl.shop -uroot -p Roboshop@1 -se "use cities; show tables;" | wc -1)
if [ $SCHEMA_CHECK -ne 0 ]
then
     mysql -h mysql.robossl.shop -uroot -p RoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
     VALIDATE $? "Loading Schema into mysqldb"
     mysql -h mysql.robossl.shop -uroot -p RoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
     VALIDATE $? "Loading appliction user data"
     mysql -h mysql.robossl.shop -uroot -p RoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
     VALIDATE $? "Loading the Master data"
else
     echo -e "$B shipping Schemas Already Exists...$Y Skipping $N" | tee -a $LOG_FILE

# Restart the Shipping Service
systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restaring Shipping Service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "$G The Script Execution is completed Successfully. And Time Taken $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

