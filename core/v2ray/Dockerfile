# Description: This dockerfile is used to build the v2ray container image.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

FROM golang:1-alpine AS builder
LABEL maintainer="honeok <honeok@duck.com"
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
    && rm -rf /var/cache/apk/* /tmp/*