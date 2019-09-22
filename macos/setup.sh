#!/usr/bin/env bash
set -ux

echo "[INFO] Setup brew"

hash brew 2>/dev/null
if [[ $? != 0 ]] ;then
  # install homebrew without prompt
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
fi

# sometime it gets checksum error if not updated
brew update 

brew install jq
brew install shellcheck

brew cask install spectacle

echo "[INFO] Setup defaults"

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
# Set a shorter Delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# ignore correction
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
