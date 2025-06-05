#!/bin/bash
#
# Description: This script is used for ipinfo-go multi architecture container build.
#
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BUMP_VERSION="$1"
WORK_DIR="$(pwd)"
[[ "$#" -ne 1 || ! -f "$WORK_DIR/Dockerfile" ]] && { printf 'Error: Build conditions not met.\n'; exit 1; }

docker buildx build \
    --no-cache \
    --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x \
    -t "honeok/ipinfo-go:$BUMP_VERSION" \
    -t "honeok/ipinfo-go:latest" \
    --push .

docker system prune -af --volumes