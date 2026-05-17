#!/bin/bash

######################################################################
# Author: Siva Ganesh Thota SL
# Project: Roboshop Automation
# Component: Catalogue Setup
# Automated Catalogue installation & configuration script
# Version: 1.0
# Date: 17/05/26
#######################################################################

# Colour Variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Log Folder Configuration
LOG_FOLDER="/var/log/shellscript-log"

# Script Metadata Variables & Log File Setup
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

# Create Log Folder and Set Time stamp
mkdir -p $LOG_FOLDER
echo -e "$B script is started executing at $(date) $N"  | tee -a $LOG_FILE

# Creating Script Directory for copying mongo.repo for installing mongodb client.
SCRIPT_DIR="$PWD"

# Root User Validation
USER_ID="$(id -u)"
if [ $USER_ID -ne 0 ]
then
     echo -e "$R ERROR:; Please Run This Script With Root User $N" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You Are Running With Root User $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
         echo -e "$G $2 is.... SUCCESS $N" | tee -a $LOG_FILE
    else
         echo -e "$R $2 is.... FAILED $N" | tee -a $LOG_FILE
         exit 1
    fi
}

# Disable Default Nodejs Version
echo -e "$B Disabling Default Nodejs Version $N"
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Nodejs"

# Enable NodeJS 20 Version
echo -e "$B Enabling NodeJS 20 Version $N"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20 Version"

# Install NodeJS
echo -e "$B Installing NodeJS $N"
dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

# Creating Roboshop Application User
id roboshop
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "Roboshop System User" Roboshop &>>$LOG_FILE
     VALIDATE $? "Creating Roboshop Application User"
else
     echo -e "$B Roboshop User Already Created.. $Y Skipping $N"
fi


# Creating Application Directory
echo -e "$B Creating a /app Directory $N"
mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating Application Directory"

# Download the Catalogue Application Code into /tmp Directory
echo -e "$B Downloading Catalogue zip File into /tmp Directory $N"
curl -o /tmp/catalogue.zip curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue zip File into /tmp Directory"

# Extract Catalogue Application Files
echo -e "$B Chage to /app and Extracting Catalogue app files"
cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Extracting Catalogue app files"

# Install NodeJS Dependencies 
echo -e "$Y Installing NodeJS Dependencies $N"
npm install &>>$LOG_FILE
VALIDATE $? "Install NodeJS Dependencies"

## Catalogue Service Configuration
# 1. Create catalogue.service locally inside project/repo
# 2. Add repository content > Refer catalogue doc
# 3. Copy file to /etc/systemd/system/catalogue.service

# Copy Catalogue Service File
echo -e "$G Copying catalogue service file $N"
cp $PWD/catalogue.service /etc/systemd/system/catalogue.service  &>>$LOG_FILE
VALIDATE $? "Copying catalogue service file"

# Reload SystemD Manager
echo -e "$Y Reloading SystemD Manager $N"
systemctl daemon Reload  
VALIDATE $? "Reloading SystemD Manager"

# Enable & Start Catalogue service
echo -e "$G Enabling & Start Catalogue service $N" 
systemctl enable catalogue  
VALIDATE $? "Enable Catalogue service"
systemctl start catalogue  
VALIDATE $? "Start Catalogue service"

## MonCagoDB Repository Configuration
# 1. Create mongodb.repo locally inside project/repo
# 2. Add repository content > Refer Mongodb doc
# 3. Copy file to /etc/yum.repos.d/

Copy MongoDB Repo File
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo  
VALIDATE $? "Copy MongoDB Repo File"

# Install MongoDB client
dnf install mongodb-mongosh-org -y  &>>$LOG_FILE
VALIDATE $? "Installing MongoDB client"

# Load catalogue schema into MongoDB
mongosh --host mongodb.robossl.shop >/app/db/master-data.sh &>>$LOG_FILE
VALIDATE $? "Load catalogue schema"


