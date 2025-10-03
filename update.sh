#!/usr/bin/env bash
#
# Description:
#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

set -eEux

OFFICIAL="$(curl -Ls https://github.com/nezhahq/nezha/raw/master/README.md | sed -n '/<!--GAMFC_DELIMITER-->/,/<!--GAMFC_DELIMITER_END-->/p')"
LOCAL="$(sed -n '/<!--GAMFC_DELIMITER-->/,/<!--GAMFC_DELIMITER_END-->/p' ./README.md)"

if [ "$OFFICIAL" != "$LOCAL" ]; then
    printf '%s\n' "$OFFICIAL" | sed -i '/<!--GAMFC_DELIMITER-->/,/<!--GAMFC_DELIMITER_END-->/{
        /<!--GAMFC_DELIMITER-->/r /dev/stdin
        /<!--GAMFC_DELIMITER-->/,/<!--GAMFC_DELIMITER_END-->/d
    }' ./README.md
fi
