# Контейнер Docker Apache 2.4 с модулем 1С внутри

## Сборка ораза Docker:

Поместить в каталог "dist" установочные пакеты для 64-битных Debian систем (*.deb)

Настройки сервера конфигурируются в файле "httpd.conf"

Собрать образ скриптом "scripts/build.cmd"

## Тестовый запуск контейнера

Создать и запустить контейнер скриптом "scripts/run.cmd"

В браузере открыть адрес "http://localhost", должна появиться стандартная страница Apache "It works!"

## Публикация инфортационных баз 1С

Используется два подключаемых каталога:
 - /usr/local/apache2/conf/extra
 - /usr/local/apache2/htdocs

В каталог "/usr/local/apache2/conf/extra" должен быть помещен файл "publications.conf" 

На каждую информационную базу в файл "publications.conf" добавляется шаблон:

    Alias "/[BaseName]" "/usr/local/apache2/htdocs/[BaseName]/"
        <Directory "/usr/local/apache2/htdocs/[BaseName]/">
            AllowOverride All
            Options None
            #Order allow,deny
            #Allow from all
            Require all granted
            SetHandler 1c-application
            ManagedApplicationDescriptor "/usr/local/apache2/htdocs/[BaseName]/default.vrd"
        </Directory>

В каталоге "/usr/local/apache2/htdocs" нужно для каждой базы создать каталог с таким именем [BaseName], в который 
поместить файл публикации базы с именем  "default.vrd" (этот файл создается платформой 1С-Предприятие при публиации 
информационной базы)
