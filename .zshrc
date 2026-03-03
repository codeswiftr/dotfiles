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
# AI tools (loaded synchronously to ensure functions are available)
if [[ -z "$DOTFILES_FAST_MODE" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/ai-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/ai-enhanced.zsh"
fi

# FORGE tools integration (QMD, forge CLI)
[[ -f "$ZSH_CONFIG_DIR/forge-tools.zsh" ]] && source "$ZSH_CONFIG_DIR/forge-tools.zsh"

# Node-specific configuration (auto-detect)
if [[ "$(hostname)" == "trinity" ]] || [[ "$(hostname)" == "code-trinity" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/trinity.zsh" ]] && source "$ZSH_CONFIG_DIR/trinity.zsh"
    [[ -f "$DOTFILES_DIR/config/agents/trinity.zsh" ]] && source "$DOTFILES_DIR/config/agents/trinity.zsh"
fi

if [[ "$(hostname)" == "gaea" ]] || [[ "$(hostname)" == "code-gaea" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/gaea.zsh" ]] && source "$ZSH_CONFIG_DIR/gaea.zsh"
fi

# FORGE integration (disabled - conflicts with forge CLI)
# if [[ -d "${FORGE_ROOT:-}" ]] && [[ -f "$ZSH_CONFIG_DIR/forge.zsh" ]]; then
#     source "$ZSH_CONFIG_DIR/forge.zsh"
# fi

# -----------------------------------------------------------------------------
# 7. User Customizations (Load Last)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# -----------------------------------------------------------------------------
# 8. Welcome Message (Interactive shells only)
# -----------------------------------------------------------------------------
if [[ $- == *i* ]] && [[ -z "$DOTFILES_QUIET" ]]; then
    echo "🚀 ZSH Ready - $(/bin/date +%H:%M)"
    
    # Tool availability (compact)
    local tools=("starship" "zoxide" "eza" "bat" "rg" "fd" "fzf" "mise")
    local available=()
    for tool in "${tools[@]}"; do
        command -v "$tool" >/dev/null && available+=("$tool")
    done
    [[ ${#available[@]} -gt 0 ]] && echo "🔧 Tools: ${available[*]}"
fi

# Atuin shell history (if installed)
if [[ -f "$HOME/.atuin/bin/env" ]]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init zsh)"
fi

# OpenCode (if installed)
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"


alias claw-relay='OPENCLAW_GATEWAY_TOKEN="2f7ad44859ce7df051b870d3adaaaf966a7fe34054f621546d44d5c12a27098b"
  openclaw node run --host prya.queue-great.ts.net --port 443 --tls --display-name "m3-browser"'


# bun completions
[ -s "/Users/bogdan/.bun/_bun" ] && source "/Users/bogdan/.bun/_bun"

# OpenClaw Completion
source "/home/openclaw/.openclaw/completions/openclaw.zsh"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# FORGE lead orchestrator restart (run from any terminal/pane)
forge-restart() {
  local pane="${1:-forge:prya}"
  echo "Sending /clear + /continue to $pane..."
  tmux send-keys -t "$pane" "/clear" Enter
  sleep 3
  tmux send-keys -t "$pane" "/continue" Enter
  echo "Done. Lead orchestrator restarting in $pane."
}

# XNODE real-time activation
export COMMAND_CENTER_URL="https://prya.queue-great.ts.net:8443"
export FORGE_WEBHOOK_TOKEN="a4xduoCkGQhTTQcEOQXPMvDAXG_7rzl7_CIs0ofTkiA"

# Load ~/.profile if available
[[ -f ~/.profile ]] && source ~/.profile

# opencode
export PATH=/Users/bogdan/.opencode/bin:$PATH

# FORGE xnode real-time activation
export COMMAND_CENTER_URL="https://prya.queue-great.ts.net"
export FORGE_WEBHOOK_TOKEN="a4xduoCkGQhTTQcEOQXPMvDAXG_7rzl7_CIs0ofTkiA"
