#!/bin/bash
#
# Copyright (c) 2025 honeok <honeok@autistici.org>
#
# SPDX-License-Identifier: Apache License 2.0

VERSION="$(wget -qO- --tries=5 "https://api.github.com/repos/caddyserver/caddy/releases/latest" | awk -F '["v]' '/tag_name/{print $5}')"

docker build --no-cache --build-arg "VERSION=$VERSION" -t "honeok/caddy:$VERSION" .

docker run -d --name caddy --network host "honeok/caddy:$VERSION"

docker system prune -af --volumes