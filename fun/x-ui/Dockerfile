# Description: Dockerfile to build a lightweight x-ui image on Alpine Linux.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/enwaiax/x-ui
# https://github.com/FranzKafkaYu/x-ui
# https://github.com/XTLS/Xray-core
# https://github.com/v2fly/geoip
# https://github.com/v2fly/domain-list-community
#
# Acknowledgments:
# https://github.com/teddysun
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

FROM --platform=$BUILDPLATFORM alpine:latest AS builder

COPY build.sh .

RUN set -ex \
        && apk update \
        && apk add --no-cache curl \
        && chmod +x build.sh && ./build.sh

FROM --platform=$BUILDPLATFORM alpine:latest

# https://docs.docker.com/build/building/multi-platform/
ARG TARGETARCH

COPY --from=builder /tmp/x-ui /usr/local/x-ui/x-ui
# copy the core program Xray-core
# https://github.com/teddysun/across/blob/master/docker/xray/Dockerfile
# https://docs.docker.com/build/building/multi-stage/ # Use an external image as a stage
COPY --from=teddysun/xray /usr/bin/xray /usr/local/x-ui/bin/xray-linux-${TARGETARCH}

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache \
            ca-certificates \
            curl \
            tzdata \
        && curl -fsSL -o /usr/local/x-ui/bin/geosite.dat "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" \
        && curl -fsSL -o /usr/local/x-ui/bin/geoip.dat "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" \
        && rm -rf /var/cache/apk/* /tmp/*

VOLUME [ "/etc/x-ui" ]

# default time of the container
ENV TZ=Asia/Shanghai

ENTRYPOINT [ "/usr/local/x-ui/x-ui" ]