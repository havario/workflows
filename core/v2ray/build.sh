#!/usr/bin/env sh
#
# Description: This script is used to build the v2ray docker image and configure the basic operating environment.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set -eux

build_v2ray() {
    if ! git clone --depth=1 --branch "$VERSION" https://github.com/v2fly/v2ray-core.git v2ray; then
        printf 'Error: Failed to clone the project branch.\n' >&2; exit 1
    fi
    cd v2ray || { printf 'Error: permission denied or directory does not exist\n' >&2; exit 1; }

    EXTRA_ARG=""
    case "$(go env GOOS)-$(go env GOARCH)" in
        linux-amd64|linux-arm64)
            EXTRA_ARG="-buildmode=pie"
        ;;
    esac
    go build "$EXTRA_ARG" -v -trimpath -ldflags "-s -w -buildid=" -o /go/bin/v2ray ./main
}

case "$1" in
    stable)
        VERSION="$(wget -qO- --tries 5 "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | grep '"tag_name"' | cut -d '"' -f4)"
    ;;
    pre)
        VERSION="$(wget -qO- --tries 5 "https://api.github.com/repos/v2fly/v2ray-core/releases" | sed -n '/"tag_name"/{s/.*: "\(.*\)".*/\1/;h}; /"prerelease": true/{g;p;q}')"
    ;;
    *)
        printf 'Error: Unable to determine v2ray version!\n' >&2; exit 1
    ;;
esac

build_v2ray