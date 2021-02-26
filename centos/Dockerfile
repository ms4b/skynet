# за основу берем последний CentOS 7
FROM centos:7

# установим московский часовой пояс
RUN rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

ARG GOSU_VERSION=1.11

# обновим систему, установим gosu, zabbix агента
RUN yum update -y \
    && yum install -y deltarpm --nogpgcheck \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && rpm -Uvh https://repo.zabbix.com/zabbix/5.2/rhel/7/x86_64/zabbix-release-5.2-1.el7.noarch.rpm \
    && yum install -y zabbix-agent --nogpgcheck \
    && chown -R zabbix:zabbix /etc/zabbix

# устанавливаем русскую локализацию
RUN yum reinstall -y glibc --nogpgcheck \
    #&& yum install -y glibc-locale-source glibc-langpack-ru --nogpgcheck \ # для CentOS 8
    && localedef -i ru_RU -f UTF-8 ru_RU.UTF-8 \
    && yum clean all \
    && rm -rf /var/cache/yum
ADD ./i18n /etc/sysconfig/
ENV LANG ru_RU.utf8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.utf8

# устанавливаем дополнителные репозитории IUS, EPEL и SCL
RUN yum install -y https://repo.ius.io/ius-release-el7.rpm  epel-release centos-release-scl-rh --nogpgcheck

# команда, выполняемая при запуске контейнера
CMD ["/bin/bash"]
