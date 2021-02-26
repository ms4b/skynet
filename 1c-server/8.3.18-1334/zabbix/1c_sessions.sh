#!/bin/bash

# каталог сервера 1С
PROGRAMPATH="/opt/1C/v8.3/x86_64"

# определим идентификатор первого кластера сервера
CLUSTER=$(${PROGRAMPATH}/rac cluster list | grep 'cluster  *' | head -1 | tail -c 37)

# информация об активных сессиях кластера
SESSIONS=$(${PROGRAMPATH}/rac session --cluster=${CLUSTER} list)

# разберем информацию об активных сессиях кластера и выделим отдельные показатели

# общее количество активных сессий
NUM_OF_TOTAL=$(echo "${SESSIONS}" | grep app-id | wc -l)

# количество активных сессий конфигуратора
NUM_OF_DES=$(echo "${SESSIONS}" | grep Designer | wc -l)

# количество активных сессий тонкого клиента
NUM_OF_1CV8C=$(echo "${SESSIONS}" | grep 1CV8C | wc -l)

# количество активных сессий толстого клиента
NUM_OF_1CV8=$(echo "${SESSIONS}" | grep 1CV8 | wc -l)
let NUM_OF_1CV8=NUM_OF_1CV8-NUM_OF_1CV8C

# количество активных сессий веб-клиента
NUM_OF_WC=$(echo "${SESSIONS}" | grep WebClient | wc -l)

# количество активных сессий фоновых заданий
NUM_OF_BJ=$(echo "${SESSIONS}" | grep BackgroundJob | wc -l)

# количество прочих активных сессий
NUM_OF_OTHER=0
let NUM_OF_OTHER=NUM_OF_TOTAL-NUM_OF_DES-NUM_OF_1CV8-NUM_OF_1CV8C-NUM_OF_WC-NUM_OF_BJ

# объединим все показатели в результирующую строку
RESULT="${NUM_OF_TOTAL}:${NUM_OF_DES}:${NUM_OF_1CV8}:${NUM_OF_1CV8C}:${NUM_OF_WC}:${NUM_OF_BJ}:${NUM_OF_OTHER}"

# выводим результат
echo "${RESULT}"