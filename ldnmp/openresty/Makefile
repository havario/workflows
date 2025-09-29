# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

RESTY_VERSION := $(shell wget -qO- https://api.github.com/repos/openresty/openresty/tags | grep '"name":' | sed -n 's/.*"name": "[^0-9]*\([0-9.]*\)".*/\1/p' | sort -Vr | head -n1)
ZSTD_VERSION := $(shell wget -qO- https://api.github.com/repos/facebook/zstd/releases/latest | grep '"tag_name":' | sed -n 's/.*"tag_name": "[^0-9]*\([0-9.]*\)".*/\1/p')

.PHONY: all
all: build

.PHONY: setup
setup:
