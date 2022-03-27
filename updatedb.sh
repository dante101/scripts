#!/bin/bash -x

#variables
DBNAME=mini_shd
DBUSER=miniuser
#DBPASS=100
DBHOST=127.0.0.1
DATE=$(date +%F:%R)
LOG=/opt/dumpdb.log
BACKUP_PATH=/opt/backupdb/
DUMPNAME=mini_shd.sql
UPLOAD_PATH=/opt/upload/
SQL=sql

#funcions

mini-shdstop () {
     systemctl stop mini-shdd.service
     sleep 2
}

mini-shdstart () {
     systemctl start mini-shdd.service
      sleep 2
}

dumpdb () {
        [ -d  ${BACKUP_PATH} ] || mkdir -p  ${BACKUP_PATH}
        echo "Start backup ${DATE}" >> ${LOG}
        pg_dump -h ${DBHOST} -d ${DBNAME} -U ${DBUSER}  -f ${BACKUP_PATH}${DUMPNAME}.${DATE}  2>> ${LOG}

        if [[ $? != 0 ]]; then
              echo -e "\e[31mDump of database wan not create. Please check log lile ${LOG}\e[0m"
              exit 1
           else
              echo -e "\e[32mEvervrything is Ok. Your dump of database was saved in /opt/backupdb/ folder\e[0m"
        fi
        echo "End backup ${DATE}" >> ${LOG}
}

dumprestore () {
       echo "Start restore ${DATE}" >> ${LOG}
       echo "Disable all users from database"
      psql  -U ${DBUSER} -h ${DBHOST} -d  ${DBNAME} -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'TARGET_DB' AND pid <> pg_backend_pid();"
      dropdb -U ${DBUSER} -h ${DBHOST} ${DBNAME} 2>> ${LOG}
      if [[ $? != 0 ]]; then
              echo -e "\e[31mDatabase wan not delete. Please check log lile ${LOG}\e[0m"
              exit 1
           else
              echo -e "\e[32mEvervrything is Ok. Database was succesfully deleted\e[0m"
      fi
        echo "Create database"
      createdb -U ${DBUSER} -h ${DBHOST} -O  ${DBUSER}  ${DBNAME} 2>> ${LOG}
      if [[ $? != 0 ]]; then
              echo -e "\e[31mDump of database wan not create. Please check log lile ${LOG}\e[0m"
              exit 1
           else
              echo -e "\e[32mEvervrything is Ok. Your dump of database was saved in /opt/backupdb/ folder\e[0m"
      fi
        echo "Restote database"
      psql  -U ${DBUSER} -h ${DBHOST} -d ${DBNAME} <  ${UPLOAD_PATH}${DBNAME}.${SQL} 2>> ${LOG}
      if [[ $? != 0 ]]; then
              echo -e "\e[31mDump of database wan not create. Please check log lile ${LOG}\e[0m"
              exit 1
           else
              rm ${UPLOAD_PATH}${DBNAME}.${SQL}
              echo -e "\e[32mEvervrything is Ok. Your dump of database was saved in /opt/backupdb/ folder\e[0m"
      fi
        echo "End restore ${DATE}" >> ${LOG}
 }


#check  that file exist

if [[ -f  ${UPLOAD_PATH}${DBNAME}.${SQL} ]]; then
         mini-shdstop
         dumpdb
         dumprestore
         mini-shdstart
      echo -e "\e[32mAll operations were completed\e[0m"
      exit 0
else
      echo -e "\e[32mSomething went wrong\e[0m"
      exit 1
fi