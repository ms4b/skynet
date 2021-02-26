#!/bin/bash
set -e

if [ "$1" = "ragent" ]; then

  exec supervisord -c ${SV}/supervisord.conf

fi

exec "$@"