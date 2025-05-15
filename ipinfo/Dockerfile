# Description: build a lightweight server that parses the X-Forwarded-For header.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the MIT License.
# This software is provided "as is", without any warranty.

FROM python:3.13-alpine3.21
WORKDIR /ipinfo
COPY ipinfo.py .
RUN set -ex \
    && apk update && apk upgrade \
    && apk add --no-cache \
        tzdata \
    && rm -rf /var/cache/apk/* /tmp/*
ENV TZ=Asia/Shanghai
ENTRYPOINT [ "python3", "ipinfo.py" ]