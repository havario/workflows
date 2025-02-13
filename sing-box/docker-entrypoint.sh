#!/bin/sh

set \
    -o errexit \
    -o nounset \
    -o noclobber

SINGBOX_WORKDIR="/etc/sing-box"
SINGBOX_BINDIR="$SINGBOX_WORKDIR/bin"
SINGBOX_CMD="$SINGBOX_BINDIR/sing-box"
SINGBOX_CONFDIR="$SINGBOX_WORKDIR/conf"
SINGBOX_LOGDIR="/var/log/sing-box"
SINGBOX_LOGFILE="$SINGBOX_LOGDIR/access.log"

GENERATE_UUID=$(cat /proc/sys/kernel/random/uuid)
PRIVATE_KEY=$(head -c 32 /dev/urandom | base64 | tr '+/' '-_' | tr -d '=')
PUBLIC_KEY=$(head -c 32 /dev/urandom | base64 | tr '+/' '-_' | tr -d '=')
IPADDRESS=$(curl -fsL -m 3 https://ipinfo.io/ip)

# Generate default config if not provided by the user
if [ ! -f "$SINGBOX_WORKDIR/config.json" ]; then
    cat > "$SINGBOX_WORKDIR/config.json" <<EOF
{
  "log": {
    "output": "/var/log/sing-box/access.log",
    "level": "info",
    "timestamp": true
  },
  "dns": {},
  "ntp": {
    "enabled": true,
    "server": "time.apple.com"
  },
  "outbounds": [
    {
      "tag": "direct",
      "type": "direct"
    },
    {
      "tag": "block",
      "type": "block"
    }
  ]
}
EOF
fi

if [ -d "$SINGBOX_CONFDIR" ] && [ -z "$(ls -A "$SINGBOX_CONFDIR" 2>/dev/null)" ]; then
    cat > "$SINGBOX_CONFDIR/VLESS-REALITY-8080.json" <<EOF
{
  "inbounds": [
    {
      "tag": "VLESS-REALITY-8080.json",
      "type": "vless",
      "listen": "::",
      "listen_port": 8080,
      "users": [
        {
          "flow": "xtls-rprx-vision",
          "uuid": "${GENERATE_UUID}"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "music.apple.com",
        "reality": {
          "enabled": true,
          "handshake": {
            "server": "music.apple.com",
            "server_port": 443
          },
          "private_key": "${PRIVATE_KEY}",
          "short_id": [
            ""
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct"
    },
    {
      "tag": "public_key_${PUBLIC_KEY}",
      "type": "direct"
    }
  ]
}
EOF

{
    echo "---------------- URL -----------------"
    echo "vless://${GENERATE_UUID}@${IPADDRESS}:8080?encryption=none&security=reality&flow=xtls-rprx-vision&type=tcp&sni=music.apple.com&pbk=${PUBLIC_KEY}&fp=chrome#reality-${PUBLIC_KEY}"
    echo "---------------- END -----------------"
} >> "$SINGBOX_LOGFILE"
fi

if [ "$#" -eq 0 ]; then
    exec "$SINGBOX_CMD" run -c "$SINGBOX_WORKDIR/config.json" -C "$SINGBOX_CONFDIR" 2>/dev/null
else
    exec "$@"
fi