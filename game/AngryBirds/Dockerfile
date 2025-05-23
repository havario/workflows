# Description: This dockerfile is used to build the containerized image of AngryBirds.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the Apache License, Version 2.0.
# Distributed on an "AS IS" basis, WITHOUT WARRANTIES.
# See http://www.apache.org/licenses/LICENSE-2.0 for details.

FROM unityci/editor:2018.2.0f1-webgl-3.1.0 AS builder
WORKDIR /AngryBirds
# https://blog.csdn.net/durongze/article/details/127992594
ENV GNUTLS_CPUID_OVERRIDE=0x1
ENV UNITY_LICENSE=""
ENV UNITY_ACTIVATION_SKIP=1
ENV UNITY_SKIP_ACTIVATION=1
ENV UNITY_DISABLE_LICENSE_CHECK=1
ENV UNITY_DISABLE_GRAPHICS_DEVICE=1
RUN set -ex \
    && apt-get update && apt-get install git \
    && git clone --branch master --single-branch https://github.com/fctony/AngryBirds.git . \
    && mkdir -p /root/.cache/unity3d /root/.local/share/unity3d/Unity \
    && chmod -R 777 /root/.cache /root/.local/share/unity3d \
    && unity-editor \
        -batchmode \
        -nographics \
        -projectPath . \
        -buildTarget WebGL \
        -buildPath ./build \
        -buildName AngryBird \
        -scenes Assets/Scenes/Game.unity Assets/Scenes/Level.unity Assets/Scenes/Loading.unity \
        -logFile /dev/stdout \
        -quit \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM nginx:stable-alpine
COPY --from=builder /AngryBirds/build /usr/share/nginx/html
RUN set -ex \
    && find /usr/share/nginx/html -type d -exec chmod 755 {} \; \
    && find /usr/share/nginx/html -type f -exec chmod 644 {} \;