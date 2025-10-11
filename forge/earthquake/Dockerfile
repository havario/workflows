# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

FROM node:24.10-alpine AS builder
WORKDIR /app
COPY package.json tsconfig.json ./
COPY static/app.ts ./static/
RUN set -ex \
    && npm install \
    && npx tsc -p .

FROM python:3.14-alpine
WORKDIR /app
COPY --from=builder /app/app.js static/app.js
COPY . .
RUN set -ex \
    && python3 -m pip install --no-cache-dir flask requests
EXPOSE 5000
ENTRYPOINT ["python3", "earthquake.py"]
