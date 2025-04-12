## X-UI Docker Image by honeok 

[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/x-ui.svg?style=flat-square)](https://hub.docker.com/r/honeok/x-ui)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/x-ui.svg?style=flat-square)](https://hub.docker.com/r/honeok/x-ui)
[![License](https://img.shields.io/github/license/honeok/cross.svg?style=flat-square)](https://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html)

[FranzKafkaYu/x-ui][1] 是一个基于 Xray 核心的多协议、多用户管理面板，提供直观的 Web 界面，方便用户管理和配置代理服务器。

它支持多种协议（如 V2Ray、Trojan、Shadowsocks、VLESS、VMess 等）。

X-UI 使用 Go 语言开发，性能优异，内存占用低。

用户可以通过浏览器访问面板，轻松设置入站规则、添加用户、管理流量和到期时间。

> **Disclaimer:** 此项目仅供个人学习交流，请不要用于非法目的，请不要在生产环境中使用。

**如果此项目对你有用，请给一个**:star2:

## 环境准备

如果你需要自己安装docker，请按照以下步骤操作 [official installation guide][2].

## 拉取镜像

```bash
docker pull honeok/x-ui
```

这是X-UI的最新版本。

It can be found at [Docker Hub][3].

## 启动容器

使用Docker cli

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
or

使用Docker Compose

```yaml
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

最后，运行以下命令来启动容器：

```bash
docker compose up -d
```

> [!WARNING]
> 如果您选择不修改这些设置，它们将随机生成
>
> 通过 `docker logs x-ui -f` 查看

###

```shell
docker exec -i x-ui sh -c 'echo 4 | x-ui'
```

[1]: https://github.com/FranzKafkaYu/x-ui
[2]: https://docs.docker.com/install
[3]: https://hub.docker.com/r/honeok/x-ui
[4]: https://sing-box.sagernet.org/configuration