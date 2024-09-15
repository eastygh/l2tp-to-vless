#!/usr/bin/env bash

set -e

VLESS_PORT=${VLESS_PORT:-'443'}
VLESS_PUBKEY_ENABLED=${VLESS_PUBKEY_ENABLED:-'false'}
VLESS_PUBKEY=${VLESS_PUBKEY:-''}
VLESS_SNI=${VLESS_SNI:-'example.com'}
VLESS_UUID=${VLESS_UUID:-''}

cat <<EOF
{
  "log": {
    "disabled": false,
    "level": "warn",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns_proxy",
        "address": "https://1.1.1.1/dns-query",
        "address_resolver": "dns_resolver",
        "strategy": "ipv4_only",
        "detour": "proxy"
      },
      {
        "tag": "dns_direct",
        "address": "https://dns.alidns.com/dns-query",
        "address_resolver": "dns_resolver",
        "strategy": "ipv4_only",
        "detour": "direct"
      },
      {
        "tag": "dns_resolver",
        "address": "223.5.5.5",
        "detour": "direct"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns_resolver"
      }
    ],
    "final": "dns_direct"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "singtun0",
      "inet4_address": "198.18.0.1/30",
      "domain_strategy": "ipv4_only",
      "stack": "gvisor",
      "mtu": 9000,
      "auto_route": false,
      "strict_route": true,
      "endpoint_independent_nat": false,
      "sniff": true,
      "sniff_override_destination": true
    }
  ],
  "outbounds": [
    {
      "type": "vless",
      "tag": "reality-out",
      "server": "${VLESS_SERVER}",
      "server_port": $VLESS_PORT,
      "uuid": "${VLESS_UUID}",
      "flow": "",
      "network": "tcp",
      "tls": {
        "enabled": true,
        "insecure": false,
        "server_name": "${VLESS_SNI}",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
        "reality": {
          "enabled": $VLESS_PUBKEY_ENABLED,
          "public_key": "${VLESS_PUBKEY}"
        }
      }
    }
  ],
  "route": {
    "auto_detect_interface": true
  }
}
EOF