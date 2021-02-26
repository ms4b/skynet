#!/bin/bash
set -e

exec 2>&1
exec /usr/bin/iperf3 -s