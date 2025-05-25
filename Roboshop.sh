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
   echo -e "Installing $2 is $G success $N " | tee -a $log_file
else
   echo -e "Installation $2 is $R Failure $N " | tee -a $log_file
fi
}

for package in ${Packages[@]}
do
dnf list installed $package &>> $log_file

if [ $? -ne 0 ]
   then
   echo -e " installing $package $G installing $N " | tee -a $log_file
   dnf install $package -y &>>$log_file
   VALIDATE $? "$package" 
else 
   echo -e " $package $G  Already installed $N " | tee -a $log_file

fi
done
