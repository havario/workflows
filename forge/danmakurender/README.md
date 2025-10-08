# DanmakuRender

[![GitHub Release](https://img.shields.io/github/v/tag/SmallPeaches/DanmakuRender.svg?style=flat-square&label=release&logo=github&color=blue)](https://github.com/SmallPeaches/DanmakuRender/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/danmakurender.svg?style=flat-square&logo=docker&color=blue&logoColor=white)](https://hub.docker.com/r/honeok/danmakurender)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/danmakurender.svg?style=flat-square&logo=docker&color=blue&logoColor=white)](https://hub.docker.com/r/honeok/danmakurender)
[![Docker Image Version](https://img.shields.io/docker/v/honeok/danmakurender.svg?style=flat-square&logo=docker&color=blue&logoColor=white)](https://hub.docker.com/r/honeok/danmakurender)


```shell
tee docker-compose.yaml >/dev/null <<'EOF'
services:
  danmakurender:
    image: honeok/danmakurender
    container_name: danmakurender
    restart: unless-stopped
    volumes:
      - $PWD/logs:/app/logs
      - $PWD/configs:/app/configs
    network_mode: bridge
EOF
```
