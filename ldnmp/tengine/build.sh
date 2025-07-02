#!/bin/bash
#
# Description: This script is used to builds and publishes the latest version of the tengine image.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# SPDX-License-Identifier: Apache-2.0

TENGINE_LVER="$(wget -qO- --tries=50 https://api.github.com/repos/alibaba/tengine/releases | sed -n 's/.*"tag_name": *"\(tengine-\|\)\([^"]*\)".*/\2/p' | sort -Vr | head -n1)"
HEADERSMORE_LVER="$(wget -qO- --tries=50 https://api.github.com/repos/openresty/headers-more-nginx-module/tags | sed -n 's/.*"name": *"v\{0,1\}\([^"]*\)".*/\1/p' | grep -v 'rc' | sort -Vr | head -n1)"
# TONGSUO_LVER="$(wget -qO- --tries=50 https://api.github.com/repos/Tongsuo-Project/Tongsuo/tags | sed -n 's/.*"name": *"\([^"]*\)".*/\1/p' | grep -v 'pre' | sort -Vr | head -n1)"
# XQUIC_LVER="$(wget -qO- --tries=50 https://api.github.com/repos/alibaba/xquic/releases | sed -n 's/.*"tag_name": *"\(v[^"]*\)".*/\1/p' | sort -Vr | head -n1 | sed 's/^v//')"

# docker build --no-cache \
#     --progress=plain \
#     --build-arg TENG_LVER="$TENGINE_LVER" \
#     --build-arg MORE_LVER="$HEADERSMORE_LVER" \
#     --build-arg TONGSUO_LVER="$TONGSUO_LVER" \
#     --build-arg XQUIC_LVER="$XQUIC_LVER" \
#     -t honeok/tengine:"$TENGINE_LVER" .

# stable tongsuo and xquic version
docker build --no-cache \
    --progress=plain \
    --build-arg TENG_LVER="$TENGINE_LVER" \
    --build-arg MORE_LVER="$HEADERSMORE_LVER" \
    -t honeok/tengine:"$TENGINE_LVER" .

docker push honeok/tengine:"$TENGINE_LVER"

docker system prune -af --volumes