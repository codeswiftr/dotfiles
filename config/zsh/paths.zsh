# ============================================================================
# PATH Configuration
# System paths and tool-specific path additions
# ============================================================================

# Base PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# Dotfiles bin directory for dot CLI
export PATH="$DOTFILES_DIR/bin:$PATH"

# Bun (JavaScript runtime)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# uv (Python package manager)
export UV_CACHE_DIR="$HOME/.cache/uv"
export UV_TOOL_DIR="$HOME/.local/share/uv/tools"
export PATH="$UV_TOOL_DIR/bin:$PATH"

# Windsurf (AI Code Editor) - Cross-platform path
if [[ -d "$HOME/.codeium/windsurf/bin" ]]; then
    export PATH="$HOME/.codeium/windsurf/bin:$PATH"
fi

# macOS specific paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Homebrew
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    fi
    
    # Mac-specific tools
    if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
        export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    fi
fi

# Linux specific paths
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Snap packages
    if [[ -d "/snap/bin" ]]; then
        export PATH="/snap/bin:$PATH"
    fi
    
    # AppImage directory
    if [[ -d "$HOME/Applications" ]]; then
        export PATH="$HOME/Applications:$PATH"
    fi
fi