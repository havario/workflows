# SPDX-License-Identifier: MIT
# Copyright (c) 2025 honeok <i@honeok.com>

# References:
# https://github.com/Minerchu/dongguaTV
# https://www.nodeseek.com/post-545203-1

FROM node:20.19-alpine
WORKDIR /app
COPY package*.json ./
RUN set -ex \
    && npm install --omit=dev
COPY . .
RUN set -ex \
    && apk add --update --no-cache tzdata \
    && chmod +x docker-entrypoint.sh
ENV TZ=Asia/Shanghai
EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["node", "server.js"]
