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
    # Pretty welcome - only show on first shell (not subshells)
    if [[ -z "$ZSH_WELCOME_SHOWN" ]]; then
        export ZSH_WELCOME_SHOWN=1

        # System info - use print -P to interpret prompt sequences
        print -P ""
        print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
        print -P "  %F{cyan}%n@%m%f  %F{green}$(uptime -p 2>/dev/null || uptime)%f  %F{yellow}zsh ${ZSH_VERSION}%f"
        print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"

        # Tool availability (compact, only show first few)
        local tools=("starship" "zoxide" "eza" "bat" "rg" "fd" "fzf" "mise")
        local available=()
        for tool in "${tools[@]}"; do
            command -v "$tool" >/dev/null && available+=("$tool")
        done
        if [[ ${#available[@]} -gt 0 ]]; then
            print -P "  %F{yellow}⚡%f ${available[1]}%f, ${available[2]}%f, ${available[3]}%f ... ${#available[@]} tools"
        fi

        # FORGE node status (if forge is available)
        if command -v forge >/dev/null 2>&1; then
            local forge_status=$(forge node health 2>/dev/null)
            if [[ -n "$forge_status" ]]; then
                print -P "  %F{magenta}🔥 FORGE%f"

                # Parse using sed (more portable)
                # Status: online/offline
                if echo "$forge_status" | sed -n 's/.*Status: \([^ ]*\).*/\1/p' | grep -q "online"; then
                    print -P "    %F{green}✓%f online"
                elif echo "$forge_status" | sed -n 's/.*Status: \([^ ]*\).*/\1/p' | grep -q "offline"; then
                    print -P "    %F{red}✗%f offline"
                fi

                # RAM: "12575 MB free / 49152 MB total"
                local ram_info=$(echo "$forge_status" | sed -n 's/.*RAM: \([^M]*\)MB free.*/\1/p')
                if [[ -n "$ram_info" ]]; then
                    print -P "    %F{blue}▮%f RAM: ${ram_info}MB free"
                fi

                # CPU: "62.7%"
                local cpu_info=$(echo "$forge_status" | sed -n 's/.*CPU: \([^%]*\)%.*/\1/p')
                if [[ -n "$cpu_info" ]]; then
                    print -P "    %F{yellow}▯%f CPU: ${cpu_info}%"
                fi

                # Queue: "52 pending"
                local queue_info=$(echo "$forge_status" | sed -n 's/.*Queue: \([^ ]*\).*/\1/p')
                if [[ -n "$queue_info" ]]; then
                    print -P "    %F{cyan}▫%f Queue: $queue_info pending"
                fi
            fi
        fi
        print -P ""
    fi
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
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# OpenClaw Completion (conditional - only if exists)
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"
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

# Load ~/.profile if available
[[ -f ~/.profile ]] && source ~/.profile

# FORGE xnode real-time activation
export COMMAND_CENTER_URL="https://prya.queue-great.ts.net"
export FORGE_WEBHOOK_TOKEN="a4xduoCkGQhTTQcEOQXPMvDAXG_7rzl7_CIs0ofTkiA"
export FORGE_ROOT="$HOME/work/FORGE"
export FORGE_API_URL=http://prya:8081
export PATH="${FORGE_ROOT}/cmd/forge:${PATH}"

# Auto-start Tailscale if not running
tailscale_start() {
    if ! tailscale status --json >/dev/null 2>&1; then
        echo "Starting Tailscale..."
        tailscale up --operator="$USER"
    fi
}
# Auto-start on every shell:
tailscale_start

# Allow plaintext WS over Tailscale
export OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=1
