@echo off

cd ..
cd ..
rem переносим сертификаты
scp -i hetzner/ssh/id_rsa root@stm.ms4b.ru:/var/volumes/certbot/conf/live/stm.ms4b.ru/*.pem ansible/sertificates/stm.ms4b.ru

