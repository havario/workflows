#!/bin/bash
#
# Description: This script is used to builds and publishes the latest version of the tengine image.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# SPDX-License-Identifier: Apache-2.0

set -eE

START_TIME="$(date +%s)"

TENGINE_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/alibaba/tengine/releases | sed -n 's/.*"tag_name": *"\(tengine-\|\)\([^"]*\)".*/\2/p' | sort -Vr | head -n1)"
ZSTD_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/facebook/zstd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')"
HEADERSMORE_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/openresty/headers-more-nginx-module/tags | sed -n 's/.*"name": *"v\{0,1\}\([^"]*\)".*/\1/p' | grep -v 'rc' | sort -Vr | head -n1)"

_exit() {
    local ET_CODE="$?"
    docker system prune -af --volumes 2>/dev/null
    echo 2>&1 "Total execution time: $MINUTES m $SECONDS s"
    exit "$ET_CODE"
}

trap '_exit' SIGINT SIGQUIT SIGTERM EXIT

docker build --no-cache \
    --progress=plain \
    --build-arg TENGINE_VERSION="$TENGINE_VERSION" \
    --build-arg ZSTD_VERSION="$ZSTD_VERSION" \
    --build-arg HEADERSMORE_VERSION="$HEADERSMORE_VERSION" \
    --tag honeok/tengine:"$TENGINE_VERSION-alpine" \
    . && echo 2>&1 "build complete!"

docker push honeok/tengine:"$TENGINE_VERSION"

END_TIME="$(date +%s)"
DURATION=$(( END_TIME - START_TIME ))
MINUTES=$(( DURATION / 60 ))
SECONDS=$(( DURATION % 60 ))