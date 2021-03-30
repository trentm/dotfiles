#!/bin/bash

# Internal trace logging of this script.
_TRACE=0
case "$0" in
    -*) _LOGINSHELL=1 ;;
    *)  unset _LOGINSHELL ;;
esac
if [[ $_TRACE == 1 && $_LOGINSHELL == 1 ]]; then
    function _trace {
        echo "[$(date "+%Y-%m-%dT%H:%M:%SZ")] .zshrc: trace: $*" >&2
        return 0
    }
else
    alias _trace=true
fi
_trace ".bashrc: start"


# the basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}


# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
      . /etc/bashrc

# notify of bg job completion immediately
set -o notify

#set -o vi

# shell opts. see bash(1) for details
shopt -s extglob >/dev/null 2>&1
shopt -s histappend >/dev/null 2>&1
shopt -s hostcomplete >/dev/null 2>&1
shopt -s interactive_comments >/dev/null 2>&1
shopt -u mailwarn >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1

# no "you have new mail" in terminal
unset MAILCHECK

# default umask
umask 0022


# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
# ----------------------------------------------------------------------

# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=yes ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=yes ;;
    *)  unset LOGIN ;;
esac

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.pyo:.swp:.swa:apache-solr-*"
HISTCONTROL=ignoredups


# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
BLACK="\[\033[0;30m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BLUE}"
    P="#"
else
    COLOR1="${BLUE}"
    COLOR2="${BLUE}"
    P="\$"
fi

# Make iTerm2 tab the current dir.  https://gist.github.com/phette23/5270658
if [ $ITERM_SESSION_ID ]; then
    export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]\$ "
    PS2=""
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2=""
}

__prompt_extra_info() {
    local branch
    if command -v __git_ps1; then
        branch=`__git_ps1 "%s"`
    fi
    local content
    content=

    if test -n "$branch"; then
        content+="$branch"
    fi
    if test -n "$TRITON_PROFILE"; then
        test -n "$content" && content+=" "
        content+="t:$TRITON_PROFILE"
    fi
    if test -n "$MANTA_PROFILE"; then
        test -n "$content" && content+=" "
        content+="m:$MANTA_PROFILE"
    fi
    if test -n "$NODE_PROFILE"; then
        test -n "$content" && content+=" "
        content+="n:$NODE_PROFILE"
    fi

    if test -n "$content"; then
        echo -n " ($content)"
    fi
}

prompt_color() {
    PS1="${COLOR2}[\t ${COLOR1}\u${COLOR2}@\h:\w"
    PS1+='$(__prompt_extra_info)'
    PS1+="]\n$P${PS_CLEAR} "
    PS2=""
}


# ----------------------------------------------------------------------
# Keychain / SSH-agent
#
# Update ~/bin/keychain from <https://github.com/funtoo/keychain/>
# ----------------------------------------------------------------------

HAVE_KEYCHAIN=$(command -v keychain)
test -n "$INTERACTIVE" -a -n "$LOGIN" -a -f $HOME/.ssh/trusted -a -n "$HAVE_KEYCHAIN" && {
    ls -1 $HOME/.ssh/*.id_rsa | grep -v '\.pub' | grep -v '\.ppk' \
        | xargs keychain --quick --quiet
    [[ -f $HOME/.keychain/$HOSTNAME-sh ]] && source $HOME/.keychain/$HOSTNAME-sh
    [[ -f $HOME/.keychain/$HOSTNAME-sh-gpg ]] && source  $HOME/.keychain/$HOSTNAME-sh-gpg
}


# ----------------------------------------------------------------------
# Shared-with-bash config.
# ----------------------------------------------------------------------

if [[ -e ~/.shellrc ]]; then
    source ~/.shellrc
else
    echo "warn: no ~/.shellrc" >&2
fi
[[ -e ~/.shellrc.private ]] && source ~/.shellrc.private
[[ -e ~/.shellrc.local ]] && source ~/.shellrc.local


# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

test -z "$BASH_COMPLETION" && {
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    test -n "$PS1" && test $bmajor -gt 1 && {
        # search for a bash_completion file to source
        # Note for Mac: `brew install bash-completion` to get bash completion
        # bits installed. Symptom of not having this:
        #   -bash: __git_ps1: command not found
        for f in /usr/local/etc/bash_completion \
                 /usr/pkg/share/bash-completion/bash_completion \
                 /usr/pkg/etc/bash_completion \
                 /opt/local/etc/bash_completion \
                 /etc/bash_completion
        do
            test -f $f && {
                . $f
                break
            }
        done
    }
    unset bash bmajor bminor
}


# override and disable tilde expansion
_expand() {
    return 0
}

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
}
unset dircolors



# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# Use the color prompt by default when interactive
if [[ `uname` == "Darwin" ]]; then
    test -n "$PS1" && prompt_color
else
    test -n "$PS1" && prompt_simple
fi


# -------------------------------------------------------------------
# Host-local and final stuff
# -------------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Hub completion (https://github.com/github/hub/tree/master/etc)
[ -s /usr/local/etc/bash_completion.d/hub.bash_completion.sh ] \
    && source /usr/local/etc/bash_completion.d/hub.bash_completion.sh

# Silence macos warning about switch to zsh
# https://apple.stackexchange.com/a/371998
export BASH_SILENCE_DEPRECATION_WARNING=1

# vim: ts=4 sts=4 shiftwidth=4 expandtab
