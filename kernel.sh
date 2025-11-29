#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

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

# debian/ubuntu
# https://xanmod.org

xanmod_install() {
    local XANMOD_VER VERSION_CODE

    # https://gitlab.com/xanmod/linux
    XANMOD_VER="$(curl -L https://dl.xanmod.org/check_x86-64_psabi.sh | awk -f - 2>/dev/null | awk -F 'x86-64-v' '{v=$2+0; if(v==4)v=3; print v}')"
    VERSION_CODE="$(grep "^VERSION_CODENAME" /etc/os-release | cut -d= -f2)"

    pkg_install gnupg
    curl -Ls https://dl.xanmod.org/archive.key | gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg --yes
}

## 主程序入口
