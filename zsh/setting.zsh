# match both capital, small leters
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# tab selecting
zstyle ':completion:*' menu select=2

# history setting
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '

setopt share_history
