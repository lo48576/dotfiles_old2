#!/bin/sh

HOST="172.16.11.82"
PORT="6600"

#SEND="curl -s telnet://${HOST}:${PORT}"
SEND="curl --max-time 1 -s telnet://${HOST}:${PORT}"

send_cmd() {
	echo -e "$@\nclose" | $SEND
}

# $1: parameter (volume, repeat, etc...)
get_status() {
	PARAM="$1"
	#send_cmd status | sed -e "/^${PARAM}:/!d" -e 's/^[^:]*: //'
	send_cmd status | sed -ne "/^${PARAM}:/s/^[^:]*: // p"
}

if ! LANG=C nmcli -t -f active,ssid,device dev wifi | grep -q "yes:SSR-NETWORK:wlp2s0" ; then
	# Not 'SSR-NETWORK'.
	exit
fi

#send_cmd "currentsong" | sed -ne 's/^Title: *\(.*\)$/\1/p'
echo -ne 'status\ncurrentsong\nclose' | $SEND \
	| sed -ne 's/^state: *\(.*\)/\1/gp;s/^Title: *\(.*\)$/\1/gp' \
	| tr '\n' '\0' | sed -e 's/\(.*\)\x0\(.*\)\x0/rogyBGM[\1]: \2/'
