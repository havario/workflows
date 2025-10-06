# Description:
#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

FROM alpine:latest AS deps
LABEL maintainer="honeok <i@honeok.com>"
ARG BILIUP_VERSION
RUN set -ex; \
    case "$(uname -m)" in \
        amd64|x86_64) OS_ARCH="x86_64" ;; \
        arm64|aarch64) OS_ARCH="aarch64" ;; \
    esac; \
    wget -qO- https://github.com/biliup/biliup-rs/releases/download/${BILIUP_VERSION}/biliupR-${BILIUP_VERSION}-${OS_ARCH}-linux.tar.xz | tar Jx -C /tmp --strip 1

FROM python:3.9-slim-bookworm AS dist
LABEL maintainer="honeok <i@honeok.com>"
ARG DANMAKU_VERSION
WORKDIR /app
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ffmpeg \
        git \
        nodejs \
        npm \
        tzdata \
    && git clone --depth=1 --branch ${DANMAKU_VERSION} https://github.com/SmallPeaches/DanmakuRender.git . \
    && python3 -m pip install --no-cache-dir -r requirements.txt --root-user-action=ignore \
    && python3 -m pip install --no-cache-dir quickjs --root-user-action=ignore \
    && apt-get purge -y --auto-remove git \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Shanghai
ENTRYPOINT ["python3", "-u", "main.py"]
