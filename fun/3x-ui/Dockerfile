# Description: Dockerfile to build a lightweight 3x-ui image on Alpine Linux.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

FROM --platform=$BUILDPLATFORM alpine:latest AS builder

COPY build.sh .

RUN set -ex \
        && chmod +x build.sh && ./build.sh

FROM --platform=$BUILDPLATFORM alpine:latest

# https://docs.docker.com/build/building/multi-platform/
ARG TARGETARCH

WORKDIR /usr/local/bin

COPY --from=builder /tmp/x-ui/x-ui /usr/local/bin/3x-ui
COPY --from=builder /tmp/xray/xray /usr/local/bin/bin/xray-linux-${TARGETARCH}
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY x-ui.sh /usr/local/bin/x-ui

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache \
            bash \
            ca-certificates \
            curl \
            tzdata \
        && chmod +x /docker-entrypoint.sh /usr/local/bin/x-ui \
        && curl -fsSL -o /usr/local/bin/bin/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" \
        && curl -fsSL -o /usr/local/bin/bin/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" \
        && curl -fsSL -o /usr/local/bin/bin/geoip_IR.dat "https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geoip.dat" \
        && curl -fsSL -o /usr/local/bin/bin/geosite_IR.dat "https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geosite.dat" \
        && curl -fsSL -o /usr/local/bin/bin/geoip_RU.dat "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat" \
        && curl -fsSL -o /usr/local/bin/bin/geosite_RU.dat "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat" \
        && rm -rf /var/cache/apk/* /tmp/*

VOLUME [ "/etc/x-ui" ]

ENV TZ=Asia/Shanghai

ENTRYPOINT [ "/docker-entrypoint.sh" ]