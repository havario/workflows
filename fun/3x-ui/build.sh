#!/usr/bin/env sh
#
# Description: This script is used to build 3x-ui binary files for multiple architectures.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set \
    -o errexit \
    -o nounset

COMMANDS="curl jq"
for _CMD in $COMMANDS; do
    if ! command -v "$_CMD" >/dev/null 2>&1; then
        apk add --no-cache "$_CMD"
    fi
done

XRAY_VERSION=$(curl -fsSL "https://api.github.com/repos/XTLS/Xray-core/releases" | jq -r 'map(select(.prerelease == true)) | sort_by(.created_at) | last | .tag_name' | sed 's/^v//')
readonly XUI_VERSION XRAY_VERSION
[ -z "$XRAY_VERSION" ] && { printf "Error: Unable to obtain xray version!\n" >&2; exit 1; }

# map system architecture to framework variable
case "$(uname -m)" in
    i*86 | x86)
        XRAY_FRAMEWORK='32'
    ;;
    x86_64 | x64 | amd64)
        XRAY_FRAMEWORK='64'
    ;;
    armv6* | armv6)
        XRAY_FRAMEWORK='arm32-v6'
    ;;
    armv7* | armv7 | arm)
        XRAY_FRAMEWORK='arm32-v7a'
    ;;
    armv8* | armv8 | arm64 | aarch64)
        XRAY_FRAMEWORK='arm64-v8a'
    ;;
    s390x)
        XRAY_FRAMEWORK='s390x'
    ;;
    *)
        printf "Error: unsupported architecture: %s\n" "$(uname -m)" >&2; exit 1
    ;;
esac

cd /tmp || { printf 'Error: permission denied or directory does not exist\n' >&2; exit 1; }

if ! curl -fsSL -O "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-${XRAY_FRAMEWORK}.zip"; then
    printf 'Error: download xray failed, please check the network!\n' >&2; exit 1
fi

# Unzip xray and add execute permissions
unzip -q "Xray-linux-$XRAY_FRAMEWORK.zip" -d ./xray
if [ ! -x "xray/xray" ]; then chmod +x xray/xray; fi