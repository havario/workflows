#!/usr/bin/env sh
#
# Copyright (c) 2025 honeok <i@honeok.com>
# Copyright 2024 The Nezha Authors. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

WORKDIR="/app"

printf "nameserver 127.0.0.11\nnameserver 8.8.4.4\nnameserver 223.5.5.5\n" >/etc/resolv.conf
exec python3 -u "$WORKDIR/main.py" --config "$WORKDIR/configs" --skip_update
