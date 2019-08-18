UNAME=`uname`
if [[ $UNAME == 'Darwin' ]] ; then
  # in mac, fn + delete is getting ~
  bindkey "^[[3~" delete-char
  # option + arrows
  bindkey "^[^[[D" backward-word
  bindkey "^[^[[C" forward-word
fi
# zplug installed plugin might overwrite some key binding so overwrite
# https://superuser.com/questions/523564/emacs-keybindings-in-zsh-not-working-ctrl-a-ctrl-e
bindkey -e