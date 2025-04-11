#!/usr/bin/env sh
#
# Description: entrypoint script to perform parameter checks and start the x-ui service.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/233boy/sing-box
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

workdir="/usr/local/bin"
usernameTemp=$(head -c 6 /dev/urandom | base64)
passwdTemp=$(head -c 6 /dev/urandom | base64)

# https://www.graalvm.org/latest/reference-manual/ruby/UTF8Locale
export LANG=en_US.UTF-8

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
        [ ! "$(is_test "$temp_port")" ] && { web_port="$temp_port"; break; }
    done
}

cd "$workdir" || { printf "Error: Failed to enter the x-ui work directory!\n"; exit 1; }

if [ ! -f "/etc/x-ui/x-ui.db" ]; then
    if [ -z "$USER_NAME" ] || [ -z "$USER_PASSWORD" ]; then
        xray-ui setting -username "$usernameTemp" -password "$passwdTemp" >/dev/null 2>&1
        printf "面板登录用户名: %s\n" "$usernameTemp" >/dev/stdout
        printf "面板登录用户密码: %s\n" "$passwdTemp" >/dev/stdout
    fi
    if [ -z "$PANEL_PORT" ]; then
        gen_port
        xray-ui setting -port "$web_port" >/dev/null 2>&1
        printf "面板登录端口: %s\n" "$web_port" >/dev/stdout
    fi
    if [ -n "$USER_NAME" ] && [ -n "$USER_PASSWORD" ]; then
        xray-ui setting -username "$USER_NAME" -password "$USER_PASSWORD" >/dev/null 2>&1
        printf "面板登录用户名: %s\n" "$USER_NAME" >/dev/stdout
        printf "面板登录用户密码: %s\n" "$USER_PASSWORD" >/dev/stdout
    fi
    if [ -n "$PANEL_PORT" ]; then
        xray-ui setting -port "$PANEL_PORT" >/dev/null 2>&1
        printf "面板登录端口: %s\n" "$PANEL_PORT" >/dev/stdout
    fi
fi

if [ "$#" -eq 0 ]; then
    exec sh -c "xray-ui run"
else
    exec "$@"
fi