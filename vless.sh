#!/usr/bin/env bash

set -e
cd /opt/src

VLESS_ROUTE_TABLE_ID=${VLESS_ROUTE_TABLE_ID:-'128'}

function start_sing_box() {
  # Generate config.json if it doesn't exist
  if ! [ -f /opt/src/config.json ]; then
    /bin/bash ./vless_config_template.sh > /opt/src/config.json
  fi

  /bin/sing-box --config /opt/src/config.json run &

  ip rule add from "${L2TP_NET}" table "${VLESS_ROUTE_TABLE_ID}"
  ip rule add from "${XAUTH_NET}" table "${VLESS_ROUTE_TABLE_ID}"
  ip route add table "${VLESS_ROUTE_TABLE_ID}" default via 198.18.0.1

}


# Start and watching vless sing-box server
while true; do
  # Проверка, запущена ли программа sing-box
  if ! pgrep -x "/bin/sing-box" > /dev/null; then
    echo "Sing-box server is not running. Starting it..."
    start_sing_box
  fi

  # Pause for 10 seconds
  sleep 10
done
