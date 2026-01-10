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

die() {
    echo >&2 "Error: $*"
    exit 1
}

if [ -z "$TRYTOP" ]; then
    TRYTOP="$WORKDIR"
fi
if [ "$#" -lt 1 ]; then
    tee >&2 <<- EOF
    Usage:
    build runner for Go | Java | Node.js | ... source

    $(realpath $0) /path/to/src
EOF
    exit 1
fi

echo "########################################"
echo "TRYTOP=$TRYTOP"
env | grep -v LS_COLORS
echo "########################################"
echo "Start build."

# Try to guest Go Java or nodeJs
echo "Auto try to detect source type and its topdir."
GAVE_SRC_TOP="$(realpath $1)"
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
    SRC_TYPE="go"
    SRC_VERSION="$(date -u -d "+8 hours" +%Y%m%d)-$(git rev-parse --short HEAD)"
    echo "Detect SRC_TOP from file $GOMOD"
elif [ -n "$(eval "$DETECT_JAVA")" ]; then
    POM="$(echo "$(eval "$DETECT_JAVA")" | head -n 1)"
    SRC_TOP="$(echo "$(realpath "$(dirname "$POM")")" | sort | head -n 1)"
    SRC_TYPE="java"
    mvn --file "$SRC_TOP" -N -Dexec.executable='echo' -Dexec.args='${project.version}' org.codehaus.mojo:exec-maven-plugin:3.6.3:exec
    SRC_VERSION="$(mvn --file "$SRC_TOP" -q -N -Dexec.executable='echo' -Dexec.args='${project.version}' org.codehaus.mojo:exec-maven-plugin:3.6.3:exec | tail -n 1)"
    echo "Detect SRC_TOP from file $POM"
elif [ -n "$(eval "$DETECT_NODEJS")" ]; then
    PACKAGE="$(echo "$(eval "$DETECT_NODEJS")" | head -n 1)"
    SRC_TOP="$(realpath "$(dirname "$PACKAGE")")"
    SRC_TYPE="nodejs"
    SRC_VERSION="$(cd "$SRC_TOP" && npm run packageVersion | tail -n 1)"
    echo "Detect SRC_TOP from file $PACKAGE"
elif [ -n "$(eval "$DETECT_DEFAULT_TOP")" ]; then
    TOPFILE="$(echo "$(eval "$DETECT_DEFAULT_TOP")" | head -n 1 | awk '{print $1}')"
    SRC_TOP="$(echo "$(realpath "$(dirname "$TOPFILE")")" | head -n 1)"
    SRC_TYPE="none"
    SRC_VERSION="v"
    echo "detect SRC_TOP from file .TOP"
elif [ -n "$(eval "$DETECT_DEFAULT_GIT")" ]; then
    TOPFILE="$(echo "$(eval "$DETECT_DEFAULT_GIT")" | head -n 1 | awk '{print $1}')"
    SRC_TOP="$(echo "$(realpath "$(dirname "$TOPFILE")")" | head -n 1)"
    SRC_TYPE="none"
    SRC_VERSION="$(date -u -d "+8 hours" +%Y%m%d)-$(git rev-parse --short HEAD)"
    echo "Detect SRC_TOP from file .TOP"
else
    SRC_TYPE="none"
    SRC_VERSION="Cant-detect-version"
    die "Can't detect SRC_TOP."
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
elif [ -n "$TEAMCITY_GIT_PATH" ]; then
    echo "Teamcity CI"
    DOCKER_IMAGE_NAME="$TEAMCITY_BUILDCONF_NAME"
    BUILD_COUNTER="-tc-$BUILD_NUMBER"
else
    echo "Can't detect name"
    DOCKER_IMAGE_NAME="$(basename "$(realpath "$SRC_TOP")")"
    BUILD_COUNTER="-ct-$(date -u +%s)"
fi

echo "########################################"
echo "SRC_TOP=$SRC_TOP"
echo "SRC_TYPE=$SRC_TYPE"
echo "SRC_VERSION=$SRC_VERSION"
echo "SRC_GIT_COMMIT_ID=$SRC_GIT_COMMIT_ID"
echo "DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME"
echo "BUILD_COUNTER=$BUILD_COUNTER"

if [ -z "$NEXUS_REPO" ]; then
    export NEXUS_REPO="${NEXUS_REPO:-'https://nexus.honeok.org/content/groups/maven'}"
fi
if [ -z "$NEXUS_SNAPSHOT" ]; then
    export NEXUS_SNAPSHOT="${DOCKER_REPO:-'https://nexus.honeok.org/content/repositories/maven-snapshot'}"
fi
if [ -z "$NEXUS_RELEASE" ]; then
    export NEXUS_RELEASE="${DOCKER_REPO:-'https://nexus.honeok.org/content/repositories/maven-release'}"
fi
if [ -z "$DOCKER_BUILD" ]; then
    DOCKER_BUILD=1
fi
if [ -z "$DOCKER_REPO" ]; then
    DOCKER_REPO="${DOCKER_REPO:-'harbor.honeok.org'}"
fi
if [ -z "$DOCKER_NS" ]; then
    DOCKER_NS="honeok/dev"
fi
if [ -z "$K8S_AUTOCD" ]; then
    K8S_AUTOCD=0
fi
if [ -z "$K8S_NS" ]; then
    K8S_NS="prod"
fi
if [ -z "$K8S_SVCNAMES" ]; then
    K8S_SVCNAMES="$DOCKER_IMAGE_NAME"
fi
if [ -z "$K8S_DOMAIN_INTERNAL" ]; then
    K8S_DOMAIN_INTERNAL="internal.honeok.dev"
fi
if [ -z "$K8S_DOMAIN_PUBLIC" ]; then
    K8S_DOMAIN_PUBLIC="honeok.org"
fi

build_go() {
    pushd "$SRC_TOP"
    go env -w GOPROXY=https://goproxy.cn,direct
    go mod download
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
