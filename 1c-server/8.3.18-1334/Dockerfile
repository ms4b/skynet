# за основу берем свой образ CentOS с поддержкой Systemd
FROM ms4b/centos:7
MAINTAINER ms4b

# версия сервера 1С
ENV VER_1C=8.3.18.1334
# каталог настроек технологического журнала сервера 1С
ENV MAIN_1C=/opt/1cv8/x86_64/${VER_1C}
# настройки кластера серверов 1С
ENV HOME_1C=/home/usr1cv8
# технологические журналы сервера 1С
ENV LOG_1C=/var/log/1c



# логи zabbix-агента
ARG LOG_ZA=/var/log/zabbix

# каталог настроен supervisor
ENV SV=/etc/supervisor
# логи supervisor
ARG LOG_SV=/var/log/supervisor

# создание пользователя и группы
RUN groupadd grp1cv8 --gid 1540 \
    && adduser --uid 1540 --gid grp1cv8 usr1cv8  \
    # создание каталогов
    && mkdir --parent /usr/share/fonts/truetype \
        ${MAIN_1C}/conf \
        ${HOME_1C} \
        ${LOG_1C}/zabbix/locks \
        ${LOG_1C}/zabbix/calls \
        ${LOG_1C}/zabbix/problem_log \
        ${LOG_1C}/log \
        /etc/zabbix/scripts \
        /etc/zabbix/zabbix_agentd.d \
        ${LOG_SV} \
        ${SV} \
    # установим пользователя и группу у каталогов сервера 1С
    && chown --recursive usr1cv8:grp1cv8 ${MAIN_1C}/conf ${HOME_1C} ${LOG_1C} \
    # установим права на запись для пользователя у каталогов сервера 1С
    && chmod --recursive 700 ${MAIN_1C}/conf ${HOME_1C} \
    # установим права на запись для пользователя и группы у каталогов логов сервера 1С
    && chmod --recursive 770 ${LOG_1C}

# перенос дистрибутивов
ADD ./dist/ /tmp/
# перенос шрифтов
ADD ./fonts/*.* /usr/share/fonts/truetype/

# установим драйверы HASP-ключей
RUN yum install -y /tmp/hasp/*.rpm \
    && rm -rf /tmp/hasp/*.rpm

# установим зависимости
RUN yum install -y  bzip2 fontconfig freetype unixODBC --nogpgcheck

# установим sepervisor
RUN yum install -y python36u-pip --nogpgcheck \
    && pip3.6 install supervisor

# установим сервер 1С
RUN yum install -y /tmp/1c/*.rpm \
    && rm -rf /tmp/1c/*.rpm

# установим iperf3 - для возможности контроля скорости
RUN yum install -y iperf3

# перенос файла конфигурации технологического журнала сервера 1С
ADD ./logcfg.xml ${MAIN_1C}/conf/
# перенос настроек zabbix-агента
ADD ./zabbix/zabbix_agentd.conf /etc/zabbix/
ADD ./zabbix/1c-rmngr.conf /etc/zabbix/zabbix_agentd.d/
# перенос скриптов Zabbix agent
ADD ./zabbix/*.sh /etc/zabbix/scripts/
# перенос скриптов запуска
ADD ./docker-entrypoint.sh /
# перенос скрипта инициализации кластера 1С
ADD ./init.sh /
# перенос настроек supervisor
ADD ./supervisor/* ${SV}/

# почистим yum
RUN yum clean all \
    && rm -rf /var/cache/yum \
    # обновляем кэш шрифтов, чтобы система увидела скопированные нами шрифты
    && fc-cache –fv \
    # установим владельцем служебных каталогов пользователя usr1cv8
    && chown -R usr1cv8:grp1cv8 ${MAIN_1C}/conf ${HOME_1C} ${LOG_1C} \
    # добавим пользователя zabbix в группу grp1cv8, чтобы он мог читать файлы журналов
    && usermod -a -G grp1cv8 zabbix \
    # установим возможность запуска скопированных скриптов
    && chmod +x /docker-entrypoint.sh /init.sh /etc/zabbix/scripts/*.sh ${SV}/*.sh

# настройки кластера серверов 1С
VOLUME ${HOME_1C}
# технологические журналы сервера 1С
VOLUME ${LOG_1C}
# логи Zabbix agent
VOLUME ${LOG_ZA}
# логи supervisor
VOLUME ${LOG_SV}

# публикация портов сервера 1C
EXPOSE 1540-1541 1560-1591

# публикация портов Zabbix agent
EXPOSE 10070

# скрипт запуска
ENTRYPOINT ["/docker-entrypoint.sh"]

# параметр скрипта запуска
CMD ["ragent"]