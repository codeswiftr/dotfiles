# =============================================================================
# Modern ZSH Configuration - 2025 Edition (Modular)
# =============================================================================

# ----- Configuration Directory Setup -----
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ZSH_CONFIG_DIR="$DOTFILES_DIR/config/zsh"

# Performance timing (optional)
DOTFILES_PERF_TIMING=${DOTFILES_PERF_TIMING:-false}
perf_time() {
    if [[ "$DOTFILES_PERF_TIMING" == "true" ]]; then
        echo "⏱️  $1: $(date +%s.%3N)" >&2
    fi
}

# ----- Load Performance Library -----
perf_time "Loading performance library"
if [[ -f "$DOTFILES_DIR/lib/performance.sh" ]]; then
    source "$DOTFILES_DIR/lib/performance.sh"
fi

# ----- Load Core Configuration Modules -----
perf_time "Loading core modules"

# Core shell configuration
[[ -f "$ZSH_CONFIG_DIR/core.zsh" ]] && source "$ZSH_CONFIG_DIR/core.zsh"

# PATH and environment setup
[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"
[[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"

# Modern tools and completions
[[ -f "$ZSH_CONFIG_DIR/tools.zsh" ]] && source "$ZSH_CONFIG_DIR/tools.zsh"

# Aliases
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"

# ----- Load Function Modules -----
perf_time "Loading function modules"

# Core functions
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"

# Development tool optimization
[[ -f "$ZSH_CONFIG_DIR/optimization.zsh" ]] && source "$ZSH_CONFIG_DIR/optimization.zsh"

# AI integration (loaded conditionally for performance)
if [[ -z "$DOTFILES_FAST_MODE" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/ai.zsh" ]] && source "$ZSH_CONFIG_DIR/ai.zsh"
fi

# Testing frameworks (loaded conditionally for performance)
if [[ -z "$DOTFILES_FAST_MODE" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/testing.zsh" ]] && source "$ZSH_CONFIG_DIR/testing.zsh"
fi

# ----- Load Legacy Functions and Custom User Config -----
perf_time "Loading legacy and user config"

# Load any remaining legacy functions from the end of old .zshrc
if [[ -f "$DOTFILES_DIR/.zshrc.legacy" ]]; then
    source "$DOTFILES_DIR/.zshrc.legacy"
fi

# User-specific customizations (optional)
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

# ----- Module Loading Status -----
perf_time "Configuration complete"

# Display loading status (only in interactive shells)
if [[ $- == *i* ]] && [[ -z "$DOTFILES_QUIET" ]]; then
    echo "🚀 Modern ZSH Configuration Loaded - $(date +%H:%M)"
    echo "🔧 Available tools: starship, zoxide, eza, bat, rg, fd, fzf, atuin"
    echo "🤖 AI tools: claude (cc), gemini (gg), aider (ai), copilot (cop)"
    echo "🧪 Testing tools: bruno (bt), playwright (pw), pytest (pt), k6"
    echo "🔒 AI Security: ai-security-status, ai-security-strict, ai-security-permissive"
    echo "⚡ Performance: perf-benchmark-startup, enable-fast-mode, perf-status"
    echo "🎯 Type 'proj' to switch projects, 'tm' for smart tmux sessions, 'testing-status' for test setup"
    echo "📦 Dotfiles version: $(cat $DOTFILES_DIR/VERSION 2>/dev/null || echo '2025.1.6') (use 'df-update' to check for updates)"
fi

# Auto-update check (async, non-blocking)
if [[ -z "$DOTFILES_FAST_MODE" ]] && [[ $- == *i* ]]; then
    { auto_update_check } &
fi