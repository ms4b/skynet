# за основу берем свой образ CentOS с поддержкой Systemd
FROM ms4b/centos:7

MAINTAINER ms4b

# источники
ARG DIST_CFG_ZA=./zabbix_agentd.conf
ARG DIST_EP=./docker-entrypoint.sh

# приемники
ARG DEST_CFG_ZA=/etc/zabbix
ARG DEST_EP=
# логи Zabbix agent
ARG LOG_ZA=/var/log/zabbix

# перенос настроек Zabbix agent
ADD ${DIST_CFG_ZA} ${DEST_CFG_ZA}
# перенос скрипта запуска
ADD ${DIST_EP} ${DEST_EP}/
# установим возможность запуска управляющего скрипта
RUN chmod +x /docker-entrypoint.sh

# публикация портов Zabbix agent
EXPOSE 10070

# описание томов, хранимых на хосте
VOLUME ${LOG_ZA}

# скрипт запуска
ENTRYPOINT ["/docker-entrypoint.sh"]

# параметр скрипта запуска
CMD ["zabbix_agent"]