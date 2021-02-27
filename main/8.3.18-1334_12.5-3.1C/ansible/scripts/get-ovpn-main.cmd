@echo off

cd ..
cd ..
rem переносим сертификаты
scp -i hetzner/ssh/id_rsa root@main.ms4b.ru:/var/volumes/openvpn/*.ovpn ansible/sertificates/main.ms4b.ru/

