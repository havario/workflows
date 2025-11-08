#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

# Thanks:
# https://www.nodeseek.com/post-499781-1

_red() { printf "\033[31m%b\033[0m" "$*"; }
_green() { printf "\033[92m%b\033[0m" "$*"; }
_yellow() { printf "\033[93m%b\033[0m" "$*"; }
_err_msg() { printf "\033[41m\033[1mError\033[0m %b" "$*"; }
_suc_msg() { printf "\033[42m\033[1mSuccess\033[0m %b" "$*"; }
_info_msg() { printf "\033[43m\033[1mInfo\033[0m %b" "$*"; }

# 各变量默认值
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"

clear() {
    [ -t 1 ] && tput clear 2>/dev/null || printf "\033[2J\033[H" || command clear
}

curl() {
    local RET
    # 添加 --fail 不然404退出码也为0
    # 32位cygwin已停止更新, 证书可能有问题, 添加 --insecure
    # centos7 curl 不支持 --retry-connrefused --retry-all-errors 因此手动 retry
    for ((i=1; i<=5; i++)); do
        command curl --connect-timeout 10 --fail --insecure "$@"
        RET="$?"
        if [ "$RET" -eq 0 ]; then
            return
        else
            # 403 404 错误或达到重试次数
            if [ "$RET" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$RET"
            fi
            sleep 1
        fi
    done
}

# reddit无需登录即可访问
check_reddit() {
    local RESULT
    RESULT="$(curl -Ls -o /dev/null -w %{http_code} --user-agent "$USER_AGENT" https://www.reddit.com)"
    case "$RESULT" in
        '200') echo -en "\r Reddit:\t\t\t $(_green 'Yes')\n" ;;
        '403') echo -en "\r Reddit:\t\t\t $(_red 'No')\n" ;;
        *) echo -en "\r Reddit:\t\t\t $(_red "Failed (Error: $RESULT)")\n" ;;
    esac
}

# imgur图片非压缩缩略图 部分机房ip看到的是缩略图 而非原图
check_imgur() {
    local RESULT HTTP_CODE CONTENT_LEN
    RESULT="$(curl -Ls -I --user-agent "$USER_AGENT" https://i.imgur.com/cJh4ed2.jpeg)"
    HTTP_CODE="$(head -n1 <<< "$RESULT" | awk '{print $2}')"
    CONTENT_LEN="$(grep -Ei "^content-length" <<< "$RESULT" | awk '{print $2}' | tr -cd '0-9')"

    case "$HTTP_CODE" in
        '200')
            if [ -z "$CONTENT_LEN" ]; then
                echo -en "\r Imgur:\t\t\t\t $(_red 'No')\n"
            elif [ "$CONTENT_LEN" -gt 307200 ]; then
                echo -en "\r Imgur:\t\t\t\t $(_green 'Yes')\n"
            else
                echo -en "\r Imgur:\t\t\t\t $(_red 'No')\n"
            fi
        ;;
        '403') echo -en "\r Imgur:\t\t\t\t $(_red 'No')\n" ;;
        *) echo -en "\r Imgur:\t\t\t\t $(_red "Failed (Error: $HTTP_CODE)")\n" ;;
    esac
}

clear
check_reddit
check_imgur
