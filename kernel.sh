#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

# References:
# https://github.com/bin456789/reinstall
# https://github.com/mlocati/docker-php-extension-installer

set -eEu

# shellcheck disable=SC2034
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

       Linux Version $(uname -r 2>/dev/null), Compiled $(uname -v 2>/dev/null | awk '{print $1,$2,$3}')
"
}

clear() {
    [ -t 1 ] && tput clear 2>/dev/null || printf "\033[2J\033[H" || command clear
}

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

check_root() {
    if [ "$EUID" -ne 0 ] || [ "$(id -ru)" -ne 0 ]; then
        die "This script must be run as root!"
    fi
}

check_bash() {
    local BASH_VER
    BASH_VER="$(bash --version 2>&1 | head -n1 | awk -F ' ' '{for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+/) {print $i; exit}}' | cut -d . -f1)"

    if [ -z "$BASH_VERSION" ]; then
        die "This script needs to be run with bash, not sh!"
    fi
    if [ -z "$BASH_VER" ] || ! [[ "$BASH_VER" =~ ^[0-9]+$ ]]; then
        die "Failed to parse Bash version!"
    fi
    if [ "$BASH_VER" -lt 4 ]; then
        die "Bash version is lower than 4.0!"
    fi
}

check_arch() {
    if [ -z "$OS_ARCH" ]; then
        case "$(uname -m 2>/dev/null)" in
            amd64 | x86_64) OS_ARCH="amd64" ;;
            *) die "This architecture is not supported."
        esac
    fi

    echo >&1 "Architecture: $OS_ARCH"
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
        else
            die "The package manager is not supported."
        fi
    done
}

load_os_info() {
    if [ ! -r /etc/os-release ]; then
        die "The file /etc/os-release is not readable."
    fi

    # shellcheck source=/dev/null
    . /etc/os-release
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

# debian/ubuntu
# https://xanmod.org
xanmod_install() {
    local XANMOD_VERSION XANMOD_KEYRING XANMOD_APTLIST

    # https://gitlab.com/xanmod/linux
    XANMOD_VERSION="$(curl -L https://dl.xanmod.org/check_x86-64_psabi.sh | awk -f - 2>/dev/null | awk -F 'x86-64-v' '{v=$2+0; if(v==4)v=3; print v}')"
    XANMOD_KEYRING="/etc/apt/keyrings/xanmod-archive-keyring.gpg"
    XANMOD_APTLIST="/etc/apt/sources.list.d/xanmod-release.list"

    dpkg -s gnupg >/dev/null 2>&1 || install_pkg gnupg
    curl -L https://dl.xanmod.org/archive.key | gpg --dearmor -vo "$XANMOD_KEYRING"
    echo "deb [signed-by=$XANMOD_KEYRING] http://deb.xanmod.org $VERSION_CODENAME main" | tee "$XANMOD_APTLIST"
    if [[ -n "$XANMOD_VERSION" && "$XANMOD_VERSION" =~ ^[0-9]$ ]]; then
        install_pkg "linux-xanmod-x64v$XANMOD_VERSION"
    fi
    rm -f "$XANMOD_APTLIST" || true
    update-grub
}

## 主程序入口
clear
linux_logo
check_root
check_bash
check_arch
load_os_info

while true; do
    -h | --help)
        show_usage
    ;;
    -x | --debug)
        set -x
        shift
    ;;
    *)
        echo "Unexpected option: $1"
        show_usage
    ;;
done

xanmod_install
