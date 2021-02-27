@echo off
cd ..
cd ..

rem переносим настройки хостов Ansible и прейбуки настройки серверов
scp -i hetzner/ssh/id_rsa ansible/*.yaml ansible@main.ms4b.ru:/home/ansible

rem переносим скрипт запуска прейбука
scp -i hetzner/ssh/id_rsa ansible/play.sh ansible@main.ms4b.ru:/home/ansible

rem переносим роли серверов
scp -r -i hetzner/ssh/id_rsa ansible/roles ansible@main.ms4b.ru:/home/ansible

rem добавляем возможность запуска для скрипта
ssh -i hetzner/ssh/id_rsa ansible@main.ms4b.ru chmod +x /home/ansible/play.sh

rem запускаем скрипт
ssh -i hetzner/ssh/id_rsa ansible@main.ms4b.ru /home/ansible/play.sh