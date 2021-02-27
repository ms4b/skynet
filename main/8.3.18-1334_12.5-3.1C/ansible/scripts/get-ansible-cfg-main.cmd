@echo off

cd ..
cd ..
rem переносим конфигурационный файл
scp -i hetzner/ssh/id_rsa ansible@main.ms4b.ru:/etc/ansible/ansible.cfg ansible/ansible_orig.cfg

