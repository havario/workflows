#!/usr/bin/env bash
#
# Description: dynamically updates dns records via cloudflare api v4 for ddns.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/yulewang/cloudflare-api-v4-ddns
# https://github.com/aipeach/cloudflare-api-v4-ddns
#
# Licensed under the Apache License, Version 2.0.
# Distributed on an "AS IS" basis, WITHOUT WARRANTIES.
# See http://www.apache.org/licenses/LICENSE-2.0 for details.

set -eu

# API key, see https://dash.cloudflare.com/profile/api-tokens
# 不正确的 api-key 会导致 E_UNAUTH 错误
CFKEY=

# 区域名称 例如: example.com
CFZONE_NAME=

# 要更新的主机名 例如: homeserver.example.com
CFRECORD_NAME=

# 记录类型 A(IPv4)|AAAA(IPv6) 默认 IPv4
CFRECORD_TYPE=A

# Cloudflare TTL记录 介于120到86400秒之间
CFTTL=120

# 忽略本地文件 仍然更新IP
FORCE=false

WANIPSITE="http://ipv4.icanhazip.com"

# get public IP
if [ "$CFRECORD_TYPE" = "A" ]; then
    :
elif [ "$CFRECORD_TYPE" = "AAAA" ]; then
    WANIPSITE="http://ipv6.icanhazip.com"
else
    echo "$CFRECORD_TYPE specified is invalid, CFRECORD_TYPE can only be A(for IPv4)|AAAA(for IPv6)"
    exit 2
fi

# 获取参数
while getopts k:h:z:t:f: opts; do
    case "$opts" in
        k) CFKEY="$OPTARG" ;;
        h) CFRECORD_NAME="$OPTARG" ;;
        z) CFZONE_NAME="$OPTARG" ;;
        t) CFRECORD_TYPE="$OPTARG" ;;
        f) FORCE="$OPTARG" ;;
    esac
done

# If required settings are missing just exit
if [ "$CFKEY" = "" ]; then
    echo "Missing api-key, get at: https://www.cloudflare.com/a/account/my-account"
    echo "and save in ${0} or using the -k flag"
    exit 2
fi
if [ "$CFRECORD_NAME" = "" ]; then 
    echo "Missing hostname, what host do you want to update?"
    echo "save in ${0} or using the -h flag"
    exit 2
fi

# If the hostname is not a FQDN
if [ "$CFRECORD_NAME" != "$CFZONE_NAME" ] && ! [ -z "${CFRECORD_NAME##*"$CFZONE_NAME"}" ]; then
    CFRECORD_NAME="$CFRECORD_NAME.$CFZONE_NAME"
    echo " => Hostname is not a FQDN, assuming $CFRECORD_NAME"
fi

# Get current and old WAN ip
WAN_IP=$(curl -s ${WANIPSITE})
WAN_IP_FILE=$HOME/.cf-wan_ip_$CFRECORD_NAME.txt
if [ -f "$WAN_IP_FILE" ]; then
    OLD_WAN_IP=$(cat "$WAN_IP_FILE")
else
    echo "No file, need IP"
    OLD_WAN_IP=""
fi

# If WAN IP is unchanged an not -f flag, exit here
if [ "$WAN_IP" = "$OLD_WAN_IP" ] && [ "$FORCE" = false ]; then
    echo "WAN IP Unchanged, to update anyway use flag -f true"
    exit 0
fi

# Get zone_identifier & record_identifier
ID_FILE=$HOME/.cf-id_$CFRECORD_NAME.txt
if [ -f "$ID_FILE" ] && [ $(wc -l "$ID_FILE" | cut -d " " -f 1) == 4 ] \
    && [ "$(sed -n '3,1p' "$ID_FILE")" == "$CFZONE_NAME" ] \
    && [ "$(sed -n '4,1p' "$ID_FILE")" == "$CFRECORD_NAME" ]; then
    CFZONE_ID=$(sed -n '1,1p' "$ID_FILE")
    CFRECORD_ID=$(sed -n '2,1p' "$ID_FILE")
else
    echo "Updating zone_identifier & record_identifier"
    CFZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$CFZONE_NAME" -H "Authorization: Bearer $CFKEY" -H "Content-Type: application/json" | grep -Eo '"id":"[^"]*'|sed 's/"id":"//' | head -1 )
    CFRECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records?name=$CFRECORD_NAME" -H "Authorization: Bearer $CFKEY" -H "Content-Type: application/json"  | grep -Eo '"id":"[^"]*'|sed 's/"id":"//' | head -1 )
    echo "$CFZONE_ID" > "$ID_FILE"
    echo "$CFRECORD_ID" >> "$ID_FILE"
    echo "$CFZONE_NAME" >> "$ID_FILE"
    echo "$CFRECORD_NAME" >> "$ID_FILE"
fi

# If WAN is changed, update cloudflare
echo "Updating DNS to $WAN_IP"

RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records/$CFRECORD_ID" \
    -H "Authorization: Bearer $CFKEY" \
    -H "Content-Type: application/json" \
    --data "{\"id\":\"$CFZONE_ID\",\"type\":\"$CFRECORD_TYPE\",\"name\":\"$CFRECORD_NAME\",\"content\":\"$WAN_IP\", \"ttl\":$CFTTL}")

if [ "$RESPONSE" != "${RESPONSE%success*}" ] && [ "$(echo "$RESPONSE" | grep "\"success\":true")" != "" ]; then
    echo "Updated succesfuly!"
    echo "$WAN_IP" > "$WAN_IP_FILE"
    exit
else
    echo 'Something went wrong :('
    echo "Response: $RESPONSE"
    exit 1
fi