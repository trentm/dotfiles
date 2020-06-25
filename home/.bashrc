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
PATH="/usr/local/go/bin:$PATH"
PATH="$HOME/opt/node-10/bin:$PATH"
if [[ -d /Library/Frameworks/Python.framework/Versions/2.7/bin ]]; then
    PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH
    PATH="$HOME/Library/Python/2.7/bin:$PATH"
fi
if [[ -d /Library/Frameworks/Python.framework/Versions/3.7/bin ]]; then
    PATH=/Library/Frameworks/Python.framework/Versions/3.7/bin:$PATH
    PATH="$HOME/Library/Python/3.7/bin:$PATH"
elif [[ -d /Library/Frameworks/Python.framework/Versions/3.6/bin ]]; then
    PATH=/Library/Frameworks/Python.framework/Versions/3.6/bin:$PATH
else
    echo ".bashrc: warning: no python.org install of Python 3 is available" >&2
fi
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/bin:$PATH"
export PATH

#[[ $(uname -s) = "SunOS" ]] && MANPATH="/opt/local/man:$MANPATH" # smartos pkgsrc
#MANPATH="$HOME/opt/node-10/share/man:$MANPATH"


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
    branch=`__git_ps1 "%s"`
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
# OS-Specific
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    alias k='open -a "Komodo IDE 8"'
    alias c=code  # vscode
    alias pixel='open -a Pixelmator'
    alias vlc='open -a /Applications/VLC.app'
    alias vlc0.9='open -a /Applications/VLC-0.9.app'

    # From MySQL setup on Mac OS X. Don't know if this install path is
    # Mac-specific.
    alias mysql-start="sudo /usr/local/mysql/support-files/mysql.server start"
    alias mysql-stop="sudo /usr/local/mysql/support-files/mysql.server stop"
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
# Aliases / Functions / Env
# ----------------------------------------------------------------------

test -n "$HAVE_VIM" && alias vi=vim

# SCC
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
alias giddyup='git fetch --tags --prune --prune-tags -a origin && git pull --rebase origin $(git rev-parse --abbrev-ref HEAD) && git submodule update --init'
alias prit='hub pull-request -p -a trentm'

alias isotime='node -e "console.log(new Date().toISOString())"'

# Checkout a Joyent Gerrit CR for this repo.
function cr-checkout {
    local crnum=$1
    if [[ -z "$crnum" ]]; then
        echo "cr-checkout: error: missing CRNUM argument" >&2
        echo "usage: cr-checkout CRNUM" >&2
        return 1
    fi
    patchset=$(git ls-remote cr | grep "refs/changes/../${crnum}/" | cut -d/ -f5 | sort -n | tail -1)
    git checkout master
    git fetch -f cr refs/changes/${crnum:(-2)}/${crnum}/${patchset}:cr-${crnum}-${patchset}
    git checkout cr-${crnum}-${patchset}
}

# Checkout a GitHub PR for this repo.
# TODO: I think there is a way to get this re-fetchable. Test this.
# Some notes at https://gist.github.com/karlhorky/88b3c8c258796cd3eb97615da36e07be
function pr-checkout {
    local prnum=$1
    if [[ -z "$prnum" ]]; then
        echo "pr-checkout: error: missing PRNUM argument" >&2
        echo "usage: pr-checkout PRNUM" >&2
        return 1
    fi
    git fetch origin +refs/pull/$prnum/head:pr-$prnum
    git checkout pr-$prnum
}


alias gist='gist --private --open' # https://github.com/defunkt/gist

alias jsondev='$HOME/tm/json/lib/json.js'
alias bumpver='json -I -f package.json -e "v = this.version.split(/\./g); if (v.length !== 3 || isNaN(Number(v[2]))) throw new Error(\"wtf semver\"); v[2]=Number(v[2])+1; this.version = v.join(\".\")"'

# pics/exiftool/flickr commands
#
# Prerequisites:
# - brew install exiftool
#
alias exif-ls='exiftool -exif:all'
function flickr-open {
    local id="$1"
    if [[ -z "$id" ]]; then
        echo "flickr-open: error: no photo ID argument given" >&2
        return 1
    else
        open -a Firefox "https://www.flickr.com/photos/trento/$id/in/photostream/"
    fi
}
function pics-set-createdate {
    local exifDate
    local isoDate
    local files

    isoDate="$1"
    shift
    files="$@"

    if [[ -z "$isoDate" ]]; then
        echo "pics-set-createdate: error: missing ISODATE argument" >&2
        echo "usage: pics-set-createdata YYYYmmddTHHMMSS FILE..." >&2
        return 1
    elif ! echo "$isoDate" | egrep '^\d{8}T\d{6}$' >/dev/null; then
        echo "pics-set-createdate: error: '$isoDate' is not of the form 'YYYYmmddTHHMMSS'" >&2
        echo "usage: pics-set-createdata YYYYmmddTHHMMSS FILE..." >&2
        return 1
    elif [[ -z "$files" ]]; then
        echo "pics-set-createdate: error: missing FILE argument(s)" >&2
        echo "usage: pics-set-createdata YYYYmmddTHHMMSS FILE..." >&2
        return 1
    fi

    # "YYYYmmddTHHMMSS" -> "YYYY:mm:dd HH:MM:SS"
    exifDate=$(echo "$isoDate" \
        | awk '{print substr($0,0,4) ":" substr($0,5,2) ":" substr($0,7,2) " " substr($0,10,2) ":" substr($0,12,2) ":" substr($0,14,2)}')
    #echo "exifDate: $exifDate"
    #echo "files: $files"

    # exiftool [OPTIONS] -TAG[+-<]=[VALUE]... FILE...
    echo "# exiftool '-CreateDate=$exifDate' $files"
    exiftool "-CreateDate=$exifDate" $files
}


alias ..='cd ..'
alias ...='cd ../..'

# Shuffle lines (from <http://stackoverflow.com/a/6511327>)
alias shuf="perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);'"

function uuid() {
    uuidgen | tr A-Z a-z  # mac has `uuidgen`
}


function mkcd() {
    mkdir -p "$1" && cd "$1"
}


# pomodoro timer
function pomo() {
    reminder 25m "pomodoro: end of timer"
    reminder 30m "pomodoro: end of break"
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
alias rgall='rg -g "*" -a'
function rgless() {
    rg --heading -n --color ansi "$@" | less -R
}
alias vimfluence=$HOME/tm/vimfluence/vimfluence
alias js2json='node -e '\''s=""; process.stdin.resume(); process.stdin.on("data",function(c){s+=c}); process.stdin.on("end",function(){o=eval("("+s+")");console.log(JSON.stringify(o)); });'\'''

export MANTASH_PS1='[\u@\H \w]$ '

export GOPATH=$HOME/go  # same as Go1.8 default

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
    export NODE_PROFILE=$ver
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


# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

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

test -r $HOME/.bash_localenv && source $HOME/.bash_localenv

# RVM
# - <http://rvm.beginrescueend.com/rvm/install/> says:
#   "Ensure that rvm is the last thing sourced in all of your shell
#   profiles - e.g. it is sourced in the user specific profile after any
#   environment variables, especially PATH are set. Otherwise, the values you set
#   be trampled when you switch rubies."
# - self-update periodically via: `rvm update --head && rvm reload`
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Hub completion (https://github.com/github/hub/tree/master/etc)
[ -s /usr/local/etc/bash_completion.d/hub.bash_completion.sh ] \
    && source /usr/local/etc/bash_completion.d/hub.bash_completion.sh

# vim: ts=4 sts=4 shiftwidth=4 expandtab
