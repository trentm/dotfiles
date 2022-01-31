# Trent's zsh config for login shells. See .zshrc for the rest.
#
# Explanation of login vs. interactive vs. not shells:
# https://www.linuxquestions.org/questions/linux-general-1/difference-between-normal-shell-and-login-shell-14983/#post4828786
#
#echo "running ~/.zprofile" >&2

# Keychain (https://www.funtoo.org/Keychain) tool to setup ssh-agent.
test -x $HOME/bin/keychain && KEYCHAIN=$HOME/bin/keychain || KEYCHAIN=$(command -v keychain)
if [[ -n "$KEYCHAIN" && -f $HOME/.ssh/trusted ]]; then
    if [[ $(uname) == "Darwin" ]]; then
        # '--inherit any' to inherit any ssh passphrases from macOS Keychain.
        eval $($KEYCHAIN --quick --quiet --eval --agents ssh --inherit any id_rsa)
    else
        eval $($KEYCHAIN --quick --quiet --eval --agents ssh id_rsa)
    fi
fi


# Setting PATH for Python 3.9
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin:${PATH}"
export PATH

# Setting PATH for Python 3.7
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH
