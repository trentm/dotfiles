# ~/.bash_profile: executed by bash(1) for login shells.
#echo .bash_profile: start

test -z "$PROFILEREAD" && test -f /etc/profile && . /etc/profile

if test -f $HOME/.bashrc; then
    #echo .bash_profile: sourcing $HOME/.bashrc
    . $HOME/.bashrc
fi

