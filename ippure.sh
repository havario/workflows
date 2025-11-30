#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

die() {
    local EXIT_CODE

    EXIT_CODE="${2:-1}"

    printf >&2 'Error: %s\n' "$1"
    exit "$EXIT_CODE"
}

get_cmd_path() {
    # -f: 忽略shell内置命令和函数, 只考虑外部命令
    # -p: 只输出外部命令的完整路径
    type -f -p "$1"
}

is_have_cmd() {
    get_cmd_path "$1" >/dev/null 2>&1
}

install_pkg() {
    for pkg in "$@"; do
        if is_have_cmd dnf; then
            dnf install -y "$pkg"
        elif is_have_cmd yum; then
            yum install -y "$pkg"
        elif is_have_cmd apt-get; then
            apt-get update
            apt-get install -y -q "$pkg"
        elif is_have_cmd apk; then
            apk add --no-cache "$pkg"
        elif is_have_cmd pacman; then
            pacman -S --noconfirm --needed "$pkg"
        else
            die "The package manager is not supported."
        fi
    done
}

curl() {
    local EXIT_CODE

    is_have_cmd curl || install_pkg curl

    # --fail             4xx/5xx返回非0
    # --insecure         兼容旧平台证书问题
    # --connect-timeout  连接超时保护
    # CentOS7 无法使用 --retry-connrefused 和 --retry-all-errors 因此手动 retry

    for ((i=1; i<=5; i++)); do
        if ! command curl --connect-timeout 10 --fail --insecure "$@"; then
            EXIT_CODE=$?
            # 403 404 错误或达到重试次数
            if [ "$EXIT_CODE" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$EXIT_CODE"
            fi
            sleep 1
        else
            return
        fi
    done
}

IPV4="$(curl -Ls -4 http://www.qualcomm.cn/cdn-cgi/trace | grep -i '^ip=' | cut -d'=' -f2 | grep .)"
curl -Ls "https://rdap.arin.net/registry/ip/$IPV4" | sed -n 's/.*"country":"\([^"]*\)".*/\1/p' | head -n1
