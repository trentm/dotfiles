#!/bin/bash
#
# Heavily borrowing from Ryan Tomayko (github.com/rtomayko/dotfiles).
#

# the basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}
: ${DOTFILES=$HOME/tm/dotfiles}

# complete hostnames from this file
: ${HOSTFILE=~/.ssh/known_hosts}

# readline config
: ${INPUTRC=~/.inputrc}

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
# PATH
# ----------------------------------------------------------------------

PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"
if [[ $(uname -s) = "SunOS" ]]; then
    # smartos pkgsrc
    PATH="/opt/local/gnu/bin:/opt/local/bin:/opt/local/sbin:$PATH"
fi
#test -d /Library/Frameworks/Python.framework/Versions/Current/bin && PATH=/Library/Frameworks/Python.framework/Versions/Current/bin:$PATH
PATH="/usr/local/go/bin:$PATH"
PATH="$HOME/opt/node-4/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"

#[[ $(uname -s) = "SunOS" ]] && MANPATH="/opt/local/man:$MANPATH" # smartos pkgsrc
#MANPATH="$HOME/opt/node-4/share/man:$MANPATH"


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
FIGNORE="~:CVS:#:.pyc:.pyo:.swp:.swa:apache-solr-*:.git"
HISTCONTROL=ignoredups

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)

# EDITOR
test -n "$HAVE_VIM" && EDITOR=vim || EDITOR=vi
export EDITOR

# PAGER
if test -n "$(command -v less)" ; then
    PAGER="less -iRwX"
    MANPAGER="less -iRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

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
    branch=`__git_ps1 "%s"`

    local gemset
    # Too slow. Causes bash output problems.
    #if test -x "$HOME/.rvm/bin/rvm-prompt"; then
    #    source $HOME/.rvm/scripts/rvm && gemset=`$HOME/.rvm/bin/rvm-prompt g`
    #fi

    if test -n "$branch" -o -n "$gemset"; then
        echo -n " ("
        test -n "$branch" && echo -n $branch
        test -n "$gemset" && echo -n $gemset
        echo -n ")"
    fi
}

prompt_color() {
    PS1="${COLOR2}[\t ${COLOR1}\u${COLOR2}@\h:\w"
    PS1+='$(__prompt_extra_info)'
    PS1+="]\n$P${PS_CLEAR} "
    PS2=""
}

# ----------------------------------------------------------------------
# OS-Specific
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    #alias k='open -a "Komodo IDE"'
    alias k='open -a "Komodo IDE 8"'
    alias komodo=k
    alias chrome='open -a "Google Chrome"'
    alias pixel='open -a Pixelmator'
    alias vlc='open -a /Applications/VLC.app'
    alias vlc0.9='open -a /Applications/VLC-0.9.app'

    # Start Canon LiDE scanner.
    # This is here to avoid having the painful "N*_ButtonManager.app" processes
    # running all the time. See
    # <http://forums.macnn.com/57/consumer-hardware-and-components/132661/attn-canon-lide-owners/>
    # for details.
    alias scanner-start='open /Library/CFMSupport/N067U_ButtonManager.app && open /Library/CFMSupport/N124U_ButtonManager.app'

    # From MySQL setup on Mac OS X. Don't know if this install path is
    # Mac-specific.
    alias mysql-start="sudo /usr/local/mysql/support-files/mysql.server start"
    alias mysql-stop="sudo /usr/local/mysql/support-files/mysql.server stop"

    # put ports on the paths if /opt/local exists
    #test -x /opt/local -a ! -L /opt/local && {
    #    PORTS=/opt/local
    #
    #    # setup the PATH and MANPATH
    #    PATH="$PORTS/bin:$PORTS/sbin:$PATH"
    #    MANPATH="$PORTS/share/man:$MANPATH"
    #
    #    # nice little port alias
    #    alias port="sudo nice -n +18 $PORTS/bin/port"
    #}
fi


# ----------------------------------------------------------------------
# Keychain / SSH-agent
#
# Update ~/bin/keychain from <https://github.com/funtoo/keychain/>
# ----------------------------------------------------------------------

HAVE_KEYCHAIN=$(command -v keychain)
test -n "$INTERACTIVE" -a -n "$LOGIN" -a -f $HOME/.ssh/trusted -a -n "$HAVE_KEYCHAIN" && {
    ls -1 $HOME/.ssh/*.id_rsa | grep -v '\.pub' | grep -v '\.ppk' \
        | xargs keychain --quick --quiet --lockwait 120
    [[ -f $HOME/.keychain/$HOSTNAME-sh ]] && source $HOME/.keychain/$HOSTNAME-sh
    [[ -f $HOME/.keychain/$HOSTNAME-sh-gpg ]] && source  $HOME/.keychain/$HOSTNAME-sh-gpg
}


# ----------------------------------------------------------------------
# Aliases / Functions
# ----------------------------------------------------------------------

test -n "$HAVE_VIM" && alias vi=vim

# SCC
alias ss='svn status -q --ignore-externals'
alias vc='python ~/tm/sandbox/tools/vc.py'
alias svn_add_ignore='python ~/tm/sandbox/tools/svn_add_ignore.py'
alias svnmerge='python ~/src/svnmerge/svnmerge.py'
alias sux='svn up --ignore-externals'
function sd() {
    svn diff --diff-cmd diff -x -U10 $* | less
}
function hd() {
    hg diff $* | less
}
function hs() {
    hg st $*
}
alias gd='git diff'
alias gds='git diff --staged'
alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias gl='git log --stat'
alias glp='git log -p'
alias gl1='git log -1'
alias giddyup='git fetch -a origin && git pull --rebase origin $(git rev-parse --abbrev-ref HEAD) && git submodule update --init'

alias jsondev='$HOME/tm/json/lib/json.js'
alias bumpver='json -I -f package.json -e "v = this.version.split(/\./g); if (v.length !== 3 || isNaN(Number(v[2]))) throw new Error(\"wtf semver\"); v[2]=Number(v[2])+1; this.version = v.join(\".\")"'

alias ..='cd ..'
alias ...='cd ../..'
alias t='cd ~/tmp'  # TODO make this a function that'll create a tmp subdir if given

# Shuffle lines (from <http://stackoverflow.com/a/6511327>)
alias shuf="perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);'"


function mkcd() {
    mkdir "$1" && cd "$1"
}

# https://gist.github.com/trentm/6126755
function googl {
    # echo URL | googl
    local url=$(cat <&0)
    (
        set -e pipefail;
        echo "{}" \
            | json -e "this.longUrl='$url'" \
            | curl -sf https://www.googleapis.com/urlshortener/v1/url \
                -H 'Content-Type: application/json' -d@- \
            | json id
    )
}


# Tools
alias pics='python $HOME/tm/pics/bin/pics'
alias markdown2="python ~/tm/python-markdown2/lib/markdown2.py"
alias eol="python $HOME/tm/eol/lib/eol.py"
alias igrep='grep -i'
alias check='python $HOME/src/check/check.py'
alias ti='python $HOME/as/openkomodo/src/python-sitelib/textinfo.py'
# I just can't type that word.
alias j="jekyll && (cd _site && staticserve)"
alias restdown=$HOME/tm/restdown/bin/restdown
alias mtime='python -c "import os,sys,stat; print(os.stat(sys.argv[1]).st_mtime)"'
alias ackless='ack --pager="less -R"'
alias ag='ag --color-line-number=31 -s -a'
alias agless='ag -s --pager="less -R" -a'
alias by='bunyan'
alias log='bunyan'
alias vimfluence=$HOME/tm/vimfluence/vimfluence
alias js2json='node -e '\''s=""; process.stdin.resume(); process.stdin.on("data",function(c){s+=c}); process.stdin.on("end",function(){o=eval("("+s+")");console.log(JSON.stringify(o)); });'\'''

export MANTASH_PS1='[\u@\h \w]$ '

#export PATH=$HOME/tm/restdown/bin:$PATH
#export PATH=$HOME/tm/node-bunyan/bin:$PATH

function staticserve() {
    for ip in `ifconfig -a | grep "inet " | awk '{print $2}'`; do
        echo "# http://${ip}:8000"
    done
    python -m SimpleHTTPServer
}

# Highlight the given term. Usage: ... | hi foo
function hi() {
    perl -pe "s/$1/\e[1;31;43m$&\e[0m/g"
}

# Highlight chars beyond 80 columns.
function col80() {
    perl -pe 's/^(.{80})(.*?)$/$1\e[1;31;43m$2\e[0m/';
}


alias date-for-date='echo "# Run the following on target machine to set to same date as here." && echo "date $(date -u "+%m%d%H%M%Y.%S")"'
alias date-from-timestamp='node -p -e "(new Date(Number(process.argv[1]))).toISOString()"'

alias ips="ifconfig -a | grep 'inet ' | awk '{print \$2}'"
alias lower='python -c "import sys; sys.stdout.write(sys.stdin.read().lower())"'

# GTD
alias gtd="python ~/Dropbox/gtd/bin/gtd.py"
alias note="python ~/Dropbox/gtd/bin/gtd.py note"

# Dev and system tools
[ "$UNAME" = "Darwin" ] && alias ldd='otool -L'
alias ps1='ps -wwx'
alias ps2='ps -wwux'
alias dir='l'
function fn() { find . -iname "*$@*"; }

# http://drawohara.com/post/6344279/crontab-temp-file-must-be-edited-in-place
alias crontab='VIM_CRONTAB=true crontab'

# See http://ubuntuforums.org/showthread.php?t=90910
# I found I've needed this on skink (Ubuntu box), at least.
[ "$UNAME" = "Linux" ] && alias screen='TERM=screen screen'

# Bash shell driver for 'go' (https://github.com/trentm/go-tool).
#export PATH=$HOME/tm/go-tool/lib:$PATH
function g {
    export GO_SHELL_SCRIPT=$HOME/.__tmp_go.sh
    PYTHONPATH=$HOME/tm/go-tool/lib:$PYTHONPATH python -m go $*
    if [ -f $GO_SHELL_SCRIPT ] ; then
        source $GO_SHELL_SCRIPT
    fi
    unset GO_SHELL_SCRIPT
}


function node-select {
    local ver dir firstpath
    ver=$1
    dir=$HOME/opt/node-$ver/bin
    if [[ ! -d $dir ]]; then
        echo "node-select: error: '$dir' does not exist" >&2
        return
    fi
    echo "select node $($dir/node --version) at $dir"
    firstpath=$(echo "$PATH" | cut -d: -f1)
    if [[ -n "$(echo "$firstpath" | grep "^$HOME/opt/node-.*/bin" 2>/dev/null)" ]]; then
        export PATH=$(echo "$PATH" | sed -e "s#$firstpath:#$dir:#")
    else
        export PATH=$dir:$PATH
    fi
}


# From Pedro (https://gist.github.com/c19e71b17ca1de05000f)
# `brew install rlwrap` to get `rlwrap`.
function parse_git_branch {
   ref=$(git symbolic-ref HEAD 2> /dev/null) || return
   echo "("${ref#refs/heads/}")"
}
alias noderepl='env NODE_NO_READLINE=1 rlwrap -p Red -S "$(parse_git_branch) node> " node'

alias docker-ip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias docker-name="docker inspect --format '{{ .Name }}'"
function docker-port {
    # The first host:port in NetworkSettings.Ports
    # Q: Does this correspond to the first '-p N:M' in 'docker run' args?
    docker inspect $1 | json -a -e '
        ports=this.NetworkSettings.Ports;
        first=ports[Object.keys(ports)[0]][0];
        this._ = first.HostIp + ":" + first.HostPort' _
}


test -f "$HOME/.bashrc_private" && source $HOME/.bashrc_private


# ----------------------------------------------------------------------
# GPG
#
# XXX:TODO: update vienc to use a temporary path in TMPDIR to be outside
# of dropbox area. See this: http://nibble.develsec.org/hg/toys/file/ddaf55c59fc7/passman
# ----------------------------------------------------------------------

function enc() {
    # Encrypt a file.
    # Usage: `enc PATH` with create `PATH.asc` and remove `PATH`.

    for ARG in $*
    do
        export ASC_PATH=$ARG.asc
        rm -f "$ASC_PATH"
        # '--armor' is to encrypt to ascii format (good for source control)
        gpg --encrypt --armor --output "$ASC_PATH" --recipient 'Trent Mick' "$ARG" \
            && rm "$ARG"
        unset ASC_PATH
    done
}
function dec() {
    # Decrypt a file.
    # Usage: `dec PATH.asc` will create `PATH`.
    for ARG in $*
    do
        gpg --output "${ARG%.*}" --decrypt "$ARG"
    done
}
function vienc() {
    # Edit an encrypted file in vi.
    # Usage: `vienc PATH.asc` will decrypt to `PATH`, edit that file in
    # vi, then re-encrypt to `PATH.asc`.
    dec "$1"
    vi "${1%.*}"
    enc "${1%.*}"
}
function catenc() {
    # Cat an encrypted file.
    # Usage: `catenc PATH.asc` will decrypt and cat the contents of `PATH.asc`.
    gpg --decrypt "$1"
}

function 11jul {
    local name
    local tmppath

    set -o errexit

    name=$(date '+%Y').txt
    encpath=$HOME/Dropbox/gtd/notes/11jul/$name.asc
    tmppath=/var/tmp/.11jul-$name
    if [[ -f $encpath ]]; then
        catenc $encpath >$tmppath
    else
        rm -f $tmppath
        touch $tmppath
    fi
    vi $tmppath
    enc $tmppath
    cp $tmppath.asc $encpath
    rm $tmppath.asc

    set +o errexit
}


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

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-h"
if [[ `uname` == "Darwin" ]]; then
    # Color support not reliably there, e.g. on Illumos.
    LS_COMMON="-hBG"
fi

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

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" && alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias l="ls -lFA"


# --------------------------------------------------------------------
# MISC COMMANDS
# --------------------------------------------------------------------

## use gem-man(1) if available:
#man () {
#    gem man -s "$@" 2>/dev/null ||
#    command man "$@"
#}

# Usage: pls [<var>]
# List path entries of PATH or environment variable <var>.
pls () { eval echo \$${1:-PATH} |tr : '\n'; }

if [[ `uname` == "Darwin" ]]; then
    # Usage: puniq [<path>]
    # Remove duplicate entries from a PATH style value while retaining
    # the original order. Use PATH if no <path> is given.
    #
    # Example:
    #   $ puniq /usr/bin:/usr/local/bin:/usr/bin
    #   /usr/bin:/usr/local/bin
    puniq () {
        # Some stupid breakage in non-GNU `sed` on some systems
        # such that it returns empty string.
        [[ `(gsed --version 2>/dev/null || true) | grep "GNU sed"` ]] && SED=gsed || SED=sed
        echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n | cut -f 2- |tr '\n' : | $SED -e 's/:$//' -e 's/^://'
    }
else
    puniq () {
        echo "$1"
    }
fi


# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# condense PATH entries
PATH=$(puniq $PATH)
MANPATH=$(puniq $MANPATH)

# Use the color prompt by default when interactive
if [[ `uname` == "Darwin" ]]; then
    test -n "$PS1" && prompt_color
else
    test -n "$PS1" && prompt_simple
fi

# Python
test -r $HOME/.pythonstartuprc && export PYTHONSTARTUP=$HOME/.pythonstartuprc


# -------------------------------------------------------------------
# Host-local and final stuff
# -------------------------------------------------------------------

test -r $HOME/.bash_localenv && . $HOME/.bash_localenv

# RVM
# - <http://rvm.beginrescueend.com/rvm/install/> says:
#   "Ensure that rvm is the last thing sourced in all of your shell
#   profiles - e.g. it is sourced in the user specific profile after any
#   environment variables, especially PATH are set. Otherwise, the values you set
#   be trampled when you switch rubies."
# - self-update periodically via: `rvm update --head && rvm reload`
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
    uname -npsr
    uptime
}


# vim: ts=4 sts=4 shiftwidth=4 expandtab
