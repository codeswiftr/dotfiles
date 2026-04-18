# =============================================================================
# ZSH Configuration - Streamlined Edition
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Essential Setup (Always load first)
# -----------------------------------------------------------------------------
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export ZSH_CONFIG_DIR="$DOTFILES_DIR/config/zsh"

# SSH session detection (used throughout to skip heavy/local-only features)
[[ -n "$SSH_CONNECTION" ]] && export DOTFILES_SSH=1

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
# 4. Tool Initialization (SSH-aware: skip heavy tools in remote sessions)
# -----------------------------------------------------------------------------
if [[ -z "$DOTFILES_SSH" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/tools-optimized.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-optimized.zsh"
else
    # Minimal tool init for SSH sessions
    [[ -f "$ZSH_CONFIG_DIR/tools-minimal.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-minimal.zsh"
fi

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

# Node-specific configuration (auto-detected — add config/zsh/<hostname>.zsh for any new machine)
_DOTFILES_NODE="${$(hostname -s 2>/dev/null || hostname)#code-}"
[[ -f "$ZSH_CONFIG_DIR/${_DOTFILES_NODE}.zsh" ]] && source "$ZSH_CONFIG_DIR/${_DOTFILES_NODE}.zsh"
[[ -f "$DOTFILES_DIR/config/agents/${_DOTFILES_NODE}.zsh" ]] && source "$DOTFILES_DIR/config/agents/${_DOTFILES_NODE}.zsh"
unset _DOTFILES_NODE

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
if [[ $- == *i* ]] && [[ "${DOTFILES_BANNER:-0}" == "1" ]] && [[ -z "$SSH_CONNECTION" ]]; then
    # Pretty welcome - opt-in via DOTFILES_BANNER=1, only show on first shell (not subshells)
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

# Background dotfiles update check — notifies when behind origin (non-blocking)
if [[ $- == *i* ]]; then
    _dotfiles_check_updates() {
        local dir="${DOTFILES_DIR:-$HOME/dotfiles}"
        [[ -d "$dir/.git" ]] || return 0
        git -C "$dir" fetch --quiet origin 2>/dev/null || return 0
        local branch behind
        branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null) || return 0
        behind=$(git -C "$dir" rev-list "HEAD..origin/$branch" --count 2>/dev/null) || return 0
        [[ "${behind:-0}" -gt 0 ]] && \
            print -P "\n  %F{yellow}dotfiles:%f ${behind} commit(s) behind — run %F{cyan}dot update%f\n"
    }
    _dotfiles_check_updates &!
fi

# Atuin: initialized via tools-optimized.zsh (lazy loader)
# Only source the env file here for PATH setup; init is handled by atuin_lazy_loader
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

# OpenCode (if installed)
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"


# claw-relay: set OPENCLAW_GATEWAY_TOKEN and OPENCLAW_RELAY_HOST in ~/.env.local
# Example: alias claw-relay='openclaw node run --host "$OPENCLAW_RELAY_HOST" --port 443 --tls --display-name "my-node"'
alias claw-relay='OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:?Set OPENCLAW_GATEWAY_TOKEN in ~/.env.local}" openclaw node run --host "${OPENCLAW_RELAY_HOST:?Set OPENCLAW_RELAY_HOST in ~/.env.local}" --port 443 --tls --display-name "${OPENCLAW_DISPLAY_NAME:-my-node}"'


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# OpenClaw Completion (conditional - only if exists)
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"
# PATH: .bun/bin and .local/bin are set in config/zsh/defaults.zsh (single source)

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

# Local machine secrets and overrides (gitignored, never committed)
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"

# FORGE integration (only on non-SSH sessions — servers don't need this)
if [[ -z "$SSH_CONNECTION" ]]; then
    export FORGE_ROOT="${FORGE_ROOT:-$HOME/work/forge-mono}"
    export FORGE_API_URL="${FORGE_API_URL:-http://prya:8081}"
    [[ -n "$FORGE_ROOT" ]] && export PATH="${FORGE_ROOT}/cmd/forge:${PATH}"

    # Auto-start Tailscale if not running (background, non-blocking)
    tailscale_start() {
        command -v tailscale >/dev/null 2>&1 || return 0
        tailscale status --json >/dev/null 2>&1 && return 0
        echo "Starting Tailscale..."
        tailscale up --operator="$USER"
    }
    tailscale_start &!

    export OPENCLAW_ALLOW_INSECURE_PRIVATE_WS=1
fi