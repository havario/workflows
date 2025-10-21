#!/bin/bash

set -eEuo pipefail

# 各变量默认值
SCRIPT_DIR="$(dirname "${BASH_SOURCE:-$0}")"
BOT_TOKEN=""
CHAT_ID=""
BARK_TOKEN=""
START_TIME="$(date +%Y-%m-%d)"

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

cd "${SCRIPT_DIR:?}" || die "Unable to enter directory."
mv -f logs/access.log "logs/access_$START_TIME.log" >/dev/null 2>&1
mv -f logs/error.log "logs/error_$START_TIME.log" >/dev/null 2>&1
docker exec nginx nginx -s reopen >/dev/null 2>&1
gzip "logs/access_$START_TIME.log" >/dev/null 2>&1
gzip "logs/error_$START_TIME.log" >/dev/null 2>&1
find logs -type f -name "*.log.gz" -mtime +7 -exec rm {} \; >/dev/null 2>&1
