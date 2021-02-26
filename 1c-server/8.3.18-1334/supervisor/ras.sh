#!/bin/bash
set -e

exec 2>&1

#MAIN_1C=/opt/1C/v8.3/x86_64
#VER_1C=номер версии сервера 1С

exec ${MAIN_1C}/${VER_1C}ras cluster
