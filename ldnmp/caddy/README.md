## Caddy Docker Image by honeok

[![Docker Pulls](https://img.shields.io/docker/pulls/honeok/caddy.svg?style=flat-square)](https://hub.docker.com/r/honeok/caddy)
[![Docker Image Size](https://img.shields.io/docker/image-size/honeok/caddy.svg?style=flat-square)](https://hub.docker.com/r/honeok/caddy)

<img src="https://user-images.githubusercontent.com/1128849/210187356-dfb7f1c5-ac2e-43aa-bb23-fc014280ae1f.svg" alt="Nginx" width="60%">

[Caddy][1] is a powerful, extensible platform to serve your sites, services, and apps, written in Go. If you're new to Caddy, the way you serve the Web is about to change.

Most people use Caddy as a web server or proxy, but at its core, Caddy is a server of servers. With the requisite modules, it can take on the role of any long-running process!

Caddy compiles for all major platforms and has no runtime dependencies.

### Plugins list

- github.com/caddyserver/cache-handler
- github.com/ueffel/caddy-brotli
- github.com/RussellLuo/caddy-ext/ratelimit
- github.com/caddyserver/transform-encoder
- github.com/caddyserver/replace-response
- github.com/caddyserver/forwardproxy
- github.com/caddyserver/ntlm-transport
- github.com/caddy-dns/cloudflare
- github.com/caddy-dns/tencentcloud
- github.com/caddy-dns/alidns
- github.com/caddy-dns/acmedns

## Prepare the host

Docker images are built for quick deployment in various computing cloud providers.

For more information on docker and containerization technologies, refer to [official document][2].

If you need to install docker by yourself, follow the [official installation guide][3].

## Pull the image

```shell
docker pull honeok/caddy
```

This image pulls the latest release of caddy.

It can be found at [Docker Hub][4].

## Start a container

```shell
docker run -d -p 80:80 --name caddy --restart=unless-stopped honeok/caddy
```

For the rest of the configuration, you only need to refer to the [caddy official documentation][5].

**Note**: The TCP port number `80` must be opened in firewall.

[1]: https://github.com/gabrielecirulli/caddy
[2]: https://docs.docker.com
[3]: https://docs.docker.com/install
[4]: https://hub.docker.com/r/honeok/caddy
[5]: https://caddyserver.com/docs