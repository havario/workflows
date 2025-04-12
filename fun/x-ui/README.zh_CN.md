# X-UI Docker Image by honeok 

[![Docker Pulls](https://img.shields.io/docker/pulls/pakho611/x-ui.svg?style=flat-square)](https://hub.docker.com/r/pakho611/x-ui)
[![Docker Image Size](https://img.shields.io/docker/image-size/pakho611/x-ui.svg?style=flat-square)](https://hub.docker.com/r/pakho611/x-ui)
[![License](https://img.shields.io/github/license/honeok/cross.svg?style=flat-square)](https://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html)

**基于Xray Core构建**

X-UI基于原作者: [FranzKafkaYu/x-ui](https://github.com/FranzKafkaYu/x-ui)

## 特点

- X-UI 是一个基于 Xray 核心的多协议、多用户管理面板，提供直观的 Web 界面，方便用户管理和配置代理服务器。
- 它支持多种协议（如 V2Ray、Trojan、Shadowsocks、VLESS、VMess 等）。
- X-UI 使用 Go 语言开发，性能优异，内存占用低。
- 用户可以通过浏览器访问面板，轻松设置入站规则、添加用户、管理流量和到期时间。

> **Disclaimer:** 此项目仅供个人学习交流，请不要用于非法目的，请不要在生产环境中使用。

**如果此项目对你有用，请给一个**:star2:

<img src="https://cdn.skyimg.de/up/2025/4/12/ac9x1a.webp" alt="x-ui" width="80%">

>

## 支持的架构

| amd64 | arm64 | armv7 | s390x |
|-------|-------|-------|-------|
|  ✔️   |  ✔️   |  ❌   |  ✔️   |

## 通过Docker安装

<details>
  <summary>点击查看 通过Docker安装</summary>

#### 使用

1. 安装Docker：

  ```shell
  curl -fsSL get.docker.com | sh
  ```

2. 通过Docker cli安装

  ```shell
  docker run -d \
      -e USER_NAME=admin \
      -e USER_PASSWORD=admin \
      -e PANEL_PORT=54321 \
      -v $PWD/db:/etc/x-ui/ \
      -v $PWD/cert:/root/cert/ \
      --network=host \
      --cap-add=NET_ADMIN \
      --restart=unless-stopped \
      --name x-ui \
      honeok/x-ui:latest
  ```

3. 通过Docker Compose安装

  ```yml
  services:
    x-ui:
      image: honeok/x-ui
      container_name: x-ui
      restart: unless-stopped
      environment:
        USER_NAME: admin
        USER_PASSWORD: admin
        PANEL_PORT: 54321
      volumes:
        - $PWD/db/:/etc/x-ui
        - $PWD/cert/:/root/cert
      network_mode: host
      cap_add:
        - NET_ADMIN
  ```

4. 运行服务：

  ```shell
  docker compose up -d
  ```

从Docker中删除3x-ui

  ```shell
  docker rm -f x-ui && rm -rf /etc/x-ui ./db ./cert
  ```
  or
  ```shell
  cd x-ui && docker compose down --rmi all --volumes --remove-orphans && cd .. && rm -rf x-ui
  ```

## 默认面板设置

**用户名、密码、端口和 Web Base Path**

> [!WARNING]
> 如果您选择不修改这些设置，它们将随机生成
>
> 通过 `docker logs x-ui -f` 查看



```shell
docker exec -i x-ui sh -c 'echo 4 | x-ui'
```