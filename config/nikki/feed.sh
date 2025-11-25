#!/bin/sh
# SPDX-License-Identifier: GPL-3.0
#
# Copyright (c) 2024-2025 The OpenWrt-nikki Authors. All rights reserved.
# Copyright (c) 2025 honeok <i@honeok.com>

# References:
# https://github.com/nikkinikki-org/OpenWrt-nikki

set -eu

# 各变量默认值
REPOSITORY_URL="https://nikkinikki.pages.dev"

die() {
    echo >&2 "Error: $*"; exit 1
}

_exists() {
    command -v "$@" >/dev/null 2>&1
}

if ! _exists opkg && ! _exists apk; then
    die "requires opkg or apk package manager!"
fi

if ! _exists fw4; then
    die "only supports openwrt build with firewall4!"
fi

# include
# shellcheck source=/dev/null
. /etc/openwrt_release

case "$DISTRIB_RELEASE" in
    *"23.05"*) BRANCH="openwrt-23.05" ;;
    *"24.10"*) BRANCH="openwrt-24.10" ;;
    "SNAPSHOT") BRANCH="SNAPSHOT" ;;
    *) die "unsupported release: $DISTRIB_RELEASE" ;;
esac

FEED_URL="$REPO_URL/$BRANCH/$DISTRIB_ARCH/nikki"

if _exists opkg; then
	wget --no-check-certificate -qO key-build.pub "$REPOSITORY_URL/key-build.pub"
	opkg-key add key-build.pub
	rm -f key-build.pub
	if grep -q nikki /etc/opkg/nikki.conf; then
        sed -i '/nikki/d' /etc/opkg/nikki.conf
	fi
	echo "src/gz nikki $FEED_URL" >> /etc/opkg/nikki.conf
	opkg update
    opkg install nikki
    opkg install luci-app-nikki
    opkg install luci-i18n-nikki-zh-cn
elif _exists apk; then
	wget --no-check-certificate -qO /etc/apk/keys/nikki.pem "$REPOSITORY_URL/public-key.pem"
	if grep -q nikki /etc/apk/repositories.d/nikki.list; then
        sed -i '/nikki/d' /etc/apk/repositories.d/nikki.list
    fi
    echo "$FEED_URL/packages.adb" >> /etc/apk/repositories.d/nikki.list
    apk update
    apk add nikki
    apk add luci-app-nikki
    apk add luci-i18n-nikki-zh-cn
fi

echo "success"
