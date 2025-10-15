#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0

echo 0 | bash <(curl -Ls https://github.com/lmc999/RegionRestrictionCheck/raw/main/check.sh | sed 's/^showGoodbye$/# showGoodbye/')
