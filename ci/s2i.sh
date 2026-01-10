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
DETECT_NODEJS="find $GAVE_SRC_TOP -maxdepth 2 -iname package.json"
DETECT_DEFAULT_TOP="find $GAVE_SRC_TOP -maxdepth 2 -iname .TOP"
DETECT_DEFAULT_GIT="find $GAVE_SRC_TOP -maxdepth 2 -iname .git"
eval "$DETECT_JAVA"
eval "$DETECT_NODEJS"

if [ -n "$(eval "$DETECT_NODEJS")" ]; then
    PACKAGE="$(echo "$(eval "$DETECT_NODEJS")" | head -n 1)"
    SRC_TOP="$(realpath "$(dirname "$PACKAGE")")"
    SRC_TYPE=nodejs
    SRC_VERSION="$(cd "$SRC_TOP" && npm run packageVersion | tail -n 1)"
    echo "detect SRC_TOP from file $PACKAGE"
fi

if [ -n "$GITLAB_CI" ]; then
    echo "GITLAB CI"
    DOCKER_IMAGE_NAME="$CI_PROJECT_NAME"
    BUILD_COUNTER="-$CI_COMMIT_REF_SLUG$SRC_GIT_COMMIT_ID-gl-$CI_BUILD_ID"
fi
