#!/bin/sh

CONFFILE="${XDG_CONFIG_HOME:-"${HOME}/.config"}/lo48576.change_wall.conf"

if [ -d "$1" ] ; then
    THEME_DIR="$1"
elif [ -f "${CONFFILE}" ] ; then
    THEME_DIR="$( cat "${CONFFILE}" )"
else
    exit
fi

: ${NUM_DISPLAY:=3}
FILENAMES="$( find "${THEME_DIR}" \( -type f -o -type l \) -print0 | shuf -z -n "${NUM_DISPLAY}" | xargs -0 -P 1 feh --bg-max )"

echo "${FILENAMES}" | tr '\0' ' '
