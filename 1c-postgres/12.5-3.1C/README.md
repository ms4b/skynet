# Контейнер Docker PostgreSQL 11.5 с патчами для 1С

## Сборка ораза Docker:

Поместить в каталог "dist/postgres" установочные пакеты для 64-битных RPM систем (*.rpm)

Поместить в каталог "dist/addon" установочные пакеты аддонов (*.rpm)

Настройки сервера конфигурируются в файле "postgresql.conf"

Собрать образ скриптом "scripts/build.cmd"

## Тестовый запуск контейнера

Создать и запустить контейнер скриптом "scripts/run.cmd"

Подключиться к серверу через PGAdmin по адресу localhost, порт 5432