#!/bin/bash
set -e

exec 2>&1

# создание каталогов
#MAIN_1C=/opt/1cv8/x86_64/${VER_1C}
#VER_1C=номер версии сервера 1С
#HOME_1C=/home/usr1cv8
#LOG_1C=/var/log/1c
mkdir --parent ${MAIN_1C}/conf ${HOME_1C} ${LOG_1C}/zabbix/locks ${LOG_1C}/zabbix/calls ${LOG_1C}/zabbix/problem_log ${LOG_1C}/log

# установим пользователя и группу у каталогов сервера 1С
chown --recursive usr1cv8:grp1cv8 ${MAIN_1C}/conf ${HOME_1C} ${LOG_1C}

# установим права на запись для пользователя у каталогов сервера 1С
chmod --recursive 700 ${MAIN_1C}/conf ${HOME_1C}

# установим права на запись для пользователя и группы у каталогов логов сервера 1С
chmod --recursive 770 ${LOG_1C}

# запуск драйвера ключа защиты
/usr/sbin/aksusbd_x86_64

# запуск агента кластера серверов 1с
exec gosu usr1cv8 ${MAIN_1C}/ragent -debug -http

