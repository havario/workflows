#!/usr/bin/env bash
# vim: set sw=4 ts=4 et:
# SPDX-License-Identifier: Apache-2.0
#
# Description:
# Copyright (c) 2021-2025 honeok <i@honeok.com>

# shellcheck disable=all

set -eE

tee >&2 <<- EOF
Usage: $0 /path/to/src
Usage: $0
EOF

SCRIPT="$(realpath "$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)/$(basename "${BASH_SOURCE:-$0}")")"
SCRIPT_DIR="$(dirname "$(realpath "$SCRIPT")")"
TRYTOP="$(
    cd "$SCRIPT_DIR"
    while [ ! -e .TOP ] && [ "$PWD" != "/" ]; do
        cd ..
    done
    pwd
)"

WORKDIR="$(pwd)"
if [ -z "$TRYTOP" ]; then
    TRYTOP="$WORKDIR"
fi

if [ "$#" -lt 1 ]; then
    tee >&2 <<- EOF
    Usage:
    build runner for Java | Node.js | ... source

    $(realpath $0) /path/to/src
EOF
    exit 1
fi

echo "########################################"
echo "TRYTOP=$TRYTOP"
env | grep -v LS_COLORS
echo "########################################"
echo "Start build."

GAVE_SRC_TOP="$(realpath $1)"

# Try to guest Java or nodeJs
echo "Auto try to detect Java or Node.js source and its topdir."
DETECT_GO="find $GAVE_SRC_TOP -maxdepth 1 -iname go.mod"
DETECT_JAVA="find $GAVE_SRC_TOP -maxdepth 1 -iname pom.xml"
DETECT_NODEJS="find $GAVE_SRC_TOP -maxdepth 2 -iname package.json"
DETECT_DEFAULT_TOP="find $GAVE_SRC_TOP -maxdepth 2 -iname .TOP"
DETECT_DEFAULT_GIT="find $GAVE_SRC_TOP -maxdepth 2 -iname .git"

# Debug
eval "$DETECT_GO"
eval "$DETECT_JAVA"
eval "$DETECT_NODEJS"

if [ -n "$(eval "$DETECT_GO")" ]; then
    GOMOD="$(echo "$(eval "$DETECT_GO")" | head -n 1)"
    SRC_TOP="$(realpath "$(dirname "$GOMOD")")"
    SRC_TYPE=go
    SRC_VERSION=""
    echo "Detect SRC_TOP from file $GOMOD"
elif [ -n "$(eval "$DETECT_JAVA")" ]; then
    POM="$(echo "$(eval "$DETECT_JAVA")" | head -n 1)"
    SRC_TOP="$(echo "$(realpath "$(dirname "$POM")")" | sort | head -n 1)"
    SRC_TYPE="java"
    mvn --file "$SRC_TOP" -N -Dexec.executable='echo' -Dexec.args='${project.version}' org.codehaus.mojo:exec-maven-plugin:1.3.1:exec
    SRC_VERSION="$(mvn --file "$SRC_TOP" -q -N -Dexec.executable='echo' -Dexec.args='${project.version}' org.codehaus.mojo:exec-maven-plugin:1.3.1:exec | tail -n 1)"
    echo "Detect SRC_TOP from file $POM"
elif [ -n "$(eval "$DETECT_NODEJS")" ]; then
    PACKAGE="$(echo "$(eval "$DETECT_NODEJS")" | head -n 1)"
    SRC_TOP="$(realpath "$(dirname "$PACKAGE")")"
    SRC_TYPE="nodejs"
    SRC_VERSION="$(cd "$SRC_TOP" && npm run packageVersion | tail -n 1)"
    echo "Detect SRC_TOP from file $PACKAGE"
fi

if [ -z "$SRC_VERSION" ]; then
    SRC_VERSION="1.0.0"
fi
SRC_GIT_COMMIT_ID="-$(cd "$SRC_TOP" && git rev-parse --short HEAD)"

if [ -n "$GITHUB_ACTIONS" ]; then
    echo "GitHub CI"
    DOCKER_IMAGE_NAME="${GITHUB_REPOSITORY#*/}"
    BUILD_COUNTER="-${GITHUB_REF_NAME//\//-}${SRC_GIT_COMMIT_ID}-gh-${GITHUB_RUN_NUMBER}"
elif [ -n "$GITLAB_CI" ]; then
    echo "GITLAB CI"
    DOCKER_IMAGE_NAME="$CI_PROJECT_NAME"
    BUILD_COUNTER="-${CI_COMMIT_REF_SLUG}${SRC_GIT_COMMIT_ID}-gl-${CI_BUILD_ID}"
elif [ -n "$JENKINS_URL" ]; then
    echo "Jenkins CI"
    DOCKER_IMAGE_NAME="$JOB_NAME"
    BUILD_COUNTER="-jk-$BUILD_NUMBER"
fi

build_go() {
    pushd "$SRC_TOP"
    go build -v -trimpath -ldflags="-s -w -buildid="
    popd
}

build_java() {
    pushd "$SRC_TOP"

    if [[ "$DOCKER_IMAGE_NAME" =~ "$NE_BOOT_MATCH" ]]; then
        ARTIFACT_DEPLOY=1
    fi
    if [ "$ENABLE_SONAR" -gt 0 ]; then
        if [ "$ARTIFACT_DEPLOY" -gt 0 ]; then
            mvn clean deploy sonar:sonar -Dsonar.projectKey=$(echo "$CI_PROJECT_PATH" | tr / .) -Dsonar.projectName=$(echo "$CI_PROJECT_PATH" | tr / .)
            exit 0
        else
            mvn clean package sonar:sonar -Dsonar.projectKey=$(echo "$CI_PROJECT_PATH" | tr / .) -Dsonar.projectName=$(echo "$CI_PROJECT_PATH" | tr / .)
        fi
    else
        if [ "$ARTIFACT_DEPLOY" -gt 0 ]; then
            mvn clean deploy
            exit 0
        else
            mvn clean package
        fi
    fi
}

build_nodejs() {
    pushd "$SRC_TOP"
    npm config set registry https://registry.npmmirror.com
    npm install --verbose
    npm run build
    popd
}
