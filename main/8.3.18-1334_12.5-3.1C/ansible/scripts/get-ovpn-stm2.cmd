@echo off

cd ..
cd ..
rem переносим сертификаты
scp -i hetzner/ssh/id_rsa root@stm2.ms4b.ru:/var/volumes/openvpn/*.ovpn ansible/sertificates/stm2.ms4b.ru

