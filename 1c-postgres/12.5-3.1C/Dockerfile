# за основу берем свой образ CentOS с поддержкой Systemd
FROM ms4b/centos:7

# источники
ARG DIST_EP_SCRIPT=./docker-entrypoint.sh
ARG DIST_BACKUP_SCRIPT=./backup.sh
ARG DIST_CFG=./postgresql.conf
ARG DIST_PG=./dist/postgres/*
ARG DIST_PGA=./dist/addon/*

# приемники
ARG DEST_CFG=/docker-entrypoint-initdb.d
ARG DEST_PG=/tmp/postgres
ARG DEST_PGA=/tmp/addon

# дополнение путей поиска приложений
ENV PATH /usr/pgsql-12/bin:$PATH
# расположение данных
ENV PGDATA /data
# расположение архивных копий
ENV BACKUP_PATH /backup

# создание пользователя и группы
RUN groupadd postgres --gid 5432 \
    && adduser --uid 5432 --gid postgres postgres \
    # создание служебных каталогов
    && mkdir --parent /var/run/postgresql ${PGDATA} ${DEST_CFG} ${DEST_PG} ${DEST_PGA} ${BACKUP_PATH} \
    && chown --recursive postgres:postgres /var/run/postgresql ${PGDATA} ${BACKUP_PATH} \
    && chmod g+s /var/run/postgresql

# перенос основного дистрибутива
ADD ${DIST_PG} ${DEST_PG}/
# перенос аддона
ADD ${DIST_PGA} ${DEST_PGA}/

# установка необходимых для postgres пакетов
RUN yum install -y readline krb5-libs openssl libxslt llvm5.0 llvm5.0-devel --nogpgcheck \
    && yum --enablerepo=centos-sclo-rh-testing install -y llvm-toolset-7-clang --nogpgcheck

# установка основного дистрибутива и аддона
RUN yum localinstall -y ${DEST_PG}/*.rpm ${DEST_PGA}/*.rpm  \
    # удаление установочных пакетов
    && rm --recursive /tmp/* \
    # очистка локального кэша
    && yum clean all

# перенос конфигурационного файла
ADD ${DIST_CFG} ${DEST_CFG}/
# перенос скрипта запуска
ADD ${DIST_EP_SCRIPT} /
# перенос скрипта резервного копирования
ADD ${DIST_BACKUP_SCRIPT} /

# установим возможность запуска управляющего скрипта и скрипта резервного копирования
RUN chmod +x /docker-entrypoint.sh /backup.sh

# скрипт запуска
ENTRYPOINT ["/docker-entrypoint.sh"]

# описание томов, хранимых на хосте
VOLUME $PGDATA
VOLUME $BACKUP_PATH

# публикация портов сервера
EXPOSE 5432

# параметр скрипта запуска
CMD ["postgres"]