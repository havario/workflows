#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2025 honeok <i@honeok.com>

set -eEuo pipefail

curl() {
    local EXIT_CODE

    # --fail             4xx/5xx返回非0
    # --insecure         兼容旧平台证书问题
    # --connect-timeout  连接超时保护
    # CentOS7 无法使用 --retry-connrefused 和 --retry-all-errors 因此手动 retry

    for ((i=1; i<=50; i++)); do
        if ! command curl --connect-timeout 10 --fail --insecure -Ls "$@"; then
            EXIT_CODE=$?
            # 403 404 错误或达到重试次数
            if [ "$EXIT_CODE" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$EXIT_CODE"
            fi
            sleep 1
        else
            return
        fi
    done
}

curl "$@"
