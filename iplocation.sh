#!/usr/bin/env bash
#
# Description: This script is used to retrieve the province and city information of a specified ip address in mainland china using public api services.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# SPDX-License-Identifier: MIT

# https://www.graalvm.org/latest/reference-manual/ruby/UTF8Locale
if locale -a 2>/dev/null | grep -qiE -m 1 "UTF-8|utf8"; then
    export LANG=en_US.UTF-8
fi

# 各变量默认值
UA_BROWSER='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36'

# 清屏函数
clrscr() {
    ( [ -t 1 ] && tput clear 2>/dev/null ) || echo -e "\033[2J\033[H" || clear
}

if [ -z "$1" ] && [ -n "$(awk '{print $1}' <<< "$SSH_CONNECTION")" ]; then
    LOGIN_IP="$(awk '{print $1}' <<< "$SSH_CONNECTION")"
fi

# https://www.nodeseek.com/post-344659-1
bilibili_api() {
    local IP_LOCATION="$1"
    local IP_API IP PROVINCE CITY

    IP_API="$(curl --user-agent "$UA_BROWSER" --max-time 5 -fsL "https://api.live.bilibili.com/ip_service/v1/ip_service/get_ip_addr?ip=$IP_LOCATION")"
    IP="$(sed -nE 's/.*"addr":"([^"]+)".*/\1/p' <<< "$IP_API")"
    PROVINCE="$(sed -nE 's/.*"province":"([^"]+)".*/\1/p' <<< "$IP_API")"
    CITY="$(sed -nE 's/.*"city":"([^"]+)".*/\1/p' <<< "$IP_API")"

    ( [[ -n "$IP" && -n "$PROVINCE" && -n "$CITY" ]] && echo "$IP $PROVINCE $CITY"; return 0 ) || return 1
}

baidu_api() {
    local IP_LOCATION="$1"
    local IP_API IP PROVINCE CITY

    IP_API="$(curl --user-agent "$UA_BROWSER" --max-time 5 -fsL "https://opendata.baidu.com/api.php?co=&resource_id=6006&oe=utf8&query=$IP_LOCATION")"
    IP="$(sed -En 's/.*"origip":"([^"]+)".*/\1/p' <<< "$IP_API")"
    PROVINCE="$(sed -En 's/.*"location":"([^省]+)省.*/\1/p' <<< "$IP_API")"
    CITY="$(sed -En 's/.*"location":"[^省]+省([^市]+)市.*/\1/p' <<< "$IP_API")"

    ( [[ -n "$IP" && -n "$PROVINCE" && -n "$CITY" ]] && echo "$IP $PROVINCE $CITY"; return 0 ) || return 1
}

iplocation() {
    local IP_ADDRESS="$1"

    bilibili_api "$IP_ADDRESS" && return 0
    baidu_api "$IP_ADDRESS" && return 0
    echo >&2 "Error: Unknown IP information."; exit 1
}

if [ "$#" -gt 1 ]; then
    echo >&2 "There are multiple parameters."; exit 1
elif [ -n "$LOGIN_IP" ]; then
    iplocation "$LOGIN_IP"
else
    iplocation "$1"
fi