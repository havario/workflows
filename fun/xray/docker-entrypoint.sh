#!/usr/bin/env sh
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/233boy/Xray
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set \
    -o errexit \
    -o nounset

XRAY_WORKDIR="/etc/xray"
XRAY_BINDIR="$XRAY_WORKDIR/bin"
XRAY_CONFDIR="$XRAY_WORKDIR/conf"
XRAY_LOGDIR="/var/log/xray"
XRAY_LOGFILE="$XRAY_LOGDIR/access.log"

# https://github.com/XTLS/Xray-core/issues/2005
TLS_SERVERS="www.icloud.com apps.apple.com music.apple.com icloud.cdn-apple.com updates.cdn-apple.com"
GENERATE_UUID=$(cat /proc/sys/kernel/random/uuid)
GENERATE_KEYS=$(sing-box generate reality-keypair)
PRIVATE_KEY=$(printf "%s" "$GENERATE_KEYS" | sed -n 's/^PrivateKey: *\(.*\)$/\1/p')
PUBLIC_KEY=$(printf "%s" "$GENERATE_KEYS" | sed -n 's/^PublicKey: *\(.*\)$/\1/p')

PUBLIC_IP=$(curl -fsL -m 5 -4 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 | xargs || \
            curl -fsL -m 5 -6 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 | xargs)

if [ -d "$XRAY_CONFDIR" ] && [ -z "$(ls -A "$XRAY_CONFDIR" 2>/dev/null)" ]; then
    TLS_SERVER=$(echo "$TLS_SERVERS" | tr " " "\n" | shuf -n 1)
    cat > "$XRAY_CONFDIR/VLESS-REALITY-30000.json" <<EOF
{
  "inbounds": [
    {
      "tag": "VLESS-REALITY-46477.json",
      "port": 30000,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "e41a93fa-2775-495b-8e4f-6592c20a41fa",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "dest": "www.amazon.com:443",
          "serverNames": [
            "www.amazon.com",
            ""
          ],
          "publicKey": "vh9lGtETeYU-pdNBFPixZt560K1U2oZgU1CDcY_UE3E",
          "privateKey": "OCVVt58HvQrSQi-qvlwZWbeVB0FsRrQGDGGos39h-FM",
          "shortIds": [
            ""
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ]
}
EOF

    if [ -z "$PUBLIC_IP" ]; then
        echo "Error: Failed to retrieve IP address, configuration generation aborted!"; exit 1
    fi

    {
        echo "-------------------- URL --------------------"
        echo ""
        echo "vless://${GENERATE_UUID}@${PUBLIC_IP}:30000?encryption=none&security=reality&flow=xtls-rprx-vision&type=tcp&sni=${TLS_SERVER}&pbk=${PUBLIC_KEY}&fp=chrome#REALITY-${PUBLIC_IP}"
        echo ""
        echo "-------------------- END --------------------"
    } >> "$XRAY_LOGFILE"
fi

if [ "$#" -eq 0 ]; then
    exec "xray" run -config "$XRAY_WORKDIR/config.json" -confdir "$XRAY_CONFDIR"
else
    exec "$@"
fi