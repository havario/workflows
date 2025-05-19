#!/usr/bin/env bash
#
# Description: This script is used to traverse the database for full backup.
#
# Copyright (c) 2024-2025 honeok <honeok@duck.com>
#
# Licensed under the MIT License.
# This software is provided "as is", without any warranty.

set -e

# https://www.graalvm.org/latest/reference-manual/ruby/UTF8Locale
export LANG=en_US.UTF-8

_green() { printf "\033[92m%s\033[0m\n" "$*"; }
_suc_msg() { printf "\033[42m\033[1mSuccess\033[0m %s\n" "$*"; }

# 各变量默认值
MYSQLBAK_PID="/tmp/mysqlbak.pid"
WORKDIR="/data/dbback"
WORKDIR_TMP="/data/dbback/tmp"

# mysqdump备份参数
BAK_PARAMETERS=(--no-defaults --single-transaction --set-gtid-purged=OFF)

gamedb1_bak() {
    local -A GAMEDB
    local -a DATABASES

    # 定义关联数组用于存储数据库连接信息, 值来自环境变量 /etc/profile.d/mysql.sh
    GAMEDB=(
        ["MYSQL_USER_GAMEDB1"]="$MYSQL_USER_GAMEDB1"
        ["MYSQL_PASSWD_GAMEDB1"]="$MYSQL_PASSWD_GAMEDB1"
        ["MYSQL_PORT_GAMEDB1"]="$MYSQL_PORT_GAMEDB1"
        ["MYSQL_IP_GAMEDB1"]="$MYSQL_IP_GAMEDB1"
    )

    while read -r DB; do
        DATABASES+=("$DB")
    done < <(mysql -h "${GAMEDB[MYSQL_IP_GAMEDB1]}" \
            -u "${GAMEDB[MYSQL_USER_GAMEDB1]}" \
            -p"${GAMEDB[MYSQL_PASSWD_GAMEDB1]}" \
            -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "(Database|information_schema|mysql|performance_schema|sys)")

    # 执行备份
    for database in "${DATABASES[@]}"; do
        /usr/bin/mysqldump "${BAK_PARAMETERS[@]}" \
        -h "${GAMEDB[MYSQL_IP_GAMEDB1]}" \
        -P "${GAMEDB[MYSQL_PORT_GAMEDB1]}" \
        -u "${GAMEDB[MYSQL_USER_GAMEDB1]}" \
        -p"${GAMEDB[MYSQL_PASSWD_GAMEDB1]}" \
        -R "$database" > "$WORKDIR_TMP/${database}_$(LC_TIME="en_DK.UTF-8" TZ=Asia/Shanghai date +%Y.%m.%d-%H:%M:%S).sql" 2>/dev/null
        _suc_msg "$(_green "$database Backup Complete!")"
    done
}

mysqlbak() {
    gamedb1_bak
}

mysqlbak