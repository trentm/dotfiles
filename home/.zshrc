# Trent's main zsh config. See .zprofile for login shell stuff.
#echo "running ~/.zshrc" >&2

# Shared-with-bash config.
if [[ -e ~/.shellrc ]]; then
    source ~/.shellrc
else
    echo "warn: no ~/.shellrc" >&2
fi
[[ -e ~/.shellrc.private ]] && source ~/.shellrc.private
[[ -e ~/.shellrc.local ]] && source ~/.shellrc.local


#
# Zsh shell options
#

setopt autocd  # can 'cd DIR' with just the 'DIR'

# Shell history tweaks. See 'emulate -lLR zsh | grep hist' for other opts.
setopt sharehistory
setopt appendhistory


# 
# Prompt
# - git status, see:
#   http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
#   https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
# - TODO: consider dropping username and hostname for local usage
#   (use SSH_CLIENT presence for remote sessions)
#
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


#
# Other
#

# Enable completion
autoload -Uz compinit && compinit

# After bashcompinit one can load bash completion files, e.g.
# those from node-cmdln.
#autoload bashcompinit && bashcompinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
