#!/bin/bash

set -eEu

# 各变量默认值
TEMP_DIR="$(mktemp -d)"
. <(curl -Ls https://github.com/workstudybuyhouse/workflows/raw/master/evil/go-gost/init.sh)
# . <(curl -Ls https://github.com/honeok/cross/raw/master/evil/go-gost/init.sh)

trap 'rm -rf "${TEMP_DIR:?}" >/dev/null 2>&1' SIGINT SIGTERM EXIT

die() {
    local EXIT_CODE

    EXIT_CODE="${2:-1}"

    printf >&2 'Error: %s\n' "$1"
    exit "$EXIT_CODE"
}

cd "$TEMP_DIR" >/dev/null 2>&1 || die "Unable to enter the work path."

get_cmd_path() {
    # -f: 忽略shell内置命令和函数, 只考虑外部命令
    # -p: 只输出外部命令的完整路径
    type -f -p "$1"
}

is_have_cmd() {
    get_cmd_path "$1" >/dev/null 2>&1
}

install_pkg() {
    for pkg in "$@"; do
        if is_have_cmd dnf; then
            dnf install -y "$pkg"
        elif is_have_cmd yum; then
            yum install -y "$pkg"
        elif is_have_cmd apt-get; then
            apt-get update
            apt-get install -y -q "$pkg"
        else
            die "The package manager is not supported."
        fi
    done
}

curl() {
    local EXIT_CODE

    is_have_cmd curl || install_pkg curl

    # --fail             4xx/5xx返回非0
    # --insecure         兼容旧平台证书问题
    # --connect-timeout  连接超时保护
    # CentOS7 无法使用 --retry-connrefused 和 --retry-all-errors 因此手动 retry

    for ((i=1; i<=5; i++)); do
        if ! command curl --connect-timeout 10 --fail --insecure "$@"; then
            EXIT_CODE=$?
            # 403 404 错误或达到重试次数
            if [ "$EXIT_CODE" -eq 22 ] || [ "$i" -eq 5 ]; then
                return "$EXIT_CODE"
            fi
            sleep 1
        else
            return
        fi
    done
}

is_china() {
    if [ -z "$COUNTRY" ]; then
        if ! COUNTRY="$(curl -L http://www.qualcomm.cn/cdn-cgi/trace | grep '^loc=' | cut -d= -f2 | grep .)"; then
            die "Can not get location."
        fi
        echo 2>&1 "Location: $COUNTRY"
    fi
    [ "$COUNTRY" = CN ]
}

main() {
    local OS_NAME LATEST_VER

    OS_NAME="$(uname -s 2>/dev/null | sed 's/.*/\L&/')"
    LATEST_VER="$(curl -L https://api.github.com/repos/go-gost/gost/releases/latest | grep '"tag_name":' | sed -n 's/.*"tag_name": "\(v[0-9.]*\)".*/\1/p')"

    case "$(uname -m 2>/dev/null)" in
        amd64|x86_64) OS_ARCH="amd64" ;;
        arm64|armv8|aarch64) OS_ARCH="arm64" ;;
        *) die "unsupported cpu architecture." ;;
    esac

    curl -L -O "https://github.com/go-gost/gost/releases/download/${LATEST_VER}/gost_${LATEST_VER#v}_${OS_NAME}_${OS_ARCH}.tar.gz"

    tar fvxz "gost_${LATEST_VER#v}_${OS_NAME}_${OS_ARCH}.tar.gz"


}

main
