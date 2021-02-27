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

echo Сборка полностью завершена
pause
exit

:publish
echo ##########
echo Сборка %1
echo ##########

cd %root_path%\%1\scripts
call publish.cmd
echo Сборка %1 выполнена
rem pause

exit /b

:commit
echo ##########
echo Фиксация изменений в локальный репозиторий
echo ##########

set /p describe="Введи описание изменений: "
echo %describe%
cd %root_path%
git commit -m "%describe%"
echo Фиксация изменений в локальный репозиторий выполнена
pause

exit /b


:push
echo ##########
echo Публикация изменений в удаленный репозиторий
echo ##########

cd %root_path%
git push skynet master
echo Публикация изменений в удаленный репозиторий выполнена
pause

exit /b

:deploy
echo ##########
echo Развертывание новой версии системы
echo ##########

cd %root_path%\main\%ver_1c%_%ver_pg%

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

echo Развертывание новой версии системы выполнено
pause

exit /b