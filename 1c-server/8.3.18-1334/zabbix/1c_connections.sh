#!/bin/bash

# каталог сервера 1С
PROGRAMPATH="/opt/1C/v8.3/x86_64"

# определим идентификатор первого кластера сервера
CLUSTER=$(${PROGRAMPATH}/rac cluster list | grep 'cluster  *' | head -1 | tail -c 37)

# информация об активных соединениях кластера
CONNECTIONS=$(${PROGRAMPATH}/rac connection --cluster=${CLUSTER} list)

# разберем информацию об активных соединениях кластера и выделим отдельные показатели

# общее количество активных соединений
NUM_OF_TOTAL=$(echo "${CONNECTIONS}" | grep application | wc -l)

# количество активных соединений конфигуратора
NUM_OF_DES=$(echo "${CONNECTIONS}" | grep Designer | wc -l)

# количество активных соединений тонкого клиента
NUM_OF_1CV8C=$(echo "${CONNECTIONS}" | grep 1CV8C | wc -l)

# количество активных соединений толстого клиента
NUM_OF_1CV8=$(echo "${CONNECTIONS}" | grep 1CV8 | wc -l)
let NUM_OF_1CV8=NUM_OF_1CV8-NUM_OF_1CV8C

# количество активных соединений веб-клиента
NUM_OF_WC=$(echo "${CONNECTIONS}" | grep WebClient | wc -l)

# количество активных соединений фоновых заданий
NUM_OF_BJ=$(echo "${CONNECTIONS}" | grep BackgroundJob | wc -l)

# количество активных соединений планировщика регламентных заданий
NUM_OF_JS=$(echo "${CONNECTIONS}" | grep JobScheduler | wc -l)

# количество активных соединений агента
NUM_OF_ASC=$(echo "${CONNECTIONS}" | grep AgentStandardCall | wc -l)

# количество прочих активных соединений
NUM_OF_OTHER=0
let NUM_OF_OTHER=NUM_OF_TOTAL-NUM_OF_DES-NUM_OF_1CV8-NUM_OF_1CV8C-NUM_OF_WC-NUM_OF_BJ-NUM_OF_JS-NUM_OF_ASC

# объединим все показатели в результирующую строку
RESULT="${NUM_OF_TOTAL}:${NUM_OF_DES}:${NUM_OF_1CV8}:${NUM_OF_1CV8C}:${NUM_OF_WC}:${NUM_OF_BJ}:${NUM_OF_JS}:${NUM_OF_ASC}:${NUM_OF_OTHER}"

# выводим результат
echo "${RESULT}"