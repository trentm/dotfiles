# Trent's main zsh config. See .zprofile for login shell stuff.

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
_trace ".zshrc: start"


# Shared-with-bash config.
if [[ -e ~/.shellrc ]]; then
    source ~/.shellrc
    _trace "loaded .shellrc"
else
    echo "warn: no ~/.shellrc" >&2
fi
if [[ -e ~/.shellrc.private ]]; then
    source ~/.shellrc.private
    _trace "loaded .shellrc.private"
fi
if [[ -e ~/.shellrc.local ]]; then
    source ~/.shellrc.local
    _trace "loaded .shellrc.local"
fi


# ---- Zsh shell options
# http://zsh.sourceforge.net/Doc/Release/Options.html
# List all opts via 'emulate -lLR zsh'. <shrug/>

setopt autocd  # can 'cd DIR' with just the 'DIR'
unsetopt nomatch # avoid: 'zsh: no matches found: <something with glob chars>'
setopt interactivecomments

# History
# See: https://superuser.com/questions/232457/zsh-output-whole-history
# on 'history [start] [end]', 'fc -l', etc.
#
# Shell history config. See 'emulate -lLR zsh | grep hist' for other opts.
setopt appendhistory
function hist {
    if [[ -z "$1" ]]; then
        # list all history
        #echo "no arg 1: '$1'"
        fc -l 1
    else
        # grep all history
        fc -lm "*$@*" 1
        #echo "arg 1: '$1', and @: '$@'"
    fi
}


# kill-word (Ctrl+W)
# The scenario:
#       word1 ~/a/b/c | <|>
# Without the following, in zsh, a Ctrl+W will kill all the way back to:
#       word1
# With bash, it will kill back to:
#       word1 ~/a/b/c
# which is what I'm used to.
autoload -U select-word-style
select-word-style shell


# ---- Prompt
# - git status, see:
#   http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
#   https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
#   TODO: consider the markers for current and staged changes (%u%c in formats,
#   requires enabling check-for-changes and check-for-staged-changes). I saw
#   a nice example using unicode black circle with coloring for the badges.
# - TODO: consider dropping username and hostname for local usage
#   (use SSH_CLIENT presence for remote sessions)
_trace "setting up prompt"
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "%s:%b"
zstyle ':vcs_info:git*' actionformats "%s:%b|%a"
function precmd() {
    local extras=()

    if [[ -n "$TRITON_PROFILE" ]]; then
        extras+=("t:$TRITON_PROFILE")
    fi
    if [[ -n "$MANTA_PROFILE" ]]; then
        extras+=("m:$MANTA_PROFILE")
    fi
    if [[ -n "$NODE_PROFILE" ]]; then
        extras+=("n:$NODE_PROFILE")
    fi
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local venvName
        venvName=$(basename "$VIRTUAL_ENV")
        if [[ $venvName == ".venv" ]]; then
            venvName=$(basename $(dirname "$VIRTUAL_ENV"))
        fi
        extras+=("venv:$venvName")
    fi
    if [[ -n "$AWS_REGION" ]]; then
        extras+=("aws:$AWS_REGION")
    fi

    vcs_info
    if [[ -n "$vcs_info_msg_0_" ]]; then
        extras+=($vcs_info_msg_0_)
    fi

    if [[ -n "$extras" ]]; then
        PS1="[%F{blue}%* %n@%m:%~ (${extras}%(?.. %F{red}rv:%?%F{blue}))]
%#%f "
    else
        PS1='[%F{blue}%* %n@%m:%~%(?.. (%F{red}rv:%?%F{blue}%))]
%#%f '
    fi
}


# ---- nvm lazy load
# Because nvm takes waaay too long to load. Adapted from:
# https://gist.github.com/rtfpessoa/811701ed8fa642f60e411aef04b2b64a

# Note: Keep this in sync with nvm default.
export PATH="/Users/trentm/.nvm/versions/node/v12.22.6/bin:$PATH"

NVM_DIR="$HOME/.nvm"
# Skip adding binaries if there is no node version installed yet
if [ -d $NVM_DIR/versions/node ]; then
    NODE_GLOBALS=(`find $NVM_DIR/versions/node -maxdepth 3 \( -type l -o -type f \) -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
fi
NODE_GLOBALS+=("nvm")

function load_nvm() {
  # Unset placeholder functions
  for cmd in "${NODE_GLOBALS[@]}"; do unset -f ${cmd} &>/dev/null; done

  # Load NVM
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  # Do not reload nvm again
  export NVM_LOADED=1
}

for cmd in "${NODE_GLOBALS[@]}"; do
  # Skip defining the function if the binary is already in the PATH
  if ! which ${cmd} &>/dev/null; then
    eval "${cmd}() { unset -f ${cmd} &>/dev/null; [ -z \${NVM_LOADED+x} ] && load_nvm; ${cmd} \$@; }"
  fi
done


# ---- Completion

# Enable completion
autoload -Uz compinit && compinit

# After bashcompinit one can load bash completion files, e.g.  those from
# node-cmdln.
autoload bashcompinit && bashcompinit

[ -s ~/.nvm/bash_completion ] && source ~/.nvm/bash_completion

if [[ -d ~/tm/dotfiles/zsh-completion ]]; then
    ls ~/tm/dotfiles/zsh-completion/*.zsh | while read f; do
        _trace "sourcing $f"
        source $f
    done
else
    echo ".zshrc: warning: no ~/tm/dotfiles/zsh-completion" >&2
fi

# TODO: verify this
# Hub completion (https://github.com/github/hub/tree/master/etc)
[ -s /usr/local/etc/bash_completion.d/hub.bash_completion.sh ] \
    && source /usr/local/etc/bash_completion.d/hub.bash_completion.sh


# ---- Other

function _iterm_title_update {
    echo -ne "\033];${PWD##*/}\007"
}
if [[ -n "$ITERM_SESSION_ID" ]]; then
    _iterm_title_update
    chpwd_functions+=(_iterm_title_update)
fi

_trace ".zshrc: end"
