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
- spectacle (only for MacOS)

## Install

```bash
cd $HOME; git clone git@github.com:go-zen-chu/simple-dotfiles.git
cd simple-dotfiles; ./setup.sh
```

## Uninstall

```bash
cd $HOME/simple-dotfiles; ./setup.sh -u
```

