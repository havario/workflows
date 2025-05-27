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
    && cd v2ray \
    && EXTRA_ARG="" \
    && case "$GOOS-$GOARCH" in \
        "linux-amd64" | "linux-arm64") \
            if [ -n "$PIE_ENABLED" ]; then \
                EXTRA_ARG="$EXTRA_ARG -buildmode=pie"; \
            fi \
            ;; \
        esac \
    && go build $EXTRA_ARG -v -trimpath -ldflags "-s -w -buildid=" -o /go/bin/v2ray ./main