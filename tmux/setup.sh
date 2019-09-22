#!/bin/bash

set -u

brew install tmux
brew install reattach-to-user-namespace

# install tpm tmux plugin manager
if [[ ! -d  "${HOME}/.tmux/plugins" ]] ; then
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

cp -i ./tmux/.tmux.conf "${HOME}"

echo "[IMPORTANT] Make sure to run ctrl+b ctrl+I for installing tmux plugins"