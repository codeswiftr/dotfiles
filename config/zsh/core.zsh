# ============================================================================
# Core ZSH Configuration
# Basic shell settings and editor configuration
# ============================================================================

# Prevent duplicate PATH entries (use -g for global scope to work with reload)
typeset -gU path PATH

# Enable colors
autoload -U colors && colors

# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Basic shell options
setopt AUTO_CD              # Auto cd when typing just directory name
setopt EXTENDED_GLOB        # Extended globbing patterns
setopt SHARE_HISTORY        # Share history between sessions
setopt HIST_VERIFY          # Show command before executing from history
setopt HIST_IGNORE_DUPS     # Don't record duplicates in history
setopt CORRECT              # Correct misspelled commands
setopt NO_BG_NICE           # Don't nice background jobs
setopt NO_NOTIFY            # Don't report background job status immediately
setopt NO_HUP              # Don't kill jobs on exit
setopt LONG_LIST_JOBS      # Show job status in format like ps

# Key bindings - Emacs mode (default) with proper arrow key support
bindkey -e  # Enable emacs key bindings (Ctrl+A, Ctrl+E, arrow keys, etc.)

# Ensure arrow keys work properly
bindkey '^[[A' up-line-or-history    # Up arrow
bindkey '^[[B' down-line-or-history  # Down arrow
bindkey '^[[C' forward-char          # Right arrow
bindkey '^[[D' backward-char         # Left arrow

# Additional common key bindings
bindkey '^[[H' beginning-of-line     # Home
bindkey '^[[F' end-of-line           # End
bindkey '^[[3~' delete-char          # Delete
bindkey '^?' backward-delete-char    # Backspace

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000