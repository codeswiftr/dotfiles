# ----- Section: Themes and plugins -----
ZSH_THEME="gruvbox"
SOLARIZED_THEME="dark"
BAT_THEME="gruvbox"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


plugins=(git tmux vi-mode zsh-syntax-highlighting zsh-autosuggestions)

if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

source $ZSH/oh-my-zsh.sh

# ----- Section: User configuration -----

set -g default-terminal "xterm-256color"

# ----- Section: PATH configuration -----

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# ----- Section: Aliases -----

# Docker
alias dc="docker compose"
alias dcc="docker context"

# Others
alias man="~/dotfiles/viman"
alias src="source ~/.zshrc"

# ----- Section: Environment variables -----



# ----- Section: Miscellaneous -----

# Print execution message
print "[$(date)] -- .zshrc executed"

