# SPDX-License-Identifier: Apache-2.0

# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

ARG NGX_VERSION=""
FROM nginx:${NGX_VERSION}-alpine AS dist
LABEL maintainer="honeok <i@honeok.com>"
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html
COPY favicon.ico /usr/share/nginx/html
RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps git \
    && rm -f /usr/share/nginx/html/* \
    && git clone --depth=1 https://github.com/noanonoa/flappy-bird.git /usr/share/nginx/html \
    && find /usr/share/nginx/html -maxdepth 1 \( -name ".DS_Store" -o -name ".git" -o -name "README.md" \) -exec rm -rf {} + \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*
