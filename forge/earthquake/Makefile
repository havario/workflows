## variables
# general
DOCKER_USERNAME := honeok
DOCKER_REPO     := earthquake
VERSION         := v$(shell date -u '+%Y.%m.%d' | awk -F. '{printf("%d.%d.%d\n", substr($$1,3), $$2, $$3)}')

# dev
DEV_IMAGE       ?= $(DOCKER_USERNAME)/$(DOCKER_REPO):dev
CONTAINER_NAME  ?= earthquake
PORT            ?= 8000

.PHONY: build run release

build:
	@echo "--> building development image $(DEV_IMAGE)"
	@docker build --no-cache --build-arg EARTHQUAKE_VERSION="$(VERSION)-dev" --tag $(DEV_IMAGE) .

run:
	@docker run -d -p $(PORT):8000 --name $(CONTAINER_NAME) $(DEV_IMAGE)

release:
	@echo "--> Release version $(VERSION) to the dockerhub $(DOCKER_USERNAME)/$(DOCKER_REPO)"
	@docker buildx build \
		--no-cache \
		--progress=plain \
		--platform linux/amd64,linux/arm64/v8 \
		--build-arg EARTHQUAKE_VERSION=$(VERSION) \
		--tag $(DOCKER_USERNAME)/$(DOCKER_REPO):$(VERSION) \
		--tag $(DOCKER_USERNAME)/$(DOCKER_REPO):latest \
		--push \
		--file Dockerfile
	@echo "--> version: $(VERSION) build complete!"
