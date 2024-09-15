#!/usr/bin/env bash

set -e
cd /opt/src

VLESS_ROUTE_TABLE_ID=${VLESS_ROUTE_TABLE_ID:-'128'}
VLESS_IFACE_NAME=${VLESS_IFACE_NAME:-'singtun0'}
VLESS_IFACE_IP=''

echo "VLESS_ROUTE_TABLE_ID: ${VLESS_ROUTE_TABLE_ID}"
echo "VLESS_IFACE_NAME: ${VLESS_IFACE_NAME}"
echo "L2TP_NET: ${L2TP_NET}"
echo "XAUTH_NET: ${XAUTH_NET}"

function wait_interface() {
  max_count=${1:-10}
  VLESS_IFACE_IP=''
  count=0
  while [ $count -lt "$max_count" ] && [ -z "${VLESS_IFACE_IP}" ]; do
    if ip addr show "${VLESS_IFACE_NAME}" > /dev/null 2>&1; then
      VLESS_IFACE_IP=$(ip addr show dev "${VLESS_IFACE_NAME}" | awk '/inet /{split($2, a, "/"); print a[1]}')
      echo "Interface ${VLESS_IFACE_NAME} found. IP-address: ${VLESS_IFACE_IP}"
    else
      echo "${VLESS_IFACE_NAME} not found, probably not created yet. Waiting..."
      sleep 1
      count=$((count + 1))
    fi
  done
}

function start_sing_box() {
  # Generate config.json if it doesn't exist
  if ! [ -f /opt/src/config.json ]; then
    /bin/bash ./vless_config_template.sh > /opt/src/config.json
  fi

  # Run sing-box
  echo "Starting sing-box"
  /bin/sing-box --config /opt/src/config.json run &

  # Wait for sing-box to start
  wait_interface 10

  # Add routes
  if [ -n "${VLESS_IFACE_IP}" ]; then
    echo "Adding routes. Gateway: ${VLESS_IFACE_IP}"
    ip rule add from "${L2TP_NET}" table "${VLESS_ROUTE_TABLE_ID}"
    ip rule add from "${XAUTH_NET}" table "${VLESS_ROUTE_TABLE_ID}"
    ip route add table "${VLESS_ROUTE_TABLE_ID}" default via "${VLESS_IFACE_IP}"
  else
    echo "No ip address found for interface: ${VLESS_IFACE_NAME} ip: ${VLESS_IFACE_IP}. Skipping route addition. Kill sing-box"
    killall sing-box
  fi

}


# Start and watching vless sing-box server
while true; do
  # Check if sing-box server is running
  if ! pgrep -x "/bin/sing-box" > /dev/null; then
    echo "Sing-box server is not running. Starting it..."
    start_sing_box
  fi

  # Pause for 10 seconds
  sleep 10
done
