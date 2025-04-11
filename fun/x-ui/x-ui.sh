#!/usr/bin/env bash
#
# Description: 
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
_err_msg() { printf "\033[41m\033[1mError$white %s\n" "$*"; }
_suc_msg() { printf "\033[42m\033[1mSuccess$white %s\n" "$*"; }
separator() { printf "%-19s\n" "-" | sed 's/\s/-/g'; }
reading() { read -rep "$(_yellow "$1")" "$2"; }

show_status() {
    if pgrep -x "xray-ui" >/dev/null 2>&1; then
        echo "面板状态: $(_green 'Running')"
        echo "Panel Status: $(_green 'Running')"
    else
        echo "面板状态: $(_red 'Not Running')"
        echo "Panel Status: $(_red 'Not Running')"
    fi
    printf "\n"
    if [ "$(ps -ef | grep "xray-linux" | grep -v "grep" | wc -l >/dev/null 2>&1)" -eq 1 ]
        echo "Xray 状态: $(_green 'Running')"
        echo "Xray Status: $(_green 'Running')"
    else
        echo "Xray 状态: $(_red 'Not Running')"
        echo "Xray Status: $(_red 'Not Running')"
    fi
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
}

show_menu