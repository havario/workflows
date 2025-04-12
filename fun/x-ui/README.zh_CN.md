# x-ui Docker Image by honeok 

<p align="center">
  <a href="https://hub.docker.com/r/pakho611/x-ui">
    <img src="https://img.shields.io/docker/pulls/pakho611/x-ui.svg?style=flat-square" alt="Docker Pulls" />
  </a>
  <a href="https://hub.docker.com/r/pakho611/x-ui">
    <img src="https://img.shields.io/docker/image-size/pakho611/x-ui.svg?style=flat-square" alt="Docker Image Size" />
  </a>
  <a href="https://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html">
    <img src="https://img.shields.io/github/license/honeok/cross.svg?style=flat-square" alt="License" />
  </a>
</p>



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