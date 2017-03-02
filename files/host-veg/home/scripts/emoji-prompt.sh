#!/bin/sh

# Usage:
# rofi -modi Emoji:~/scripts/emoji-prompt.sh -show Emoji

if [ -z "$@" ] ; then
    awk -F';' '!/^[0-9A-F]*;</ { print $1 ": " $2 }' /usr/share/unicode-data/UnicodeData.txt
else
    CODE="$(echo "$@" | sed -ne 's/^\([0-9A-F]*\):.*/\1/p')"
    #echo "code=${CODE}" >>templog
    CHAR="$(printf "\U${CODE}")"
    #echo "char=${CHAR}" >>templog
    echo -n "$CHAR" | xsel --input --primary
    echo -n "$CHAR" | xsel --input --clipboard
fi
