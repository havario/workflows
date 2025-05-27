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

FROM debian:stable-slim AS frontend
WORKDIR /go/src/h-ui
RUN set -ex \
    && apt-get update && apt-get install -y --no-install-recommends curl gnupg wget ca-certificates git \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs npm \
    && TAG=$(wget -qO- --tries=3 "https://api.github.com/repos/jonssonyan/h-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && git clone --depth=1 --branch "$TAG" "https://github.com/jonssonyan/h-ui.git" . \
    && cd frontend \
    && npm install && npm run build:prod

FROM golang:1-alpine AS builder
WORKDIR /go/src/h-ui
COPY --from=frontend /go/src/h-ui /go/src/h-ui
ARG TARGETOS TARGETARCH
ENV CGO_ENABLED=0
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
RUN set -ex \
    && apk add --no-cache build-base gcc git \
    && go build -trimpath -ldflags "-s -w" -o /go/bin/h-ui ./main.go

FROM alpine:latest
LABEL maintainer="honeok <honeok@duck.com>"
RUN set -ex \
    && apk upgrade \
    && apk add --no-cache bash ca-certificates nftables tzdata \
    && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/h-ui /usr/bin/h-ui
ENV TZ=Asia/Shanghai
ENTRYPOINT ["h-ui"]