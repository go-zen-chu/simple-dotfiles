#!/bin/bash
set -u

brew install zsh
echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells
brew install zplug

chsh -s /usr/local/bin/zsh || true # for skipping in CI

touch "${HOME}/local.zsh"
cp -i ./zsh/.zshrc "${HOME}" || true # for skipping in CI