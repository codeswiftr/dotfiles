# ============================================================================
# Dynamic Environment Configuration
# Variables that require runtime evaluation or conditional logic
# Static defaults are in defaults.zsh
# ============================================================================

# ----------------------------------------------------------------------------
# API Keys (loaded from environment, not hardcoded)
# ----------------------------------------------------------------------------
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"
export GEMINI_API_KEY="${GEMINI_API_KEY:-}"

# ----------------------------------------------------------------------------
# Tool-Specific Dynamic Configuration
# ----------------------------------------------------------------------------

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
