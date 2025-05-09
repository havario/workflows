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

FROM alpine:latest

COPY . .

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache \
            ca-certificates \
            curl \
            tzdata \
        && chmod +x docker-entrypoint.sh \
        && chmod +x build.sh && ./build.sh \
        && rm -f build.sh \
        && rm -rf /var/cache/apk/* /tmp/* \
        && ln -sf /dev/stdout /var/log/xray/access.log

ENV TZ=Asia/Shanghai

ENTRYPOINT [ "/docker-entrypoint.sh" ]