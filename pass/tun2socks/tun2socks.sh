#!/usr/bin/env bash
#
# Description: This script sets up a transparent proxy on the server using tun2socks, which routes all network traffic from any application.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# Acknowledgment: https://github.com/xjasonlyu/tun2socks
#
# SPDX-License-Identifier: GPL-2.0-only

# 当前脚本版本号
readonly VERSION='v1.0.1 (2025.06.09)'

# https://www.graalvm.org/latest/reference-manual/ruby/UTF8Locale
if locale -a 2>/dev/null | grep -qiE -m 1 "UTF-8|utf8"; then
    export LANG=en_US.UTF-8
fi
# 环境变量用于在debian或ubuntu操作系统中设置非交互式 (noninteractive) 安装模式
export DEBIAN_FRONTEND=noninteractive
# 设置PATH环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# 自定义彩色字体
_red() { printf "\033[91m%b\033[0m\n" "$*"; }
_green() { printf "\033[92m%b\033[0m\n" "$*"; }
_yellow() { printf "\033[93m%b\033[0m\n" "$*"; }
_blue() { printf "\033[94m%b\033[0m\n" "$*"; }
_cyan() { printf "\033[96m%b\033[0m\n" "$*"; }
_err_msg() { printf "\033[41m\033[1mError\033[0m %b\n" "$*"; }
_suc_msg() { printf "\033[42m\033[1mSuccess\033[0m %b\n" "$*"; }
_info_msg() { printf "\033[43m\033[1mInfo\033[0m %b\n" "$*"; }

# 各变量默认值
RANDOM_CHAR="$(head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 5)"
TEMP_WORKDIR="/tmp/tun2socks_$RANDOM_CHAR"
UA_BROWSER='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36'

# curl默认参数
declare -a CURL_OPTS=(--max-time 5 --retry 2 --retry-max-time 10)

die() {
    _err_msg "$(_red "$@")" >&2; exit 1
}

# https://github.com/xjasonlyu/tun2socks/wiki/Load-TUN-Module
# Create the necessary file structure for /dev/net/tun
if [ ! -c /dev/net/tun ]; then
    if [ ! -d /dev/net ]; then
        mkdir -m 755 /dev/net
    fi
    mknod /dev/net/tun c 10 200
    chmod 0755 /dev/net/tun
fi

# Load the tun module if not already loaded
if ( ! (lsmod | grep -q "^tun\s")); then
    insmod /lib/modules/tun.ko
fi

TUN2SOCKS_VER="$(curl "${CURL_OPTS[@]}" -fsL "https://api.github.com/repos/xjasonlyu/tun2socks/releases/latest" | awk -F'"' '/"tag_name":/{print $4}')"