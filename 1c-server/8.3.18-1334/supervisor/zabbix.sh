#!/bin/bash
set -e

exec 2>&1
exec /usr/sbin/zabbix_agentd --foreground