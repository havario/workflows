# Description: This dockerfile is designed to custom compile openresty with brotli and zstandard compression support.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# SPDX-License-Identifier: Apache-2.0

# Second stage image name
ARG RESTY_LVER

FROM alpine:latest AS builder
LABEL maintainer="honeok <honeok@disroot.org>"
ARG RESTY_LVER ZSTD_LVER

RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        brotli-dev \
        build-base \
        curl \
        git \
        openssl-dev \
        pcre2-dev \
        perl \
        zlib-dev \
    && cd /tmp \
    && curl -Ls https://openresty.org/download/openresty-${RESTY_LVER}.tar.gz -o openresty-${RESTY_LVER}.tar.gz  \
    && tar fxz openresty-${RESTY_LVER}.tar.gz \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && curl -Ls https://github.com/facebook/zstd/releases/download/v${ZSTD_LVER}/zstd-${ZSTD_LVER}.tar.gz -o zstd-${ZSTD_LVER}.tar.gz \
    && tar fxz zstd-${ZSTD_LVER}.tar.gz \
    && cd zstd-${ZSTD_LVER} \
    && make clean \
    && CFLAGS="-fPIC" make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd /tmp \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
    && cd openresty-${RESTY_LVER} \
    && ./configure \
        --with-compat \
        --add-dynamic-module=../ngx_brotli \
        --add-dynamic-module=../zstd-nginx-module \
    && make \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*

FROM openresty/openresty:${RESTY_LVER}-alpine AS dist
LABEL maintainer="honeok <honeok@disroot.org>"
ARG RESTY_LVER
COPY --from=builder /tmp/openresty-${RESTY_LVER}/build/nginx-*/objs/*.so /usr/local/openresty/nginx/modules/
RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        binutils \
    && apk add --no-cache \
        curl \
    && strip /usr/local/openresty/nginx/modules/*.so \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*