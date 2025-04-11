#!/usr/bin/env bash
#
# Description: x-ui management panel, providing basic x-ui backend management.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/FranzKafkaYu/x-ui
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

# /usr/local/bin # ./x-ui -h
# Usage of ./x-ui:
#   -v	show version

# Commands:
#     run            run web panel
#     v2-ui          migrate form v2-ui
#     setting        set settings

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
white='\033[0m'
_red() { printf "$red%s$white\n" "$*"; }
_green() { printf "$green%s$white\n" "$*"; }
_yellow() { printf "$yellow%s$white\n" "$*"; }
separator() { printf "%-19s\n" "-" | sed 's/\s/-/g'; }
reading() { read -rep "$(_yellow "$1")" "$2"; }

WORKDIR="/usr/local/bin"
XUIBIN="$WORKDIR/xray-ui"

show_status() {
    if pgrep -x "xray-ui" >/dev/null 2>&1; then
        echo "面板状态: $(_green 'Running')"
    else
        echo "面板状态: $(_red 'Not Running')"
    fi
    printf "\n"
    if [ "$(ps -ef | grep 'xray-linux' | grep -v grep | wc -l)" -ge 1 ]; then
        echo "Xray 状态: $(_green 'Running')"
    else
        echo "Xray 状态: $(_red 'Not Running')"
    fi
}

reset_user() {
    reading '确定要将用户名和密码重置为admin吗? (y/n)' 'choose'
    case "$choose" in
        'Y' | 'y') : ;;
        *) show_menu ;;
    esac
    "$XUIBIN" setting -username admin -password admin
    echo "用户名和密码已重置为 $(_green 'admin'), 现在请重启面板"
    confirm_restart
}

show_menu() {
    printf "\n"
    _green ' x-ui 面板管理脚本'
    echo " $(_green '0.') 退出脚本"
    separator
    echo " $(_green '1.') 重置用户名密码"
    echo " $(_green '2.') 重置面板设置"
    echo " $(_green '3.') 设置面板端口"
    echo " $(_green '4.') 查看当前面板信息"
    separator
    printf "\n"
    show_status
    printf "\n"
    reading '请输入选择 [0-4], 查看面板登录信息请输入数字4' 'choose'
    case "$choose" in
        0) exit 0 ;;
        1) reset_user ;;
        *) _red '请输入正确的数字 [0-17], 查看面板登录信息请输入数字' && show_menu ;;
    esac
}

show_menu