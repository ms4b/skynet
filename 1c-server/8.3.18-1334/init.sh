#!/bin/bash
set -e

init_cluster() {
  # создаем новый кластер
  local ID=$(${MAIN_1C}/rac cluster insert \
    --name=${CLUSTER_NAME} \
    --host=$(hostname) \
    --port=${MNG_PORT} \
    --expiration-timeout=${EXPIRATION_TIMEOUT} \
    --lifetime-limit=${LIFETIME_LIMIT} \
    --security-level=${SECURITY_LEVEL} \
    --session-fault-tolerance-level=${SESSION_FAULT_TOLERANCE_LEVEL} \
    --load-balancing-mode=${LOAD_BALANCING_MODE} \
    --kill-problem-processes=${KILL_PROBLEM_PROSESSES} \
    --kill-by-memory-with-dump=${KILL_BY_MEMORY_WITH_DUMP} \
    | tail -c 37)
  sleep ${RAS_SLEEP} # пауза, чтобы не глючил
  echo ${ID}
}

init_base() {
  # создаем информационную базу в новом кластере
  local ID=$(${MAIN_1C}/rac infobase \
    --cluster=$1 \
    create \
      --create-database \
      --name=${DB_NAME_1C} \
      --dbms=PostgreSQL \
      --db-server=${DB_SERVER} \
      --db-name=${DB_NAME_DB} \
      --locale=ru \
      --db-user=${POSTGRES_USER} \
      --db-pwd=${POSTGRES_PASSWORD} \
      --descr='Created automatically' \
      --date-offset=0 \
      --security-level=${SECURITY_LEVEL} \
      --scheduled-jobs-deny=off \
      --license-distribution=allow \
    | tail -c 37)
  sleep ${RAS_SLEEP} # пауза, чтобы не глючил
  echo ${ID}
}

init_admins() {
  # создаем нового администратора сервера 1С
  echo -e "\e[33m...создание нового администратора сервера 1С\e[0m"
  ${MAIN_1C}/rac agent admin register \
    --name=${SERVER_USER} \
    --pwd=${SERVER_PWD} \
    --descr='Created automatically' \
    --auth=pwd
  sleep ${RAS_SLEEP} # пауза, чтобы не глючил
  echo -e "\e[33m...создание администратора сервера 1С завершено\e[0m"

  # создаем нового администратора кластера
  echo -e "\e[33m...создание администратора кластера\e[0m"
  ${MAIN_1C}/rac cluster admin \
    --cluster=$1 \
    register \
      --name=${CLUSTER_USER} \
      --pwd=${CLUSTER_PWD} \
      --descr='Created automatically' \
      --auth=pwd \
      --agent-user=${SERVER_USER} \
      --agent-pwd=${SERVER_PWD}
  sleep ${RAS_SLEEP} # пауза, чтобы не глючил
  echo -e "\e[33m...создание администратора кластера завершено\e[0m"
}

#######################
#  Кластер
#######################

# список существующих кластеров
CURRENT_CLUSTER_LIST=$(${MAIN_1C}/rac cluster list)
sleep ${RAS_SLEEP} # пауза, чтобы не глючил
# количество существующих кластеров
NUM_OF_CLUSTERS=$(echo "${CURRENT_CLUSTER_LIST}" | grep '^cluster' | wc -l)

if [[ ${NUM_OF_CLUSTERS} -gt 1 ]]; then
  # больше чем 1 кластер, явно ручные корректировки - ничего менять не будем
  echo -e "\e[33m...обнаружено ${NUM_OF_CLUSTERS} кластеров\e[0m"
else
  # 1 или 0 кластеров

  if [[ ${NUM_OF_CLUSTERS} -eq 1 ]]; then
    # 1 кластер, возможно созданный по умолчанию
    echo -e "\e[33m...обнаружен 1 кластер\e[0m"

    # имя текущего кластера
    CURRENT_CLUSTER_NAME=$(echo "${CURRENT_CLUSTER_LIST}" | grep '^name')
    CURRENT_CLUSTER_NAME=${CURRENT_CLUSTER_NAME#*: }   # значение после разделителя ': '
    CURRENT_CLUSTER_NAME=${CURRENT_CLUSTER_NAME//\"/}  # без кавычек

    if [[ "${CURRENT_CLUSTER_NAME}" == "${CLUSTER_NAME}" ]]; then
      # это созданный скриптом кластер
      echo -e "\e[33m...обнаруженный кластер - корректный, имя ${CURRENT_CLUSTER_NAME}\e[0m"
      exit 0 # ничего больше делать не надо
    else
      # это незнакомый кластер (скорее всего создан автоматически)
      echo -e "\e[33m...обнаруженный кластер - не корректный, имя ${CURRENT_CLUSTER_NAME}\e[0m"
      # удалим непонятный кластер

      # идентификатор текущего кластера
      CURRENT_CLUSTER_ID=$(echo "${CURRENT_CLUSTER_LIST}" | grep '^cluster')
      CURRENT_CLUSTER_ID=${CURRENT_CLUSTER_ID#*: }     # значение после разделителя ': '

      echo -e "\e[33m...удаление кластера ${CURRENT_CLUSTER_ID}\e[0m"
      ${MAIN_1C}/rac cluster remove --cluster=${CURRENT_CLUSTER_ID}
      sleep ${RAS_SLEEP} # пауза, чтобы не глючил
      echo -e "\e[33m...удаление кластера ${CURRENT_CLUSTER_ID} завершено\e[0m"

      echo -e "\e[33m...создание нового кластера\e[0m"
      CURRENT_CLUSTER_ID=$(init_cluster)
      echo -e "\e[33m...создание нового кластера завершено\e[0m"
    fi
  else
    # нет кластеров
    echo -e "\e[33m...кластеров не обнаружено\e[0m"

    # создание кластера
    echo -e "\e[33m...создание нового кластера\e[0m"
    CURRENT_CLUSTER_ID=$(init_cluster)
    echo -e "\e[33m...создание нового кластера завершено\e[0m"
  fi

  if [[ -z ${CURRENT_CLUSTER_ID} ]]; then
    # не удалось создать кластер
    # дальше нет смысла двигаться
    echo -e "\e[33m...похоже что создать новый кластер не удалось\e[0m"
  else
    # удалось создать кластер
    echo -e "\e[33m...создан новый кластер ${CURRENT_CLUSTER_ID}\e[0m"
  fi

  # создание информационной базы
  echo -e "\e[33m...создание новой информационной базы\e[0m"
  DATA_BASE_ID=$(init_base ${CURRENT_CLUSTER_ID})
  echo -e "\e[33m...создание новой информационной базы завершено\e[0m"

  if [[ -z ${DATA_BASE_ID} ]]; then
    # не удалось создать информационную базу
    echo -e "\e[33m...похоже что создать новую информационную базу не удалось\e[0m"
  else
    # удалось создать информационную базу
    echo -e "\e[33m...создана новая информационная база ${DATA_BASE_ID}\e[0m"
  fi

  # создание администраторов
  init_admins ${CURRENT_CLUSTER_ID}

fi

exit 0 # ничего больше делать не надо