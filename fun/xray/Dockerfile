# Description: build a lightweight xray image on alpine linux.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/233boy/Xray
# https://github.com/teddysun/across
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

FROM alpine:latest AS builder

COPY xray.sh .

RUN set -ex \
        && apk update \
        && apk add --no-cache \
            curl \
        && chmod +x xray.sh && ./xray.sh \
        && rm -f xray.sh

FROM alpine:latest

COPY --from=builder /tmp/xray/xray /etc/xray/bin/xray
COPY config.json /etc/xray/config.json

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache \
            ca-certificates \
            curl \
            tzdata \
        && chmod +x docker-entrypoint.sh \
        && chmod +x build.sh && ./build.sh \
        && rm -f build.sh \
        && curl -fsL -o /etc/xray/bin/geoip.dat "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" \
        && curl -fsL -o /etc/xray/bin/geosite.dat "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" \
        && rm -rf /var/cache/apk/* /tmp/* \
        && ln -sf /dev/stdout /var/log/xray/access.log

ENV TZ=Asia/Shanghai

ENTRYPOINT [ "/docker-entrypoint.sh" ]