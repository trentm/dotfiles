#!/bin/bash

#
# Create a new '~/tmp/asdf' play npm area.
# (This dir is a symlink from a "~/tmp/asdf.TIMESTAMP" dir, so the old ones
# still exist.)
#

if [ "$TRACE" != "" ]; then
    export PS4='${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -o xtrace
fi
set -o errexit
set -o pipefail


TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
mkdir ~/tmp/asdf.$TIMESTAMP
if [[ -h ~/tmp/asdf ]]; then
    rm ~/tmp/asdf
elif [[ -d ~/tmp/asdf ]]; then
    mv ~/tmp/asdf ~/tmp/asdf.bak
fi
ln -s ~/tmp/asdf.$TIMESTAMP ~/tmp/asdf

cd ~/tmp/asdf
echo package-lock=false >.npmrc
source ~/.nvm/nvm.sh
npm init -y

