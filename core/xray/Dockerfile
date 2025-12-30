# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2025 honeok <i@honeok.com>

FROM alpine:latest AS base

FROM base AS dist
LABEL maintainer="honeok <i@honeok.com>"
ARG TARGETARCH
ARG TARGETVARIANT
ARG TZ=Asia/Shanghai
RUN set -ex \
    && apk add --no-cache --update bash ca-certificates tzdata
COPY xray-${TARGETARCH}${TARGETVARIANT} /usr/local/bin/xray
ENV TZ=$TZ
ENTRYPOINT ["xray"]
