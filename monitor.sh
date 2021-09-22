#!/bin/bash
#set -xx
set -a
#export $0 $1 $2  $3 $4 $5 $6 $7 $8 $9
VAR1=$1
VAR2=$2
VAR3=$3
VAR4=$4
VAR5=$5
VAR6=$6
VAR7=$7
VAR8=$8
VAR9=$9
OS_VERSION=$(cat /etc/os-release | awk -F= 'NR==1 {print $2}')
PROG=$(basename $0)
usage (){
  echo -e   "\e[0m$PROG: Usage: $PROG  <parametr> argument
        paramets:
            -p, --proc - работа с директорией /proc
            -c, --cpu - работа с процессором
            -m, --memory - работа с памятью
            -d, --disks - работа с дисками
            -n, --network - работа с сетью
            -la, --loadaverage - вывод средней нагрузки на систему
            -k, --kill - отправка сигналов процессам (простой аналог утилиты kill)
            -o, --output - сохранение результатов работы скрипта на диск
            -h, --help - вывод предназначения скрипта, помощи для верного запуска и описания всех команд с примерами\e[0m"
            return
}
#Work with /PROC directory
_proc () {
    local PROC="/proc"
    if [[ -d "$PROC/$VAR2" ]];then
        echo "$(ls -l "$PROC/$VAR2")"
    elif  [[ -f "$PROC/$VAR2" ]];then
        echo "$(cat "$PROC/$VAR2")"             
    else 
        echo "$(ls -l "$PROC")"
    fi
    return
}

#CPU Info
_cpu () {
    if [[ ! -x /usr/bin/mpstat ]];then
        echo -e "\e[0mSysstat does not installed. Please install sysstat packet first and try again\e[0m"
        echo -e "\e[0mRun $PKGMGR install sysstat\e[0m"
        exit 1
    else
        case $VAR2 in
            usr) echo -e "\e[33m$(mpstat | awk 'NR==4 {print $4}')\e[0m"
            ;;
            sys) echo -e "\e[33m$(mpstat | awk 'NR==4 {print $6}')\e[0m"
            ;;
            idle) echo -e "\e[33m$(mpstat | awk 'NR==4 {print ${13}')\e[0m"
            ;;
            *) echo -e "\e[33m$(mpstat)\e[0m"
        esac
    fi
}

#Memory Info

_mem () {
    case "$VAR2" in
        total) echo -e "\e[32mTotal memory installed: $(free -h | awk 'NR==2 {print $2}')\e[0m" 
        ;;
        used) echo -e "\e[32mMemory is used:$(free -h | awk 'NR==2 {print $3}')\e[0m" 
        ;;
        free) echo -e "\e[32mMemore free: $(free -h | awk 'NR==2 {print $4}')\[e0m" 
        ;;
        available) echo -e "\e[32mMemory available: $(free -h | awk 'NR==2 {print $7}')\e[0m"
        ;;
        *) free -h
    esac
    return
}

#Disk info

_disk () {
    local DISK=$VAR2
    if [[ -z $DISK ]];then
        echo -e "\e[33mThere is noting to do Bay...\e[0m"
    else
        echo -e "\e[32m$(df -h $DISK)\e[0m"
    fi
}

_net () {
    
}

if [[ -z "$1" || "$1" == "--help" || "$1" == "-h" ]];then
    usage
elif [[ -n "$1" ]];then
        case "$1" in
            -p|--proc) _proc
            ;;
            -c|--cpu) _cpu
            ;;
            -m|--memory) _mem
            ;;
            -d|--disk) _disk
            ;;
            -n|--network) _net
            ;;
            -la|--loadaverage) _load
            ;;
            -k|--kill) _kill
            ;;
            -o|--output) _output
            ;;
            *) usage
        esac
else
    echo -e "Please use -h or --help in order to show reference"
fi

if [[ "$OS_VERSION" == Fedora ]];then
        PKGMGR=yum
    elif [[ "$OS_VERSION" == Debian ]];then
        PKGMGR=apt
else    
    echo -e "\e[33mHave no idea what kind of packet manager you use"
fi