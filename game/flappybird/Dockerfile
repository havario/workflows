# Description: This dockerfile is used to build web game Flappy-Bird.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the Apache License, Version 2.0.
# Distributed on an "AS IS" basis, WITHOUT WARRANTIES.
# See http://www.apache.org/licenses/LICENSE-2.0 for details.

FROM nginx:stable-alpine

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -ex \
    && apk update && apk upgrade \
    && apk add --no-cache git \
    && rm -rf /usr/share/nginx/html/* \
    && cd /usr/share/nginx/html \
    && git clone --branch master --single-branch https://github.com/noanonoa/flappy-bird.git . \
    && sed -i 's|<title>Game Project 001</title>|<title>Flappy Bird</title>|' index.html \
    && curl -fsL https://flappybird.io/favicon.ico -o favicon.ico \
    && sed -i '/^worker_processes/s|^worker_processes.*$|worker_processes 1;|' /etc/nginx/nginx.conf \
    && printf "server_tokens off;\nautoindex off;\n" > /etc/nginx/conf.d/security.conf \
    && apk del git \
    && rm -rf /var/cache/apk/* /tmp/*