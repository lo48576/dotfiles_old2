# Declares a block.
# $1: Block description.
# $2: Disabled flag. If `disabled`, the function will fail.
block() {
    [[ ${2:-} != 'disabled' ]]
}

# Chooses an executable command from the list and prints it.
# $1: List of commands.
get_command() {
    typeset -a commands
    commands=(${(s/:/)1})
    for com in $commands ; do
        if whence $com >/dev/null ; then
            echo $com
            return 0
        fi
    done
}

# Exports the variable if not empty.
# $1: Variable name or `varname=value` style string.
# $2: Unset flag. If `unset`, the variable `$1' may be unset.
export_nonempty() {
    local varname=${1%%=*}
    [[ -z $varname ]] && return 1
    local unset_flag=${2:-}

    if [[ $varname == $1 ]] ; then
        # Only varname is given.
        if [[ -n ${(P)varname:-} ]] ; then
            export $varname
        elif [[ $unset_flag == 'unset' ]] ; then
            unset $varname
        fi
        return 0
    fi
    local value=${1#*=}
    if [[ -n $value ]] ; then
        export $varname=$value
    elif [[ $unset_flag == 'unset' ]] ; then
        unset $varname
    fi
}

# Unsets the variable if empty.
# $1: Variable name or `varname=value` style string.
unset_empty() {
    local varname=${1%%=*}
    [[ -z $varname ]] && return 1

    if [[ $varname == $1 ]] ; then
        # Only varname is given.
        if [[ -z ${(P)varname} ]] ; then
            unset $varname
        fi
        return 0
    fi
    local value=${1#*=}
    if [[ -z $value ]] ; then
        unset $varname
    else
        typeset -g $varname=$value
    fi
}

# Exports a variable if the constructed path is directory path.
# $1: Variable name to export (or unset).
# $2: Path prefix (which should exist and should be directory).
# $3: Path suffix.
# $4: Unset flag. If `unset`, the variable `$1' may be unset.
export_suffix_dir() {
    local varname=$1
    local prefix=$2
    local suffix=$3
    local unset_flag=${4:-}
    local p=${prefix}${suffix}
    if [[ -d $prefix && -d $p ]] ; then
        export ${varname}=$p
    elif [[ $unset_flag == 'unset' ]] ; then
        unset ${varname}
    fi
}

# Zshrc-local variables.
typeset -gA _zshrc

# Default configs which don't require external command invocation.
block 'Default constants' && {
    block 'Config paths' && {
        _zshrc[config_path.dir_colors]=${HOME}/.dir_colors
        _zshrc[config_path.npm.completion]=${HOME}/.zsh/functions/Completion/_npm
    }
    block 'Zsh params' && {
        block 'time' && () {
            # Show `time` result when a process runs more than 30 cpu seconds.
            _zshrc[zsh.time.REPORTTIME]=30
            local timefmt=(
                'job: %J'
                'User: %U'
                'Kernel: %S'
                'Elapsed: %E'
                'CPU: %P'
                )
            _zshrc[zsh.time.TIMEFMT]=$(print -l $timefmt)
        }
        block 'History' && {
            # History file.
            _zshrc[zsh.hist.HISTFILE]=${HISTFILE:-${HOME}/.zsh_histfile}
            # Number of histories to save on memory.
            _zshrc[zsh.hist.HISTSIZE]=1000000
            # Number of histories to save on file.
            _zshrc[zsh.hist.SAVEHIST]=1000000000
        }
    }
    block 'Envvars' && {
        _zshrc[env.LANG.default]='ja_JP.UTF-8'
        _zshrc[env.PATH.initial]=$PATH
    }
    block 'Application-specific stuff' && {
        block 'Golang' && {
            # Golang base directory.
            _zshrc[env.GOPATH]=${GOPATH:-${HOME}/.go}
            # Golang binaries directory.
            _zshrc[bindir.go]=${_zshrc[env.GOPATH]:+$_zshrc[env.GOPATH]/bin}
        }
        block 'Rustlang' && {
            # Cargo base directory.
            _zshrc[env.CARGO_HOME]=${CARGO_HOME:-${HOME}/.cargo}
            # Cargo binaries directory.
            _zshrc[bindir.cargo]=${_zshrc[env.CARGO_HOME]:+$_zshrc[env.CARGO_HOME]/bin}
        }
    }
    block 'Acceptable commands' && {
        # `less` may exist on all environment...
        _zshrc[commands.pager]='less'
        _zshrc[commands.editor]='nvim:vim:vi:nano'
        _zshrc[commands.visual]=$_zshrc[commands.editor]
    }
}

# Set PATH temporarily (to use later).
block 'Set PATH temporarily only with constants' && {
    block 'PATH' && {
        typeset -U path

        # System paths.
        path=(
            $path
            /usr/libexec(N-/)
            )

        # User-local binary directory to which some package managers
        # of languages install packages.
        block 'Programming languages' && () {
            local bindir
            for bindir in ${(@Mk)_zshrc:#bindir.*} ; do
                path=(
                    $_zshrc[$bindir](N-/)
                    $path)
            done
        }

        # Remove world-writable directories.
        #
        # * `N`: Take only paths which exist.
        # * `-/`: Take only directories.
        # * `^W`: Take only non-world-writable paths.
        # * `${^spec}`: Enable `RC_EXPAND_PARAM`.
        path=(${^path}(N-/^W))

        export PATH
    }
}

# Gets parameters using external commands.
block 'Get parameters with external binaries' && {
    block 'Rustlang' && {
        # Rustc sysroot.
        _zshrc[app_base.rustc.sysroot]=$(whence rustc >/dev/null && rustc --print sysroot)
        # Rustc nightly sysroot.
        _zshrc[app_base.rustc.sysroot.nightly]=$(whence rustup >/dev/null && rustup run nightly rustc --print sysroot)
    }
    block 'Ruby' && {
        # Gem binaries directory.
        #   You can use
        #       `ruby -e 'require "rubygems"; puts Gem::bindir'`
        #   or
        #       `ruby -rubygems -e 'puts Gem.bindir'`
        #   instead of using `gem`.
        #   `gem` is 6x or more slower than using `ruby` directly.
        _zshrc[bindir.gem]=$(whence ruby gem >/dev/null && ruby -rubygems -e 'puts Gem.bindir')
    }
    block 'Python' && {
        # Pip base directory.
        _zshrc[app_base.pip]=$(whence python >/dev/null && python -m site --user-base)
        # Pip binaries directory.
        export_suffix_dir '_zshrc[bindir.pip]' $_zshrc[app_base.pip] '/bin' unset
    }
    block 'Javascript' && {
        # Npm binaries directory.
        # FIXME: `npm bin` is too slow... (it takes more than 0.4s)
        #_zshrc[bindir.npm]=$(whence npm >/dev/null && npm bin 2>/dev/null)
        #_zshrc[bindir.npm]=${HOME}/node_modules/.bin
    }
}

# Zsh-global stuff.
block 'Zsh global' && {
    block 'fpath' && {
        # Path to completion and prompts configuration
        fpath=(
            ${HOME}/.zsh/functions/*(N-/)
            $fpath)
    }

    block 'History' && {
        # History file.
        unset_empty HISTFILE=$_zshrc[zsh.hist.HISTFILE]
        # Number of histories to save on memory.
        unset_empty HISTSIZE=$_zshrc[zsh.hist.HISTSIZE]
        # Number of histories to save on file
        unset_empty SAVEHIST=$_zshrc[zsh.hist.SAVEHIST]

        # Ignore duplicate command-line in history
        setopt hist_ignore_all_dups
        # Ignore duplicate command-line of the previous command-line
        setopt hist_ignore_dups
        # Never remember command-line which begins with whitespace
        setopt hist_ignore_space
        # Share command history data
        setopt share_history
    }
}

# Environment variables (including complete `PATH`.
block 'Environment variables' && {
    block 'Applications' && {
        block 'Golang' && {
            # `go`
            # Golang packages directory
            export_nonempty GOPATH=$_zshrc[env.GOPATH]
        }

        block 'Rustlang' && {
            # `cargo`
            export_nonempty CARGO_HOME=$_zshrc[env.CARGO_HOME]
        }
    }

    block 'Common environment variables' && {
        # About `(N-/)`, see Zsh Manual 14.8.7 Glob Qualifiers
        # <http://zsh.sourceforge.net/Doc/Release/Expansion.html#Glob-Qualifiers>.
        #
        #   * `N`: sets the `NULL_GLOB` option for the current pattern.
        #   * `-`: follow symlinks.
        #   * `/`: directories.
        block 'PATH' && {
            typeset -U path

            # Clear temporary paths.
            PATH=$_zshrc[env.PATH.initial]

            # System paths.
            path=(
                $path
                /usr/libexec(N-/)
                )

            # User-local binary directory to which some package managers
            # of languages install packages.
            block 'Programming languages' && () {
                local bindir
                for bindir in "${(@Mk)_zshrc:#bindir.*}" ; do
                    path=(
                        $_zshrc[$bindir](N-/)
                        $path)
                done
            }

            # User-local directories.
            path=(
                ${HOME}/bin(N-/)
                ${HOME}/app{,32,64}/*(N-/)
                ${HOME}/scripts(N-/)
                $path)

            # For `sudo`.
            # Root user already has these paths in $PATH,
            # so the settings below is for non-root users.
            if [[ $EUID -ne 0 ]] ; then
                typeset -xT SUDO_PATH sudo_path
                typeset -U sudo_path
                sudo_path=(
                    /usr/local/sbin(N-/)
                    /usr/sbin(N-/)
                    /sbin(N-/)
                    $sudo_path)
                path+=($sudo_path)
            fi

            # Remove world-writable directories.
            #
            # * `N`: Take only paths which exist.
            # * `-/`: Take only directories.
            # * `^W`: Take only non-world-writable paths.
            # * `${^spec}`: Enable `RC_EXPAND_PARAM`.
            path=(${^path}(N-/^W))

            export PATH
        }

        block 'MANPATH' && {
            typeset -U manpath
            # See `man 1 manpath`.
            #
            # > If `$MANPATH` is prefixed by a colon, then the value of the variable is appended
            # > to the list determined from the content of the configuration files.
            # > If the colon comes at the end of the value in the variable,
            # > then the determined list is appended to the content of the variable.
            # > If the value of the variable contains a double colon (`::`),
            # > then the determined list is inserted in the middle of the value, between the two colons.
            #
            # Append `:` to `$MANPATH` by appending empty string to `$manpath`.
            manpath=(
                $manpath
                '')
            export MANPATH
        }

        block 'INCLUDE' && {
            typeset -U include
            include=(
                $include)
            export INCLUDE
        }

        block 'LD_LIBRARY_PATH' && {
            typeset -xT LD_LIBRARY_PATH ld_library_path
            typeset -U ld_library_path
            () {
                local rustc_sysroot_nightly=$_zshrc[app_base.rustc.sysroot.nightly]
                ld_library_path=(
                    ${rustc_sysroot_nightly:+${rustc_sysroot_nightly}/lib}(N-/)
                    $ld_library_path)
            }
        }
    }

    block 'LANG and TERM' && {
        block 'Distinguish terminal and terminal multiplexer' && {
            # Distinguish terminal emulator and terminal multiplexer
            case $TERM in
                linux)
                    # virtual console (such as getty, agetty...)
                    _zshrc[terminal.emulator]='linux'
                    ;;
                screen*|tmux*)
                    # tmux or GNU screen.
                    if [[ -n $TMUX ]] ; then
                        _zshrc[terminal.multiplexer]='tmux'
                    else
                        _zshrc[terminal.multiplexer]='screen'
                    fi
                    ;;
                mlterm*)
                    # mlterm.
                    _zshrc[terminal.emulator]='mlterm'
                    ;;
            esac

            if [[ -n $MLTERM ]] ; then
                # mlterm.
                _zshrc[terminal.emulator]='mlterm'
            elif [[ -n $XTERM_VERSION ]] ; then
                # xterm.
                _zshrc[terminal.emulator]='xterm'
            elif [[ $COLORTERM == 'gnome-terminal' ]] ; then
                # GNOME terminal.
                _zshrc[terminal.emulator]='gnome-terminal'
            fi

            if [[ -n $TERM ]] ; then
                _zshrc[terminal.emulator]=${_zshrc[terminal.emulator]:-linux}
            fi
        }

        # Set $LANG and $TERM.
        # I can see only 16 colors on tty (agetty),
        # so 'LANG="ja_JP.UTF-8"' is not always adequate.
        block 'Set TERM and LANG' && {
            case $_zshrc[terminal.emulator] in
                mlterm)
                    LANG=$_zshrc[env.LANG.default]
                    TERM='mlterm-256color'
                    ;;
                xterm|gnome-terminal)
                    LANG=$_zshrc[env.LANG.default]
                    TERM='xterm-256color'
                    ;;
                linux)
                    LANG='C'
                    ;;
                '')
                    LANG=$_zshrc[env.LANG.default]
                    ;;
                *)
                    LANG='C'
                    ;;
            esac
            case $_zshrc[terminal.multiplexer] in
                screen|tmux)
                    # ON GNU screen or tmux,
                    # use setting of the parent process.
                    # default: C
                    if [[ -n $LANG && $LANG != 'C' ]] ; then
                        LANG=$_zshrc[env.LANG.default]
                    fi
                    ;;
            esac
            case $_zshrc[terminal.multiplexer] in
                screen)
                    TERM='screen-256color'
                    ;;
                tmux)
                    TERM='tmux-256color'
                    ;;
            esac

            # Use `C` locale with root user.
            if [[ $EUID -eq 0 ]] ; then
                LANG='C'
            fi

            export_nonempty LANG
            export_nonempty TERM
        }

        block 'Other locale settings' && {
            export LC_TIME='C'
        }
    }
}

# Configs which may be used with multiple commands.
block 'Applications global' && {
    block 'Editors' && {
        # EDITOR.
        export_nonempty EDITOR=$(get_command $_zshrc[commands.editor])

        # VISUAL.
        export_nonempty VISUAL=$(get_command $_zshrc[commands.visual])
    }

    block 'Pager' && {
        # PAGER.
        export_nonempty PAGER=$(get_command $_zshrc[commands.pager])

        # Options for `less`.
        # -xn (--tabs=n): Set tabstops.
        # -X (--no-init): Disable sending the termcap initialization and
        #                 deinitialization string to the terminal.
        # -M (--LONG-PROMPT): Causes less to prompt even more verbosely than `more`.
        # -i (--ignore-case): Causes searches to ignore case except when a search
        #                     pattern contains uppercase letters.
        # -I (--IGNORE-CASE): Like -i, but always ignore case.
        # -R (--RAW-CONTROL-CHARS): Causes ANSI color escape sequences are output in "raw" form.
        export LESS='-x4 -XMiR'

        if whence src-hilite-lesspipe.sh >/dev/null ; then
            export LESSOPEN='| src-hilite-lesspipe.sh %s 2>&-'
        fi
    }

    block 'Zsh builtins' && {
        # For `time` command (zsh built-in).
        unset_empty REPORTTIME=$_zshrc[zsh.time.REPORTTIME]
        unset_empty TIMEFMT=$_zshrc[zsh.time.TIMEFMT]
    }
}

# Configs which may be used from single applications.
block 'Application' && {
    block 'tmux' && {
        if [[ -n $TMUX ]] ; then
            # Set window title.
            # #T: pane_title
            # #W: window_name
            # #S: session_name
            tmux set set-titles-string '#T [[#W]] #S - tmux'
        fi
    }

    block 'ls' && {
        # `ls` (LS_COLORS)
        if [[ -f $_zshrc[config_path.dir_colors] ]] && whence dircolors >/dev/null ; then
            eval $(dircolors -b $_zshrc[config_path.dir_colors])
        fi
    }

    block 'Rust' && () {
        if whence rustc >/dev/null ; then
            export_suffix_dir RUST_SRC_PATH $_zshrc[app_base.rustc.sysroot] '/lib/rustlib/src/rust/src' unset
        fi
    }

    block 'gpg-agent' disabled && {
        # gpg-agent
        # Start the gpg-agent if not already running.
        if ! pgrep -x -u ${USER} gpg-agent >/dev/null 2>&1; then
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
}

# Prompt style settings.
block 'Prompt style' && {
    #autoload -Uz colors && colors
    autoload -Uz promptinit && promptinit

    # Set prompt
    prompt larry2
}

# Completion settings.
block 'Completion' && {
    # Load completion feature.
    autoload -Uz compinit
    # `-C` is for faster boot.
    # -C: skip security check (see <http://zsh.sourceforge.net/Doc/Release/Completion-System.html#index-compinit>).
    compinit -C

    block 'General' && {
        zstyle :compinstall filename ${ZDOTDIR:-${HOME}}/.zshrc
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
    }

    block 'Files and directories' && {
        # replace ':' (colon) with ' ' (whitespace).
        zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    }

    block 'man' && {
        # Separate by sections.
        zstyle ':completion:*:manuals' separate-sections true
        # Change style because the string "manual page, section xx" is hard to see
        # (because of many completion candidates).
        zstyle ':completion:*:*:man:*:manuals.*' format '%F{yellow}%B%U%d%u%b%f'
    }

    block 'kill' && {
        # Show completion candidates as process tree.

        # style: pid(yellow) %cpu(cyan) tty(blue) [user(green)] cmd(yellow and red)
        zstyle -e ':completion:*:*:*:*:processes' command \
            'if (( $funcstack[(eI)$_comps[sudo]] )) ; then \
                reply="ps --forest -e -o pid,%cpu,tty,user,cmd" \
            else \
                reply="ps --forest -u $USER -o pid,%cpu,tty,cmd" \
            fi'
        zstyle ':completion:*:*:*:*:processes' list-colors \
            "=(#b) #([0-9]#) #([0-9]#.[0-9]#) #([^ ]#) #([A-Za-z][A-Za-z0-9\-_.]#)# #([\|\\_ ]# )([^ ]#)*=31=33=36=34=32=36=33"
        # Disable sorting because it brakes process tree.
        zstyle ':completion:*:*:*:*:processes' sort false
        # Show completion list (process tree) always
        zstyle ':completion:*:*:kill:*' force-list always

        # For `killall`.
        zstyle -e ':completion:*:processes-names' command \
            'if (( $funcstack[(eI)$_comps[sudo]] )) ; then \
                reply="ps -e -o cmd" \
            else \
                reply="ps -u $USER -o cmd" \
            fi'
    }

    block 'sudo' && {
        zstyle ':completion:*:sudo:*' command-path $path
    }

    block 'npm' && () {
        if whence npm >/dev/null ; then
            local npm_completion_file=$_zshrc[config_path.npm.completion]
            # NOTE: `npm` is very slow, so cache the result.
            [[ -e $npm_completion_file ]] || npm completion >$npm_completion_file
            source "$npm_completion_file"
        fi
    }
}

# CLI and user-input related stuff.
block 'Command line and input' && {
    block 'Prompt and command line' && {
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
    }

    block 'Keys' && {
        # Suppose to use dvorak layout at typo correction
        setopt dvorak

        # Vim-like key binding
        bindkey -v

        block 'History search' && {
            # Incremental search with ^P and ^N (like vim)
            autoload history-search-end
            zle -N history-beginning-search-backward-end history-search-end
            zle -N history-beginning-search-forward-end history-search-end
            bindkey '^P' history-beginning-search-backward-end
            bindkey '^N' history-beginning-search-forward-end
        }

        # Disable execution of the last command with 'r'.
        # You can do it with history or incremental search
        disable r

        block 'Special keys' && () {
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

        # `Ctrl-H`.
        bindkey '^H'    backward-delete-char
        # Backspace (in some terminal like tmux)
        bindkey '^?'    backward-delete-char

        # Push command to stack (`Esc-q` at emacs binding)
        # `Ctrl+7` (in dvorak, `Shift+7` is `^&`.)
        # You can use `Ctrl+-` (`Shift+-` is `^_`.)
        bindkey '^_' push-line
        # Esc, then `q`.
        bindkey -a 'q' push-line

        # Show help with `Esc H`.
        #bindkey -a 'H' run-help

        cdup() {
            # skip lines to leave old prompt
            echo ; echo
            cd ..
            whence precmd >/dev/null && precmd
            for __pre_func in $precmd_functions ; do $__pre_func ; done
            zle reset-prompt
        }
        zle -N cdup
        # `cd ../` by `Ctrl-6` (in US Keyboard).
        # If you want to type `^^` (`Ctrl-^`), use `Ctrl-V Ctrl-6`.
        bindkey '^^' cdup
    }
}

# Configs for external plugins and external settings.
block 'External plugins and settings' && {
    block 'Load other zsh configs if exist' && {
        # autoload functions in `${HOME}/.zsh/functions/myfuncs/`.
        autoload -Uz ${HOME}/.zsh/functions/myfuncs/*(:t)

        # `+X`: load function immediately.
        autoload +XUz mytmux

        # Aliases.
        [[ -f ${HOME}/.zshrc.alias ]] && source ${HOME}/.zshrc.alias
        # Host-dependent settings.
        [[ -f ${HOME}/.zshrc.local ]] && source ${HOME}/.zshrc.local
    }

    block 'Plugins' && {
        # zsh-syntax-highlighting
        [[ -f ${HOME}/.zsh/zsh-syntax-highlighting.zsh.local ]] && source ${HOME}/.zsh/zsh-syntax-highlighting.zsh.local
    }
}

# Defines and registers widgets.
block 'Widgets' && {
    block 'rhq' && {
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
    }
}

# Initializes the CLI.
block 'Initialize' && {
    if [[ -n $TERM ]] ; then
        # Print information about terminal
        echo "terminal emulator: ${_zshrc[terminal.emulator]}"
        echo "terminal multiplexer: ${_zshrc[terminal.multiplexer]}"
        echo "terminal: ${TERM}"
        echo "language: ${LANG}"
    fi
}

# Performance measurement.
false && {
    if (which zprof >/dev/null) ; then
        zprof | less
    fi
}

unset block get_command export_nonempty unset_empty export_suffix_dir

# vim: set foldmethod=syntax :
