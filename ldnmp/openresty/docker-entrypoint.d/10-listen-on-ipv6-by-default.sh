#!/usr/bin/env sh
# vim:sw=4:ts=4:et

set -e

entrypoint_log() {
    if [ -z "${RESTY_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

SCRIPT="$(basename "$0")"
DEFAULT_CONF="/etc/nginx/conf.d/default.conf"

# check if we have ipv6 available
if [ ! -f "/proc/net/if_inet6" ]; then
    entrypoint_log "$SCRIPT: info: ipv6 not available"
    exit 0
fi

if [ ! -f "$DEFAULT_CONF" ]; then
    entrypoint_log "$SCRIPT: info: $DEFAULT_CONF is not a file or does not exist"
    exit 0
fi

# check if the file can be modified, e.g. not on a r/o filesystem
touch "$DEFAULT_CONF" 2>/dev/null || { entrypoint_log "$SCRIPT: info: can not modify $DEFAULT_CONF (read-only file system ?)"; exit 0; }

# check if the file is already modified, e.g. on a container restart
grep -qiE "listen  \[::]\:80;" "$DEFAULT_CONF" && { entrypoint_log "$SCRIPT: info: IPv6 listen already enabled"; exit 0; }

if [ -f "/etc/os-release" ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
else
    entrypoint_log "$SCRIPT: info: can not guess the operating system"
    exit 0
fi

entrypoint_log "$SCRIPT: info: Getting the checksum of $DEFAULT_CONF"

case "$ID" in
    "debian" )
        CHECKSUM="$(dpkg-query --show --showformat='${Conffiles}\n' nginx | grep "$DEFAULT_CONF" | cut -d' ' -f3)"
        echo "$CHECKSUM  $DEFAULT_CONF" | md5sum -c - >/dev/null 2>&1 || {
            entrypoint_log "$SCRIPT: info: $DEFAULT_CONF differs from the packaged version"
            exit 0
        }
    ;;
    "alpine" )
        CHECKSUM="$(apk manifest nginx 2>/dev/null| grep "$DEFAULT_CONF" | cut -d' ' -f1 | cut -d ':' -f2)"
        echo "$CHECKSUM  $DEFAULT_CONF" | sha1sum -c - >/dev/null 2>&1 || {
            entrypoint_log "$SCRIPT: info: $DEFAULT_CONF differs from the packaged version"
            exit 0
        }
    ;;
    *)
        entrypoint_log "$SCRIPT: info: Unsupported distribution"
        exit 0
    ;;
esac

# enable ipv6 on default.conf listen sockets
sed -i -E 's,listen       80;,listen       80;\n    listen  [::]:80;,' "$DEFAULT_CONF"

entrypoint_log "$SCRIPT: info: Enabled listen on IPv6 in $DEFAULT_CONF"

exit 0