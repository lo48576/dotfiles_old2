#!/bin/sh

if [ ! -d "$IMAGES_DIR" ] ; then
    echo "ERROR: Images directory (\$IMAGES_DIR) is not specified or not a directory."
    exit 1
fi

: ${NUM_DISPLAY:=1}
FILENAMES="$( find "${IMAGES_DIR}" \( -type f -o -type l \) -print0 | shuf -z -n "${NUM_DISPLAY}" | xargs -0 -P 1 feh --bg-max )"

echo "${FILENAMES}" | tr '\0' ' '
