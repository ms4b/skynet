call version.cmd
cd ..
docker build --tag ms4b/zabbix-agent:%ver% .
docker push ms4b/zabbix-agent:%ver%