#!/bin/sh
set -e

if [ "$1" = "httpd" ]; then
    # Apache gets grumpy about PID files pre-existing
    #echo "deleting PID"
    #rm -f /usr/local/apache2/logs/httpd.pid
    echo "starting HTTPD"
    exec httpd -DFOREGROUND
fi

if [ "$1" != "httpd" ]; then
    exec "$@"
fi