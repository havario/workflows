FROM node:24.10-alpine AS builder
WORKDIR /app
COPY package.json tsconfig.json ./
COPY static/app.ts ./static/
RUN set -ex \
    && npm install \
    && npx tsc -p .

FROM python:3.14-alpine AS dist
WORKDIR /app
COPY --from=builder /app/app.js static/app.js
COPY . .
RUN set -ex \
    && chmod +x earthquake.py \
    && python3 -m pip install --no-cache-dir flask requests
EXPOSE 5000
ENV TZ=Asia/Shanghai
ENTRYPOINT ["./earthquake.py"]
