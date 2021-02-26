# за основу берем стандартный образ Alpine+Nginx: https://hub.docker.com/_/nginx
FROM nginx:1.17.9-alpine
MAINTAINER ms4b

# каталог с логами
ARG LOGS=/var/log
# основной файл конфигурации
ARG DIST_CFG=./nginx.conf
# расположение основного файла конфигурации
ARG DEST_CFG=/etc/nginx
# расположение дополнительных файлов конфигурации
ARG DEST_CFG_ADD=/etc/nginx/conf.d

# удалим файлы конфигурации по умолчанию
RUN rm ${DEST_CFG_ADD}/default.conf ${DEST_CFG}/nginx.conf \
# перенаправление ошибок в docker
&& ln -s /dev/stderr ${LOGS}/error.log \
# перенаправление обращений в docker
&& ln -s /dev/stdout ${LOGS}/access.log

# перенос основаного файла конфигурации
ADD ${DIST_CFG} ${DEST_CFG}/

VOLUME /etc/letsencrypt
VOLUME /var/www/certbot
VOLUME /etc/nginx/conf.d

# публикация портов сервера
EXPOSE 80 443

