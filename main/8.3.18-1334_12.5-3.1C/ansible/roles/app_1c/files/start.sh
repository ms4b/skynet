#!/bin/bash
# скрипт устанавливает и запускает все необходимое для нормального функционирования целевой системы

# немедленный выход, если выходное состояние команды ненулевое
set -e

# версии контейнеров
source ./.env

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
  docker-compose run --rm openvpn ovpn_genconfig -u udp://${DOMAIN} -N -d -c -p "route 172.20.20.0 255.255.255.0" -p "sndbuf 524288" -p "rcvbuf 524288" -e "topology subnet"

  echo -e "\e[33m...инициалиация шифрования\e[0m"
  docker-compose run --rm openvpn ovpn_initpki

  echo -e "\e[33m...инициалиация пользователя\e[0m"
  docker-compose run --rm openvpn easyrsa build-client-full ${VPN_USER}

  echo -e "\e[33m...формирования файла подключения для VPN-клиента\e[0m"
  docker-compose run --rm openvpn ovpn_getclient ${VPN_USER} > ${OPENVPN_PATH}/${VPN_USER}.ovpn

  return 0
}

init_sert() {

  if [[ -e "${CERTBOT_PATH}/live/${DOMAIN}/privkey.pem" ]] && [[ -e "${CERTBOT_PATH}/live/${DOMAIN}/fullchain.pem" ]]; then
    echo -e "\e[33m...найдены уже полученные сертификаты для ${DOMAIN}, инициализация не требуется\e[0m"
    return 0
  else
    echo -e "\e[33m...сертификаты для ${DOMAIN} не найдены, требуется инициализация\e[0m"
  fi

  if [[ ! -e "${CERTBOT_PATH}/options-ssl-nginx.conf" ]] || [[ ! -e "${CERTBOT_PATH}/ssl-dhparams.pem" ]]; then
    echo -e "\e[33m...загрузка рекомендуемых TLS параметров\e[0m"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "${CERTBOT_PATH}/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "${CERTBOT_PATH}/ssl-dhparams.pem"
    echo -e "\e[33m...завершено\e[0m"
  else
    echo -e "\e[33m...найдены уже полученные рекомендуемые TLS параметры\e[0m"
  fi

  echo -e "\e[33m...создание фиктивного сертификата для ${DOMAIN}\e[0m"
  local INT_PATH="/etc/letsencrypt/live/${DOMAIN}"
  mkdir -p "${CERTBOT_PATH}/live/${DOMAIN}"
  docker-compose run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:1024 -days 1\
      -keyout '${INT_PATH}/privkey.pem' \
      -out '${INT_PATH}/fullchain.pem' \
      -subj '/CN=localhost'" certbot
  echo -e "\e[33m...завершено\e[0m"

  echo -e "\e[33m...пересоздание контейнера nginx\e[0m"
  docker-compose up --force-recreate -d --no-deps nginx
  echo -e "\e[33m...завершено\e[0m"

  echo -e "\e[33m...удаление фиктивного сертификата для ${DOMAIN}\e[0m"
  docker-compose run --rm --entrypoint "\
    rm -Rf ${INT_PATH} && \
    rm -Rf /etc/letsencrypt/archive/${DOMAIN} && \
    rm -Rf /etc/letsencrypt/renewal/${DOMAIN}.conf" certbot
  echo -e "\e[33m...завершено\e[0m"

  echo -e "\e[33m...запрос реального сертификата Let's Encrypt для ${DOMAIN}\e[0m"

  docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    --register-unsafely-without-email \
    -d ${DOMAIN} \
    --rsa-key-size ${RCA_KEY_SIZE} \
    --agree-tos \
    --force-renewal" certbot
  echo -e "\e[33m...завершено\e[0m"

  echo -e "\e[33m...перезапуск nginx\e[0m"
  docker-compose exec nginx nginx -s reload
  echo -e "\e[33m...завершено\e[0m"

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
# часто используемые в скрипте каталоги
RES=/var/volumes/1c-hasp
KEY=/usr/local/hasp-keys
VHCI=/usr/lib/modules/$(uname -r)/kernel/drivers/usb/host

# настройки для сертификата
DOMAIN=$(hostname)
RCA_KEY_SIZE=4096
CERTBOT_PATH="/var/volumes/certbot/conf"

# настройки для vpn
OPENVPN_PATH="/var/volumes/openvpn"
VPN_USER="1c"

# копиляция драйверов и эмулятора usbhasp
echo -e "\e[31m-= Копиляция драйверов и эмулятора usbhasp =-\e[0m"
docker run -ti --rm -v /lib/modules:/lib/modules:ro -v ${RES}:/var/output:rw ms4b/1c-hasp:$(uname -r)

echo -e "\e[33m...содержимое каталога результатов компиляции (должен быть файл kver):\e[0m"
cd ${RES}
# результат компиляции
ls -l
cd ${WD}

# контрольная точка
if [[ -e "${RES}/kver" ]]; then
  # компиляция драйверов и эмулятора HASP прошла успешно

  # версия ядра, под которое выполнена компиляция
  KVER=$(cat ${RES}/kver)

  echo -e "\e[33m...драйверы и эмулятор HASP скомпилированы под ядро ${KVER}\e[0m"
else
  # не удалось скомпилировать драйверы и эмулятор HASP
  # критическая ошибка
  error_exit "Ошибка: драйверы и эмулятор HASP не скомпилированы!"
fi

# контрольная точка
if [[ "${KVER}" == "$(uname -r)" ]]; then
  # версии ядер совпадают
  echo -e "\e[33m...ядро хоста имеет ту же версию\e[0m"
else
  # не удалось скомпилировать драйверы и эмулятор HASP
  # критическая ошибка
  error_exit "Ошибка: версия ядра хоста $(uname -r)"
fi

#########################################
# драйвер usb-vhci
#########################################
echo -e "\e[31m-= Запуск драйвера usb-vhci =-\e[0m"

# запущенный эмулятор usbhasp помешает выгрузить модули ядра usb-vhci
if [[ "$(systemctl is-active usbhaspd.service)" == "active" ]]; then
  # сервис запущен
  echo -e "\e[33m...обнаружена запущенная служба эмулятора usbhaspd\e[0m"
  systemctl stop usbhaspd.service
  echo -e "\e[33m...служба эмуляторf usbhaspd остановлена\e[0m"
else
  # сервис не запущен
  echo -e "\e[33m...служба эмулятора usbhaspd не запущена\e[0m"
fi

# выгружаем модуль usb_vhci_iocifc
RUN=$(lsmod | grep 'usb_vhci_iocifc' | wc -l)
if [[ ${RUN} -gt 0 ]]; then
  echo -e "\e[33m...обнаружен загруженный в ядро модуль usb_vhci_iocifc\e[0m"
  rmmod usb-vhci-iocifc
  echo -e "\e[33m...модуль ядра usb_vhci_iocifc выгружен из ядра\e[0m"
else
  # модуль usb_vhci_iocifc не загружен в ядро
  echo -e "\e[33m...модуль ядра usb_vhci_iocifc не загружен в ядро\e[0m"
fi

# выгружаем модуль usb_vhci_hcd
RUN=$(lsmod | grep 'usb_vhci_hcd' | wc -l)
if [[ ${RUN} -gt 0 ]]; then
  echo -e "\e[33m...обнаружен загруженный в ядро модуль usb_vhci_hcd\e[0m"
  rmmod usb_vhci_hcd
  echo -e "\e[33m...модуль ядра usb_vhci_hcd выгружен из ядра\e[0m"
else
  # модуль usb_vhci_hcd не загружен в ядро
  echo -e "\e[33m...модуль ядра usb_vhci_hcd не загружен в ядро\e[0m"
fi

# скопируем модули ядра usb_vhci в нужное место
echo -e "\e[33m...установка модулей ядра usb_vhci\e[0m"
cp -f -p ${RES}/*.ko ${VHCI}/
echo -e "\e[33m...модули ядра usb_vhci установлены\e[0m"

# загружаем модуль usb_vhci_hcd в ядро
echo -e "\e[33m...загрузка модуля usb-vhci-hcd в ядро\e[0m"
insmod "${VHCI}/usb-vhci-hcd.ko"
echo -e "\e[33m...модуль usb-vhci-hcd загружен в ядро\e[0m"

# загружаем модуль usb-vhci-iocifc в ядро
echo -e "\e[33m...загрузка модуля usb-vhci-iocifc в ядро\e[0m"
insmod "${VHCI}/usb-vhci-iocifc.ko"
echo -e "\e[33m...модуль usb-vhci-iocifc загружен в ядро\e[0m"

echo -e "\e[33m...список загруженных модулей (должно быть 2):\e[0m"
# результат загрузки модулей
lsmod | grep 'usb_vhci'

# установка модулей в автозагрузку
echo -e "\e[33m...настройка автоматической загрузки модулей usb-vhci в ядро\e[0m"
echo usb-vhci-hcd > /etc/modules-load.d/usb-vhci-hcd.conf
echo usb-vhci-iocifc >> /etc/modules-load.d/usb-vhci-hcd.conf
echo -e "\e[33m...автоматическая загрузка модулей usb-vhci в ядро настроена\e[0m"

# контрольная точка
NUM=$(lsmod | grep 'usb_vhci' | wc -l)
if [[ ${NUM} -eq 2 ]]; then
  # модули драйвера успешно загружены в ядро
  echo -e "\e[33m...драйвер usb-vhci запущен\e[0m"
else
  # не удалось загрузить в ядро модули драйвера
  # критическая ошибка
  error_exit "Ошибка: драйвер usb-vhci не запущен"
fi

#########################################
# библиотека libusb_vhci (нужна для usbhasp)
#########################################
echo -e "\e[31m-= Запуск библиотеки libusb_vhci =-\e[0m"

# скопируем модули библиотеки libusb_vhci в нужное место
echo -e "\e[33m...установка библиотеки libusb_vhci\e[0m"
cp -f -p -P ${RES}/*.so* /usr/lib64/
echo -e "\e[33m...библиотека libusb_vhci установлена\e[0m"

# обновим кэш библиотек
echo -e "\e[33m...обновление кэша библиотек\e[0m"
ldconfig -v
echo -e "\e[33m...кэш библиотек обновлен\e[0m"

# без контрольной точки
echo -e "\e[33m...библиотека libusb_vhci запущена\e[0m"

#########################################
# драйвер защиты HASP
#########################################
echo -e "\e[31m-= Запуск драйвера защиты HASP =-\e[0m"

# установим драйвер защиты, если не установлен
if [[ $(yum list installed | grep -c 'aksusbd') -eq 0 ]]; then
  # драйвер защиты HASP не установлен
  echo -e "\e[33m...драйвер защиты HASP не установлен\e[0m"

  # установим драйвер защиты HASP
  echo -e "\e[33m...установливаем драйвер защиты HASP\e[0m"
  cd ${RES}
  yum install -y aksusbd*.rpm
  echo -e "\e[33m...драйвер защиты HASP установлен\e[0m"
else
  # драйвер защиты HASP установлен
  echo -e "\e[33m...драйвер защиты HASP уже установлен\e[0m"
fi

# включаем автозагрузку сервиса
if [[ "$(systemctl is-enabled aksusbd.service)" == "enabled" ]]; then
  # автозагрузка сервиса включена
  echo -e "\e[33m...автозагрузка службы драйвера защиты HASP уже включена\e[0m"
else
  # автозагрузка сервиса выключена
  systemctl enable aksusbd.service
  echo -e "\e[33m...автозагрузка службы драйвера защиты HASP включена\e[0m"
fi

# запускаем сервис
if [[ "$(systemctl is-active aksusbd.service)" == "active" ]]; then
  # сервис запущен
  echo -e "\e[33m...служба драйвера защиты HASP уже запущена\e[0m"
else
  # сервис не запущен
  systemctl start aksusbd.service
  echo -e "\e[33m...служба драйвера защиты HASP запускается\e[0m"
fi

echo -e "\e[33m...статус службы драйвера защиты HASP (должен быть active):\e[0m"
# результат установки драйвера
systemctl status aksusbd.service

# контрольная точка
if [[ "$(systemctl is-active aksusbd.service)" == "active" ]]; then
  # драйвер успешно запущен
  echo -e "\e[33m...драйвер защиты HASP запущен\e[0m"
else
  # не удалось запустить драйвер
  # критическая ошибка
  error_exit "Ошибка: драйвер защиты HASP не запущен"
fi

#########################################
# эмулятор usbhasp
#########################################
echo -e "\e[31m-= Запуск эмулятора usbhasp =-\e[0m"

# скопируем эмулятор usbhasp и дампы ключей защиты в нужное место
echo -e "\e[33m...установка эмулятора usbhasp\e[0m"

cp -f ${RES}/usbhasp /usr/sbin/
rm -f ${KEY}/*.json
cp -f ${RES}/*.json ${KEY}/
cp -f ${RES}/usbhaspd.service /etc/systemd/system/

# обновление конфигурации сервисов
systemctl daemon-reload
echo -e "\e[33m...эмулятор usbhasp установлен\e[0m"

# включаем автозагрузку сервиса
if [[ "$(systemctl is-enabled usbhaspd.service)" == "enabled" ]]; then
  # автозагрузка сервиса включена
  echo -e "\e[33m...автозагрузка службы эмулятора usbhaspd уже включена\e[0m"
else
  # автозагрузка сервиса выключена
  systemctl enable usbhaspd.service
  echo -e "\e[33m...автозагрузка службы эмулятора usbhaspd включена\e[0m"
fi

# запускаем сервис
if [[ "$(systemctl is-active usbhaspd.service)" == "active" ]]; then
  # сервис запущен
  echo -e "\e[33m...служба эмулятора usbhaspd уже запущена\e[0m"
else
  # сервис не запущен
  systemctl start usbhaspd.service
  echo -e "\e[33m...служба эмулятора usbhaspd запускается\e[0m"
fi

echo -e "\e[33m...статус службы эмулятора usbhaspd (должен быть active):\e[0m"
# результат запуска эмулятора
systemctl status usbhaspd.service

# контрольная точка
if [[ "$(systemctl is-active usbhaspd.service)" == "active" ]]; then
  # эмулятор успешно запущен
  echo -e "\e[33m...эмулятор usbhaspd запущен\e[0m"
else
  # не удалось запустить эмулятор
  # критическая ошибка
  error_exit "Ошибка: эмулятор usbhaspd не запущен"
fi

# установим утилиты для работы с usb
echo -e "\e[33m...установка утилит для работы с USB\e[0m"
if [[ $(yum list installed | grep -c 'usbutils') -eq 0 ]]; then
  # утилиты еще не установлены
  yum install -y usbutils
  echo -e "\e[33m...утилиты для работы с USB уже установлены\e[0m"
else
  # утилиты уже установлены
  echo -e "\e[33m...утилиты для работы с USB уже установлены\e[0m"
fi

echo -e "\e[33m...список активных USB-устройств (должно быть хотя-бы одно):\e[0m"
# результат запуска эмулятора
lsusb

# контрольная точка
if [[ $(lsusb | wc -l) -gt 0 ]]; then
  # эмулятор успешно запущен
  echo -e "\e[33m...USB-устройства появились\e[0m"
else
  # не удалось запустить драйвер
  # критическая ошибка
  error_exit "Ошибка: USB-устройства не появились"
fi

# контрольная точка
if [[ -e /dev/aks ]]; then
  # эмулятор успешно запущен
  echo -e "\e[33m...список активных aks-устройств (должно быть хотя-бы одно):\e[0m"
  # результат запуска эмулятора
  cd /dev/aks/hasp
  ls -l
  echo -e "\e[33m...aks-устройства появились\e[0m"
else
  # не удалось запустить драйвер
  # критическая ошибка
  error_exit "Ошибка: aks-устройства не появились"
fi

# откроем права доступа к устройствам
echo -e "\e[33m...настройка прав на устройства эмулятора\e[0m"
chmod 666 /dev/usb-vhci /dev/bus/usb /dev/aks/hasp/*
echo -e "\e[33m...права на устройства эмулятора настроены\e[0m"

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

# настройка маршрута для VPN-трафика
echo -e "\e[33m...настройка маршрута для VPN-трафика\e[0m"

RUN=$(ip route | grep "192.168.255.0/24 via ${VPN_IP_OPENVPN}" | wc -l)
if [[ ${RUN} -gt 0 ]]; then
  # маршрут уже есть
  echo -e "\e[33m...использован существующий маршрут для VPN-трафика\e[0m"
else
  # маршрута еще нет
  ip route add 192.168.255.0/24 via ${VPN_IP_OPENVPN}
  echo -e "\e[33m...создан новый маршрут для VPN-трафика \e[0m"
fi

echo -e "\e[31m...инициализация системы сертификатов безопасности\e[0m"
init_sert
echo -e "\e[31m...инициализация системы сертификатов безопасности завершена \e[0m"

echo -e "\e[33m...список активных контейнеров (должно быть 8):\e[0m"
docker ps

# контрольная точка
NUM=$(docker ps | wc -l)
let "NUM -= 1" # заголовок
if [[ ${NUM} -eq 9 ]]; then
  # контейнеры успешно запущены
  echo -e "\e[33m...контейнеры запущены\e[0m"
else
  # не удалось запустить контейнеры
  # критическая ошибка
  error_exit "Ошибка: контейнеры не запущены"
fi

# инициализация сервера 1С
echo -e "\e[31m-= Инициализация сервера 1С =-\e[0m"
docker exec -ti 1c-server ./init.sh
echo -e "\e[33m...сервер 1С иницилизирован\e[0m"

echo -e "\e[31m-= Система успешно запущена! =-\e[0m"