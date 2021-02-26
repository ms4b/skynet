# за основу берем свой образ CentOS с поддержкой Systemd
FROM ms4b/centos:7
MAINTAINER ms4b

# версия ядра хоста
ENV KERNEL_VER=3.10.0-1062.9.1.el7.x86_64
# версия драйвера виртуального USB порта
ENV V_USB_DRIVER_VER=vhci-hcd-1.15
# версия библиотеки драйвера виртуального USB порта
ENV V_USB_LIB_VER=libusb_vhci-0.8

# каталог исходников
ENV SRC=/usr/src
# каталог временных файлов
ENV TMP=/tmp
# каталог результатов
ENV RES=/var/output

# перенос дистрибутивов
ADD ./dist/ ${TMP}/
# перенос исходников
ADD ./src/ ${SRC}/

# установим заголовки ядра (нужны для сборки драйверов из исходников)
RUN yum install -y ${TMP}/kernel/kernel-devel-${KERNEL_VER}.rpm

# установим Development Tools, понадобится для компиляции из исходников
RUN yum install -y "Development Tools"

# установим зависимости
RUN yum install -y jansson-devel

# почистим yum
RUN yum clean all \
    && rm -rf /var/cache/yum \
    # создание каталога результатов
    && mkdir ${RES}

ADD ./docker-entrypoint.sh /
ADD ./usbhaspd.service ${TMP}/

# установим возможность запуска скопированных скриптов
RUN chmod +x /docker-entrypoint.sh

# модули ядра хоста
VOLUME /lib/modules

# каталог результатов
VOLUME ${RES}

# скрипт запуска
ENTRYPOINT ["/docker-entrypoint.sh"]

# параметр скрипта запуска
CMD ["emul"]