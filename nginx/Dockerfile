# Description: self-compiled nginx with a custom server header for branding.
#
# Copyright (C) 2025 honeok <honeok@duck.com>
#
# Licensed under the Apache License, Version 2.0.
# Distributed on an "AS IS" basis, WITHOUT WARRANTIES.
# See http://www.apache.org/licenses/LICENSE-2.0 for details.

FROM alpine:latest AS builder

# Docker Build Arguments
ARG NGX_LVER
ARG BUILD_OPTION

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache --virtual .build-deps \
            curl \
            gcc \
            libc-dev \
            linux-headers \
            make \
            openssl-dev \
            pcre2-dev \
            zlib-dev \
        && cd /tmp \
        && curl -fskL "https://nginx.org/download/nginx-${NGX_LVER}.tar.gz" -o nginx-${NGX_LVER}.tar.gz \
        && tar -zxf nginx-${NGX_LVER}.tar.gz \
        && cd nginx-${NGX_LVER} \
        && sed -i 's/\(#define\s\+NGINX_VER\s\+\)"nginx\/"\(\s\+NGINX_VERSION\)/\1"honeok\/"\2/' src/core/nginx.h \
        && sed -i 's/static u_char ngx_http_server_string\[\] = \"Server: nginx\"/static u_char ngx_http_server_string\[\] = \"Server: honeok\"/' src/http/ngx_http_header_filter_module.c \
        && sed -i 's/<center>nginx<\/center>/<center>honeok<\/center>/' src/http/ngx_http_special_response.c \
        && eval "./configure ${BUILD_OPTION}" \
        && make -j$(nproc) \
        && make install \
        && apk del .build-deps \
        && rm -rf /var/cache/apk/*

FROM nginx:alpine

COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx

COPY html /usr/share/nginx/html