#!/bin/bash

set -eEuo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE:-$0}")"
BOT_TOKEN=""
CHAT_ID=""
BARK_TOKEN=""

die() {
    echo >&2 "Error: $*"; exit 1
}

curl() {
    local RET
    for ((i=1; i<=5; i++)); do
        command curl --connect-timeout 10 --fail --insecure "$@"
        RET="$?"
        if [ "$RET" -eq 0 ]; then
            return
        else
            if [ "$RET" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$RET"
            fi
            sleep 1
        fi
    done
}

send_msg() {
    local MESSAGE="$1"

    if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
        curl -Ls -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
            -H "Content-Type: application/json" \
            -d "{\"chat_id\":\"$CHAT_ID\",\"text\":\"$MESSAGE\"}" >/dev/null 2>&1
    fi
    if [ -n "$BARK_TOKEN" ]; then
        curl -Ls "https://api.honeok.de/$BARK_TOKEN/Nginx/$MESSAGE" >/dev/null 2>&1
    fi
}
