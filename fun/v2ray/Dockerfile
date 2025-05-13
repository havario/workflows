# Description: build a lightweight v2ray image on alpine linux.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/v2fly/docker
# https://github.com/teddysun/across
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

FROM golang:1-alpine AS builder

WORKDIR /go/src

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache --virtual .build-deps \
            build-base \
            curl \
            git \
        && TAG=$(curl -fsL --retry 5 "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
        && git clone --depth=1 --branch "$TAG" https://github.com/v2fly/v2ray-core.git \
        && cd v2ray-core \
        && CGO_ENABLED=0 GOOS=linux go build -v -trimpath -ldflags="-s -w -buildid=" -o /go/bin/v2ray ./main \
        && cd .. \
        && apk del .build-deps \
        && rm -rf /var/cache/apk/* /tmp/*

FROM alpine:latest

COPY --from=builder /go/bin/v2ray /usr/bin/v2ray

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache \
            ca-certificates \
            curl \
            tzdata \
        && mkdir -p /usr/share/v2ray /var/log/v2ray \
        && curl -fsL -o /usr/share/v2ray/geoip.dat "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" \
        && curl -fsL -o /usr/share/v2ray/geosite.dat "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" \
        && curl -fsL -o /usr/share/v2ray/geoip-only-cn-private.dat "https://github.com/v2fly/geoip/releases/latest/download/geoip-only-cn-private.dat" \
        && rm -rf /var/cache/apk/* /tmp/*

ENV TZ=Asia/Shanghai

ENTRYPOINT ["/usr/bin/v2ray"]