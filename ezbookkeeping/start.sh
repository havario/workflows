#!/bin/sh

set -eE

# mariadb
[ ! -d "$PWD/db_data" ] && mkdir "$PWD/db_data"
[ ! -d "$PWD/db_log" ] && mkdir "$PWD/db_log"

# ezbookkeeping
[ ! -d "$PWD/ez_storage" ] && mkdir "$PWD/ez_storage"
[ ! -d "$PWD/ez_log" ] && mkdir "$PWD/ez_log"
chown 1000:1000 "$PWD/ez_storage" "$PWD/ez_log"

docker compose up -d
