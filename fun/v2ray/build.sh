#!/usr/bin/env sh
#
# Description: This script is used to build the basic operating environment for v2ray.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set -eux

# Run default path
V2RAY_WORKDIR="/etc/v2ray"
V2RAY_BINDIR="$V2RAY_WORKDIR/bin"
V2RAY_CONFDIR="$V2RAY_WORKDIR/conf"
V2RAY_LOGDIR="/var/log/v2ray"
V2RAY_ACCESS_LOG="$V2RAY_LOGDIR/access.log"
V2RAY_ERROR_LOG="$V2RAY_LOGDIR/error.log"

mkdir -p "$V2RAY_WORKDIR" "$V2RAY_BINDIR" "$V2RAY_CONFDIR" "$V2RAY_LOGDIR" >/dev/null 2>&1
touch "$V2RAY_ACCESS_LOG" "$V2RAY_ERROR_LOG" >/dev/null 2>&1
ln -sf "$V2RAY_BINDIR/v2ray" /usr/local/bin/v2ray