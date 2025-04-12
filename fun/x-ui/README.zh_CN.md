# X-UI Docker Image by honeok 

[![Docker Pulls](https://img.shields.io/docker/pulls/pakho611/x-ui.svg?style=flat-square)](https://hub.docker.com/r/pakho611/x-ui)
[![Docker Image Size](https://img.shields.io/docker/image-size/pakho611/x-ui.svg?style=flat-square)](https://hub.docker.com/r/pakho611/x-ui)
[![License](https://img.shields.io/github/license/honeok/cross.svg?style=flat-square)](https://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html)

**基于Xray Core构建**

X-UI基于原作者: [FranzKafkaYu/x-ui](https://github.com/FranzKafkaYu/x-ui)

## 特点

- X-UI 是一个用于构建代理以绕过网络限制的平台

> **Disclaimer:** 此项目仅供个人学习交流，请不要用于非法目的，请不要在生产环境中使用。

**如果此项目对你有用，请给一个**:star2:

<img src="https://cdn.skyimg.de/up/2025/4/12/ac9x1a.webp" alt="x-ui" width="80%">

## 架构要求

| amd64 | arm64 | armv7 | s390x |
|-------|-------|-------|-------|
|  ✔️   |  ✔️   |  ❌   |  ✔️   |

## 通过Docker安装

1. 安装Docker：

```shell
curl -fsSL get.docker.com | sh
```

2. 通过Docker Compose安装

```yml
services:
  x-ui:
    image: honeok/x-ui
    container_name: x-ui
    restart: unless-stopped
#    environment:
#      USER_NAME: admin
#      USER_PASSWORD: admin
#      PANEL_PORT: 54321
    volumes:
      - $PWD/db/:/etc/x-ui
      - $PWD/cert/:/root/cert
    network_mode: host
    cap_add:
      - NET_ADMIN
```




```shell
docker exec -i x-ui sh -c 'echo 4 | x-ui'
```