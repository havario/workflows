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

echo "DEBUG: $TARGETARCH $(uname -m)"

# Determine system arch based
case "$TARGETOS/$TARGETARCH" in
    linux/386 ) OS_ARCH="386" ;;
    linux/amd64 ) OS_ARCH="amd64" ;;
    linux/arm64 | linux/arm64/v8 ) OS_ARCH="arm64" ;;
    linux/arm* )
        case "$(uname -m)" in
            armv6* ) OS_ARCH="armv6" ;;
            armv7* ) OS_ARCH="armv7" ;;
            * ) printf "Error: unsupported arm architecture: %s\n" "$(uname -m)" >&2; exit 1 ;;
        esac
        ;;
    linux/ppc64le ) OS_ARCH="ppc64le" ;;
    linux/riscv64 ) OS_ARCH="riscv64" ;;
    linux/s390x ) OS_ARCH="s390x" ;;
    * ) printf "Error: unsupported architecture: %s\n" "$TARGETARCH" >&2; exit 1 ;;
esac

# Create necessary directories
mkdir -p "$SINGBOX_WORKDIR" "$SINGBOX_BINDIR" "$SINGBOX_CONFDIR" "$SINGBOX_LOGDIR" >/dev/null 2>&1
touch "$SINGBOX_LOGFILE" >/dev/null 2>&1

cd "$SINGBOX_BINDIR" || { printf "Error: Failed to enter the sing-box bin directory!\n" >&2; exit 1; }
# Extract and install Sing-Box
if ! curl -fsL -O "https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_LVER}/sing-box-${SINGBOX_LVER}-${TARGETOS}-${OS_ARCH}.tar.gz"; then
    printf "Error: Download Sing-Box failed, please check the network!\n" >&2; exit 1
fi
tar -zxf "sing-box-${SINGBOX_LVER}-${TARGETOS}-${OS_ARCH}.tar.gz" --strip-components=1 || { printf "Error: tar sing-box package failed!\n" >&2; exit 1; }
find . -mindepth 1 -maxdepth 1 ! -name 'sing-box' -exec rm -rf {} +
[ ! -x "$SINGBOX_BINDIR/sing-box" ] && chmod +x "$SINGBOX_BINDIR/sing-box"
ln -sf "$SINGBOX_BINDIR/sing-box" /usr/local/bin/sing-box