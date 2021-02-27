@echo off
rem На на управляющем сервере:
rem устанавливаем Ansible - yum install ansible

rem не уверен, что все остальное нужно
rem устанавливаем репозиторий EPEL - yum install epel-release
rem устанавливаем репозиторий IUS - yum install https://centos7.iuscommunity.org/ius-release.rpm
rem устанавливаем актуальный Python - yum install python36
rem устанавливаем pip - yum install python36u-pip && pip3.6 install --upgrade pip
rem устанавливаем docker - pip3.6 install docker


cd ..
cd ..

rem переносим приватный ключ для доступа к серверам
scp -i hetzner/ssh/id_rsa hetzner/ssh/id_rsa root@main.ms4b.ru:/root/.ssh/
ssh -i hetzner/ssh/id_rsa ansible@main.ms4b.ru chmod 0600 /root/.ssh/id_rsa



rem добавляем оcновного пользователя - adduser ansible
rem добавляем пользовател в группу sudo - usermod -aG wheel ansible
rem переносим разрешенные  /root/.ssh/authorized_keys в /home/ansible/.ssh
rem меняем владельца файла - chown ansible:ansible authorized_keys
rem после этого можем зайти на сервер под пользователем ansible - ssh -i hetzner/ssh/id_rsa ansible@main.ms4b.ru

rem добавление задания на загрузку бэкапов с серверов rsync --archive -e ssh --remove-source-files --quiet root@stm2.ms4b.ru:/var/volumes/backup/ /mnt/backup/stm2.ms4b.ru

