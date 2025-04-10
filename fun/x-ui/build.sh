#!/usr/bin/env sh
#
# Description: This script is used to build x-ui binary files for multiple architectures.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/FranzKafkaYu/x-ui
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set \
    -o errexit \
    -o nounset

# FranzKafkaYu's x-ui was archived on November 14, 2024, with its latest version fixed at 0.3.4.4
# fetching the latest version via API might be my obsessive pursuit of this version-checking approach...
LATEST_VERSION=$(curl -fsSL "https://api.github.com/repos/FranzKafkaYu/x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
readonly LATEST_VERSION
[ -z "$LATEST_VERSION" ] && { printf "Error: Unable to obtain x-ui version!\n" >/dev/stderr; exit 1; }

shopt -s nocasematch
# map system architecture to framework variable
case "$(uname -m)" in
    's390x')
        FRAMEWORK='s390x'
    ;;
    'x86_64' | 'x64' | 'amd64')
        FRAMEWORK='amd64'
    ;;
    'aarch64' | 'arm64')
        FRAMEWORK='arm64'
    ;;
    *)
        printf "Error: unsupported architecture: %s\n" "$(uname -m)" >/dev/stderr; exit 1
    ;;
esac

cd /tmp || { printf 'Error: permission denied or directory does not exist\n' >/dev/stderr; exit 1; }

# Extract and install x-ui
if ! curl -fsSL -O "https://github.com/FranzKafkaYu/x-ui/releases/download/${LATEST_VERSION}/x-ui-linux-${FRAMEWORK}.tar.gz"; then
    printf 'Error: download x-ui failed, please check the network!\n' >/dev/stderr; exit 1
fi

tar -zxf "x-ui-linux-$FRAMEWORK.tar.gz" --strip-components=1
chmod +x x-ui