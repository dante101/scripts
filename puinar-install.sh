#!/bin/bash
if [ $UID != 0 ]; then
	echo -e "\e[31mЗапуск это хрени возможен только с правами пользователя ROOT, а Вы не ROOT !!!\e[0m"
	exit 1
fi
ping -c 2 10.178.5.13 > /dev/null
if [ $? != 0 ]; then
        echo -e "\e[31mСборочная машина не отвечат, проверьте сетевое соединение!"\e[0m
        exit 1
fi

FILE=/opt/ktsokr/nkr

reinstall () {
                            dpkg --purge ktsokr-nkr || dpkg --purge ktsokr-libs
                            scp user@10.178.5.13:/home/user/deploy/stretta/ktsokr-libs.deb /tmp/
                            scp user@10.178.5.13:/home/user/deploy/stretta/ktsokr-nkr.deb /tmp/
                            cd /tmp/
                            dpkg -i ktsokr-libs.deb
                            dpkg -i ktsokr-nkr.deb
                               if [[ $? == 0 ]]; then
                                   echo -e "\e[32mEverything went fine.Congrats!\e[0m"
                               else 
                                   echo -e "\e[31m Something went wrong. Sorry"
                                   exit 1
                               fi              
}


install (){
                            scp user@10.178.5.13:/home/user/deploy/stretta/ktsokr-libs.deb /tmp/
                            scp user@10.178.5.13:/home/user/deploy/stretta/ktsokr-nkr.deb /tmp/
                            cd /tmp/
                            dpkg -i ktsokr-libs.deb
                            dpkg -i ktsokr-nkr.deb
                               if [[ $? == 0 ]]; then
                                   echo -e "\e[32mEverything went fine.Congrats!\e[0m"
                               else 
                                   echo -e "\e[31m Something went wrong. Sorry"
                                   exit 1
                               fi  
}

if [[ -d "$FILEr" ]]; then
    echo -e "\e[32mПУ НКР уже установлен! Хоте удалить и переустановить?\e[0m y/n"
    read ANS
    if [[ "$ANS" != y ]]; then
        ANS=false
        until  [ "$ANS" = false ];
        do
           echo -e "\e[32mОтветь может быть только y или n. Или нажмите Ctrl+C для выхода\e[0m y/n"
        done
    fi
else
   case "$ANS" in
        y) reinstall
        ;;
        n) exit 0
            echo "Exiting..."
        ;;
   esac

fi

if  [[ ! -d "$FILE" ]]; then
    echo -e "\e[32mПУ НКР не установлен! Хоте установить?\e[0m y/n"
    read ANS2
    if [[ "$ANS2" != y ]]; then
        ANS2=false
        until  [ "$ANS2" = false ]; 
        do
           echo -e "\e[32mОтветь может быть только y или n. Или нажмите Ctrl+C для выхода\e[0m y/n"
        done
   fi
else
   case "$ANS2" in
        y) install
        ;;
        n) exit 0
            echo "Exiting..."
        ;;
   esac
fi
