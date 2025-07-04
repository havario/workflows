# Description: This dockerfile builds a tengine containerized image for production, inheriting all compilation parameters of nginx and adding extra modules.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#                           <i@honeok.com>
#
# References:
# https://github.com/alibaba/tengine
# https://github.com/alibaba/xquic
# https://github.com/Axizdkr/tengine
# https://github.com/BoringCat/tengine-docker
# https://github.com/TouTooNet/Tengine
# https://github.com/nginx/docker-nginx
# https://github.com/openresty/docker-openresty
# https://github.com/facebook/zstd
# https://github.com/google/ngx_brotli
# https://developer.aliyun.com/article/1078661
#
# SPDX-License-Identifier: Apache-2.0

FROM alpine:latest AS builder

LABEL maintainer="honeok <honeok@disroot.org>"

# Docker Build Arguments
ARG TENGINE_VERSION
ARG ZSTD_VERSION

RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps \
        build-base \
        curl \
        git \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
    && cd /tmp \
    && curl -Ls https://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz -o tengine-${TENGINE_VERSION}.tar.gz \
    && tar fxz tengine-${TENGINE_VERSION}.tar.gz \
    && curl -Ls https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz -o zstd-${ZSTD_VERSION}.tar.gz \
    && tar fxz zstd-${ZSTD_VERSION}.tar.gz \
    && cd zstd-${ZSTD_VERSION} \
    && make clean \
    && CFLAGS="-fPIC" make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd /tmp \
    && git clone --depth=10 https://github.com/tokers/zstd-nginx-module.git \
    && cd tengine-${TENGINE_VERSION} \
    && ./configure \
        --with-compat \
        --add-dynamic-module=../zstd-nginx-module \
    && make \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*

FROM alpine:latest AS dist

LABEL maintainer="honeok <honeok@disroot.org>"

# Docker Build Arguments
ARG TONGSUO_VERSION=8.3.2
ARG XQUIC_VERSION=1.6.0
ARG TENGINE_VERSION
ARG HEADERSMORE_VERSION

# Copy the dynamic library file of the zstd compression module.
COPY --from=builder /tmp/tengine-${TENGINE_VERSION}/objs/*.so /usr/lib/nginx/modules/

# See CMakeLists.txt
ARG XQUIC_CONFIG_OPTIONS="\
    -DCMAKE_BUILD_TYPE=Release \
    -DGCOV=off \
    -DXQC_ENABLE_TESTING=0 \
    -DXQC_SUPPORT_SENDMMSG_BUILD=1 \
    -DXQC_ENABLE_EVENT_LOG=0 \
    -DXQC_ENABLE_BBR2=1 \
    -DXQC_DISABLE_RENO=0 \
    -DSSL_TYPE=babassl \
    -DSSL_PATH=/usr/local/babassl \
    -DSSL_INC_PATH=/usr/local/babassl/include \
    -DSSL_LIB_PATH=/usr/local/babassl/lib/libssl.a;/usr/local/babassl/lib/libcrypto.a \
    "

# https://github.com/alibaba/tengine-ingress/blob/master/images/tengine/rootfs/build.sh
ARG TENGINE_CONFIG_OPTIONS="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --user=nginx \
    --group=nginx \
    --without-select_module \
    --without-poll_module \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --without-http_upstream_keepalive_module \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-mail \
    --with-mail_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    --with-stream_sni \
    --with-compat \
    --with-jemalloc \
    --with-openssl-opt=enable-tls1_3 \
    --with-openssl-async \
    --add-module=modules/mod_config \
    --add-module=modules/mod_dubbo \
    --add-module=modules/ngx_http_concat_module \
    --add-module=modules/ngx_http_footer_filter_module \
    --add-module=modules/ngx_http_proxy_connect_module \
    --add-module=modules/ngx_http_reqstat_module \
    --add-module=modules/ngx_http_slice_module \
    --add-module=modules/ngx_http_sysguard_module \
    --add-module=modules/ngx_http_trim_filter_module \
    --add-module=modules/ngx_http_upstream_check_module \
    --add-module=modules/ngx_http_upstream_consistent_hash_module \
    --add-module=modules/ngx_http_upstream_dynamic_module \
    --add-module=modules/ngx_http_upstream_dyups_module \
    --add-module=modules/ngx_http_upstream_keepalive_module \
    --add-module=modules/ngx_http_upstream_session_sticky_module \
    --add-module=modules/ngx_http_upstream_vnswrr_module \
    --add-module=modules/ngx_http_user_agent_module \
    --add-module=modules/ngx_http_xquic_module \
    --add-module=modules/ngx_multi_upstream_module \
    --add-module=modules/ngx_slab_stat \
    --add-module=modules/ngx_brotli \
    --add-module=modules/headers-more-nginx-module-${HEADERSMORE_VERSION} \
    "

ARG TENGINE_XQUIC_OPTIONS="\
    --with-xquic-inc="../xquic-tags-v${XQUIC_VERSION}/include" \
    --with-xquic-lib="../xquic-tags-v${XQUIC_VERSION}/build" \
    --with-openssl="../Tongsuo-tags-${TONGSUO_VERSION}" \
    "

# Inherited from nginx
ARG BUILD_OPT_FLAGS="\
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
        brotli-dev \
        build-base \
        cmake \
        gd-dev \
        geoip-dev \
        git \
        jemalloc-dev \
        libc-dev \
        libevent-dev \
        libxslt-dev \
        linux-headers \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
# Bring in curl and ca-certificates to make registering on DNS SD easier
    && apk add --no-cache \
        ca-certificates \
        curl \
    && cd $tempDir \
# See https://github.com/alibaba/tengine/blob/master/modules/ngx_http_xquic_module/README.md
    && curl -Ls https://github.com/Tongsuo-Project/Tongsuo/archive/tags/${TONGSUO_VERSION}.tar.gz -o ${TONGSUO_VERSION}.tar.gz \
    && tar fxz ${TONGSUO_VERSION}.tar.gz \
    && cd Tongsuo-tags-${TONGSUO_VERSION} \
    && ./config --prefix=/usr/local/babassl \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install_sw \
    && cd $tempDir \
    && curl -Ls https://github.com/alibaba/xquic/archive/tags/v${XQUIC_VERSION}.tar.gz -o v${XQUIC_VERSION}.tar.gz \
    && tar fxz v${XQUIC_VERSION}.tar.gz \
    && cd xquic-tags-v${XQUIC_VERSION} \
    && mkdir -p build; cd build \
    && cmake ${XQUIC_CONFIG_OPTIONS} -DCMAKE_C_FLAGS="-Wno-dangling-pointer" .. \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && cp libxquic.so /usr/local/lib/ \
    && cd $tempDir \
    && curl -Ls https://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz -o tengine-${TENGINE_VERSION}.tar.gz \
    && tar fxz tengine-${TENGINE_VERSION}.tar.gz \
    && cd tengine-${TENGINE_VERSION} \
    && curl -Ls https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERSMORE_VERSION}.tar.gz -o v${HEADERSMORE_VERSION}.tar.gz \
    && tar fxz v${HEADERSMORE_VERSION}.tar.gz -C modules/ \
    && git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli modules/ngx_brotli \
    && curl -Ls https://github.com/honeok/tools/raw/master/ldnmp/tengine/patchs/ngx_xquic_intercom.patch | patch -p0 \
    && eval ./configure ${TENGINE_CONFIG_OPTIONS} ${TENGINE_XQUIC_OPTIONS} ${BUILD_OPT_FLAGS} \
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
        scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/local/lib/*.so \
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

ENV TZ=UTC

COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
# See https://github.com/nginx/docker-nginx/issues/377
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]