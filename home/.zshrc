# Trent's main zsh config. See .zprofile for login shell stuff.
echo "running ~/.zshrc" >&2

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
# - TODO: git status
# - TODO: my profile stuff
# - TODO: consider '%3~'
# - TODO: consider dropping username and hostname for local usage
#   (use SSH_CLIENT presence for remote sessions)
# - TODO: consider time from bash prompt
# - TODO: consider newline from bash prompt
#       [22:06:31 trentm@purple:~]
#       $
# - with xterm-256color can use more colours via %F{0} to %F{255}
#
PS1='%n@%m:%B%F{240}%~%f%b%(?.. (%F{red}status=%?%f%)) %# '

#
# Other
#

# Enable completion
autoload -Uz compinit && compinit

# After bashcompinit one can load bash completion files, e.g.
# those from node-cmdln.
#autoload bashcompinit && bashcompinit

