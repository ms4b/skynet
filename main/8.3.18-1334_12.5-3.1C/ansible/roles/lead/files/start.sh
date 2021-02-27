#!/bin/bash
# скрипт устанавливает и запускает все необходимое для нормального функционирования целевой системы

# немедленный выход, если выходное состояние команды ненулевое
set -e

# для вывода имени файла в сообщениях об ошибке
PROGNAME=$(basename $0)

function error_exit {
  echo -e "\e[33m${PROGNAME}: ${1:-"Unknown Error"}\e[0m" 1>&2
  exit 1
}

init_vpn() {

  if [[ -e "${OPENVPN_PATH}/${VPN_USER}.ovpn" ]]; then
    echo -e "\e[33m...найдена существующая VPN-сервера конфигурация, инициализация не требуется\e[0m"
    return 0
  else
    echo -e "\e[33m...не найдена конфигурация VPN-сервера, требуется инициализация\e[0m"
  fi

  echo -e "\e[33m...очистка каталога VPN-сервера\e[0m"
  rm -f -R ${OPENVPN_PATH}/*

  cd ${WD}

  echo -e "\e[33m...генерация конфигурации VPN-сервера\e[0m"
  docker-compose run --rm openvpn ovpn_genconfig -u udp://${DOMAIN}

  echo -e "\e[33m...инициалиация шифрования\e[0m"
  docker-compose run --rm openvpn ovpn_initpki

  echo -e "\e[33m...инициалиация пользователя\e[0m"
  docker-compose run --rm openvpn easyrsa build-client-full ${VPN_USER}

  echo -e "\e[33m...формирования файла подключения для VPN-клиента\e[0m"
  docker-compose run --rm openvpn ovpn_getclient ${VPN_USER} > ${OPENVPN_PATH}/${VPN_USER}.ovpn

  return 0
}

# очистим экран
clear

# проверка на установленность docker-compose
if ! [ -x "$(command -v docker-compose)" ]; then
  # критическая ошибка
  error_exit "Ошибка: docker-compose не установлен!"
fi

# сохраним текущий каталог, он нам понадобится при запуске контейнеров
WD=$(pwd)

DOMAIN=$(hostname)
OPENVPN_PATH="/var/volumes/openvpn"
VPN_USER="main_ms4b_ru"

#########################################
# контейнеры docker
#########################################

echo -e "\e[31m...инициализация VPN-сервера\e[0m"
init_vpn
echo -e "\e[31m...инициализация VPN-сервера завершена \e[0m"

# запускаем контейнеры
echo -e "\e[31m-= Запуск контейнеров =-\e[0m"
cd ${WD}
docker-compose up -d

echo -e "\e[33m...список активных контейнеров (должно быть 8):\e[0m"
docker ps

# контрольная точка
NUM=$(docker ps | wc -l)
let "NUM -= 1" # заголовок
if [[ ${NUM} -eq 1 ]]; then
  # контейнеры успешно запущены
  echo -e "\e[33m...контейнеры запущены\e[0m"
else
  # не удалось запустить контейнеры
  # критическая ошибка
  error_exit "Ошибка: контейнеры не запущены"
fi

echo -e "\e[31m-= Система успешно запущена! =-\e[0m"