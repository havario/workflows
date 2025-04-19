#!/usr/bin/env bash
#
# Description: check the status of your ip on various geo-restricted services.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
purple='\033[35m'
cyan='\033[36m'
white='\033[0m'
_red() { echo -e "$red"$*"$white"; }
_green() { echo -e "$green"$*"$white"; }
_yellow() { echo -e "$yellow"$*"$white"; }
_purple() { echo -e "$purple"$*"$white"; }
_cyan() { echo -e "$cyan"$*"$white"; }

ScriptTitle() {
    echo "--------------------- A unlock.sh Script By honeok --------------------"
    echo
    echo " $(_cyan 'bash <(curl -sL https://github.com/honeok/cross/raw/master/unlock.sh)')"
}

