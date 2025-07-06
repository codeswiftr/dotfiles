# ============================================================================
# Modern Tool Integration
# Configuration for modern CLI tools and version managers
# ============================================================================

# Initialize completions with caching
if type init_completions_cached >/dev/null 2>&1; then
    init_completions_cached
else
    # Fallback to standard completion initialization
    autoload -U compinit && compinit
fi

# Mise (multi-language version manager) - optimized initialization
if command -v mise >/dev/null 2>&1; then
    if [[ -n "$DOTFILES_FAST_MODE" ]]; then
        # Fast mode - minimal mise initialization
        eval "$(mise activate zsh --quiet)"
    else
        # Full mise initialization with shell completions
        eval "$(mise activate zsh)"
        # Load mise completions asynchronously for better performance
        { eval "$(mise completion zsh)" } &
    fi
fi

# Tool initialization with performance optimization
if [[ -n "$DOTFILES_FAST_MODE" ]]; then
    # Fast mode - minimal initialization
    command -v starship >/dev/null && eval "$(starship init zsh)"
    command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
else
    # Full initialization
    command -v starship >/dev/null && eval "$(starship init zsh)"
    command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
    # Load atuin asynchronously for better performance
    command -v atuin >/dev/null && { eval "$(atuin init zsh)" & }
fi

# FZF initialization
if command -v fzf >/dev/null 2>&1; then
    # Auto-completion
    [[ $- == *i* ]] && source "$HOME/.fzf.zsh" 2>/dev/null
fi