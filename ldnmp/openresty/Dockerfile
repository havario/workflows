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
ARG RESTY_J=4

RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        brotli-dev build-base git openssl-dev pcre-dev perl zlib-dev \
    && cd /tmp \
    && wget -qO "openresty-${RESTY_LVER}.tar.gz" "https://openresty.org/download/openresty-${RESTY_LVER}.tar.gz" \
    && tar zxf "openresty-${RESTY_LVER}.tar.gz" \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && wget -qO "zstd-${ZSTD_LVER}.tar.gz" "https://github.com/facebook/zstd/releases/download/v${ZSTD_LVER}/zstd-${ZSTD_LVER}.tar.gz" \
    && tar zxf "zstd-${ZSTD_LVER}.tar.gz" \
    && cd "zstd-${ZSTD_LVER}" \
    && make clean \
    && CFLAGS="-fPIC" make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
    && cd "openresty-${RESTY_LVER}" \
    && ./configure --with-compat \
        --add-dynamic-module=../ngx_brotli \
        --add-dynamic-module=../zstd-nginx-module \
    && make -j${RESTY_J} \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

FROM openresty/openresty:${RESTY_LVER}-alpine
LABEL maintainer="honeok <honeok@disroot.org>"
ARG RESTY_LVER
COPY --from=builder /tmp/openresty-${RESTY_LVER}/build/nginx-*/objs/*.so /usr/local/openresty/nginx/modules/