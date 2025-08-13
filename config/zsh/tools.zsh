# --- Optimized Tool Configuration ---
# This file uses 'mise' for tool management for faster shell startup.

# --- Mise (formerly rtx) ---
# This is the primary tool manager.
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# --- Bun ---
# Enable shell completions
if command -v bun &> /dev/null; then
    [ -s "$HOME/.bun/install/bun-completion.zsh" ] && source "$HOME/.bun/install/bun-completion.zsh"
fi

# --- Starship Prompt ---
# Loaded directly for speed
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# --- Zoxide ---
# Loaded directly for speed
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
