# ============================================================================
# PATH Configuration Extension
# For paths that require conditional logic or platform detection
# Base PATH is set in defaults.zsh (single source)
# ============================================================================

# ----------------------------------------------------------------------------
# Conditional Tool Paths
# ----------------------------------------------------------------------------

# Mise (lazy-loaded path setup)
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
elif [[ -d "$HOME/.mise/bin" ]]; then
    export PATH="$HOME/.mise/bin:$PATH"
fi

# ----------------------------------------------------------------------------
# Development Tool Paths (conditional)
# ----------------------------------------------------------------------------

# Android SDK (if installed)
if [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"
fi

# Flutter (if installed)
if [[ -d "$HOME/flutter/bin" ]]; then
    export PATH="$HOME/flutter/bin:$PATH"
fi

# ----------------------------------------------------------------------------
# Local PATH (highest priority, loaded last)
# ----------------------------------------------------------------------------
# User-specific local binaries (not tracked in dotfiles)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Secret PATH additions (API keys, tokens, etc.)
[[ -f "$HOME/.paths.local" ]] && source "$HOME/.paths.local"
