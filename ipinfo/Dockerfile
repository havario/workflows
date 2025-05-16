# Description: build a lightweight resolve X-Forwarded-For header server image.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the MIT License.
# This software is provided "as is", without any warranty.

FROM python:3.13-alpine3.21
COPY ipinfo.py .
RUN apk upgrade \
    && apk add --no-cache tzdata \
    && rm -rf /var/cache/apk/* /tmp/*
EXPOSE 8000
ENV TZ=Asia/Shanghai
ENV PYTHONUNBUFFERED=1
ENTRYPOINT [ "python3", "ipinfo.py" ]
