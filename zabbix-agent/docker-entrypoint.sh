#!/bin/bash
set -e

if [ "$1" = "zabbix_agent" ]; then
  echo "Starting Zabbix agent..."
  exec /usr/sbin/zabbix_agentd -f
fi

exec "$@"
