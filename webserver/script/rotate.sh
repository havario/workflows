#!/bin/bash

set -eEuo pipefail

# 各变量默认值
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BOT_TOKEN=""
CHAT_ID=""
BARK_TOKEN=""

# 设置PATH环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
# 环境变量用于在debian或ubuntu操作系统中设置非交互式 (noninteractive) 安装模式
export DEBIAN_FRONTEND=noninteractive

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

check_root() {
    if [ "$EUID" -ne 0 ] || [ "$(id -ru)" -ne 0 ]; then
        die "This script must be run as root."
    fi
}

check_cmd() {
    local -a INSTALL_PKG
    INSTALL_PKG=("curl" "gzip")

    for pkg in "${INSTALL_PKG[@]}"; do
        if ! _exists "$pkg" >/dev/null 2>&1; then
            pkg_install "$pkg"
        fi
    done
}

check_srv() {
    local -a WEB_SRV
    WEB_SRV=("nginx" "openresty" "tengine")
    for ((i=0; i<${#WEB_SRV[@]}; i++)); do
        if docker ps --filter "name=${WEB_SRV[i]}" -q | grep -q .; then
            CONTAINER_NAME="${WEB_SRV[i]}"
            break
        fi
    done

    if [ -z "$CONTAINER_NAME" ]; then
        die "No matching servers found."
    fi
}

# 日志截断
log_rotate() {
    local START_TIME
    START_TIME="$(date +%Y-%m-%d)"

    cd "${SCRIPT_DIR:?}" >/dev/null 2>&1 || die "Unable to enter directory."
    mv -f logs/access.log "logs/access_$START_TIME.log" >/dev/null 2>&1
    mv -f logs/error.log "logs/error_$START_TIME.log" >/dev/null 2>&1
    docker exec "$CONTAINER_NAME" nginx -s reopen >/dev/null 2>&1
    gzip "logs/access_$START_TIME.log" >/dev/null 2>&1
    gzip "logs/error_$START_TIME.log" >/dev/null 2>&1
    find logs -type f -name "*.log.gz" -mtime +7 -exec rm {} \; >/dev/null 2>&1
}

build_msg() {
    END_TIME="$(date -u '+%Y-%m-%d %H:%M:%S' -d '+8 hours')"
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

check_root
check_cmd
check_srv
log_rotate
build_msg
send_msg
