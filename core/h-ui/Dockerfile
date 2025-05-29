# Description: This Dockerfile is used to build the h-ui container.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# References:
# https://github.com/jonssonyan/h-ui
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

FROM golang:1-alpine AS builder
LABEL maintainer="honeok <honeok@duck.com>"
WORKDIR /go/src
ARG TARGETOS TARGETARCH
ARG GOPROXY=""
ARG VERSION
ENV CGO_ENABLED=0
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
COPY build.sh .
RUN set -ex \
    && apk add --no-cache build-base git \
    && chmod +x build.sh && ./build.sh ${VERSION} \
    && rm -rf /var/cache/apk/*

FROM alpine:latest AS dist
LABEL maintainer="honeok <honeok@duck.com>"
RUN set -ex \
    && apk upgrade \
    && apk add --no-cache bash ca-certificates nftables tzdata \
    && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/h-ui /usr/bin/h-ui
ENV TZ=Asia/Shanghai
ENV GIN_MODE=release
ENTRYPOINT ["h-ui"]