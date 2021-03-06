#!/bin/bash
# скрипт удаляет с хоста все, что относится к целевой системе
# !!! ПОКА НЕ РЕАЛИЗОВАНО !!!

# немедленный выход, если выходное состояние команды ненулевое
set -e

# очистим экран
clear

echo -e "\e[31m-= Запуск драйвера защиты HASP =-\e[0m"

# установим драйвер защиты, если не установлен
INSTALLED=$(yum list installed | grep -c 'aksusbd')
echo '!!!'
if [[ -z "${INSTALLED}" ]]; then
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