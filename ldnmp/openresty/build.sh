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
ZSTD_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/facebook/zstd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')"

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
    --build-arg RESTY_VERSION="$RESTY_VERSION" \
    --build-arg ZSTD_VERSION="$ZSTD_VERSION" \
    --tag honeok/openresty:"$RESTY_VERSION-alpine" \
    --tag honeok/openresty:alpine \
    --push \
    .