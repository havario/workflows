# Description: This dockerfile is builds nezha dashboard with a new geoip database to fix correct country flag display.
#
# Copyright (c) 2025 honeok <i@honeok.com>
#
# References:
# https://github.com/naiba/nezha
#
# SPDX-License-Identifier: Apache-2.0

ARG BUILD_DATE=""
ARG NEZHA_VERSION=""

FROM golang:1.21-alpine AS builder
LABEL org.opencontainers.image.authors="honeok <i@honeok.com>" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="Apache-2.0"
ARG NEZHA_VERSION=""
WORKDIR /go/src/github.com/naiba/nezha
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE=1"
RUN set -ex \
    && apk add --update --no-cache git gcc musl-dev \
    && git clone --depth=1 --branch ${NEZHA_VERSION} https://github.com/nezhahq/nezha.git .
COPY geoip.db /go/src/github.com/naiba/nezha/pkg/geoip/geoip.db
RUN set -ex \
    && go build -v -trimpath -ldflags="\
    -s -w -buildid= \
    -X 'github.com/naiba/nezha/service/singleton.Version=${NEZHA_VERSION#v}' \
    -extldflags '-static -fpic' \
    " -o /go/bin/dashboard ./cmd/dashboard

FROM ghcr.io/naiba/nezha-dashboard:${NEZHA_VERSION} AS dist
LABEL org.opencontainers.image.authors="honeok <i@honeok.com>" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="Apache-2.0"
COPY --from=builder /go/bin/dashboard /dashboard/app