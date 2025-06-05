#!/bin/bash
#
# Description: This script is used to build the caddy container image during the test phase.
#
# Copyright (c) 2025 honeok <honeok@autistici.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VERSION="$(wget -qO- --tries=5 "https://api.github.com/repos/caddyserver/caddy/releases/latest" | awk -F '["v]' '/tag_name/{print $5}')"

docker build --no-cache --build-arg "VERSION=$VERSION" -t "honeok/caddy:$VERSION" .

docker run -d --name caddy --network host "honeok/caddy:$VERSION"

docker system prune -af --volumes