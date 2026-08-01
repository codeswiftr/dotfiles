# =============================================================================
# ZSH Configuration — thin loader
# Source modules live in config/zsh/. Host / secrets stay out of this file.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Essential setup
# -----------------------------------------------------------------------------
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export ZSH_CONFIG_DIR="$DOTFILES_DIR/config/zsh"

# Modes: full (default) | minimal (SSH) | agent (coding agents / CI)
# Override with DOTFILES_MODE=... in the environment or ~/.zshrc.local
[[ -n "$SSH_CONNECTION" ]] && export DOTFILES_SSH=1
: "${DOTFILES_MODE:=${DOTFILES_SSH:+minimal}}"
: "${DOTFILES_MODE:=full}"
if [[ "$DOTFILES_MODE" == "agent" || -n "${FORGE_AGENT_TYPE:-}" || -n "${CI:-}" ]]; then
    export DOTFILES_MODE=agent
    export DOTFILES_AGENT_SAFE=1
fi

# -----------------------------------------------------------------------------
# 2. Defaults + core (PATH, env, setopts)
# -----------------------------------------------------------------------------
[[ -f "$ZSH_CONFIG_DIR/defaults.zsh" ]] && source "$ZSH_CONFIG_DIR/defaults.zsh"
[[ -f "$ZSH_CONFIG_DIR/core.zsh" ]] && source "$ZSH_CONFIG_DIR/core.zsh"
[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"
[[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"

# -----------------------------------------------------------------------------
# 3. Tools (SSH / agent → minimal; interactive human → optimized)
# -----------------------------------------------------------------------------
if [[ -z "$DOTFILES_SSH" && -z "$DOTFILES_AGENT_SAFE" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/tools-optimized.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-optimized.zsh"
else
    [[ -f "$ZSH_CONFIG_DIR/tools-minimal.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-minimal.zsh"
fi

# -----------------------------------------------------------------------------
# 4. UX modules
# -----------------------------------------------------------------------------
[[ -f "$ZSH_CONFIG_DIR/history-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/history-enhanced.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"
if [[ -n "$DOTFILES_AGENT_SAFE" && -f "$ZSH_CONFIG_DIR/agent-safe.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/agent-safe.zsh"
fi

# -----------------------------------------------------------------------------
# 5. Optional features
# -----------------------------------------------------------------------------
if [[ "$DOTFILES_MODE" == "full" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/ai-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/ai-enhanced.zsh"
fi

# FORGE operator helpers (skipped on SSH inside forge.zsh)
[[ -f "$ZSH_CONFIG_DIR/forge.zsh" ]] && source "$ZSH_CONFIG_DIR/forge.zsh"

# Optional fleet profile (openclaw, extra agent PATH bits) — no secrets
if [[ "${DOTFILES_PROFILE:-}" == "fleet" || -f "$DOTFILES_DIR/config/profiles/fleet/.enabled" ]]; then
    [[ -f "$DOTFILES_DIR/config/profiles/fleet/shell.zsh" ]] && \
        source "$DOTFILES_DIR/config/profiles/fleet/shell.zsh"
fi

# Node / host config: config/zsh/<hostname>.zsh
_DOTFILES_NODE="${$(hostname -s 2>/dev/null || hostname)#code-}"
[[ -f "$ZSH_CONFIG_DIR/${_DOTFILES_NODE}.zsh" ]] && source "$ZSH_CONFIG_DIR/${_DOTFILES_NODE}.zsh"
[[ -f "$DOTFILES_DIR/config/agents/${_DOTFILES_NODE}.zsh" ]] && source "$DOTFILES_DIR/config/agents/${_DOTFILES_NODE}.zsh"
unset _DOTFILES_NODE

# -----------------------------------------------------------------------------
# 6. User customizations last
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"

# Avoid stale FORGE_API_URL leaking into every shell (see forge.zsh helpers).
if [[ -n "${FORGE_API_URL:-}" && "${DOTFILES_FORGE_KEEP_GLOBAL_API:-0}" != "1" ]]; then
    export FORGE_PROFILE_API_URL="$FORGE_API_URL"
    unset FORGE_API_URL
fi

# -----------------------------------------------------------------------------
# 7. Interactive-only extras (humans; never agents)
# -----------------------------------------------------------------------------
if [[ $- == *i* && -z "$DOTFILES_AGENT_SAFE" ]]; then
    if [[ "${DOTFILES_BANNER:-0}" == "1" && -z "$SSH_CONNECTION" && -z "$ZSH_WELCOME_SHOWN" ]]; then
        export ZSH_WELCOME_SHOWN=1
        print -P ""
        print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
        print -P "  %F{cyan}%n@%m%f  %F{yellow}zsh ${ZSH_VERSION}%f  mode=%F{green}${DOTFILES_MODE}%f"
        print -P "%F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
        print -P ""
    fi

    # Background update notice (non-blocking)
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
