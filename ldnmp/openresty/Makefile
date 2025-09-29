# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

# variables
DOCKER_USER := honeok
DOCKER_REPO := openresty
RESTY_VERSION := $(shell wget -qO- https://api.github.com/repos/openresty/openresty/tags | grep '"name":' | sed -n 's/.*"name": "[^0-9]*\([0-9.]*\)".*/\1/p' | sort -Vr | head -n1)
ZSTD_VERSION := $(shell wget -qO- https://api.github.com/repos/facebook/zstd/releases/latest | grep '"tag_name":' | sed -n 's/.*"tag_name": "[^0-9]*\([0-9.]*\)".*/\1/p')
PLAIN_DIR := plain

.PHONY: all
all: build

# buildx builder
.PHONY: setup
setup:
	@docker buildx ls | grep -w builder >/dev/null 2>&1 || docker buildx create --name builder --use
	@docker buildx inspect --bootstrap builder

.PHONY: build
build: setup
	@cd $(PLAIN_DIR) && find . -type f -name "*.sh" -exec dos2unix {} \; -exec chmod +x {} \;
	@cd $(PLAIN_DIR) && docker buildx build \
		--no-cache \
		--progress=plain \
		--platform linux/amd64,linux/arm64/v8 \
		--build-arg RESTY_VERSION=$(RESTY_VERSION) \
		--build-arg ZSTD_VERSION=$(ZSTD_VERSION) \
		--tag $(DOCKER_USER)/$(DOCKER_REPO):$(RESTY_VERSION)-alpine \
		--tag $(DOCKER_USER)/$(DOCKER_REPO):alpine \
		--push \
		. && echo "build complete!" >&2

# clean up
.PHONY: clean
clean:
	@docker buildx prune --all --force 2>/dev/null || true
	@docker system prune -af --volumes 2>/dev/null || true
	@docker buildx rm -f builder 2>/dev/null || true
