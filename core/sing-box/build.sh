#!/usr/bin/env sh
#
# Description: This script is used to build Sing-box binary files for multiple architectures.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set -eux

# Run default path
SINGBOX_WORKDIR="/etc/sing-box"
SINGBOX_BINDIR="$SINGBOX_WORKDIR/bin"
SINGBOX_CONFDIR="$SINGBOX_WORKDIR/conf"
SINGBOX_LOGDIR="/var/log/sing-box"
SINGBOX_LOGFILE="$SINGBOX_LOGDIR/access.log"

command -v curl >/dev/null 2>&1 || apk add --no-cache curl

# Sing-box version adaptation
case "$1" in
    stable)
        VERSION="$(curl -fsL --retry 5 "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | awk -F '["v]' '/tag_name/{print $5}')"
    ;;
    beta)
        VERSION="$(curl -fsL --retry 5 "https://api.github.com/repos/SagerNet/sing-box/releases" | awk -F '"' '/tag_name/ && /-beta/ {sub(/^v/, "", $4); print $4}' | sort -Vr | head -n1)"
    ;;
    alpha)
        VERSION="$(curl -fsL --retry 5 "https://api.github.com/repos/SagerNet/sing-box/releases" | awk -F '"' '/tag_name/ && /-alpha/ {sub(/^v/, "", $4); print $4}' | sort -Vr | head -n1)"
    ;;
    *)
        printf 'Error: Unable to determine Sing-box version!\n' >&2; exit 1;
    ;;
esac

# JQ version adaptation
JQ_VERSION="$(curl -fsL --retry 5 "https://api.github.com/repos/jqlang/jq/releases/latest" | grep '"tag_name":' | cut -d '"' -f4)"

# Determine system arch based
case "$(uname -m)" in
    i*86 | x86)
        SINGBOX_FRAMEWORK="386" # 32-bit x86
        JQ_FRAMEWORK="i386"
    ;;
    x86_64 | amd64)
        SINGBOX_FRAMEWORK="amd64" # 64-bit x86
        JQ_FRAMEWORK="amd64"
    ;;
    armv6*)
        SINGBOX_FRAMEWORK="armv6" # ARMv6
        JQ_FRAMEWORK="armel"
    ;;
    armv7*)
        SINGBOX_FRAMEWORK="armv7" # 32-bit ARM
        JQ_FRAMEWORK="armhf"
    ;;
    arm64 | aarch64)
        SINGBOX_FRAMEWORK="arm64" # 64-bit ARM
        JQ_FRAMEWORK="arm64"
    ;;
    ppc64le)
        SINGBOX_FRAMEWORK="ppc64le" # PowerPC 64-bit
        JQ_FRAMEWORK="ppc64el"
    ;;
    riscv64)
        SINGBOX_FRAMEWORK="riscv64" # RISC-V 64-bit
        JQ_FRAMEWORK="riscv64"
    ;;
    s390x)
        SINGBOX_FRAMEWORK="s390x" # IBM S390x
        JQ_FRAMEWORK="s390x"
    ;;
    *)
        printf "Error: unsupported architecture: %s\n" "$(uname -m)" >&2; exit 1
    ;;
esac

# Create necessary directories
mkdir -p "$SINGBOX_WORKDIR" "$SINGBOX_BINDIR" "$SINGBOX_CONFDIR" "$SINGBOX_LOGDIR" >/dev/null 2>&1
touch "$SINGBOX_LOGFILE" >/dev/null 2>&1

cd "$SINGBOX_BINDIR" || { printf 'Error: Failed to enter the sing-box bin directory!\n'; exit 1; }

# Extract and install Sing-Box
if ! curl -fsL -O "https://github.com/SagerNet/sing-box/releases/download/v$VERSION/sing-box-$VERSION-linux-$SINGBOX_FRAMEWORK.tar.gz"; then
    printf 'Error: Download sing-Box failed, please check the network!\n' >&2; exit 1
fi

tar -zxf "sing-box-$VERSION-linux-$SINGBOX_FRAMEWORK.tar.gz" --strip-components=1 || { printf 'Error: tar Sing-box package failed!\n'; exit 1; }
find . -mindepth 1 -maxdepth 1 ! -name 'sing-box' -exec rm -rf {} +
[ ! -x "$SINGBOX_BINDIR/sing-box" ] && chmod +x "$SINGBOX_BINDIR/sing-box"
ln -s "$SINGBOX_BINDIR/sing-box" /usr/local/bin/sing-box

# Install JQ
if ! curl -fsL "https://github.com/jqlang/jq/releases/download/$JQ_VERSION/jq-linux-$JQ_FRAMEWORK" -o /usr/bin/jq; then
    printf 'Error: Download jq failed, please check the network!\n' >&2; exit 1
fi
[ ! -x /usr/bin/jq ] && chmod +x /usr/bin/jq