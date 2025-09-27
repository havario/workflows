# Description:
#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0
#
# References:
# https://github.com/fatedier/frp
# https://github.com/vgist/dockerfiles

FROM alpine:latest AS dist

LABEL maintainer="honeok <i@honeok.com>"

ARG FRPS_VERSION=""
ARG TARGETOS
ARG TARGETARCH

RUN set -ex \
    && apk upgrade \
    && cd /tmp \
    && wget -qO- https://github.com/fatedier/frp/releases/download/v${FRPS_VERSION}/frp_${FRPS_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz | tar xz \
    && mkdir -p /etc/frp \
    && mv frp_${FRPS_VERSION}_${TARGETOS}_${TARGETARCH}/frps /usr/bin \
    && mv frp_${FRPS_VERSION}_${TARGETOS}_${TARGETARCH}/frps.toml /etc/frp \
    && rm -rf /var/cache/apk/* /tmp/*

ENTRYPOINT [ "/usr/bin/frps" ]

CMD ["-c","/etc/frp/frps.toml"]
