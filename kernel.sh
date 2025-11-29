#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

set -eE

readonly SCRIPT_VERSION='v25.11.30'

# 强制linux输出英文
# https://www.gnu.org/software/gettext/manual/html_node/The-LANGUAGE-variable.html
export LC_ALL=C

# 设置PATH环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# 环境变量用于在debian或ubuntu操作系统中设置非交互式 (noninteractive) 安装模式
export DEBIAN_FRONTEND=noninteractive

# https://github.com/deater/linux_logo
linux_logo() {
    printf "\
                                                                 #####
                                                                #######
                   @                                            ##O#O##
  ######          @@#                                           #VVVVV#
    ##             #                                          ##  VVV  ##
    ##         @@@   ### ####   ###    ###  ##### ######     #          ##
    ##        @  @#   ###    ##  ##     ##    ###  ##       #            ##
    ##       @   @#   ##     ##  ##     ##      ###         #            ###
    ##          @@#   ##     ##  ##     ##      ###        QQ#           ##Q
    ##       # @@#    ##     ##  ##     ##     ## ##     QQQQQQ#       #QQQQQQ
    ##      ## @@# #  ##     ##  ###   ###    ##   ##    QQQQQQQ#     #QQQQQQQ
  ############  ###  ####   ####   #### ### ##### ######   QQQQQ#######QQQQQ
"
}

die() {
    echo >&2 "Error: $*"
    exit 1
}

_exists() {
    local _CMD="$1"
    if type "$_CMD" >/dev/null 2>&1; then return;
    elif command -v "$_CMD" >/dev/null 2>&1; then return;
    elif which "$_CMD" >/dev/null 2>&1; then return;
    else return 1;
    fi
}

curl() {
    local RET
    # 添加 --fail 不然404退出码也为0
    # 32位cygwin已停止更新, 证书可能有问题, 添加 --insecure
    # centos7 curl 不支持 --retry-connrefused --retry-all-errors 因此手动 retry
    for ((i=1; i<=5; i++)); do
        command curl --connect-timeout 10 --fail --insecure "$@"
        RET="$?"
        if [ "$RET" -eq 0 ]; then
            return
        else
            # 403 404 错误或达到重试次数
            if [ "$RET" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$RET"
            fi
            sleep 1
        fi
    done
}

pkg_install() {
    for pkg in "$@"; do
        if _exists dnf; then
            dnf install -y "$pkg"
        elif _exists yum; then
            yum install -y "$pkg"
        elif _exists apt-get; then
            apt-get update
            apt-get install -y -q "$pkg"
        else
            die "The package manager is not supported."
        fi
    done
}

# debian/ubuntu
# https://xanmod.org
xanmod_install() {
    local XANMOD_VER VERSION_CODE

    # https://gitlab.com/xanmod/linux
    XANMOD_VER="$(curl -L https://dl.xanmod.org/check_x86-64_psabi.sh | awk -f - 2>/dev/null | awk -F 'x86-64-v' '{v=$2+0; if(v==4)v=3; print v}')"
    VERSION_CODE="$(grep "^VERSION_CODENAME" /etc/os-release | cut -d= -f2)"

    pkg_install gnupg
    curl -L https://dl.xanmod.org/archive.key | gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $VERSION_CODE main" | tee /etc/apt/sources.list.d/xanmod-release.list
    if [[ -n "$XANMOD_VER" && "$XANMOD_VER" =~ ^[0-9]$ ]]; then
        pkg_install "linux-xanmod-x64v$XANMOD_VER"
    fi
}

## 主程序入口
linux_logo
xanmod_install
