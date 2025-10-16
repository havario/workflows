#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
#
# Description:
# Copyright (c) 2025 honeok <i@honeok.com>

set -eEu

UNLOCK_RESULT="$(bash <(curl -Ls https://github.com/lmc999/RegionRestrictionCheck/raw/main/check.sh | sed 's/^showGoodbye$/# showGoodbye/') <<< "0")"
CLEAN_RESULT="$(echo "$UNLOCK_RESULT" | sed -n '1h;1!H;${g;s#.*https://t.me/gameaccelerate##p}')"
echo "$CLEAN_RESULT"
