#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

ARG NEZHA_VERSION=""

FROM golang:1.21-alpine AS builder
LABEL maintainer="honeok <i@honeok.com>"
ARG NEZHA_VERSION=""
WORKDIR /go/src/github.com/nezhahq/nezha
RUN set -ex \
    && apk add --update --no-cache git \
    && git clone --depth=1 --branch ${NEZHA_VERSION} https://github.com/nezhahq/nezha.git .
COPY geoip.db /go/src/github.com/nezhahq/nezha/pkg/geoip/geoip.db
RUN set -ex \
    && go build -v -trimpath -ldflags="-s -w -buildid= -extldflags=-static" -o /go/bin/dashboard ./cmd/dashboard

FROM ghcr.io/naiba/nezha-dashboard:${NEZHA_VERSION} AS dist
LABEL maintainer="honeok <i@honeok.com>"
COPY --from=builder /go/bin/dashboard /dashboard/app