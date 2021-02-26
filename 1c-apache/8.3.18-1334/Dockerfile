# за основу берем стандартный образ Debian+Apache 2.4: https://store.docker.com/images/httpd
FROM httpd:2.4
MAINTAINER ms4b

# для избежания ошибок установки
ARG DEBIAN_FRONTEND=noninteractive
# дистрибутив 1С
ARG DIST_SERVER_1C=./dist/*.deb
# основная конфигурация Apache
ARG DIST_CFG=./httpd.conf

# приемники
ARG DEST_TMP=/tmp
ARG DEST_CFG=/usr/local/apache2/conf
# расположение сайтов
ARG DEST_BASES=/usr/local/apache2/htdocs
# расположение логов
ARG LOGS=/usr/local/apache2/logs

# перенос дистрибутивов 1С
ADD ${DIST_SERVER_1C} ${DEST_TMP}/

# установка 1С
RUN dpkg -i /tmp/*.deb \
    # удаление дистрибутива
    && rm /tmp/*.deb \
    # удаление ненужных пакетов
    && apt-get clean \
    # перенаправление ошибок в docker
    && ln -s /dev/stderr ${LOGS}/error.log \
    # перенаправление обращений в docker
    && ln -s /dev/stdout ${LOGS}/access.log

# перенос файла настроек Apache
ADD ${DIST_CFG} ${DEST_CFG}/

# каталог конфигураций с публикациями
VOLUME ${DEST_CFG}/extra/
# каталог с сайтами
VOLUME ${DEST_BASES}/

# публикация портов сервера
EXPOSE 80