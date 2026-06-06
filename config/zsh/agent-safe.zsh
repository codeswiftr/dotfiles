# ============================================================================
# Agent-safe shell compatibility
# Keep common command names predictable for coding agents and automation.
# ============================================================================

export DOTFILES_AGENT_SAFE=1

# Avoid interactive pagers or decorated output in command captures.
export PAGER="cat"
export GIT_PAGER="cat"
export MANPAGER="cat"
export BAT_PAGER="cat"
export BAT_STYLE="plain"
export LESS="-F -X"
export CLICOLOR="0"

# Standard commands must keep their standard semantics. Prefer short explicit
# aliases such as ll, tree, bat, rg, and fd for human convenience.
unalias cat less grep find ls man vim vi tmux python python3 pip pip3 node npm npx 2>/dev/null || true

# zsh spelling correction prompts are useful for humans but hazardous when an
# agent runs generated commands non-interactively.
unsetopt CORRECT CORRECT_ALL 2>/dev/null || true

agent-safe-status() {
    echo "DOTFILES_AGENT_SAFE=${DOTFILES_AGENT_SAFE:-0}"
    echo "DOTFILES_MODE=${DOTFILES_MODE:-full}"
    echo "PAGER=${PAGER:-unset}"
    echo "GIT_PAGER=${GIT_PAGER:-unset}"
    echo "MANPAGER=${MANPAGER:-unset}"
    echo "BAT_PAGER=${BAT_PAGER:-unset}"
    echo "LESS=${LESS:-unset}"
    echo "CORRECT=${options[correct]}"
    alias cat less grep find ls man vim vi tmux python python3 pip pip3 node npm npx 2>/dev/null || true
}
