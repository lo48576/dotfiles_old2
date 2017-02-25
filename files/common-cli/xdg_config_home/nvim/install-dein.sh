#!/bin/sh

CACHE_HOME="${XDG_CACHED_HOME:-"${HOME}/.cache"}"
DEIN_DIR="${CACHE_HOME}/dein"

cd "${DEIN_DIR}"
if [ ! -f installer.sh ] ; then
	curl --fail 'https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh' >installer.sh
fi
sh ./installer.sh .
