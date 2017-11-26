#!/bin/sh
XMONAD_PATH=/usr/bin/xmonad
XTERM=xterm

cd ~

if [ ! -x "$XMONAD_PATH" ] ; then
    echo ".xsession: ${XMONAD_PATH} not exist. trying to exec ${XTERM}" >> $HOME/.xsession-errors
    exec $XTERM
fi

. "${HOME}/.xsession.env"
export LANG XMODIFIER GTK_IM_MODULE QT_IM_MODULE
export _JAVA_AWT_WM_NONREPARENTING=1
unset TMUX
# Get value without colon (e.g. "0" from ":0").
DISPLAY_ID="${DISPLAY:1}"

xrandr -s 0
# Low (less than 1.00) brightness: workaround for (physically) corrupted screen since 2017-06-26.
xrandr --output eDP1 --brightness 0.85
polkit-gnome-authentication-agent-1 &

systemctl --user restart "xsession-start@${DISPLAY_ID}.service"
# About gnome-keyring-daemon, see <https://wiki.archlinux.jp/index.php/GNOME_Keyring>.
#eval $(gnome-keyring-daemon --start --components=secrets)

# `dbus-launch` is required for gpg-agent to use OS's password manager.
exec dbus-launch --exit-with-session $XMONAD_PATH
