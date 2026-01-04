#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# Description:
# follow bash bible: https://github.com/dylanaraps/pure-bash-bible
# Copyright (c) 2025 honeok <i@honeok.com>

# shellcheck disable=all

set -eE

get_ifaces() {
    while read -r line; do
        line="${line## }"
        if [[ "$line" == *:* ]]; then
            iface="${line%%:*}"
            if [[ "$iface" != "lo" ]]; then
                echo "$iface"
            fi
        fi
    done < /proc/net/dev
}

get_bytes() {
    local iface="$1"
    while read -r line; do
        line="${line## }"
        if [[ "$line" == "$iface":* ]]; then
            line="${line//:/ }"
            read -ar cols <<< "$line"
            # cols[1]: 入口流量
            # cols[9]: 出口流量
            echo "${cols[1]} ${cols[9]}"
            return
        fi
    done < /proc/net/dev
}
