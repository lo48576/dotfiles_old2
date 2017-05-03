#!/bin/sh

# Usage:
# rofi -modi Wifi:~/scripts/rofi-wifi.sh -show Wifi

show_list() {
    #nmcli dev wifi
    # SSID should be the last field because they may have special characters.
    echo -e "接続中\t周波数\t\t強度\tSSID"
    CHECK_MARK="$(echo -e '\u2713')"
    LANG=en_US.UTF-8 nmcli --mode tabular --escape no --terse --fields active,freq,signal,ssid dev wifi | \
        sed -E 's/^([^:]*):([^:]*):([^:]*):(.*)$/\1\t\2\t\3\t\4/' | \
        sed -e 's/^yes/  '"$CHECK_MARK"'/' -e 's/^no//'
}

if [ -z "$@" ] ; then
    show_list
else
    if echo "$@" | grep -q '^接続中' ; then
        # Header is selected.
        show_list
        exit
    else
        SSID="$(echo "$@" | sed -e 's/[^\t]*\t[^\t]*\t[^\t]*\t\(.*\)/\1/')"
        nohup nmcli con up ifname wlp2s0 ap "${SSID}" >/dev/null &
    fi
fi
