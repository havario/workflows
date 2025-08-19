<div align="center">
  <br>
  <img width="360" style="max-width:80%" src="https://github.com/nezhahq/nezha/raw/master/.github/brand.svg" title="哪吒监控 Nezha Monitoring">
  <br>
  <small><i>LOGO designed by <a href="https://xio.ng" target="_blank">熊大</a> .</i></small>
  <br><br>
  <p>:trollface: <b>Nezha Monitoring: Self-hostable, lightweight, servers and websites monitoring and O&M tool.</b></p>
  <p>Supports <b>monitoring</b> system status, HTTP (SSL certificate change, upcoming expiration, expired), TCP, Ping and supports <b>push alerts</b>, run scheduled tasks and <b>web terminal</b>.</p>
</div>

<div align="center">
  <a href="https://hub.docker.com/r/honeok/nezha-dashboard"><img src="https://img.shields.io/docker/pulls/honeok/nezha-dashboard.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://hub.docker.com/r/honeok/nezha-dashboard"><img src="https://img.shields.io/docker/image-size/honeok/nezha-dashboard.svg?style=flat-square" alt="Docker Image Size"></a>
  <a href="https://hub.docker.com/r/honeok/nezha-dashboard"><img src="https://img.shields.io/docker/v/honeok/nezha-dashboard.svg?style=flat-square" alt="Docker Image Version"></a>
</div>

![image](https://cdn.skyimg.net/up/2025/8/19/8e036a4d.webp)

## Purpose

The sole purpose of this Docker image is to update the GeoIP database to correct the country flag display in Nezha Dashboard.

This image is automatically built at the beginning of each month.

This repository builds both `v0` and `v1` versions, ensuring the GeoIP database is always kept up-to-date.

## Pull the image

```shell
docker pull honeok/nezha-dashboard
```

It can be found at [Docker Hub][1] and view the build records on [GitHub][2].

## Special Thanks

- [IPInfo](https://ipinfo.io) for providing an accurate GeoIP Database.

## Acknowledgements

- All developers of the Nezha Probe project.

[1]: https://hub.docker.com/r/honeok/nezha-dashboard
[2]: https://github.com/honeok/tools/tree/master/forge/nezha-dashboard