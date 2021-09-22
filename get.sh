#!/bin/bash
set -xx
echo -e "Ввидите ip адрес  FTP сервера.."
read IP

echo -e "Ввидите имя файда для скачивания.."
read FILE

ping-test () {
ping -c 3 $IP
if [[ $? != 0 ]];then
    echo -e "Сервер не доступен"
    exit 1
else
    return 0
fi
}

usage () {
    echo -e "Использование $0. $0 <ip address>"
    return
}

get () {
   lftp <<- _EOF_
    $IP
    get
    $FILE
_EOF_
}

if [[ -z $IP ]];then
    echo -e "Пропущен обезательный параметр, ip адрес сервера"
    usage
    exit 1
elif
    [[ ! $IP =~ ^[0-9]{3}\.[0-9]{3}\.[0-9]{3}\.[0-9]{3}$ ]];then
            echo -e "Это не адрес сервера. Пример адреса: 192.168.1.20"
            usage
            exit 1

else
    get
fi