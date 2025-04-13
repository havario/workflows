#!/usr/bin/env bash
#
# Description: entrypoint script to perform parameter checks and start the x-ui service.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

WORKDIR="/3x-ui"

# https://www.graalvm.org/latest/reference-manual/ruby/UTF8Locale
export LANG=en_US.UTF-8

separator() { printf "%-50s\n" "-" | sed 's/\s/-/g'; }

cd "$WORKDIR" || { printf "Error: Failed to enter the 3x-ui work directory!\n"; exit 1; }

generate_string() {
    local LENGTH="$1"

    RANDOM_STRING=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w "$LENGTH" | head -n 1)
    echo "$RANDOM_STRING"
}

generate_port() {
    local IS_USED_PORT=""
    local IS_COUNT TEMP_PORT

    is_port() {
        [ ! "$IS_USED_PORT" ] && IS_USED_PORT=$(netstat -tunlp | sed -n 's/.*:\([0-9]\+\).*/\1/p' | sort -nu)
        echo "$IS_USED_PORT" | sed 's/ /\n/g' | grep ^"${1}"$
        return
    }

    for ((IS_COUNT=1; IS_COUNT<=5; IS_COUNT++)); do
        TEMP_PORT=$(shuf -i 10000-65535 -n 1)
        if [ ! "$(is_port "$TEMP_PORT")" ]; then
            WEB_PORT="$TEMP_PORT" && break
        fi
        [ "$IS_COUNT" -eq 5 ] && { printf "Error: no free port found after 5 attempts.\n" >&2; exit 1; }
    done
}

check_config() {
    if [ ! -f "/etc/x-ui/x-ui.db" ]; then
        printf "\n"
        printf "                  \033[42m\033[1m%s\033[0m\n" "login info"
        separator
        if [ -z "$USER_NAME" ] || [ -z "$USER_PASSWORD" ] || [ -z "$BASE_PATH" ]; then
            USERNAME_TEMP=$(generate_string 10)
            PASSWD_TEMP=$(generate_string 10)
            BASEPATH_TEMP=$(generate_string 15)
            3x-ui setting -username "$USERNAME_TEMP" -password "$PASSWD_TEMP" -webBasePath "$BASEPATH_TEMP"
        fi
        if [ -z "$PANEL_PORT" ]; then
            generate_port
            3x-ui setting -port "$WEB_PORT"
        fi
        if [ -n "$USER_NAME" ] && [ -n "$USER_PASSWORD" ] && [ -n "$BASE_PATH" ]; then
            3x-ui setting -username "$USER_NAME" -password "$USER_PASSWORD" -webBasePath "$BASEPATH_TEMP"
        fi
        if [ -n "$PANEL_PORT" ]; then
            3x-ui setting -port "$PANEL_PORT"
        fi
        3x-ui migrate
        separator
        printf "\n"
    fi
}

check_config

if [ "$#" -eq 0 ]; then
    exec "3x-ui"
else
    exec "$@"
fi