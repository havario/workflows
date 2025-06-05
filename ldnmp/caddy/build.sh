#!/bin/bash

VERSION="$(wget -qO- --tries=5 "https://api.github.com/repos/caddyserver/caddy/releases/latest" | awk -F '["v]' '/tag_name/{print $5}')"

docker build --no-cache --build-arg "VERSION=$VERSION" -t "honeok/caddy:$VERSION" .

docker system prune -af --volumes