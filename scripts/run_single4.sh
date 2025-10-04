#!/usr/bin/env bash
set -euo pipefail
CTRL_IP="${CTRL_IP:-127.0.0.1}"
CTRL_PORT="${CTRL_PORT:-6633}"
sudo mn --topo single,4 --controller=remote,ip="$CTRL_IP",port="$CTRL_PORT"
