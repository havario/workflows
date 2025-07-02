# Description: This dockerfile builds a tengine containerized image for production, inheriting all compilation parameters of nginx and adding extra modules.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# References:
# https://github.com/alibaba/tengine
# https://github.com/Axizdkr/tengine
# https://github.com/TouTooNet/Tengine
# https://github.com/BoringCat/tengine-docker
# https://github.com/alibaba/xquic
# https://github.com/nginx/docker-nginx
# https://github.com/openresty/docker-openresty
# https://developer.aliyun.com/article/1078661
#
# SPDX-License-Identifier: Apache-2.0

FROM alpine:latest AS dist
LABEL maintainer="honeok <honeok@disroot.org>"

# Docker Build Arguments
ARG TONGSUO_LVER=8.3.2
ARG XQUIC_LVER=1.6.0
ARG TENG_LVER MORE_LVER

# https://github.com/alibaba/xquic
ARG XQUIC_CONFIG_OPTIONS="\
    -DXQC_ENABLE_TESTING=1 \
    -DXQC_SUPPORT_SENDMMSG_BUILD=1 \
    -DXQC_ENABLE_EVENT_LOG=1 \
    -DXQC_ENABLE_BBR2=1 \
    -DXQC_ENABLE_RENO=1 \
    -DSSL_TYPE=babassl \
    -DSSL_PATH=/usr/local/babassl \
    -DSSL_INC_PATH=/usr/local/babassl/include \
    -DSSL_LIB_PATH=/usr/local/babassl/lib/libssl.a;/usr/local/babassl/lib/libcrypto.a \
    "

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
    --with-pcre \
    --with-pcre-jit \
    --with-select_module \
    --with-poll_module \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_degradation_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
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
    --without-http_rewrite_module \
    --with-openssl-async \
    --with-http_xslt_module \
    --with-http_geoip_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_sni \
    --with-stream_geoip_module \
    --add-module=modules/ngx_http_concat_module \
    --add-module=modules/ngx_http_footer_filter_module \
    --add-module=modules/ngx_http_proxy_connect_module \
    --add-module=modules/ngx_http_reqstat_module \
    --add-module=modules/ngx_http_slice_module \
    --add-module=modules/ngx_http_sysguard_module \
    --add-module=modules/ngx_http_trim_filter_module \
    --add-module=modules/ngx_http_upstream_consistent_hash_module \
    --add-module=modules/ngx_http_upstream_dynamic_module \
    --add-module=modules/ngx_http_upstream_dyups_module \
    --add-module=modules/ngx_http_upstream_check_module \
    --add-module=modules/ngx_http_upstream_session_sticky_module \
    --add-module=modules/ngx_http_upstream_vnswrr_module \
    --add-module=modules/ngx_http_user_agent_module \
    --add-module=modules/ngx_http_xquic_module \
    --add-module=modules/ngx_multi_upstream_module \
    --add-module=modules/ngx_slab_stat \
    --add-module=modules/ngx_brotli \
    --add-module=modules/headers-more-nginx-module-${MORE_LVER} \
    "

ARG TENG_OPT_FLAGS="\
    --with-cc-opt='-Os -fstack-clash-protection -Wformat -Werror=format-security -fno-plt -g' \
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs' \
    "

ARG TENG_XQUIC_OPTIONS="\
    --with-xquic-inc="../xquic-${XQUIC_LVER}/include" \
    --with-xquic-lib="../xquic-${XQUIC_LVER}/build" \
    --with-openssl="../Tongsuo-tags-${TONGSUO_LVER}" \
    "

RUN set -ex \
# create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
# let's build binaries from the published packaging sources
    && tempDir="$(mktemp -d)" \
    && apk add --update --no-cache --virtual .build-deps \
        brotli-dev \
        build-base \
        cmake \
        gd-dev \
        geoip-dev \
        git \
        libc-dev \
        libevent-dev \
        libxslt-dev \
        linux-headers \
        openssl-dev \
        pcre-dev \
        zlib-dev \
    && apk add --no-cache \
        ca-certificates \
        curl \
    && cd $tempDir \
# See https://github.com/alibaba/tengine/blob/master/modules/ngx_http_xquic_module/README.md#%E7%BC%96%E8%AF%91
    && curl -Ls https://github.com/Tongsuo-Project/Tongsuo/archive/tags/${TONGSUO_LVER}.tar.gz -o ${TONGSUO_LVER}.tar.gz \
    && tar fxz ${TONGSUO_LVER}.tar.gz \
    && cd Tongsuo-tags-${TONGSUO_LVER} \
    && ./config --prefix=/usr/local/babassl \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install_sw \
    && cd $tempDir \
    && curl -Ls https://github.com/alibaba/xquic/archive/tags/v${XQUIC_LVER}.tar.gz -o v${XQUIC_LVER}.tar.gz \
    && tar fxz v${XQUIC_LVER}.tar.gz \
    && cd xquic-tags-v${XQUIC_LVER} \
    && mkdir -p build; cd build \
    && cmake ${XQUIC_CONFIG_OPTIONS} -DCMAKE_C_FLAGS="-Wno-error=deprecated-declarations -Wno-error=dangling-pointer" .. \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && cp libxquic.so /usr/local/lib/ \
    && cd $tempDir \
    && curl -Ls https://tengine.taobao.org/download/tengine-${TENG_LVER}.tar.gz -o tengine-${TENG_LVER}.tar.gz \
    && tar fxz tengine-${TENG_LVER}.tar.gz \
    && cd tengine-${TENG_LVER} \
    && curl -Ls https://github.com/openresty/headers-more-nginx-module/archive/v${MORE_LVER}.tar.gz -o v${MORE_LVER}.tar.gz \
    && tar fxz v${MORE_LVER}.tar.gz -C modules/ \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli modules/ngx_brotli \
    && eval ./configure ${TENG_BASE_CONFIG} ${TENG_CONFIG_OPTIONS} ${TENG_OPT_FLAGS} ${TENG_XQUIC_OPTIONS} \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && rm -f /etc/nginx/*.default \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /usr/share/nginx/html/ \
# create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d \
    && curl -Ls https://github.com/nginx/docker-nginx/raw/master/entrypoint/docker-entrypoint.sh -o /docker-entrypoint.sh \
    && curl -Ls https://github.com/nginx/docker-nginx/raw/master/entrypoint/10-listen-on-ipv6-by-default.sh -o /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh \
    && curl -Ls https://github.com/nginx/docker-nginx/raw/master/entrypoint/15-local-resolvers.envsh -o /docker-entrypoint.d/15-local-resolvers.envsh \
    && curl -Ls https://github.com/nginx/docker-nginx/raw/master/entrypoint/20-envsubst-on-templates.sh -o /docker-entrypoint.d/20-envsubst-on-templates.sh \
    && curl -Ls https://github.com/nginx/docker-nginx/raw/master/entrypoint/30-tune-worker-processes.sh -o /docker-entrypoint.d/30-tune-worker-processes.sh \
    && chmod +x /docker-entrypoint.sh /docker-entrypoint.d/* \
    && install -m 644 html/index.html /usr/share/nginx/html/ \
    && install -m 644 html/50x.html /usr/share/nginx/html/ \
    && curl -Ls https://github.com/alibaba/tengine/raw/master/docs/image/tengine-logo.png -o /usr/share/nginx/html/favicon.ico \
    && ln -s /usr/lib/nginx/modules /etc/nginx/modules \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && strip /usr/local/lib/*.so \
    && apk del --no-network .build-deps \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache $runDeps \
# Add `envsubst` for templating environment variables
    && apk add --no-cache gettext-envsubst \
# Bring in tzdata so users could set the timezones through the environment
# variables
    && apk add --no-cache tzdata \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && rm -rf /var/cache/apk/* \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ENV TZ="UTC"

COPY nginx.conf /etc/nginx/
COPY conf.d/default.conf /etc/nginx/conf.d/
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80 443

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]