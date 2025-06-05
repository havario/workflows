# Description: This Dockerfile is used to build the ipinfo-go query interface container image.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.24-alpine AS builder
LABEL maintainer="honeok <honeok@disroot.org>"
WORKDIR /go/src/ipinfo
COPY . .
ARG GOPROXY=""
ENV CGO_ENABLED=0
RUN set -ex \
    && apk add --no-cache build-base \
    && go build -v -trimpath -ldflags "-s -w -buildid=" -o /go/bin/ipinfo ./main

FROM alpine:latest AS dist
LABEL maintainer="honeok <honeok@disroot.org>"
WORKDIR /ipinfo
COPY --from=builder /go/bin/ipinfo /ipinfo/ipinfo
COPY --from=builder /go/src/ipinfo/*.mmdb /ipinfo/
RUN set -ex \
    && apk upgrade \
    && apk add --no-cache tzdata \
    && ln -sf /ipinfo/ipinfo /usr/bin/ipinfo \
    && wget --no-check-certificate -qO /ipinfo/favicon.ico "https://cdn.skyimg.net/up/2025/5/29/e8c32aa5.webp" \
    && rm -rf /var/cache/apk/*
ENV TZ=Asia/Shanghai
ENV GIN_MODE=release
EXPOSE 8080
ENTRYPOINT [ "ipinfo" ]