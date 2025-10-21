#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2021 The Nx-Engine Ops Team. All rights reserved.
# Copyright (c) 2021-2025 yihao.he <yihao.he@nx-engine.com>
#                         honeok <i@honeok.com>

# Thanks:
# jimin.huang <jimin.huang@nx-engine.com>
# zhenqiang.zhang <zhenqiang.zhang@nx-engine.com>

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

# 获取一个IP即返回
ip_address() {
    local IPV4_ADDRESS IPV6_ADDRESS
    IPV4_ADDRESS="$(curl -Ls -4 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 || true)"
    IPV6_ADDRESS="$(curl -Ls -6 http://www.qualcomm.cn/cdn-cgi/trace 2>/dev/null | grep -i '^ip=' | cut -d'=' -f2 || true)"

    if [[ -n "$IPV4_ADDRESS" && "$IPV4_ADDRESS" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IPV4_ADDRESS="$(sed -E 's/^([0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}\.[0-9]{1,3}$/\1.*.*/' <<< "$IPV4_ADDRESS")"
        echo "$IPV4_ADDRESS"
        return
    fi
    if [[ -n "$IPV6_ADDRESS" && "$IPV6_ADDRESS" =~ ^([0-9a-fA-F]{0,4}:){2,} ]]; then
        IPV6_ADDRESS="$(sed -E 's/^(([^:]+:){2}).*/\1*:*:*:*:*:*' <<< "$IPV6_ADDRESS")"
        echo "$IPV6_ADDRESS"
        return
    fi
}

send_msg() {
    local MESSAGE="$1"
    curl -Ls -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"$CHAT_ID\",\"text\":\"$MESSAGE\"}" >/dev/null 2>&1
}
