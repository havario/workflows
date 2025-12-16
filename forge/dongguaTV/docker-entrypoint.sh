#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 honeok <i@honeok.com>

set -e

_info_msg() {
    echo >&2 "$(date '+%Y/%m/%d %H:%M:%S') $@"
}

: "${TMDB_API_KEY:?Error: TMDB_API_KEY missing.}"
sed -i "s#const TMDB_API_KEY = [\"'].*[\"'];#const TMDB_API_KEY = \"$TMDB_API_KEY\";#g" public/index.html

# replace api.themoviedb.org proxy
if [ -n "$PROXY_URL" ]; then
    sed -i "s#const MY_PROXY = [\"'].*[\"'];#const MY_PROXY = \"$PROXY_URL\";#g" public/index.html
else
    _info_msg "$0: No custom Proxy URL set. using default. skipping configuration"
fi

# replace admin password
if [ -n "$ADMIN_PASSWD" ]; then
    sed -i "s#const ADMIN_PASSWORD = [\"'].*[\"'];#const ADMIN_PASSWORD = \"$ADMIN_PASSWD\";#g" server.js
else
    _info_msg "$0: admin password not set, using default password 'admin'."
fi

exec "$@"
