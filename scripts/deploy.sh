#!/bin/sh

cd "$(dirname "$0")/.."
APP_BASE_DIR="$(pwd)"


# $1: temporary directory path.
# $2: target name.
# $3: target directory path.
deploy() {
    TARGET_NAME="$2"
    TARGET_DIR="$3"
    TEMP_DIR="$1/${TARGET_NAME}"

    mkdir "${TEMP_DIR}"
    SRC_DIR="${SRC_BASE_DIR}/${TARGET_NAME}"
    if [ -d "${SRC_DIR}" ] ; then
        cp -a "${SRC_DIR}" "${TEMP_DIR}"
    fi
    mkdir -p "${TARGET_DIR}"
    find "${TEMP_DIR}" -mindepth 2 -maxdepth 2 -exec cp -a --remove-destination -t "${TARGET_DIR}" -- '{}' \+
    rm -rf "${TEMP_DIR}"
}


if [ $# -eq 0 ] ; then
    xargs -a ./profile -r -I'{}' "$0" '{}'
elif [ $# -eq 1 ] ; then
    # $1: source directory.
    SRC_BASE_DIR="${APP_BASE_DIR}/files/$1"
    if [ \! -d "${SRC_BASE_DIR}" ] ; then
        exit 0
    fi

    TEMP_BASE_DIR="$(mktemp -d)"
    deploy "${TEMP_BASE_DIR}" "home" "${HOME}"
    deploy "${TEMP_BASE_DIR}" "xdg_config_home" "${XDG_CONFIG_HOME:-"${HOME}/.config"}"
    rm -rf "${TEMP_BASE_DIR}"
fi
