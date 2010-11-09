# ~/.bashrc: executed by bash(1) for non-login shells.
#echo .bashrc: start

# If have already run this, don't do it again.
#XXX Does this work on other plats?
test ! -z $_MYBASHRC && return
readonly _MYBASHRC=true 

#XXX Doing this on HP-UX (on llbertha, at least) breaks 'scp' to that box.
#    You get some stty error.
if test `uname -s` != "HP-UX"; then
    test -z "$PROFILEREAD" && test -f /etc/profile &&  . /etc/profile
fi

# Setup my (Trent's) typical environment settings.
if test -f $HOME/.bash_env; then
    #echo .bashrc: sourcing $HOME/.bash_env
    . $HOME/.bash_env
fi


# If not running interactively, don't bother setting up the rest.
if tm_is_interactive_shell; then

    umask 022

    # Don't put duplicate lines in the history. See bash(1) for more options.
    #export HISTCONTROL=ignoredups

    # Check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    # Enable color support of ls and also add handy aliases.
    if test "$TERM" != "dumb" && is_on_path dircolors; then
        eval "`dircolors -b`"
        alias ls='ls --color=auto'
    fi

    # Make less more friendly for non-text input files, see lesspipe(1).
    [ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

    # Set variable identifying the chroot you work in (used in the prompt
    # below).
    if test -z "$debian_chroot" && test -r /etc/debian_chroot; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # Set a fancy prompt (non-color, unless we know we "want" color).
    case "$TERM" in
    xterm-color|xterm)
        PS1='[\t ${debian_chroot:+($debian_chroot)}\u@\h:\w]\n\$ '
        #XXX Better non-bright-green prompt color.
        #PS1='[${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]]\n\$ '
        ;;
    *)
        PS1='[\t ${debian_chroot:+($debian_chroot)}\u@\h:\w]\n\$ '
        ;;
    esac

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
    *)
        ;;
    esac

    # Define your own aliases here ...
    if test -f $HOME/.bash_aliases; then
        . $HOME/.bash_aliases
    fi


    # Enable programmable completion features (you don't need to enable this,
    # if it's already enabled in /etc/bash.bashrc and /etc/profile sources
    # /etc/bash.bashrc).
    #if test -f /etc/bash_completion; then
    #    . /etc/bash_completion
    #fi

fi # tm_is_interactive_shell


if test -f $HOME/.bash_localenv; then
    #echo .bashrc: sourcing $HOME/.bash_localenv
    . $HOME/.bash_localenv
fi


# RVM
# - <http://rvm.beginrescueend.com/rvm/install/> says:
#   "Ensure that rvm is the last thing sourced in all of your shell
#   profiles - e.g. it is sourced in the user specific profile after any
#   environment variables, especially PATH are set. Otherwise, the values you set
#   be trampled when you switch rubies." 
# - self-update periodically via: `rvm update --head && rvm reload`
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"



