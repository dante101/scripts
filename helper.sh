#!/bin/bash
#######################################################################################################
#Проверка версии Астры
########################################################################################################
OS_VERSION=$(cat /etc/astra_version) 2> /dev/null
if [[ "$OS_VERSION" == "SE 1.6 (smolensk)" ]]; then
	OS_VERSION=16
	PG_V="postgresql-9.6"
	WEB_V="apache2"
elif [[ "$OS_VERSION" == "SE 1.5 (smolensk)" ]]; then
	OS_VERSION=15
	PG_V="postgresql-9.4"
	WEB_V="apache2"
else
	LSB=$(lsb_release -d | awk '{print $2,$4}')
	echo -e "\e[1;38;5;31mNo suitable OS has been detected. Exiting ......\n
	ваша OS is $LSB\e[0m"
	exit 1
fi
PID_PATH=/run/
APACHE_PID_FOLDER=$PID_PATH/$WEB_V
PG_PID_FOLDER=$PID_PATH/postgresql
WEB_WORKDIR=/etc/$WEB_V
PG_WORKDIR=/etc/postgresql
TIMESTAMP=$(date "+%d-%m-%Y")
WEB_CONF=$WEB_WORKDIR/apache2.conf
WEB_SITES=$WEB_WORKDIR/site-available/
########################################################################################################
#Проверка доступности репозитория
########################################################################################################





########################################################################################################
#Конфигурационный файл для Астра 1.5
########################################################################################################
site15(){
	apt-get install libapache2-mod-auth-pam
								a2enmod auth_pam
								mkdir /var/www/$SITE_NAME
	/etc/apache2/sites-available/cat <<- _EOF_ > $SITE_NAME

								
								
								
								 <VirtualHost *:$PORT>
									ServerAdmin webmaster@localhost 
									DocumentRoot /var/www/$SITE_NAME 
									<Directory /> 
								 		AuthType Basic 
										AuthPAM_Enabled on 
										AuthName \"PAM\" 
										require valid-user 
										Options +Indexes +FollowSymLinks +MultiViews 
										AllowOverride None 
									</Directory> 
									 ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/ 
									<Directory "/usr/lib/cgi-bin"> 
										AllowOverride None \n
										Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch 
										Order allow,deny 
										Allow from all 
									</Directory> 
									ErrorLog ${APACHE_LOG_DIR}/error.log	
									LogLevel warn 
									CustomLog ${APACHE_LOG_DIR}/access.log combined 
								</VirtualHost>  
									_EOF_
								echo -e	"Listen $PORT" >> /etc/apache2/ports.conf
									  a2ensite $SITE_NAME
									 service apache2 reload
									echo -e "\e[1;38;5;1mУбидитесь что  пользователю заданы мандатные атрибуты\e[0m "
									2>/dev/null
}
########################################################################################################
#Конфигурационный файл для Астра 1.6
########################################################################################################
site16 () {
	apt-get install libapache2-mod-authnz-pam
	mkdir /var/www/$SITE_NAME
	a2enmod authnz_pam
	/etc/apache2/sites-available/cat  <<-   _EOF_ > $SITE_NAME.conf

									
									
									
									
 							<VirtualHost *:$PORT> 
									ServerAdmin webmaster@localhost 
									DocumentRoot /var/www/$SITE_NAME 
								<Directory /> 
								 		AuthType Basic 
										AuthBasicProvider PAM 
										AuthPAMService apache2
										AuthName "PAM" 
										require valid-user 
										Options +Indexes +FollowSymLinks +MultiViews 
										AllowOverride None 
								</Directory> 
									 ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/ 
								<Directory "/usr/lib/cgi-bin"> 
										AllowOverride None 
										Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch 
										Order allow,deny 
										Allow from all 
								</Directory> 
									ErrorLog ${APACHE_LOG_DIR}/error.log	
									LogLevel warn 
									CustomLog ${APACHE_LOG_DIR}/access.log combined 
							</VirtualHost>  
									_EOF_
									echo -e "\e[1;38;5;1mУбидитесь что  пользователю заданы мандатные атрибуты\e[0m " 2>/dev/null		
									
									 echo -e "Listen $PORT" >> /etc/apache2/ports.conf
									 systemctl reload apache2
}
########################################################################################################
#Функция создания базы данных
########################################################################################################
create_db () {
	echo -e "Имя пользователя который имет права на создание баз данных:     "
	read   USER
	echo -e "Название для базы данных:     "
	read   NEW_DB
	createdb -U $USER $NEW_DB
	
}
########################################################################################################
#Функция резервного копирования базы данных
########################################################################################################
backup_db () {
	local HOME=$(pwd)
	local FORMAT=sql
	local PG_USERS=$(psql -U postgres -c "\du" |cut -d \| -f 1)
	local LIST_DB=$(psql -U postgres -c "\l" |cut -d \| -f 1 | egrep -v template* |egrep -v  postgres*)
			user () {
				for arg
				do
				echo "$arg"
				done
			}
			user () $PG_USERS
	echo -e "$PG_USERS"
	echo -e "Имя пользователя который имет права на создание резервных копий баз данных:     "
	read   USER
		i=$USER
		for i in $PG_USERS
		do
			if [[ i == $PG_USERS ]]; then
				echo -e ""
				else
			fi
		done		
	echo -e "доступные варианты: $LIST_DB" 		
	echo -e "Резервную копию какой базу данных выполнить: "
	read   DB_NAME
	#pg_dump -U $USER -F p -f $HOME/$DB_NAME.$FORMAT "$DB_NAME"
	if	[[ -d $HOME/$DB_NAME.$FORMAT ]] || [[ -f $HOEM/$DB_NAME.$FORMAT ]]; then
			echo -e "\e[32mрезервная копия базы данных $DB_NAME уже существует. Хотите удалить и создать новый? да/нет\e[0m"
			read DEL_DB
			case "$DEL_DB" in
			[Д,д,Y,y,Yes,yes,Да,да,у,У] )
				rm $HOME/$DB_NAME.$FORMAT
				pg_dump -U $USER -F p -f $HOME/$DB_NAME.$FORMAT "$DB_NAME"
			;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mВыход ..|.\e[0m"
				exit 0
			;;
			*)
				echo -e "WRONG ANSWER!!!"
				exit 0
			;;
			esac

	fi		
		echo -e   "Хотите архивировать дамп базы данных? да/нет" 
		read ANSWER
			case "$ANSWER" in
				[Д,д,Y,y,Yes,yes,Да,да,у,У] )
					echo -e   "Какой формат архива? Возможные варианты: gz, bzip, zip  "
					read ARCHIVE
					if [ "$ARCHIVE" != gz ] || [ "$ARCHIVE" != bzip ] || [ "$ARCHIVE" != zip ]; then
						local BOOLEN=false
					fi
						until [ "$BOOLEN" = false ]
						do
							echo -e "Выбран неверный формат архива. Выберите: gz, bzip, zip или нажмите ctrl+С для выхода "
							read ARCHIVE	
						done
					
								if [[ $ARCHIVE==gz ]]; then
									tar czvf $DB_NAME.$FORMAT.$ARCHIVE $DB_NAME.$FORMAT
									elif [[ $ARCHIVE==bzip ]]; then
									tar cjvf $DB_NAME.$FORMAT.$ARCHIVE $DB_NAME.$FORMAT
									elif [[ $ARCHIVE==zip ]]; then
									zip $DB_NAME.$FORMAT.$ARCHIVE $DB_NAME.$FORMAT
									else
									echo -e "не известная ошибка"
										exit 1
								fi
			 ;;
				[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[31mВыход ..|.\e[0m"
				exit 0
		
			 ;;
			*)
				echo -e "WRONG ANSWER!!!"
				exit 1
			 ;;
			esac   
}
###################################################################################################
#Функция установки apache2
###################################################################################################
web_intall () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT. Для установки вэб-сервера требуются права супер-пользователя.  \e[0m"
	exit 1
fi
pidof apache2 > /dev/null
if [[ $? -eq 0 ]]; then
	echo -e "\e[32mсервер apache установлен и запущен\e[0m"
	exit 0
elif [[ -d $APACHE_PID_FOLDER ]]; then
	echo -e "\e[32mсервер apache установлен, но не запущен. Хотите стартовать сервер?да\нет\e[0m"
		read START
		case "$START" in
			[Д,д,Y,y,Yes,yes,Да,да,у,У] )
				service apache2 start
				;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[15m Выход..|.\e[0m"
				exit 0
				;;
			*)
				echo -e "Не допустимая операция!!!"
				exit 1
				;;
		esac
else
	apt-get update && apt-get install apache2 -y && apt-get autoremove -y

fi
usermod -aG shadow www-data
setfacl -d -m u:www-data:r /etc/parsec/macdb
setfacl -R -m u:www-data:r /etc/parsec/macdb
setfacl  -m u:www-data:rx /etc/parsec/macdb
echo -e "Хотите создать конфигурационный файл да/нет?"
read   ANS
    case $ANS in
		[Д,д,Y,y,Yes,yes,Да,да,у,У] )
			echo -e "\e[1;38;5;15mИмя сайта:\e[0m "
			read -p ""  SITE_NAME
			if [[ -f $WEB_SITES/$SITE_NAME ]]; then
				echo -e "$SITE_NAME уже существует. Хотите удалить и создать новый? да/нет"
			fi
			echo -e "\e[1;38;5;15mУкажите ПОРТ. 80 или 8080 рекомендуется:  "
			read -p "" PORT
				if [[ $PORT -lt 1 ]] || [[ $PORT -gt 65535 ]]; then
				echo -e "\e[31не верное значение порта. порт должен быть в диапазоне 1 - 65535\e[0m"
				elif
				 [[ $OS_VERSION == 15 ]]; then 
					 site15
				else 
				 	site16
				fi
				;;
		[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[15mВыход .......\e[0m"
				exit 0
				;;
		   		*)
				echo -e "WRONG ANSWER!!!"
				exit 1
				;;
  esac

}
########################################################################################################
#Функция установки сервера баз данных
########################################################################################################
db_srv_install () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT. Для установки сервера базданных требуются права супер-пользователя.  \e[0m"
	exit 1
fi
	pidof postgres > /dev/null
	if [[ $? -eq 0 ]]; then
 	echo -e "\e[32mсервер баз данных установлен и запущен\e[0m"
	exit 0
	elif [[ -d $PID_PATH/postgresql ]]; then
		echo -e "\e[32mсервер сервер баз данных установлен, но не запущен. Хотите стартовать сервер?да\нет\e[0m"
		read START_DB
		case "$START_DB" in
			[Д,д,Y,y,Yes,yes,Да,да,у,У] )
				service postgresql start
				;;
			[N,n,Н,н,Нет,нет,No,no] )
				echo -e "\e[15m Выход..|.\e[0m"
				exit 0
				;;
			*)
				echo -e "Не допустимая операция!!!"
				exit 1
				;;
		esac

	else
	apt-get update && apt-get install $PG_V -y && apt-get autoremove -y
	fi

	usermod -aG shadow postgres
	setfacl -d -m u:postgres:r /etc/parsec/macdb
	setfacl -R -m u:postgres:r /etc/parsec/macdb
	setfacl  -m u:postgres:rx /etc/parsec/macdb
	setfacl -d -m u:postgres:r /etc/parsec/capdb
	setfacl -R -m u:postgres:r /etc/parsec/capdb
	setfacl  -m u:postgres:rx /etc/parsec/capdb
}
########################################################################################################
#Функция удаления сервера баз данных
########################################################################################################
rm_db_srv () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT. Для удаления сервера базданных требуются права супер-пользователя.  \e[0m"
	exit 1 
else
	apt-get remove $PG_V -y && 	apt-get autoremove -y
	rm -rf $PID_PATH/postgresql
	setfacl -d -m u:postgres:--- /etc/parsec/macdb
	setfacl -R -m u:postgres:--- /etc/parsec/macdb
	setfacl  -m u:postgres:--- /etc/parsec/macdb
	setfacl -d -m u:postgres:--- /etc/parsec/capdb
	setfacl -R -m u:postgres:--- /etc/parsec/capdb
	setfacl  -m u:postgres:--- /etc/parsec/capdb
fi
}
########################################################################################################
#Функция удаления вэб сервера
########################################################################################################
rm_web_srv () {
#Проверка на рута
if [[ $UID != 0 ]]; then
	echo -e "\e[31mвы не ROOT идите на хер\e[0m"
	exit 1 >&2
fi

apt-get remove apache2 -y && apt-get purge apache2 -y
apt-get autoremove -y
#rm -r /etc/$WEB_V
setfacl -d -m u:www-data:--- /etc/parsec/macdb
setfacl -R -m u:www-data:--- /etc/parsec/macdb
setfacl  -m u:www-data:--- /etc/parsec/macdb
}

#Очистка экрана
clear
echo -e "\e[1;5;38;5;31mATANTION Please\e[0m. \e[1;38;5;15mДанный скрип предназанчен для использования только в ОС Астра Линукс SE smolensk\e[0m"

#Выбор действия
echo -e "\e[1;38;5;32mВыбирите действие: \n
\e[1;38;5;33mустановить веб сервер apache нажмите - 1\n
\e[1;38;5;33mустановить сервер базы данны нажмите -  2\n
\e[1;38;5;33mсделать резервную копию базы данных нажмите -  3\n
\e[1;38;5;33mудалить сервер базы данных нажмите -  4\n
\e[1;38;5;33mудалить веб сервер apache2 нажмите -  5\n
\e[1;38;5;33mсоздать базу данных нажмите -  6\e[0m\n
Или нажмите ctrl+C для выхода."

#Выполнение варианта дествия пользователя
read VARIANT
if [[ -z $VARIANT ]]; then
	echo -e "не чего не выбрано. выход ......."
	exit 0
fi
case "$VARIANT" in
#установка apache2
1)

	web_intall

;;

#Установка сервера баз данных
2)

	db_srv_install
;;
#Создание резервной копии базы данных
3)
	backup_db
;;
#Удаление Postgresql
4)
	rm_db_srv
;;
#Удаление Apache2
5)
	rm_web_srv
;;
#Создание базы данных
6)
	create_db
	
;;
	*)
	echo -e "\e[15mНе чего не выбрано. Выход.....\e[0m"
	exit 0
;;
esac
