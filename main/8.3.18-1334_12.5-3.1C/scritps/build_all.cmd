@echo off

call environment.cmd

rem call :commit
rem call :push

call :publish centos
call :publish 1c-apache\%ver_1c%
call :publish 1c-hasp
call :publish 1c-postgres\%ver_pg%
call :publish 1c-server\%ver_1c%
rem call :publish nginx
rem call :publish zabbix-agent
rem call :deploy

echo ���ઠ ��������� �����襭�
pause
exit

:publish
echo ##########
echo ���ઠ %1
echo ##########

cd %root_path%\%1\scripts
call publish.cmd
echo ���ઠ %1 �믮�����
rem pause

exit /b

:commit
echo ##########
echo ������ ��������� � ������� ९����਩
echo ##########

set /p describe="����� ���ᠭ�� ���������: "
echo %describe%
cd %root_path%
git commit -m "%describe%"
echo ������ ��������� � ������� ९����਩ �믮�����
pause

exit /b


:push
echo ##########
echo �㡫����� ��������� � 㤠����� ९����਩
echo ##########

cd %root_path%
git push skynet master
echo �㡫����� ��������� � 㤠����� ९����਩ �믮�����
pause

exit /b

:deploy
echo ##########
echo �������뢠��� ����� ���ᨨ ��⥬�
echo ##########

cd %root_path%\main\%ver_1c%_%ver_pg%

rem ��७�ᨬ ����ன�� ��⮢ Ansible � �३�㪨 ����ன�� �ࢥ஢
scp -i hetzner/ssh/id_rsa ansible/*.yaml ansible@main.ms4b.ru:/home/ansible

rem ��७�ᨬ �ਯ� ����᪠ �३�㪠
scp -i hetzner/ssh/id_rsa ansible/play.sh ansible@main.ms4b.ru:/home/ansible

rem ��७�ᨬ ஫� �ࢥ஢
scp -r -i hetzner/ssh/id_rsa ansible/roles ansible@main.ms4b.ru:/home/ansible

rem ������塞 ����������� ����᪠ ��� �ਯ�
ssh -i hetzner/ssh/id_rsa ansible@main.ms4b.ru chmod +x /home/ansible/play.sh

rem ����᪠�� �ਯ�
ssh -i hetzner/ssh/id_rsa ansible@main.ms4b.ru /home/ansible/play.sh

echo �������뢠��� ����� ���ᨨ ��⥬� �믮�����
pause

exit /b