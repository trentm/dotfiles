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
    function _trace {}
fi
_trace start


# Shared-with-bash config.
if [[ -e ~/.shellrc ]]; then
    source ~/.shellrc
else
    echo "warn: no ~/.shellrc" >&2
fi
[[ -e ~/.shellrc.private ]] && source ~/.shellrc.private
[[ -e ~/.shellrc.local ]] && source ~/.shellrc.local


# ---- Zsh shell options

setopt autocd  # can 'cd DIR' with just the 'DIR'

# Shell history tweaks. See 'emulate -lLR zsh | grep hist' for other opts.
setopt sharehistory
setopt appendhistory


# ---- Prompt
# - git status, see:
#   http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
#   https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
#   TODO: consider the markers for current and staged changes (%u%c in formats,
#   requires enabling check-for-changes and check-for-staged-changes). I saw
#   a nice example using unicode black circle with coloring for the badges.
# - TODO: consider dropping username and hostname for local usage
#   (use SSH_CLIENT presence for remote sessions)
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

source ~/.nvm/bash_completion


# ---- Other

function _iterm_title_update {
    echo -ne "\033];${PWD##*/}\007"
}
if [[ -n "$ITERM_SESSION_ID" ]]; then
    _iterm_title_update
    chpwd_functions+=(_iterm_title_update)
fi


_trace "end"