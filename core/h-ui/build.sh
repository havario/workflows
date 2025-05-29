#!/usr/bin/env sh
#
# Description: This script is used to build h-ui panels in multiple stages.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

set -eux

VERSION="$1"

if ! git clone --depth=1 --branch "$VERSION" https://github.com/jonssonyan/h-ui.git; then
    printf 'Error: Failed to clone the project branch.\n' >&2; exit 1
fi

cd h-ui || { printf 'Error: permission denied or directory does not exist\n' >&2; exit 1; }

go build -trimpath -ldflags "-s -w" -o /go/bin/h-ui ./main.go