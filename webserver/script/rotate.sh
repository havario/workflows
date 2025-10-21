#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

set -eEuo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE:-$0}")"
BOT_TOKEN=""
CHAT_ID=""
BARK_TOKEN=""

die() {
    echo >&2 "Error: $*"; exit 1
}

curl() {
    local RET
    for ((i=1; i<=5; i++)); do
        command curl --connect-timeout 10 --fail --insecure "$@"
        RET="$?"
        if [ "$RET" -eq 0 ]; then
            return
        else
            if [ "$RET" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$RET"
            fi
            sleep 1
        fi
    done
}

ip_address() {
    local IPV4_ADDRESS IPV6_ADDRESS
    IPV4_ADDRESS="$(curl -Ls -4 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 || true)"
    IPV6_ADDRESS="$(curl -Ls -6 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 || true)"
    if [[ -n "$IPV4_ADDRESS" && "$IPV4_ADDRESS" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "$IPV4_ADDRESS"
        return
    fi
}

send_msg() {
    local MESSAGE="$1"
    curl -Ls -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"$CHAT_ID\",\"text\":\"$MESSAGE\"}" >/dev/null 2>&1
}
