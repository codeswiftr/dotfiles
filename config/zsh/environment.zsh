# ============================================================================
# Dynamic Environment Configuration
# Variables that require runtime evaluation or conditional logic
# Static defaults are in defaults.zsh
# ============================================================================

# ----------------------------------------------------------------------------
# Terminal Compatibility (Ghostty SSH fix)
# ----------------------------------------------------------------------------
# Fix "missing or unsuitable terminal: xterm-ghostty" when SSHing with Ghostty
# to servers that lack the ghostty terminfo entry
if [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
    export TERM="xterm-256color"
fi

# Alternative: Always use xterm-256color when running in Ghostty
# Uncomment if you prefer this approach:
# if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
#     export TERM="xterm-256color"
# fi

# ----------------------------------------------------------------------------
# API Keys (loaded from environment, not hardcoded)
# ----------------------------------------------------------------------------
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export GEMINI_API_KEY="${GEMINI_API_KEY:-}"

# ----------------------------------------------------------------------------
# Tool-Specific Dynamic Configuration
# ----------------------------------------------------------------------------

# NPM - Use user directory for global packages (avoids sudo on Linux)
if [[ ! -d "$HOME/.npm-global" ]]; then
    mkdir -p "$HOME/.npm-global"
fi
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# PIPENV - only if installed
if command -v pipenv >/dev/null 2>&1; then
    export PIPENV_VENV_IN_PROJECT=1
fi

# ----------------------------------------------------------------------------
# Development Mode Detection
# ----------------------------------------------------------------------------
# Auto-detect if we're in a development environment
if [[ -f "$DOTFILES_DIR/.git/config" ]]; then
    export DOTFILES_DEV_MODE=true
fi
