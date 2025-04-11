#!/usr/bin/env sh
#
# Description: entrypoint script to perform parameter checks and start the x-ui service.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/233boy/sing-box
# https://github.com/yonggekkk/sing-box-yg
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

workdir="/usr/local/bin"
usernameTemp=$(head -c 6 /dev/urandom | base64)
passwdTemp=$(head -c 6 /dev/urandom | base64)

gen_port() {
    is_count=0
    is_used_port=''

    is_test() {
        [ ! "$is_used_port" ] && is_used_port=$(netstat -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)
        echo "$is_used_port" | sed 's/ /\n/g' | grep ^"${1}"$
        return
    }

    while :; do
        is_count=$((is_count + 1))
        if [ "$is_count" -ge 5 ]; then
            printf "Error: no free port found after 5 attempts.\n" >&2 && exit 1
        fi
        temp_port=$(shuf -i 10000-65535 -n 1)
        [ ! "$(is_test "$temp_port")" ] && { panel_port="$temp_port"; break; }
    done
}

cd "$workdir" || { printf "Error: Failed to enter the x-ui work directory!\n"; exit 1; }

if [ ! -f "/etc/x-ui/x-ui.db" ]; then
    if [ -z "$USER_NAME" ] || [ -z "$USER_PASSWORD" ]; then
        xray-ui setting -username "$usernameTemp" -password "$passwdTemp"
        printf ""
    fi
    if [ -z "$PANEL_PORT" ]; then
        gen_port
        xray-ui setting -port "$panel_port"
    fi
else
    if [ -n "$USER_NAME" ] || [ -n "$USER_PASSWORD" ]; then
        xray-ui setting -username "$USER_NAME" -password "$USER_PASSWORD"
    fi
    if [ -n "$PANEL_PORT" ]; then
        xray-ui setting -port "$PANEL_PORT"
    fi
fi

if [ "$#" -eq 0 ]; then
    exec xray-ui run
else
    exec "$@"
fi