# Description: This dockerfile is used to build the containerized image of AngryBirds.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the Apache License, Version 2.0.
# Distributed on an "AS IS" basis, WITHOUT WARRANTIES.
# See http://www.apache.org/licenses/LICENSE-2.0 for details.

FROM unityci/editor:2018.2.0f1-webgl-3.1.0 AS builder
WORKDIR /AngryBirds
RUN set -ex \
    apt-get update && apt-get install git \
    && git clone --branch master --single-branch https://github.com/fctony/AngryBirds.git . \
    && unity-editor \
        -batchmode \
        -nographics \
        -projectPath . \
        -buildTarget WebGL \
        -buildPath ./build \
        -buildName AngryBird \
        -scenes Assets/Scenes/main.unity \
        -logFile /dev/stdout \
        -quit \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM nginx:stable-alpine
COPY --from=builder /AngryBirds/build /usr/share/nginx/html
RUN set -ex \
    && find /usr/share/nginx/html -type d -exec chmod 755 {} \; \
    && find /usr/share/nginx/html -type f -exec chmod 644 {} \;