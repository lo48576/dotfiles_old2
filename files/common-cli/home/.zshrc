# Zsh Global {{{1
#
# Zsh Global
#

# Path to completion and prompts configuration
fpath=(
	${HOME}/.zsh/functions/*(N-/)
	${fpath})

# }}}1 Zsh Global


# Zsh History {{{1
#
# History
#

# History file
HISTFILE=${HISTFILE:-${HOME}/.zsh_histfile}
# Number of histories to save on memory
HISTSIZE=1000000
# Number of histories to save on file
SAVEHIST=1000000000

# Ignore duplicate command-line in history
setopt hist_ignore_all_dups
# Ignore duplicate command-line of the previous command-line
setopt hist_ignore_dups
# Never remember command-line which begins with whitespace
setopt hist_ignore_space
# Share command history data
setopt share_history

# }}}1 Zsh History


# Environment variables {{{1
#
# Environment Variables
#

# `go`
# golang packages directory
export GOPATH=${HOME}/.go

# PATH {{{2
#
# PATH
#

typeset -U path
# path(foo): 条件fooにマッチするパスのみ残す。
# 条件:
#   N: NULL_GLOBオプションを設定。
#      globがマッチしない場合や存在しないパスであった場合無視する。
#   -: シンボリックリンクそのものでなく、その指す先のファイルに評価する。
#   /: ディレクトリのみを残す。

# system
path=(
	$path
	/usr/libexec(N-/)
	)

# User-local binary directory to which some package managers
# of languages install packages.
path=(
	# cargo crates (rust)
	${CARGO_HOME:-${HOME}/.cargo}/bin(N-/)
	# ruby gems (ruby)
	#   You can use
	#       `ruby -e 'require "rubygems"; puts Gem::bindir'`
	#   or
	#       `ruby -rubygems -e 'puts Gem.bindir'`
	#   instead of using `gem`.
	#   `gem` is 6x or more slower than using `ruby` directly.
	$(whence ruby gem >/dev/null && ruby -rubygems -e 'puts Gem.bindir')(N-/)
	# pip (python)
	$(whence python >/dev/null && python -m site --user-base)/bin(N-/)
	# npm (javascript)
	# FIXME: `npm bin` is too slow... (it takes more than 0.4s)
	#$(whence npm >/dev/null && npm bin 2>/dev/null)(N-/)
	#${HOME}/node_modules/.bin(N-/)
	# go (golang)
	${GOPATH}/bin(N-/)
	$path)

# User-local directories.
path=(
	${HOME}/bin(N-/)
	${HOME}/app{,32,64}/*(N-/)
	${HOME}/scripts(N-/)
	#${HOME}/local/bin(N-/)
	$path)

# For `sudo`.
# Root already has these paths in $PATH,
# so the settings below is for non-root users.
if [[ $EUID -ne 0 ]] ; then
	typeset -xT SUDO_PATH sudo_path
	typeset -U sudo_path
	sudo_path=(
		/usr/local/sbin(N-/)
		/usr/sbin(N-/)
		/sbin(N-/)
		$sudo_path)
	path=($path $sudo_path)
fi

export PATH
# }}}2 PATH

#
# MANPATH
#
typeset -U manpath
manpath=(
	#${HOME}/local/share/man(N-/)
	#${HOME}/local/man(N-)
	$manpath
	"")
# MANPATHの末尾にコロン(:)があると、システム全体の検索パスが末尾に追加される。
# MANPATHの先頭にコロン(:)があると、システム全体の検索パスが先頭に追加される。
# 空文字列をmanpathの最後に追加することで、MANPATHの最後にコロンを付ける。
export MANPATH

#
# INCLUDE
#
typeset -U include
include=(
	#${HOME}/local/include(N-/)
	$include)
export INCLUDE

#
# LD_LIBRARY_PATH
#
typeset -xT LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path
ld_library_path=(
	#${HOME}/local/lib(N-/)
	$(whence rustc >/dev/null && rustc +nightly --print sysroot)/lib(N-/)
	$ld_library_path)

# LANG and TERM {{{2
#
# LANG and TERM
#

# Distinguish terminal emulator and terminal multiplexer
case $TERM in
	linux)
		# virtual console (such as getty, agetty...)
		ZSHRC_TERMINAL_EMULATOR="linux"
		;;
	screen*|tmux*)
		if [[ -n $TMUX ]] ; then
			ZSHRC_TERMINAL_MULTIPLEXER="tmux"
		else
			ZSHRC_TERMINAL_MULTIPLEXER="screen"
		fi
		;;
	mlterm*)
		ZSHRC_TERMINAL_EMULATOR="mlterm"
		;;
esac
if [[ -n $MLTERM ]] ; then
	# mlterm
	ZSHRC_TERMINAL_EMULATOR="mlterm"
elif [[ -n $XTERM_VERSION ]] ; then
	ZSHRC_TERMINAL_EMULATOR="xterm"
elif [[ $COLORTERM == "gnome-terminal" ]] ; then
	ZSHRC_TERMINAL_EMULATOR="gnome-terminal"
fi

if [[ -n $TERM ]] ; then
    ZSHRC_TERMINAL_EMULATOR=${ZSHRC_TERMINAL_EMULATOR:-linux}
else
    ZSHRC_TERMINAL_EMULATOR="noterm"
fi

export ZSHRC_TERMINAL_EMULATOR
export ZSHRC_TERMINAL_MULTIPLEXER

# Set $LANG and $TERM.
# I can see only 16 colors on tty1-6 (agetty),
# so 'LANG="ja_JP.UTF-8"' is not always adequate.
function {
	local USER_DEFAULT_LANG="ja_JP.UTF-8"
	case $ZSHRC_TERMINAL_EMULATOR in
		mlterm)
			LANG=$USER_DEFAULT_LANG
			TERM="mlterm-256color"
			;;
		xterm|gnome-terminal)
			LANG=$USER_DEFAULT_LANG
			TERM="xterm-256color"
			;;
		linux)
			LANG="C"
			;;
        noterm)
            LANG=$USER_DEFAULT_LANG
            ;;
		*)
			LANG="C"
			;;
	esac
	case $ZSHRC_TERMINAL_MULTIPLEXER in
		screen|tmux)
			# ON GNU screen or tmux,
			# use setting of the parent process.
			# default: C
			if [[ -n $LANG && $LANG != "C" ]] ; then
				LANG=$USER_DEFAULT_LANG
			fi
			;;
	esac
	case $ZSHRC_TERMINAL_MULTIPLEXER in
		screen)
			TERM="screen-256color"
			;;
		tmux)
			TERM="tmux-256color"
			;;
	esac
}

if [[ $EUID -eq 0 ]] ; then
	LANG="C"
fi

export LANG
export TERM

# }}}2 LANG and TERM

#
# Other locales
#
export LC_TIME="C"

# Applicatinso Global {{{2
#
# Applications Global
#

# EDITOR
if whence -p nvim >/dev/null ; then
	export EDITOR="nvim"
elif whence -p vim >/dev/null ; then
	export EDITOR="vim"
elif whence -p vi >/dev/null ; then
	export EDITOR="vi"
fi

# PAGER
# `less` may exist on all environment...
export PAGER="less"
# Options for less
# -xn (--tabs=n): Set tabstops.
# -X (--no-init): Disable sending the termcap initialization and
#                 deinitialization string to the terminal.
# -M (--LONG-PROMPT): Causes less to prompt even more verbosely than `more`.
# -i (--ignore-case): Causes searches to ignore case except when a search
#                     pattern contains uppercase letters.
# -I (--IGNORE-CASE): Like -i, but always ignore case.
# -R (--RAW-CONTROL-CHARS): Causes ANSI color escape sequences are output in "raw" form.
export LESS='-x4 -XMiR'

# }}}2 Applications Global

# Applications Local {{{2
#
# Applications local
#

# `ls` (LS_COLORS)
if [[ -f "${HOME}/.dir_colors" ]] ; then
	eval $(dircolors -b "${HOME}/.dir_colors")
fi

# `time` (zsh built-in)
# Show `time` result when a process runs more than 30 cpu time
REPORTTIME=30
TIMEFMT="job: %J
User: %U
Kernel: %S
Elapsed: %E
CPU: %P"

type rustc >/dev/null 2>&1 && export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# }}}2 Applications Local

# }}}1 Environment variables


# Prompt Style {{{1
#
# Prompt Style
#

#autoload -Uz colors && colors
autoload -Uz promptinit && promptinit

# Set prompt
#prompt larry1
prompt larry2

# }}}1 Prompt Style


# Completion {{{1
#
# Completion
#

# Load completion feature
autoload -Uz compinit
# `-C` is for faster boot.
# -C: skip security check (see http://zsh.sourceforge.net/Doc/Release/Completion-System.html#index-compinit )
compinit -C

#
# General
#
zstyle :compinstall filename "${ZDOTDIR:-${HOME}}/.zshrc"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# Use cache for the completion
zstyle ':completion::complete:*' use-cache 1

# Use compact list when there is lots of items
setopt list_packed

# No beep on completion
setopt no_listbeep

# Allow implicit conversion from lower alphabets to capitals on completion search.
# (Note that capitals are not converted to lowers.)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#
# Files and Directories
#

# replace ':' (colon) with ' ' (whitespace).
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

#
# `man`
#

# Separate by sections.
zstyle ':completion:*:manuals' separate-sections true
# "manual page, section xx" という文字列が候補に埋もれて見辛いので、
# スタイルを変える
zstyle ':completion:*:*:man:*:manuals.*' format '%F{yellow}%B%U%d%u%b%f'

#
# `kill`
#
# プロセスの候補をプロセスツリーで表示する。

# style: pid(yellow) %cpu(cyan) tty(blue) [user(green)] cmd(yellow and red)
zstyle -e ':completion:*:*:*:*:processes' command \
	'if (( $funcstack[(eI)$_comps[sudo]] )) ; then \
		reply="ps --forest -e -o pid,%cpu,tty,user,cmd" \
	else \
		reply="ps --forest -u $USER -o pid,%cpu,tty,cmd" \
	fi'
zstyle ':completion:*:*:*:*:processes' list-colors \
	"=(#b) #([0-9]#) #([0-9]#.[0-9]#) #([^ ]#) #([A-Za-z][A-Za-z0-9\-_.]#)# #([\|\\_ ]# )([^ ]#)*=31=33=36=34=32=36=33"
# プロセスツリーで表示するので、勝手にソートされるとツリーが崩れるため、ソートを無効化。
zstyle ':completion:*:*:*:*:processes' sort false
# Show completion list (process tree) always
zstyle ':completion:*:*:kill:*' force-list always

# `killall`
zstyle -e ':completion:*:processes-names' command \
	'if (( $funcstack[(eI)$_comps[sudo]] )) ; then \
		reply="ps -e -o cmd" \
	else \
		reply="ps -u $USER -o cmd" \
	fi'

# `sudo`
zstyle ':completion:*:sudo:*' command-path $path

# `npm`
if whence npm >/dev/null ; then
	function {
		local npm_completion_file=${HOME}/.zsh/functions/Completion/_npm
		# NOTE: `npm` is very slow, so cache the result.
		[[ -e $npm_completion_file ]] || npm completion >$npm_completion_file
		source "$npm_completion_file"
	}
fi


# }}}1 Completion


# Command Line and Input {{{1
#
# Command Line and Input
#

#
# Prompt and Command Line
#

# Enable typo correction
setopt correct

# Use beep
setopt beep

# Change current directory without "cd"
setopt autocd

# Don't remove trailing slash of command line automatically
setopt no_autoremoveslash

# Kill the delay after hitting <ESC>.
export KEYTIMEOUT=1

# Keys {{{2
#
# Keys
#

# Suppose to use dvorak layout at typo correction
setopt dvorak

# Vim-like key binding
bindkey -v

# Incremental search with ^P and ^N (like vim)
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# Disable execution of the last command with 'r'.
# You can do it with history or incremental search
disable r

function {
	# for detail, see
	# https://wiki.archlinuxjp.org/index.php/Zsh#.E3.82.AD.E3.83.BC.E3.83.90.E3.82.A4.E3.83.B3.E3.83.89
	typeset -A key
	key[Home]=${terminfo[khome]}
	key[End]=${terminfo[kend]}
	key[Insert]=${terminfo[kich1]}
	key[Delete]=${terminfo[kdch1]}
	key[BackSpace]=${terminfo[kbs]}

	[[ -n ${key[Home]}      ]] && bindkey "${key[Home]}"      beginning-of-line
	[[ -n ${key[End]}       ]] && bindkey "${key[End]}"       end-of-line
	[[ -n ${key[Insert]}    ]] && bindkey "${key[Insert]}"    overwrite-mode
	[[ -n ${key[Delete]}    ]] && bindkey "${key[Delete]}"    delete-char
	# NOTE: Some terminal may has wrong sequence as key[BackSpace]...
	[[ -n ${key[BackSpace]} ]] && bindkey "${key[BackSpace]}" backward-delete-char

	[[ -n ${key[Home]}      ]] && bindkey -M vicmd "${key[Home]}"      beginning-of-line
	[[ -n ${key[End]}       ]] && bindkey -M vicmd "${key[End]}"       end-of-line
	[[ -n ${key[Delete]}    ]] && bindkey -M vicmd "${key[Delete]}"    delete-char
	[[ -n ${key[BackSpace]} ]] && bindkey -M vicmd "${key[BackSpace]}" backward-char
}

# Ctrl-H
bindkey "^H"    backward-delete-char
# Backspace (in some terminal like tmux)
bindkey "^?"    backward-delete-char

# Push command to stack (Esc-q at emacs binding)
# Ctrl+7 (in dvorak, Shift+7 is '&'.)
# You can use Ctrl+- (Shift+- is '_'.)
bindkey '^_' push-line
# Esc, then 'q'
bindkey -a 'q' push-line

# Show help with `Esc H`
#bindkey -a 'H' run-help

cdup() {
	# skip lines to leave old prompt
	echo ; echo
	cd ..
	type precmd >/dev/null 2>&1 && precmd
	for __pre_func in $precmd_functions ; do $__pre_func ; done
	zle reset-prompt
}
zle -N cdup
# `cd ../` by Ctrl-6 (in US Keyboard).
# If you want to type "^^"(Ctrl-^), `Ctrl-V Ctrl-6`.
bindkey '^^' cdup

# }}}2 Keys

# }}}1 Command Line and Input


# External Plugins and Settings {{{1
#
# External Plugins and Settings
#

#
# Load other zsh configs if exist
#

# autoload functions in ${HOME}/.zsh/functions/myfuncs/
autoload -Uz ${HOME}/.zsh/functions/myfuncs/*(:t)

# `+X`: load function immediately.
autoload +XUz mytmux

# Aliases
[[ -f ${HOME}/.zshrc.alias ]] && source "${HOME}/.zshrc.alias"
# Host-dependent settings
[[ -f ${HOME}/.zshrc.local ]] && source "${HOME}/.zshrc.local"

#
# Plugins
#

# zsh-syntax-highlighting
[[ -f ${HOME}/.zsh/zsh-syntax-highlighting.zsh.local ]] && source "${HOME}/.zsh/zsh-syntax-highlighting.zsh.local"


# }}}1 External Plugins and Settings


# Application {{{1
#
# Application
#

# tmux
if [[ -n $TMUX ]] ; then
	# Set window title.
	# #T: pane_title
	# #W: window_name
	# #S: session_name
	tmux set set-titles-string '#T [[#W]] #S - tmux'
fi

# gpg-agent
false && () {
	# Start the gpg-agent if not already running.
	if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
		gpg-connect-agent /bye >/dev/null 2>&1
	fi

	# Set SSH to use gpg-agent.
	unset SSH_AGENT_PID
	if [[ ${gnupg_SSH_AUTH_SOCK_by:-0} -ne $$ ]] ; then
		export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh
	fi
	# Set GPG TTY.
	export GPG_TTY=$(tty)

	# Refresh gpg-agent tty in case user switches into an X session.
	gpg-connect-agent updatestartuptty /bye >/dev/null
}

# }}}1 Application


# Widgets {{{1
#
# Define and register widgets
#

# Select git reposiotories.
# See http://ubnt-intrepid.hatenablog.com/entry/rhq .
function __fuzzy-select-repositories() {
    local selected=$(rhq list | sk --prompt='REPOS> ' --query="$LBUFFER")
    if [[ -n $selected ]]; then
        BUFFER=" cd \"${selected}\""
        zle accept-line
    fi
    zle clear-screen
}
zle -N __fuzzy-select-repositories
bindkey '^g' __fuzzy-select-repositories

# }}}1


# Initialize {{{1
#
# Initialize
#

if [[ -n $TERM ]] ; then
    # Print information about terminal
    echo "terminal emulator: ${ZSHRC_TERMINAL_EMULATOR}"
    echo "terminal multiplexer: ${ZSHRC_TERMINAL_MULTIPLEXER}"
    echo "terminal: ${TERM}"
    echo "language: ${LANG}"
fi

#if (which zprof >/dev/null) ; then
#	zprof | less
#fi

# }}}1

# vim: set foldmethod=marker :
