#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

set -eE

die() {
    local EXIT_CODE

    EXIT_CODE="${2:-1}"

    printf >&2 'Error: %s\n' "$1"
    exit "$EXIT_CODE"
}

get_cmd_path() {
    # -f: 忽略shell内置命令和函数, 只考虑外部命令
    # -p: 只输出外部命令的完整路径
    type -f -p "$1"
}

is_have_cmd() {
    get_cmd_path "$1" >/dev/null 2>&1
}

install_pkg() {
    local PKG_MGR NEED_UP

    if is_have_cmd dnf; then
        PKG_MGR="dnf"
    elif is_have_cmd yum; then
        PKG_MGR="yum"
    elif is_have_cmd apt-get; then
        PKG_MGR="apt-get"
        NEED_UP="true"
    else
        die "No supported package manager found."
    fi

    [ "$NEED_UP" ] && "$PKG_MGR" update
    "$PKG_MGR" install -y "$@"
}

# 提取主版本号
os_version() {
    local MAIN_VER
    MAIN_VER="$(grep -oE "[0-9.]+" <<< "$VERSION_ID")"
    MAJOR_VER="${MAIN_VER%%.*}"
}

curl() {
    local EXIT_CODE

    is_have_cmd curl || install_pkg curl

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

is_china() {
    if [ -z "$COUNTRY" ]; then
        if ! COUNTRY="$(curl -L http://www.qualcomm.cn/cdn-cgi/trace | grep '^loc=' | cut -d= -f2 | grep .)"; then
            die "Can not get location."
        fi
        echo 2>&1 "Location: $COUNTRY"
    fi
    [ "$COUNTRY" = CN ]
}

# http://developer.aliyun.com/mirror/elrepo?spm=a2c6h.13651102.0.0.b9361b11Q0alNh
# https://www.rockylinux.cn/notes/rocky-linux-9-nei-he-sheng-ji-zhi-6.html
rhel_install() {
    local ELREPO_URL
    local KERNEL_CHANNEL="$1"

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
        8 | 9 | 10)
            rpm -q epel-release >/dev/null 2>&1 || install_pkg epel-release
            # 导入ELRepo GPG公钥
            # RHEL 10默认策略会拒绝旧算法key
            # error: Certificate 309BC305BAADAE52:
            rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org || true
            install_pkg --nogpgcheck "https://www.elrepo.org/elrepo-release-$MAJOR_VER.el$MAJOR_VER.elrepo.noarch.rpm"
            dnf makecache
            if is_china; then
                sed -i 's/mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/elrepo.repo
                sed -i "s#elrepo.org/linux#mirror.nju.edu.cn/elrepo#g" /etc/yum.repos.d/elrepo.repo
            fi
            install_pkg --nogpgcheck --enablerepo=elrepo-kernel "kernel-$KERNEL_CHANNEL" "kernel-$KERNEL_CHANNEL-devel"
        ;;
        *)
            die "Unsupported system version."
        ;;
    esac
}

. /etc/os-release
os_version
rhel_install
