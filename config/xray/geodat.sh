#!/usr/bin/env bash
#
# Description: This script is used to fetches and updates the latest geo data file automatically.
#
# Copyright (c) 2025 honeok <i@honeok.com>
#
# Thanks:
# https://github.com/Loyalsoldier/v2ray-rules-dat
#
# SPDX-License-Identifier: GPL-2.0-only

set -eE

# 各变量默认值
RANDOM_CHAR="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 5)"
TEMP_DIR="/tmp/geodat_$RANDOM_CHAR"

# 终止信号捕获退出前清理操作
_exit() {
    local ERR_CODE="$?"
    rm -rf "$TEMP_DIR" >/dev/null 2>&1
    exit "$ERR_CODE"
}

# 终止信号捕获
trap '_exit' SIGINT SIGQUIT SIGTERM EXIT

# 临时工作目录
mkdir -p "$TEMP_DIR" >/dev/null 2>&1
if [ "$(cd -P -- "$(dirname -- "$0")" && pwd -P)" != "$TEMP_DIR" ]; then
    cd "$TEMP_DIR" >/dev/null 2>&1
fi

curl --retry 2 -LsO https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
curl --retry 2 -LsO https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat.sha256sum
sha256sum -c geoip.dat.sha256sum
curl --retry 2 -LsO https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
curl --retry 2 -LsO https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat.sha256sum
sha256sum -c geosite.dat.sha256sum

mv -f *.dat /etc/xray/bin
systemctl restart xray.service --quiet