# ============================================================================
# Cross-Platform Defaults - Single Source of Truth
# Essential settings that work on macOS, Linux, and WSL
# ============================================================================

# ----------------------------------------------------------------------------
# Core PATH (single source)
# ----------------------------------------------------------------------------
# Ensure essential system paths are always present
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

# ----------------------------------------------------------------------------
# Tool Paths
# ----------------------------------------------------------------------------
# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust
export CARGO_HOME="$HOME/.cargo"
export PATH="$CARGO_HOME/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# uv Python tools
export UV_TOOL_DIR="$HOME/.local/share/uv/tools"
export PATH="$UV_TOOL_DIR/bin:$PATH"

# ----------------------------------------------------------------------------
# Environment Variables (single source)
# ----------------------------------------------------------------------------
# Python
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export UV_LINK_MODE="copy"
export UV_COMPILE_BYTECODE="1"
export RUFF_CACHE_DIR="$HOME/.cache/ruff"

# Node
export NODE_ENV="${NODE_ENV:-development}"
export BUN_INSTALL_CACHE_DIR="$HOME/.bun/cache"

# Mise (version manager)
export MISE_USE_TOML="1"

# Themes
export BAT_THEME="Catppuccin Mocha"

# FZF - Single source of truth (with fallbacks for missing tools)
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"
else
    # Fallback to find (slower but universally available)
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*'"
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="
    --height 40% 
    --layout=reverse 
    --border 
    --inline-info
    --cycle
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --bind='ctrl-u:preview-half-page-up'
    --bind='ctrl-d:preview-half-page-down'
    --bind='ctrl-/:toggle-preview'"

# FORGE Portfolio
export FORGE_ROOT="${FORGE_ROOT:-$HOME/work/FORGE}"

# Performance/Debug
export DOTFILES_PERF_TIMING="${DOTFILES_PERF_TIMING:-false}"
export DOTFILES_DEBUG="${DOTFILES_DEBUG:-false}"

# Security
export AI_SECURITY_ENABLED="${AI_SECURITY_ENABLED:-true}"
export AI_ALLOW_CODE_SHARING="${AI_ALLOW_CODE_SHARING:-false}"
export AI_ALLOW_GIT_DATA="${AI_ALLOW_GIT_DATA:-false}"

# ----------------------------------------------------------------------------
# Platform-Specific PATH Additions
# ----------------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    export BROWSER="open"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    
    # Homebrew (Apple Silicon)
    [[ -d "/opt/homebrew/bin" ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    
    # VS Code
    [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] && \
        export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    
    # Windsurf
    [[ -d "$HOME/.codeium/windsurf/bin" ]] && \
        export PATH="$HOME/.codeium/windsurf/bin:$PATH"
        
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    export BROWSER="xdg-open"
    
    # Snap
    [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
    
    # AppImage
    [[ -d "$HOME/Applications" ]] && export PATH="$HOME/Applications:$PATH"
fi

# ----------------------------------------------------------------------------
# Cache Directories
# ----------------------------------------------------------------------------
export UV_CACHE_DIR="$HOME/.cache/uv"
export BUN_INSTALL_CACHE_DIR="$HOME/.bun/cache"
