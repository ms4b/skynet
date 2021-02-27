#!/bin/bash
# скрипт остановливает все необходимое для функционирования целевой системы

# немедленный выход, если выходное состояние команды ненулевое
set -e

# очистим экран
clear

#########################################
# контейнеры docker
#########################################

# останавливаем контейнеры
echo -e "\e[31m-= Остановка контейнеров =-\e[0m"
docker-compose down
echo -e "\e[33m...контейнеры остановлены\e[0m"

# очистим docker от лишней информации
echo -e "\e[31m-= Очистка Docker =-\e[0m"
docker system prune --volumes --force
echo -e "\e[33m...docker очищен\e[0m"

#########################################
# эмулятор usbhasp
#########################################
echo -e "\e[31m-= Остановка эмулятора usbhasp =-\e[0m"

# останавливаем сервис
if [[ "$(systemctl is-active usbhaspd.service)" == "active" ]]; then
  # сервис запущен
  echo -e "\e[33m...служба эмулятора usbhaspd запущена\e[0m"
  systemctl stop usbhaspd.service
  echo -e "\e[33m...служба эмулятора usbhaspd останавливается\e[0m"
else
  # сервис не запущен
  echo -e "\e[33m...служба эмулятора usbhaspd уже остановлена\e[0m"
fi

# выключаем автозагрузку сервиса
if [[ "$(systemctl is-enabled usbhaspd.service)" == "enabled" ]]; then
  # автозагрузка сервиса включена
  echo -e "\e[33m...автозагрузка службы эмулятора usbhaspd включена\e[0m"
  systemctl disable usbhaspd.service
  echo -e "\e[33m...автозагрузка службы эмулятора usbhaspd выключается\e[0m"
else
  # автозагрузка сервиса выключена
  echo -e "\e[33m...автозагрузка службы эмулятора usbhaspd уже выключена\e[0m"
fi

echo -e "\e[33m...эмулятор usbhasp остановлен\e[0m"

#########################################
# драйвер защиты HASP
#########################################
echo -e "\e[31m-= Остановка драйвера защиты HASP =-\e[0m"

# останавливаем сервис
if [[ "$(systemctl is-active aksusbd.service)" == "active" ]]; then
  # сервис запущен
  echo -e "\e[33m...служба драйвера защиты HASP запущена\e[0m"
  systemctl stop aksusbd.service
  echo -e "\e[33m...служба драйвера защиты HASP останавливается\e[0m"
else
  # сервис не запущен
  echo -e "\e[33m...служба драйвера защиты HASP уже остановлена\e[0m"
fi

# выключаем автозагрузку сервиса
if [[ "$(systemctl is-enabled aksusbd.service)" == "enabled" ]]; then
  # автозагрузка сервиса включена
  echo -e "\e[33m...автозагрузка службы драйвера защиты HASP включена\e[0m"
  systemctl disable aksusbd.service
  echo -e "\e[33m...автозагрузка службы драйвера защиты HASP выключается\e[0m"
else
  # автозагрузка сервиса выключена
  echo -e "\e[33m...автозагрузка службы драйвера защиты HASP уже выключена\e[0m"
fi

echo -e "\e[33m...драйвер защиты HASP остановлен\e[0m"

#########################################
# драйвер usb-vhci
#########################################
echo -e "\e[31m-= Остановка драйвера usb-vhci =-\e[0m"

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

# удаление модулей из автозагрузки
if [[ -e /etc/modules-load.d/usb-vhci-hcd.conf ]]; then
  echo -e "\e[33m...обнаружена автоматическая загрузка в ядро модулей usb_vhci\e[0m"
  rm -f /etc/modules-load.d/usb-vhci-hcd.conf
  echo -e "\e[33m...автоматическая загрузка модулей usb-vhci в ядро отключена\e[0m"
else
  echo -e "\e[33m...автоматическая загрузка модулей usb-vhci в ядро уже отключена\e[0m"
fi

echo -e "\e[33m...драйвер usb-vhci остановлен\e[0m"

echo -e "\e[31m-= Система успешно остановлена! =-\e[0m"