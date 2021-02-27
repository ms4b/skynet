#!/bin/bash
set -e

exec 2>&1

#MAIN_1C=/opt/1cv8/x86_64/${VER_1C}
#VER_1C=номер версии сервера 1С

exec ${MAIN_1C}/ras cluster
