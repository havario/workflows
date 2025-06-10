#!/usr/bin/env sh
#
# Description: This script is used to build Sing-box binary files for multiple architectures.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# SPDX-License-Identifier: GPL-2.0-only

set -eux

SINGBOX_LVER="$1"
# Run default path
SINGBOX_WORKDIR="/etc/sing-box"
SINGBOX_BINDIR="$SINGBOX_WORKDIR/bin"
SINGBOX_CONFDIR="$SINGBOX_WORKDIR/conf"
SINGBOX_LOGDIR="/var/log/sing-box"
SINGBOX_LOGFILE="$SINGBOX_LOGDIR/access.log"

command -v curl >/dev/null 2>&1 || apk add --no-cache curl

# Create necessary directories
mkdir -p "$SINGBOX_WORKDIR" "$SINGBOX_BINDIR" "$SINGBOX_CONFDIR" "$SINGBOX_LOGDIR" >/dev/null 2>&1
touch "$SINGBOX_LOGFILE" >/dev/null 2>&1

cd "$SINGBOX_BINDIR" || { printf "Error: Failed to enter the sing-box bin directory!\n"; exit 1; }
# Extract and install Sing-Box
if ! curl -fsL -O "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_LVER}/sing-box-${SINGBOX_LVER}-${TARGETOS}-${TARGETARCH}.tar.gz"; then
    printf "Error: Download sing-Box failed, please check the network!\n" >&2; exit 1
fi
tar -zxf "sing-box-${SINGBOX_LVER}-${TARGETOS}-${TARGETARCH}.tar.gz" --strip-components=1 || { printf "Error: tar Sing-box package failed!\n"; exit 1; }
find . -mindepth 1 -maxdepth 1 ! -name 'sing-box' -exec rm -rf {} +
[ ! -x "$SINGBOX_BINDIR/sing-box" ] && chmod +x "$SINGBOX_BINDIR/sing-box"
ln -s "$SINGBOX_BINDIR/sing-box" /usr/local/bin/sing-box