FROM node:24.10-alpine AS builder
WORKDIR /app
COPY . .
RUN set -ex \
    && npm install \
    && npm run build

FROM python:3.14-alpine AS dist
ARG EARTHQUAKE_VERSION
ARG TZ=Asia/Shanghai
LABEL org.opencontainers.image.author="honeok <i@honeok.com>" \
    org.opencontainers.image.description="The earthquake dashboard container delivering real time visualization of global USGS seismic data." \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.source="https://github.com/honeok/tools" \
    org.opencontainers.image.title="earthquake" \
    org.opencontainers.image.version="$EARTHQUAKE_VERSION"
WORKDIR /app
COPY --from=builder /app/app.js static/app.js
COPY earthquake.py .
COPY templates/ templates/
COPY static/*.css static/
RUN set -ex \
    && python3 -m pip install --no-cache-dir flask gunicorn requests
EXPOSE 8000
ENV TZ=$TZ
ENTRYPOINT ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:8000", "earthquake:app"]
