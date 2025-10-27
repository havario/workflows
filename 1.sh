#!/bin/bash

BOT_TOKEN="7718937420:AAHpozXlpjK1cvPZvbCojQjQsQW2iiP-LwY"
CHAT_ID="6485476975"

die() {
    echo >&2 "Error: $*"; exit 1
}

send_msg() {
    local MESSAGE="$1"

    if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
        curl -Ls -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
            -H "Content-Type: application/json" \
            -d "{\"chat_id\":\"$CHAT_ID\",\"text\":\"$MESSAGE\"}" >/dev/null 2>&1
    fi
}

ip_address() {
    local IPV4_ADDRESS IPV6_ADDRESS

    IPV4_ADDRESS="$(curl -Ls -4 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 || true)"
    IPV6_ADDRESS="$(curl -Ls -6 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 || true)"

    if [[ -n "$IPV4_ADDRESS" && "$IPV4_ADDRESS" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        PUBLIC_IP="$IPV4_ADDRESS"
        MASKED_IP="$(awk -F. 'NF==4{print $1"."$2".*.*"} NF!=4{print ""}' <<<"$IPV4_ADDRESS")"
        return
    fi
    if [[ -n "$IPV6_ADDRESS" && "$IPV6_ADDRESS" == *":"* ]]; then
        PUBLIC_IP="[$IPV6_ADDRESS]"
        MASKED_IP="$(awk -F: '{print $1":"$2":"$3":*:*:*:*:*"}' <<< "$IPV6_ADDRESS")"
        return
    fi

    die "No valid public ip."
}

ip_info() {
    local IP_API

    IP_API="$(curl -Ls "https://api.ipbase.com/v1/json/$PUBLIC_IP")"
    SERVER_CITY="$(sed -En 's/.*"(city_name|cityName|city)":[ ]*"([^"]+)".*/\2/p' <<< "$IP_API")"
}

# 构建消息推送
const_msg() {
    local END_TIME
    END_TIME="$(date -u '+%Y-%m-%d %H:%M:%S' -d '+8 hours')"

    ip_address
    ip_info

    send_msg "$END_TIME
$MASKED_IP $SERVER_CITY
nginx complete log rotation!"
}

const_msg
