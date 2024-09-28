[English](README.md)

# IPsec VPN Server convert to VLESS VPN on Docker

[![Docker Stars](docs/images/badges/docker-stars.svg)](https://hub.docker.com/r/easty/l2tp-to-vless/) [![Docker Pulls](docs/images/badges/docker-pulls.svg)](https://hub.docker.com/r/easty/l2tp-to-vless/)

Docker image to run an IPsec VPN server, with IPsec/L2TP, Cisco IPsec and IKEv2 and
convert traffic to VLESS VPN destination.

Based on Alpine 3.20 with [Libreswan](https://libreswan.org) (IPsec VPN software) and [xl2tpd](https://github.com/xelerance/xl2tpd) (L2TP daemon).

Original repository: https://github.com/hwdsl2/docker-ipsec-vpn-server

**[&raquo; :book: Book: Build Your Own VPN Server: A Step by Step Guide](https://books2read.com/vpnguide?store=amazon)**

## Quick start

Use this command to set up an IPsec VPN server on Docker with VLESS VPN destination:

```
docker run \
    --name ipsec-vpn-server \
    --restart=always \
    -v ikev2-vpn-data:/etc/ipsec.d \
    -v /lib/modules:/lib/modules:ro \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d --privileged \
     easty/l2tp-to-vless
```

Read about setup L2TP Vpn Server in [Original Readme](https://github.com/hwdsl2/docker-ipsec-vpn-server/blob/master/README.md)

vpn.env example:

```
# Note: All the variables to this image are optional.
# See README for more information.
# To use, uncomment and replace with your own values.

# Define IPsec PSK, VPN username and password
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
# VPN_IPSEC_PSK=your_ipsec_pre_shared_key
# VPN_USER=your_vpn_username
# VPN_PASSWORD=your_vpn_password

# Define additional VPN users
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
# - Usernames and passwords must be separated by spaces
# VPN_ADDL_USERS=additional_username_1 additional_username_2
# VPN_ADDL_PASSWORDS=additional_password_1 additional_password_2

# Use a DNS name for the VPN server
# - The DNS name must be a fully qualified domain name (FQDN)
# VPN_DNS_NAME=vpn.example.com

# Specify a name for the first IKEv2 client
# - Use one word only, no special characters except '-' and '_'
# - The default is 'vpnclient' if not specified
# VPN_CLIENT_NAME=your_client_name

# Use alternative DNS servers
# - By default, clients are set to use Google Public DNS
# - Example below shows Cloudflare's DNS service
# VPN_DNS_SRV1=1.1.1.1
# VPN_DNS_SRV2=1.0.0.1

# Protect IKEv2 client config files using a password
# - By default, no password is required when importing IKEv2 client configuration
# - Uncomment if you want to protect these files using a random password
# VPN_PROTECT_CONFIG=yes


# Configure VLESS
# outbound configuration see vless_config_template.sh
VLESS_SERVER="horizon-vless.myserver.com"
VLESS_PORT=443
VLESS_PUBKEY_ENABLED=true
VLESS_PUBKEY="AP24JYROAB8odK5glVW_KLnsWl3UZ-voaGq_9ihQgTL"
VLESS_SNI="microsoft.com"
VLESS_UUID="86d1bf14-b5d5-4f10-9e61-f51118558fd9"

```