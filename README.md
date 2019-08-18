# simple-dotfiles

[![CircleCI](https://circleci.com/gh/go-zen-chu/simple-dotfiles.svg?style=svg)](https://circleci.com/gh/go-zen-chu/simple-dotfiles)

Simple dotfiles for primer.

## Currently supported OS

- MacOS
- CentOS

## supported tools

- tmux
  - install tmux
  - update $HOME/.tmux.conf and refer ./tmux settings
- zsh
  - install zsh, zplug
  - update $HOME/.zshrc and refer ./zsh settings

## Install

Place this repo at $HOME

```bash
cd $HOME; git clone https://github.com/go-zen-chu/simple-dotfiles.git; cd $HOME/simple-dotfiles

# install tmux
./setup.sh --tmux

# install zsh
./setup.sh --zsh
chsh -s /usr/local/bin/zsh
```
