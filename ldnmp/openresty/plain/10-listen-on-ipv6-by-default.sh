#!/bin/sh
# vim:sw=4:ts=4:et
# SPDX-License-Identifier: BSD-2-Clause

set -e

entrypoint_log() {
    if [ -z "${RESTY_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

ME=$(basename "$0")
DEFAULT_CONF_FILE="etc/nginx/conf.d/default.conf"
CHECKSUM="5595cfb7b243d04cdf5e5b8749b792362c2712b0"

# check if we have ipv6 available
if [ ! -f "/proc/net/if_inet6" ]; then
    entrypoint_log "$ME: info: ipv6 not available"
    exit 0
fi

if [ ! -f "/$DEFAULT_CONF_FILE" ]; then
    entrypoint_log "$ME: info: /$DEFAULT_CONF_FILE is not a file or does not exist"
    exit 0
fi

# check if the file can be modified, e.g. not on a r/o filesystem
touch /$DEFAULT_CONF_FILE 2>/dev/null || { entrypoint_log "$ME: info: can not modify /$DEFAULT_CONF_FILE (read-only file system?)"; exit 0; }

# check if the file is already modified, e.g. on a container restart
grep -q "listen  \[::\]:80;" /$DEFAULT_CONF_FILE && { entrypoint_log "$ME: info: IPv6 listen already enabled"; exit 0; }

if [ -f "/etc/os-release" ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
else
    entrypoint_log "$ME: info: can not guess the operating system"
    exit 0
fi

entrypoint_log "$ME: info: Getting the checksum of /$DEFAULT_CONF_FILE"

case "$ID" in
    alpine|debian)
        echo "$CHECKSUM  /$DEFAULT_CONF_FILE" | sha1sum -c - >/dev/null 2>&1 || {
            entrypoint_log "$ME: info: /$DEFAULT_CONF_FILE differs from the packaged version"
            exit 0
        }
    ;;
    *)
        entrypoint_log "$ME: info: Unsupported distribution"
        exit 0
    ;;
esac

# enable ipv6 on default.conf listen sockets
sed -i -E 's,listen       80;,listen       80;\n    listen  [::]:80;,' /$DEFAULT_CONF_FILE

entrypoint_log "$ME: info: Enabled listen on IPv6 in /$DEFAULT_CONF_FILE"

exit 0
