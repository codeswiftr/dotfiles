# ============================================================================
# Core ZSH Configuration
# Basic shell settings and editor configuration
# ============================================================================

# Prevent duplicate PATH entries
typeset -U path PATH

# Enable colors
autoload -U colors && colors

# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Basic shell options
setopt AUTO_CD           # Auto cd when typing just directory name
setopt EXTENDED_GLOB     # Extended globbing patterns
setopt SHARE_HISTORY     # Share history between sessions
setopt HIST_VERIFY       # Show command before executing from history
setopt HIST_IGNORE_DUPS  # Don't record duplicates in history
setopt CORRECT           # Correct misspelled commands

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000