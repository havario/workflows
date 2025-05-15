# Description: build a lightweight resolve X-Forwarded-For header server image.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the MIT License.
# This software is provided "as is", without any warranty.

FROM python:3.13-alpine3.21
COPY ipinfo.py /usr/local/bin/ipinfo
RUN set -ex \
    && apk update && apk upgrade \
    && chmod +x /usr/local/bin/ipinfo \
    && apk add --no-cache \
        tzdata \
    && rm -rf /var/cache/apk/* /tmp/*
ENV TZ=Asia/Shanghai
ENTRYPOINT [ "ipinfo" ]