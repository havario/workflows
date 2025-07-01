# Description: 
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# References:
# https://github.com/alibaba/tengine
# https://github.com/Axizdkr/tengine
# https://github.com/nginx/docker-nginx
# https://developer.aliyun.com/article/1078661
#
# SPDX-License-Identifier: Apache-2.0

FROM alpine:latest AS dist
LABEL maintainer="honeok <honeok@disroot.org>"
ARG TENG_LVER MORE_LVER

ARG TENG_BASE_CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    "

ARG TENG_CONFIG_OPTIONS="\
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-openssl-opt=enable-tls1_3 \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-stream_geoip_module=dynamic \
    --add-module=modules/ngx_http_upstream_consistent_hash_module \
    --add-module=modules/ngx_http_upstream_check_module \
    --add-module=modules/headers-more-nginx-module-${MORE_LVER} \
    --add-module=modules/ngx_http_upstream_session_sticky_module \
    "

ARG TENG_OPT_FLAGS="\
    --with-cc-opt='-Os -fstack-clash-protection -Wformat -Werror=format-security -fno-plt -g' \
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs' \
    "

RUN set -ex \
# create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
# let's build binaries from the published packaging sources
    && tempDir="$(mktemp -d)" \
    && apk add --update --no-cache --virtual .build-deps \
        curl \
        findutils \
        gcc \
        geoip-dev \
        gd-dev \
        libc-dev \
        libxslt-dev \
        linux-headers \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
    && cd $tempDir \
    && curl -Ls https://tengine.taobao.org/download/tengine-${TENG_LVER}.tar.gz -o tengine-${TENG_LVER}.tar.gz \
    && tar fxz tengine-${TENG_LVER}.tar.gz \
    && cd tengine-${TENG_LVER} \
    && curl -Ls https://github.com/openresty/headers-more-nginx-module/archive/v${MORE_LVER}.tar.gz -o v${MORE_LVER}.tar.gz \
    && tar fxz v${MORE_LVER}.tar.gz -C modules/ \
    && eval ./configure ${TENG_BASE_CONFIG} ${TENG_CONFIG_OPTIONS} ${TENG_OPT_FLAGS} \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && ln -s /usr/lib/nginx/modules /etc/nginx/modules \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache $runDeps \
# Add `envsubst` for templating environment variables
    && apk add --no-cache ca-certificates curl gettext-envsubst \
    && apk del --no-network .build-deps \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443
# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]