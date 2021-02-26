#!/bin/bash

# немедленный выход, если выходное состояние команды ненулевое
set -e

function error_exit {
  echo -e "\e[33m${PROGNAME}: ${1:-"Unknown Error"}\e[0m" 1>&2
  exit 1
}

if [[ -z $1 ]]; then
  # критическая ошибка
  error_exit "Ошибка: не указан обязательный параметр - вид бэкапа!"
fi

# каталог для резервной копии
DESTINATION_PATH=${BACKUP_PATH}/$1/$(date +%Y-%m-%d_%H-%M-%S)

# создаем каталог для резервной копии
echo "Создание каталога для резервной копии ${DESTINATION_PATH}"
mkdir --parent ${DESTINATION_PATH}
# сменим владельца каталога на пользователя, под которым работает PostgreSQL
chown ${POSTGRES_USER}:${POSTGRES_USER} ${DESTINATION_PATH}
# даем права на чтение и запись только пользователю, под которым работает PostgreSQL
chmod 774 ${DESTINATION_PATH}
echo "OK"

# архивирование всех таблиц, кроме таблицы "config", под пользователем БД postgres_adm, системным пользователем root
echo "Архивирование всех таблиц, кроме таблицы config"
pg_dump --username=${POSTGRES_USER} --format=directory --jobs=${BACKUP_JOBS} --blobs --encoding=UTF8 --exclude-table-data=config --file=${DESTINATION_PATH} ${DB_NAME_DB} && echo "OK"

# архивирование таблицы "config", под пользователем БД postgres, под системным пользователем postgres
echo "Архивирование таблицы config"
psql --username=${POSTGRES_USER} --command="COPY public.config TO '${DESTINATION_PATH}/config' WITH BINARY;" --dbname=${DB_NAME_DB} && echo "OK"

# проверка существования базы данных для восстановления резервной копии
if [[ "$(psql --username=${POSTGRES_USER} -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME_BACKUP}'")" = '1' ]]
then
    echo "База данных ${DB_NAME_BACKUP} существует"

    # удаление подключений к базе
    echo "Удаление существующих подключений к базе данных ${DB_NAME_BACKUP}"
    psql --username=${POSTGRES_USER} --command="SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '${DB_NAME_BACKUP}' AND pid <> pg_backend_pid();" --dbname=${DB_NAME_BACKUP} && echo "OK"

    # удаление базы, если существует
    echo "Удаление базы данных ${DB_NAME_BACKUP}"
    dropdb --username=${POSTGRES_USER} --if-exists ${DB_NAME_BACKUP} && echo "OK"

else
    echo "База данных ${DB_NAME_BACKUP} не существует"
fi

# создание базы
echo "Создание базы данных ${DB_NAME_BACKUP}"
createdb --username=${POSTGRES_USER} --owner=${POSTGRES_USER} --encoding=UTF8 ${DB_NAME_BACKUP} && echo "OK"

# восстановление всех таблиц, кроме таблицы "config"
echo "Восстановление всех таблиц, кроме таблицы config в базу данных ${DB_NAME_BACKUP}"
pg_restore --username=${POSTGRES_USER} --dbname ${DB_NAME_BACKUP} --jobs=${BACKUP_JOBS} ${DESTINATION_PATH} && echo "OK"

# восстановление таблицы "config"
echo "Восстановление таблицы config в базу данных ${DB_NAME_BACKUP}"
psql --username ${POSTGRES_USER} --dbname=${DB_NAME_BACKUP} --command "\COPY public.config FROM '${DESTINATION_PATH}/config' WITH BINARY;" && echo "OK"

# удаление старых архивов
echo "Удаление архивов старше ${BACKUP_AGE} дней"
find ${BACKUP_PATH}/* -mtime +${BACKUP_AGE} -delete && echo "OK"

# удаление пустых каталогов
echo "Удаление пустых каталогов"
find ${BACKUP_PATH} -type d -empty -delete && echo "OK"

echo "Процедура архивирования успешно завершена"