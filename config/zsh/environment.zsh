# ============================================================================
# Environment Variables
# Tool-specific environment configuration and optimizations
# ============================================================================

# Python environment
export RUFF_CACHE_DIR="$HOME/.cache/ruff"

# Modern tool optimizations
export UV_LINK_MODE="copy"  # Faster installs
export UV_COMPILE_BYTECODE="1"  # Pre-compile for speed
export BUN_INSTALL_CACHE_DIR="$HOME/.bun/cache"
export MISE_USE_TOML="1"  # Faster than .tool-versions

# Themes
export BAT_THEME="Catppuccin Mocha"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# FZF color scheme (Catppuccin Mocha)
export FZF_DEFAULT_OPTS="
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Language-specific environment variables
export PYTHONDONTWRITEBYTECODE=1  # Don't create .pyc files
export PYTHONUNBUFFERED=1         # Force stdout/stderr to be unbuffered
export PIPENV_VENV_IN_PROJECT=1   # Create .venv in project directory

# Node.js environment
export NODE_ENV=${NODE_ENV:-development}

# Go environment
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust environment
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

# AI/Development tools
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export GEMINI_API_KEY="${GEMINI_API_KEY:-}"

# Performance and debugging
export DOTFILES_PERF_TIMING="${DOTFILES_PERF_TIMING:-false}"
export DOTFILES_DEBUG="${DOTFILES_DEBUG:-false}"

# Security
export AI_SECURITY_ENABLED="${AI_SECURITY_ENABLED:-true}"
export AI_ALLOW_CODE_SHARING="${AI_ALLOW_CODE_SHARING:-false}"
export AI_ALLOW_GIT_DATA="${AI_ALLOW_GIT_DATA:-false}"

# Cross-platform compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
    export BROWSER="open"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux specific
    export BROWSER="xdg-open"
fi