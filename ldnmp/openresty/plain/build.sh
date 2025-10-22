#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Description: This script is used to builds and publishes the latest version of the openresty image.
# Copyright (c) 2025 honeok <i@honeok.com>

set -eEu

START_TIME="$(date +%s)"

RESTY_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/openresty/openresty/tags | grep '"name":' | sed -E 's/.*"name": *"([^"]+)".*/\1/' | sort -rV | head -n1 | sed 's/v//')"
ZSTD_VERSION="$(wget -qO- --tries=50 https://api.github.com/repos/facebook/zstd/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')"
DOCKER_USERNAME="honeok"
DOCKER_REPO="openresty"

_exit() {
    local ET_CODE="$?"
    docker buildx prune --all --force 2>/dev/null
    docker system prune -af --volumes 2>/dev/null
    docker buildx rm -f builder 2>/dev/null
    echo 2>&1 "Total execution time: $MINUTES m $SECONDS s"
    exit "$ET_CODE"
}

trap '_exit' INT TERM EXIT

docker buildx create --name builder --use || true
docker buildx inspect --bootstrap || true

find . -type f -name "*.sh" -exec dos2unix {} \; -exec chmod +x {} \;

docker buildx build \
    --no-cache \
    --progress=plain \
    --platform linux/amd64,linux/arm64 \
    --build-arg RESTY_VERSION="$RESTY_VERSION" \
    --build-arg ZSTD_VERSION="$ZSTD_VERSION" \
    --build-arg RESTY_STRIP_BINARIES=1 \
    --tag "$DOCKER_USERNAME"/"$DOCKER_REPO":"$RESTY_VERSION-alpine" \
    --push \
    . && echo 2>&1 "build complete!"

END_TIME="$(date +%s)"
DURATION=$(( END_TIME - START_TIME ))
MINUTES=$(( DURATION / 60 ))
SECONDS=$(( DURATION % 60 ))
