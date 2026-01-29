# =============================================================================
# ZSH Configuration - Streamlined Edition
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Essential Setup (Always load first)
# -----------------------------------------------------------------------------
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export ZSH_CONFIG_DIR="$DOTFILES_DIR/config/zsh"

# -----------------------------------------------------------------------------
# 2. Defaults (Cross-Platform, Single Source)
# -----------------------------------------------------------------------------
# This file contains: PATH, environment variables, FZF settings
[[ -f "$ZSH_CONFIG_DIR/defaults.zsh" ]] && source "$ZSH_CONFIG_DIR/defaults.zsh"

# -----------------------------------------------------------------------------
# 3. Core Configuration
# -----------------------------------------------------------------------------
[[ -f "$ZSH_CONFIG_DIR/core.zsh" ]] && source "$ZSH_CONFIG_DIR/core.zsh"
[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"
[[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"

# -----------------------------------------------------------------------------
# 4. Tool Initialization (Optimized)
# -----------------------------------------------------------------------------
[[ -f "$ZSH_CONFIG_DIR/tools-optimized.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-optimized.zsh"

# -----------------------------------------------------------------------------
# 5. User Experience
# -----------------------------------------------------------------------------
[[ -f "$ZSH_CONFIG_DIR/history-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/history-enhanced.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"

# -----------------------------------------------------------------------------
# 6. Optional Features (Conditional)
# -----------------------------------------------------------------------------
# AI tools (async loading for faster startup)
if [[ -z "$DOTFILES_FAST_MODE" ]]; then
    {
        [[ -f "$ZSH_CONFIG_DIR/ai-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/ai-enhanced.zsh"
    } &
fi

# FORGE integration (only if FORGE_ROOT exists)
if [[ -d "${FORGE_ROOT:-}" ]] && [[ -f "$ZSH_CONFIG_DIR/forge.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/forge.zsh"
fi

# -----------------------------------------------------------------------------
# 7. User Customizations (Load Last)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# -----------------------------------------------------------------------------
# 8. Welcome Message (Interactive shells only)
# -----------------------------------------------------------------------------
if [[ $- == *i* ]] && [[ -z "$DOTFILES_QUIET" ]]; then
    echo "🚀 ZSH Ready - $(date +%H:%M)"
    
    # Tool availability (compact)
    local tools=("starship" "zoxide" "eza" "bat" "rg" "fd" "fzf" "mise")
    local available=()
    for tool in "${tools[@]}"; do
        command -v "$tool" >/dev/null && available+=("$tool")
    done
    [[ ${#available[@]} -gt 0 ]] && echo "🔧 Tools: ${available[*]}"
fi
