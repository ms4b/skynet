# Контейнер Docker c эмулятором USB для хоста на CentOS 7

## Сборка ораза Docker:

### Подготовка дистрибутивов

#### Драйвер HASP защиты

Скачть с ресурса http://ftp.etersoft.ru/pub/Etersoft/HASP/last/x86_64/CentOS/7 дистрибутивы:
 - haspd-7.90-eter2centos.x86_64.rpm
 - haspd-modules-7.90-eter2centos.x86_64.rpm
 
Поместить установочные файлы в каталог _dist/hasp_.

#### Исходники ядра kernel-devel

Узнать версию ядра хоста командой "uname -r"

Скачать с ресурса http://mirror.centos.org/centos/7/updates/x86_64/Packages/ пакет kernel-devel версии, совпадающей с версией ядра хоста:
 - kernel-devel-{версия ядра}.x86_64.rpm

Поместить установочный файл в каталог _dist/kernel_.

### Дампы ключей защиты

Поместить файлы дампов в формате "JSON" эмулируемых ключей защиты в каталог _dumps_.

### Обновление исходников (только если нужно использовать более новые версии)

#### Драйвер виртуального USB vhci-hcd

Скачать исходники vhci-hcd с ресурса https://sourceforge.net/projects/usb-vhci/files/linux%20kernel%20module, распаковать.

Поместить исходники vhci-hcd в каталог _src/vhci-hcd-{версия}_

В файлах _usb-vhci-hcd.c_ и _usb-vhci-iocifc.c_ находим и комментируем строку _"#define DEBUG"_.
В файле _usb-vhci-iocifc.c_ добавляем строку _"#include <linux/uaccess.h>"_.

В _Dockerfile_ скорректировать версию в переменной окружения _V_USB_DRIVER_VER_

#### Библиотека libusb-vhci

Скачать исходники libusb_vhci с ресурса https://sourceforge.net/projects/usb-vhci/files/native%20libraries, распаковать.

Поместить исходники libusb_vhci в каталог _src/libusb_vhci-{версия}_

В _Dockerfile_ скорректировать версию в переменной окружения _V_USB_LIB_VER_

#### Эмулятор usbhasp

Скачать исходники usbhasp с ресурса https://github.com/sam88651/UsbHasp.git

Поместить исходники usbhasp в каталог _src/UsbHasp_

В файле _/src/UsbHasp/nbproject/Makefile-Release.mk_ заменить _"CFLAGS="_ на _"CFLAGS=-std=gnu99"_

Собрать образ скриптом "scripts/build.cmd"

## Тестовый запуск контейнера

Создать и запустить контейнер скриптом "scripts/run.cmd"