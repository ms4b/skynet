#!/bin/bash

# немедленный выход, если выходное состояние команды ненулевое
set -e

function error_exit {
  echo -e "\e[33m${PROGNAME}: ${1:-"Unknown Error"}\e[0m" 1>&2
  exit 1
}

if [[ -z $1 ]]; then
  # критическая ошибка
  error_exit "Ошибка: не указан обязательный параметр - каталог !"
fi

# удаление старых архивов
echo "Удаление архивов старше ${BACKUP_AGE} дней"
find ${BACKUP_PATH}/* -mtime +${BACKUP_AGE} -delete && echo "OK"
