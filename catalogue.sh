#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)
Log_folder="/var/log/roboshop_logs"
SCRIPT_NAME=$(echo $0 |cut -d . -f1)
log_file="$Log_folder/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $Log_folder
echo " script execution started: $(date)" | tee -a $log_file

if [ $USERID -ne 0 ]
    then
    echo -e " $R you are running user access, pls run in root access $N" | tee -a $log_file
    exit 1
else
    echo -e "$G you are running in root access $N" | tee -a $log_file
fi

VALIDATE(){
    if [ $1 -eq 0 ] 
    then
    echo -e "$2 is $G success $N " | tee -a $log_file
    else
    echo -e "$2 is $R Failure $N " | tee -a $log_file
    exit 1
    fi
}

dnf module disable nodejs -y  &>>$log_file
VALIDATE $? "Disabling exisisting nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$log_file
VALIDATE $? "Installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

mkdir /app &>>$log_file
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

cd /app &>>$log_file
unzip /tmp/catalogue.zip &>>$log_file

npm install &>>$log_file
VALIDATE $? "installing dependies"

CP $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$log_file
VALIDATE $? "copying catalogue services"

systemctl daemon-reload &>>$log_file
systemctl enable catalogue &>>$log_file
systemctl start catalogue
VALIDATE $? "Starting catalogue"

cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$log_file
VALIDATE $? "installing mongodb"

mongosh --host mongodb.nanidevops.site </app/db/master-data.js &>>$log_file
