# PATH
export PATH="$HOME/.local/bin:$PATH"

# Vi-style line editing (Esc -> command mode, then h/j/k/l, w/b, 0/$, etc.)
bindkey -v
export KEYTIMEOUT=1

# Show insert/command mode in the prompt
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    PROMPT='%F{yellow}(cmd)%f %n@%m:%~%# '
  else
    PROMPT='%F{green}(ins)%f %n@%m:%~%# '
  fi
  zle reset-prompt
}
zle -N zle-keymap-select
PROMPT='%F{green}(ins)%f %n@%m:%~%# '

# History search with Ctrl-p / Ctrl-n
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey -M vicmd '^P' history-beginning-search-backward
bindkey -M vicmd '^N' history-beginning-search-forward

# Word ops on Ctrl (not only Alt). Ctrl+Backspace usually sends ^H in terminals.
# With tmux `xterm-keys on`, Ctrl+Left/Right are \e[1;5D / \e[1;5C.
for keymap in emacs viins; do
  bindkey -M $keymap '^H'     backward-kill-word   # Ctrl+Backspace (^H)
  bindkey -M $keymap '\e^?'   backward-kill-word   # Alt+Backspace (tmux remap)
  bindkey -M $keymap '\e^H'   backward-kill-word   # Alt+Backspace (some terminals)
  bindkey -M $keymap '^[[3;5~' kill-word           # Ctrl+Delete
  bindkey -M $keymap '^[[1;5C' forward-word        # Ctrl+Right
  bindkey -M $keymap '^[[1;5D' backward-word       # Ctrl+Left
  bindkey -M $keymap '^[[1;5A' beginning-of-line   # Ctrl+Up (optional)
  bindkey -M $keymap '^[[1;5B' end-of-line         # Ctrl+Down (optional)
done

# Tab completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

# Better history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

export nviminit="~/.config/nvim/init.lua"

# Go
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# OpenClaw Completion
[ -s "/home/nurul/.openclaw/completions/openclaw.zsh" ] && . "/home/nurul/.openclaw/completions/openclaw.zsh"

. "$HOME/.local/bin/env"
