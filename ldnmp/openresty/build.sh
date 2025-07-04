#!/bin/bash
#
# Description: This script is used to builds and publishes the latest version of the openresty image.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# SPDX-License-Identifier: Apache-2.0

RESTY_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/openresty/openresty/tags | grep '"name":' | sed -E 's/.*"name": *"([^"]+)".*/\1/' | sort -Vr | head -n1 | sed 's/v//')"
LUAROCKS_VERSION="$(wget -qO- --tries=5 "https://api.github.com/repos/luarocks/luarocks/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')"

_exit() {
    local ERR_CODE="$?"
    docker system prune -af --volumes 2>/dev/null
    exit "$ERR_CODE"
}

docker build --no-cache \
    --progress=plain \
    --build-arg RESTY_VERSION="$RESTY_VERSION" \
    --build-arg LUAROCKS_VERSION="$LUAROCKS_VERSION" \
    -t honeok/openresty:"$RESTY_VERSION" .

docker push honeok/openresty:"$RESTY_VERSION"