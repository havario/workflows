#!/usr/bin/env bash
#
# Description: This script is used to builds and publishes the latest version of the openresty image.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# SPDX-License-Identifier: Apache-2.0

set -eE

RESTY_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/openresty/openresty/tags | grep '"name":' | sed -E 's/.*"name": *"([^"]+)".*/\1/' | sort -Vr | head -n1 | sed 's/v//')"

_exit() {
    local ERR_CODE="$?"
    docker buildx prune --all --force 2>/dev/null
    docker system prune -af --volumes 2>/dev/null
    docker buildx rm -f builder 2>/dev/null
    exit "$ERR_CODE"
}

trap '_exit' SIGINT SIGQUIT SIGTERM EXIT

docker buildx create --name builder --use
docker buildx inspect --bootstrap

# If the docker-entrypoint script does not have permissions.
find ./ -type f -name "*.sh" -exec dos2unix {} \; -exec chmod +x {} \;

docker buildx build \
    --no-cache \
    --progress=plain \
    --platform linux/amd64,linux/arm64/v8 \
    -t "honeok/openresty:$RESTY_VERSION-alpine" \
    -t "honeok/openresty:alpine" \
    --push \
    .