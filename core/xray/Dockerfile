FROM alpine:latest AS base

FROM base AS dist
LABEL maintainer="honeok <i@honeok.com>"
ARG TARGETARCH
ARG TARGETVARIANT
RUN set -ex \
    && apk add --no-cache --upgrade bash ca-certificates curl openssl tzdata
COPY xray-${TARGETARCH}${TARGETVARIANT} /usr/bin/xray
ENTRYPOINT ["xray"]
