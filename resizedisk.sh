#!/bin/bash 
TOTALSIZE=$(parted /dev/sda p |egrep Disk |egrep -o '[0-9]+(\.[0-9])?')
SDA1=$(parted /dev/sda p |egrep Size -A 1 | egrep [[:digit:]] | awk '{print $4}')
SDA=$(lsblk  | grep -P sda1 |awk  '{print $4}' |grep -oE '[0-9]{1,5}+(\.[0-9]{1,3})?')


usage () {
printf "\e[33m1. Данный скрип работает только с диском sda.\e[0m 
              2. Изменить раздел в меньшую сторону нельзя.
              3. Размер раздела указывается просто цифрами. Наприме: 30 или 40. Добавлять какие либо знаки, такие как  GB или MB не допускается
              4. Если нужно использовать все доступное пространство диска просто наберите \e[32mmax \e[33mили \e[32mMAX\e[0m].
    \e[32m######################################################################################################\e[0m\r
      ------>   \e[32mТекущий размер раздела sda1  \e[0m$SDA1  \e[32mвсего на диске доступно \e[0m$TOTALSIZE GB\e[0m <------
    \e[32m######################################################################################################\e[0m\r

       \e[5mЗапустите скрипт еще раз без параметров.\e[0m\n\r"
      } 


if [[ -z $1 && ! -f /tmp/resizedisk.lock ]]; then  
   : > /tmp/resizedisk.lock
   usage
   exit 0
fi

echo "Идет установка зависимостей. Пожалуйста ждите."
printf "\e[33################################\e[0m"
apt update  &> /dev/null
apt install expect -y &> /dev/null  
apt install cloud-guest-utils -y  &> /dev/null

resizepart () {
/usr/bin/expect <<  _EOF_
spawn parted 
expect "(parted)"
send "resizepart 1\r"
expect "Warning: Partition /dev/sda1 is being used. Are you sure you want to continue?"
send "Yes\r"
expect "End?"
send "${NEWSIZE}GiB\r"
expect "(parted)"
send "print\r"
expect "(parted)"
send "quit\r"
expect eof
_EOF_
resize2fs /dev/sda1 
clear
local MESS=$(df -h | egrep sda1)
echo -e "\e[32m Раздел изменен $MESS\e[0m"
}

resize () {
   echo -e "\e[32mУкажите будующий размер раздела или MAX для использования всего пространства:\e[0m"
   read NEWSIZE
   
   echo -e "\e[32###############\e[0m"
if 
     [[ ${NEWSIZE} == max || ${NEWSIZE} == MAX ]]; then
     growpart_fn

  elif
      [[ ${NEWSIZE} < ${SDA} || ${NEWSIZE} > ${SIZE} ]]; then
         echo -e " Указанный ${NEWSIZE} или меньше текущего, либо больше максимально возможного\e[0m] "
         exit 1
  else 
     resizepart
fi

}

growpart_fn () {
growpart /dev/sda 1 &&  resize2fs /dev/sda1
} 


echo -e "\e[32mТекущий размер раздела sda1  \e[0m$SDA1  \e[32mвсего на диске доступно \e[0m$SIZE GB\e[0m "
echo -e "Хотите изменить размер раздела sda1? y/n"
read ANS
if [[ -z ${ANS} ]]; then
     usage
    
else
  case ${ANS} in
    y)  resize
   ;;
    n)  echo  -e "Nothing to do. Exiting ...."
        rm /tmp/resizedisk.lock
        exit 2
      ;;
    *) usage
     ;;
esac
   
fi
#trap "/tmp/resizedisk.lock"
rm /tmp/resizedisk.lock