#!/bin/bash

declare -A osInfo;

# Checks the output of the file /etc/x and according to it, tells which package manager does the system use. Weird Associative array
osInfo[/etc/redhat-release]="sudo dnf install -y"
osInfo[/etc/arch-release]="sudo pacman -S --noconfirm"
osInfo[/etc/SuSE-release]="sudo zypper install -y"
osInfo[/etc/debian_version]="sudo apt install -y"

for f in "${!osInfo[@]}"
do
    if [[ -f $f ]];then
        package_manager="${osInfo[$f]}"
    fi
done

echo "Installing vsfptd service" 

$package_manager vsftpd

echo "Turning ftp server on"

sudo systemctl enable --now vsftpd 

echo "UFW firewall can cause issues. Do you want to disable it (y), add vsftpd to the exceptions list (e) or keep UFW on (on)"

read -r decision

if [ "$decision" = "y" ]; 
then
    sudo ufw disable
fi


if [ "$decision" = "e" ]; 
then
    sudo ufw allow vsftpd
fi

echo "Connecting to FTP server"
echo "Remember to activate 'write enable' on the configuration file. You can use any FTP client from now on. Goodbye"

ip=`ip a | grep -oP '(?<=inet )192\.168\.\d+\.\d+'`

ftp $ip
