#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

ARG NEZHA_VERSION=""

FROM golang:1.21-alpine AS builder
LABEL maintainer="honeok <i@honeok.com>"
ARG NEZHA_VERSION=""
WORKDIR /go/src/github.com/nezhahq/nezha
COPY geoip.db /go/src/geoip.db
RUN set -ex \
    && apk add --update --no-cache --virtual .build-deps curl git \
    && git clone --depth=1 --branch ${NEZHA_VERSION} https://github.com/nezhahq/nezha.git . \
    && mv /go/src/geoip.db pkg/geoip/geoip.db \
    && go build -v -trimpath -ldflags="-s -w -buildid= -extldflags=-static" -o /go/bin/dashboard ./cmd/dashboard \
    && apk del --no-network .build-deps \
    && rm -rf /var/cache/apk/*

FROM ghcr.io/naiba/nezha-dashboard:${NEZHA_VERSION} AS dist
LABEL maintainer="honeok <i@honeok.com>"
COPY --from=builder /go/bin/dashboard /dashboard/app