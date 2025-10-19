# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2024-2025 honeok <i@honeok.com>
#
# Description: This dockerfile is used to add third-party modules to nginx and recompile the nginx web server.
#
# References:
# https://github.com/kejilion/docker
# https://github.com/google/ngx_brotli
# https://github.com/facebook/zstd
# https://github.com/nginx/nginx-acme
# https://github.com/owasp-modsecurity
# https://coreruleset.org/docs

ARG NGX_VERSION=""

FROM alpine:latest AS builder

LABEL maintainer="honeok <i@honeok.com>"

ARG NGX_VERSION=""
ARG ZSTD_VERSION=""
ARG HEADERS_MORE_TAG=""
ARG ACME_VERSION=""

RUN set -ex \
# https://github.com/owasp-modsecurity/ModSecurity/blob/v3/master/configure.ac
    && apk add --update --no-cache --virtual .build-deps \
        autoconf \
        automake \
        brotli-dev \
        build-base \
        cargo \
        clang-dev \
        curl \
        curl-dev \
        geoip-dev \
        git \
        libtool \
        libxml2-dev \
        lmdb-dev \
        linux-headers \
        lua5.1-dev \
        make \
        openssl-dev \
        pcre2-dev \
        pkgconfig \
        rust \
        yajl-dev \
        zlib-dev \
    && cd /tmp \
    && curl -Ls https://github.com/nginx/nginx/releases/download/release-${NGX_VERSION}/nginx-${NGX_VERSION}.tar.gz -o nginx-${NGX_VERSION}.tar.gz \
    && tar fxz nginx-${NGX_VERSION}.tar.gz \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli \
    && curl -Ls https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz -o zstd-${ZSTD_VERSION}.tar.gz \
    && tar fxz zstd-${ZSTD_VERSION}.tar.gz \
    && cd zstd-${ZSTD_VERSION} \
    && make clean \
    && CFLAGS="-fPIC" make -j$(getconf _NPROCESSORS_ONLN) \
    && make -j$(getconf _NPROCESSORS_ONLN) install \
    && cd /tmp \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
    && curl -Ls https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_TAG}.tar.gz -o v${HEADERS_MORE_TAG}.tar.gz \
    && tar fxz v${HEADERS_MORE_TAG}.tar.gz \
    && curl -Ls https://github.com/nginx/nginx-acme/releases/download/v${ACME_VERSION}/nginx-acme-${ACME_VERSION}.tar.gz -o nginx-acme-${ACME_VERSION}.tar.gz \
    && tar fxz nginx-acme-${ACME_VERSION}.tar.gz \
    && git clone --depth 1 https://github.com/owasp-modsecurity/ModSecurity \
    && cd ModSecurity \
    && git submodule init \
    && git submodule update \
    && ./build.sh \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make -j$(getconf _NPROCESSORS_ONLN) install \
    && cd /tmp \
    && git clone https://github.com/owasp-modsecurity/ModSecurity-nginx \
    && cd nginx-${NGX_VERSION} \
    && ./configure \
        --with-compat \
        --with-http_ssl_module \
        --add-dynamic-module=../ngx_brotli \
        --add-dynamic-module=../zstd-nginx-module \
        --add-dynamic-module=../headers-more-nginx-module-${HEADERS_MORE_TAG} \
        --add-dynamic-module=../nginx-acme-${ACME_VERSION} \
        --add-dynamic-module=../ModSecurity-nginx \
    && make modules \
    && strip objs/*.so \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*

FROM nginx:${NGX_VERSION}-alpine AS dist

LABEL maintainer="honeok <i@honeok.com>"

ARG NGX_VERSION=""
ARG CORERULESET_VERSION=""

COPY --from=builder /tmp/nginx-${NGX_VERSION}/objs/*.so /usr/lib/nginx/modules
COPY --from=builder /usr/local/modsecurity/lib/* /usr/local/modsecurity/lib/
COPY html /usr/share/nginx/html

RUN set -ex \
    && apk add --update --no-cache \
        lmdb \
        lua5.1 \
        yajl \
    && mkdir /etc/nginx/modsec \
    && cd /tmp \
    && curl -Ls https://github.com/coreruleset/coreruleset/archive/v${CORERULESET_VERSION}.tar.gz -o v${CORERULESET_VERSION}.tar.gz \
    && tar fxz v${CORERULESET_VERSION}.tar.gz --strip-components=1 -C /etc/nginx/modsec \
    && mv /etc/nginx/modsec/crs-setup.conf.example /etc/nginx/modsec/crs-setup.conf \
    && printf "%s\n" \
    "SecAction \\" \
    "    \"id:900110,\\" \
    "    phase:1,\\" \
    "    pass,\\" \
    "    setvar:tx.inbound_anomaly_score_threshold=30,\\" \
    "    setvar:tx.outbound_anomaly_score_threshold=16\"" >> /etc/nginx/modsec/crs-setup.conf \
    && curl -Ls https://github.com/owasp-modsecurity/ModSecurity/raw/v3/master/modsecurity.conf-recommended -o /etc/nginx/modsec/modsecurity.conf \
    && sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf \
# https://github.com/SpiderLabs/owasp-modsecurity-crs/issues/656
    && sed -i 's/SecPcreMatchLimit [0-9]\+/SecPcreMatchLimit 20000/' /etc/nginx/modsec/modsecurity.conf \
    && sed -i 's/SecPcreMatchLimitRecursion [0-9]\+/SecPcreMatchLimitRecursion 20000/' /etc/nginx/modsec/modsecurity.conf \
# https://blog.wpsec.com/wordpress-modsecurity-waf
    && sed -i 's/^SecRequestBodyLimit\s\+[0-9]\+/SecRequestBodyLimit 16777216/' /etc/nginx/modsec/modsecurity.conf \
    && sed -i 's/^SecRequestBodyNoFilesLimit\s\+[0-9]\+/SecRequestBodyNoFilesLimit 524288/' /etc/nginx/modsec/modsecurity.conf \
    && sed -i 's/^SecAuditEngine RelevantOnly/SecAuditEngine Off/' /etc/nginx/modsec/modsecurity.conf \
    && echo 'Include /etc/nginx/modsec/crs-setup.conf' >> /etc/nginx/modsec/modsecurity.conf \
    && echo 'Include /etc/nginx/modsec/plugins/*-config.conf' >> /etc/nginx/modsec/modsecurity.conf \
    && echo 'Include /etc/nginx/modsec/plugins/*-before.conf' >> /etc/nginx/modsec/modsecurity.conf \
    && echo 'Include /etc/nginx/modsec/rules/*.conf' >> /etc/nginx/modsec/modsecurity.conf \
    && echo 'Include /etc/nginx/modsec/plugins/*-after.conf' >> /etc/nginx/modsec/modsecurity.conf \
    && curl -Ls https://github.com/owasp-modsecurity/ModSecurity/raw/v3/master/unicode.mapping -o /etc/nginx/modsec/unicode.mapping \
    && curl -Ls https://m.360buyimg.com/i/jfs/t1/338259/3/13529/2356/68cfeb12F04f8452e/5edd63c5e68fc7fa.webp -o /usr/share/nginx/html/favicon.ico \
    && ldconfig /usr/local/modsecurity/lib \
    && rm -rf /var/cache/apk/* /tmp/* /etc/nginx/modsec/*.md /etc/nginx/modsec/docs /etc/nginx/modsec/LICENSE /etc/nginx/modsec/*.json \
    && find /etc/nginx/modsec/ -maxdepth 1 -name ".*" ! -name "." ! -name ".." -exec rm -rf {} \;
