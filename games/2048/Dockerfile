# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

FROM nginx:${NGX_VERSION}-alpine AS dist
LABEL maintainer="honeok <i@honeok.com>"
ARG NGX_VERSION=""
RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        git \
    && rm -f /usr/share/nginx/html/* \
    && git clone --depth=1 https://github.com/gabrielecirulli/2048.git /usr/share/nginx/html \
    && find /usr/share/nginx/html -maxdepth 1 \( -name ".git" -o -name ".*" -o -name "*.md" -o -name "LICENSE*" -o -name "Rakefile" \) -exec rm -rf {} + \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*
