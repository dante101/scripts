#!/bin/bash
#vars

IP=$(hostname -I)
RELEASE=$(cat /etc/os-release |egrep  PRETTY_NAME | awk -F= '{print $2}')
KERNEL=$(uname -a | cut -d " " -f 3)
USERS=$(who | cut -d' ' -f1 | sort | uniq)
DATE=$(date)
UPTIME=$(uptime |awk '{print $1,$2}')
TOTAL_MEM=$(free -h | awk -c '{print $1,$2}' |egrep -i "mem:" |awk '{print $2} ')
TOTAL_SWAP=$(free -h | awk -c '{print $1,$2}' |egrep -i "swap" |awk '{print $2}')
USED_MEM=$(free -h | awk -c '{print $1,$3}' |egrep -i "mem" |awk '{print $2}')
USED_SWAP=$(free -h | awk -c '{print $1,$2}' |egrep -i "swap" |awk '{print $2}')
FREE_MEM=$(free -h | awk -c '{print $1,$4}' |egrep -i "mem" |awk '{print $2}')
FREE_SWAP=$(free -h | awk -c '{print $1,$4}' |egrep -i "swap" |awk '{print $2}')
LAST=$( last -15 |awk '{print $1,$3,$4,$5,$6,$7,$10}' |egrep -v reboot | egrep [0-9].[0-9].[0-9].[0-9] | sort )
########################################################################################################################################
echo -e "\e[0m==========================================================================================================================="
echo -e "\e[1;38;5;178mHi there !         			\e[1;5;38;5;208mWelcome to RUSBITECH SPB  Division\e[0m       "
echo -e "\e[0m==========================================================================================================================="
echo -e "\e[1;38;5;15m - Hostname .............................: $HOSTNAME  "
echo -e "\e[1;38;5;15m - IP Address ...........................: $IP  "
echo -e "\e[1;38;5;15m - Release ..............................: $RELEASE  "
echo -e "\e[1;38;5;15m - Kernel ...............................: $KERNEL  "
echo -e "\e[1;38;5;15m - Users who are login now...............: $USERS"
echo -e "\e[1;38;5;15m - System current time ..................: $DATE  "
echo -e "\e[1;38;5;15m - System uptime ........................: $UPTIME  "
echo -e "\e[1;38;5;15m - Total Memory .........................: $TOTAL_MEM  "
echo -e "\e[1;38;5;15m - SWAP .................................: $TOTAL_SWAP  "
echo -e "\e[1;38;5;15m - Used Memory...........................: $USED_MEM  "
echo -e "\e[1;38;5;15m - Used SWAP ............................: $USED_SWAP  "
echo -e "\e[1;38;5;15m - Free Memory ..........................: $FREE_MEM  "
echo -e "\e[1;38;5;15m - Free SWAP ............................: $FREE_SWAP  "
echo -e "\e[0m=============================================================================================================================="
echo -e "\e[1;38;5;15m - Last login was ...............: \n
$LAST"
