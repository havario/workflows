#!/usr/bin/env bash

nginx() {
    local LATEST_VER CURRENT_VER

    LATEST_VER="$(wget -qO- --tries=50 https://api.github.com/repos/nginx/nginx/releases | grep '"tag_name":' | sed -n 's/.*"tag_name": "[^0-9]*\([0-9.]*\)".*/\1/p' | sort -rV | head -n1)"
    CURRENT_VER="$(wget -qO- --tries=50 https://hub.docker.com/v2/repositories/honeok/nginx/tags 2>/dev/null | grep -o '"name":"[^"]*"' | awk -F'"' '{print $4}' | grep -E -- '-alpine$' | sort -rV | head -n1 | sed 's/-alpine$//')"
}

nginx
