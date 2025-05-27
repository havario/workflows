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

FROM docker.gh-proxy.com/golang:1-alpine AS builder
WORKDIR /go/src/h-ui
ARG TARGETOS TARGETARCH
ENV CGO_ENABLED=0
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
RUN set -ex \
    && apk add --no-cache build-base gcc git nodejs npm \
    && TAG=$(wget -qO- --tries=3 "https://api.github.com/repos/jonssonyan/h-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && git clone --depth=1 --branch "$TAG" "https://github.com/jonssonyan/h-ui.git" . \
    && cd frontend \
    && npm install && npm run build:prod \
    && cd .. \
    && go build -trimpath -ldflags "-s -w" -o /go/bin/h-ui ./main.go

FROM docker.gh-proxy.com/alpine:latest
LABEL maintainer="honeok <honeok@duck.com>"
RUN set -ex \
    && apk upgrade \
    && apk add --no-cache bash ca-certificates nftables tzdata \
    && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/h-ui /usr/bin/h-ui
ENV GIN_MODE=release
ENV TZ=Asia/Shanghai
ENTRYPOINT ["h-ui"]