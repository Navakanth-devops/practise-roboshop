#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)
Log_folder="/var/log/roboshop_logs"
SCRIPT_NAME=$(echo $0 |cut -d . -f1)
log_file="$Log_folder/$SCRIPT_NAME.log"

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
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
VALIDATE $? "copyieng mongodb repo"

dnf install mongodb-org -y &>>$log_file
VALIDATE $? "installing mongo db"

systemctl enable mongod
systemctl start mongod
VALIDATE $? "starting mongodb" &>>$log_file

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "editing mongodb for remote connection" &>>$log_file

systemctl restart mongod
VALIDATE $? "Restarting  Mongodb" &>>$log_file