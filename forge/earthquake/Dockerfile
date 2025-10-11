FROM node:24.10-alpine AS builder
WORKDIR /app
COPY package.json tsconfig.json ./
COPY static/app.ts ./static/
RUN set -ex \
    && npm install \
    && npx tsc -p .

FROM python:3.14-alpine AS dist
WORKDIR /app
COPY --from=builder /app/*.js static/
COPY earthquake.py .
COPY templates/ templates/
COPY static/*.css static/
RUN set -ex \
    && python3 -m pip install --no-cache-dir flask gunicorn requests
EXPOSE 8000
ENV TZ=Asia/Shanghai
ENTRYPOINT ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:8000", "earthquake:app"]
