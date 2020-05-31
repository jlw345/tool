#!/bin/bash

#Upgrade system components
echo "Start upgrading system components..."
yum -y update
echo "Upgrade system components complete."

#Install common components
echo "Start to install common components..."
yum install -y curl vim wget unzip gzip git nano crontabs ntp bash-completion python expect perl ntp tree
echo "Common components installation completed."

#About time
yum -y install ntp
systemctl stop ntpd.service
systemctl stop ntpdate.service
systemctl disable ntpd.service
systemctl disable ntpdate.service

ntpdate time1.google.com
if [ $? -ne 0 ];then
	ntpdate -ubv time1.google.com
	if [ $? -ne 0 ];then
		echo -e "\e[41;37m Time synchronization failed.\e[0m"
	else
		echo "Time synchronization successful."
	fi
fi
echo "Time synchronization successful."
hwclock -w
timedatectl set-ntp no
echo "Time written to hardware successful."

#Modify time zone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
if [ $? -eq 0 ];then
	echo "Time zone modified successfully."
else
	echo -e "\e[41;37m Time zone modification failed. \e[0m"
fi

#selinux
setenforce 0
sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
if [ $? -eq 0 ];then
	echo "SELinux shut down successfully"
else
	echo -e "\e[41;37m Error in SELinux. \e[0m"
fi

#Denyhosts installation
wget -N --no-check-certificate https://raw.githubusercontent.com/jlw345/DenyHosts/master/denyhosts.sh && chmod +x denyhosts.sh && ./denyhosts.sh
if [ $? -eq 0 ];then
	echo "Denyhosts installed successfully."
else
	echo -e "\e[41;37m Denyhosts installation failed. \e[0m"
fi

echo -e "\e[42;37m Program running completed. \e[0m"
