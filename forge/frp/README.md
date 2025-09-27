# FRP

[![GitHub release](https://img.shields.io/github/v/tag/fatedier/frp.svg?style=flat-square&label=release&logo=github&color=brightgreen)](https://github.com/fatedier/frp/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/frp.svg?style=flat-square&logo=docker&color=brightgreen)](https://hub.docker.com/r/honeok/frp)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/frp.svg?style=flat-square&logo=docker&color=brightgreen)](https://hub.docker.com/r/honeok/frp)
[![Docker Image Version](https://img.shields.io/docker/v/honeok/frp.svg?style=flat-square&logo=docker&color=brightgreen)](https://hub.docker.com/r/honeok/frp)

[FRP][1] is a high-performance reverse proxy focused on NAT traversal, supporting protocols such as TCP, UDP, HTTP, HTTPS, and P2P communication. It enables you to securely and conveniently expose local services behind a NAT or firewall to the public internet through a relay server with a public IP.

## Architecture

![Architecture](https://github.com/fatedier/frp/raw/master/doc/pic/architecture.png)

## Prepare the host

If you need to install docker by yourself, follow the [official][2] installation guide.

## Pull the image

```shell
docker pull honeok/frp
```

This pulls the latest release of Xray-core.

It can be found at [Docker Hub][3].

## Start a container

Add the following content to the `docker-compose.yaml` file.

```shell
tee docker-compose.yaml >/dev/null <<'EOF'
services:
  frp:
    image: honeok/frp
    container_name: frp
    restart: unless-stopped
    volumes:
      - $PWD/frps.toml:/etc/frp/frps.toml
    command: frps -c /etc/frp/frps.toml
    network_mode: host
EOF
```

[1]: https://gofrp.org
[2]: https://docs.docker.com/install
[3]: https://hub.docker.com/r/honeok/frp
