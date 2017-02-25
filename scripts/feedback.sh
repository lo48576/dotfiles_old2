#!/bin/sh

cd "$(dirname "$0")/.."
APP_BASE_DIR="$(pwd)"


# $1: temporary directory path.
# $2: source directory base path.
# $3: target name.
# $4: target directory path.
collect() {
    SOURCE_BASE_DIR="$2"
    TARGET_NAME="$3"
    TARGET_DIR="$4"
    TEMP_DIR="$1/${TARGET_NAME}"
    SRC_DIR="${SRC_BASE_DIR}/${TARGET_NAME}"
    mkdir -p "${TEMP_DIR}"

    if [ -d "${SRC_DIR}" ] ; then
        cd "${SRC_DIR}"
        find . -mindepth 1 \( -type d -exec mkdir -p -- "${TEMP_DIR}/{}" \; \) -o \( -type f -exec cp -f -- "${TARGET_DIR}/{}" "${TEMP_DIR}/{}" \; \)
        cd "${APP_BASE_DIR}"
    fi
}

# $1: temporary directory path.
# $2: source directory base path.
# $3: target name.
# $4: target directory path.
distribute() {
    SRC_DIR="$2"
    TARGET_NAME="$3"
    TARGET_DIR="$4"
    TEMP_DIR="$1/${TARGET_NAME}"
    SRC_DIR="${SRC_BASE_DIR}/${TARGET_NAME}"

    if [ -d "${SRC_DIR}" ] ; then
        cd "${SRC_DIR}"
        find . -mindepth 1 -type f -exec cp -a --remove-destination -- "${TEMP_DIR}/{}" "${SRC_DIR}/{}" \; -exec rm "${TEMP_DIR}/{}" \;
        cd "${APP_BASE_DIR}"
    fi
}


if [ $# -eq 0 ] ; then
    TEMP_BASE_DIR="$(mktemp -d)"
    xargs -a ./profile -r -I'{}' "$0" collect "${TEMP_BASE_DIR}" '{}'
    tac ./profile | xargs -r -I'{}' "$0" distribute "${TEMP_BASE_DIR}" '{}'
    rm -rf "${TEMP_BASE_DIR}"
elif [ $# -eq 3 ] ; then
    # $1: mode.
    # $2: temporary directory.
    # $3: source directory.
    MODE="$1"
    TEMP_BASE_DIR="$2"
    SRC_BASE_DIR="${APP_BASE_DIR}/files/$3"
    if [ \! -d "${SRC_BASE_DIR}" ] ; then
        exit 0
    fi

    case "${MODE}" in
        collect)
            collect "${TEMP_BASE_DIR}" "${SRC_BASE_DIR}" "home" "${HOME}"
            collect "${TEMP_BASE_DIR}" "${SRC_BASE_DIR}" "xdg_config_home" "${XDG_CONFIG_HOME:-"${HOME}/.config"}"
            ;;
        distribute)
            distribute "${TEMP_BASE_DIR}" "${SRC_BASE_DIR}" "home" "${HOME}"
            distribute "${TEMP_BASE_DIR}" "${SRC_BASE_DIR}" "xdg_config_home" "${XDG_CONFIG_HOME:-"${HOME}/.config"}"
            ;;
        *)
            ;;
    esac
fi

