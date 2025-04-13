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

WORKDIR /3x-ui

COPY --from=builder /tmp/x-ui/x-ui /3x-ui/3x-ui
COPY --from=builder /tmp/xray/xray /3x-ui/bin/xray-linux-${TARGETARCH}
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY x-ui.sh /usr/local/bin/x-ui

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache \
            ca-certificates \
            tzdata \
            fail2ban \
        && chmod +x /docker-entrypoint.sh /usr/local/bin/x-ui \
        && rm -f /etc/fail2ban/jail.d/alpine-ssh.conf \
        && cp -f /etc/fail2ban/jail.conf /etc/fail2ban/jail.local \
        && sed -i "s/^\[ssh\]$/&\nenabled = false/" /etc/fail2ban/jail.local \
        && sed -i "s/^\[sshd\]$/&\nenabled = false/" /etc/fail2ban/jail.local \
        && sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" /etc/fail2ban/fail2ban.conf \
        && ln -sf /3x-ui/3x-ui /usr/local/bin/3x-ui \
        && curl -fsSL -o /3x-ui/bin/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" \
        && curl -fsSL -o /3x-ui/bin/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" \
        && rm -rf /var/cache/apk/* /tmp/*

VOLUME [ "/etc/x-ui" ]

ENV TZ=Asia/Shanghai

ENTRYPOINT [ "/docker-entrypoint.sh" ]