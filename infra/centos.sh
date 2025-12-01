#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

set -eE

curl() {
    local EXIT_CODE

    # is_have_cmd curl || install_pkg curl

    # --fail             4xx/5xx返回非0
    # --insecure         兼容旧平台证书问题
    # --connect-timeout  连接超时保护
    # CentOS7 无法使用 --retry-connrefused 和 --retry-all-errors 因此手动 retry

    for ((i=1; i<=5; i++)); do
        if ! command curl --connect-timeout 10 --fail --insecure "$@"; then
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

# http://developer.aliyun.com/mirror/elrepo?spm=a2c6h.13651102.0.0.b9361b11Q0alNh
# https://www.rockylinux.cn/notes/rocky-linux-9-nei-he-sheng-ji-zhi-6.html
rhel_install() {
    local ELREPO_URL

    # 设置默认值为最新主线内核
    # lt: 长期支持的稳定内核
    # ml: 最新主线内核
    KERNEL_CHANNEL="${KERNEL_CHANNEL:-ml}"

    case "$MAJOR_VER" in
        7)
            [ "$KERNEL_CHANNEL" = "ml" ] && VERSION="6.9.7-1" || VERSION="5.4.278-1"
            ELREPO_URL="https://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS"
            for i in "" "-devel"; do
                RPM_PKG_NAME="kernel-$KERNEL_CHANNEL$i-$VERSION.el7.elrepo.x86_64.rpm"
                curl -L -O "$ELREPO_URL/$RPM_PKG_NAME"
            done
            yum localinstall -y "kernel-$KERNEL_CHANNEL"*
            # 更改内核启动顺序
            if [ -z "$GITHUB_CI" ]; then
                grub2-set-default 0
                grub2-mkconfig -o /etc/grub2.cfg
                grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
            fi
            rm -f "kernel-$KERNEL_CHANNEL"* || true
        ;;
        *)
            :
        ;;
    esac
}

rhel_install
