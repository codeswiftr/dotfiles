# ============================================================================
# FORGE operator environment
# Current workflow helpers for human operators and local agent sessions.
# ============================================================================

[[ -n "$DOTFILES_SSH" ]] && return 0

: "${FORGE_ROOT:=$HOME/work/forge-mono}"
: "${FORGE_LOCAL_API_URL:=http://localhost:8081}"
: "${FORGE_HUB_API_URL:=http://prya:8081}"
: "${OPENCLAW_ALLOW_INSECURE_PRIVATE_WS:=1}"

export FORGE_ROOT FORGE_LOCAL_API_URL FORGE_HUB_API_URL OPENCLAW_ALLOW_INSECURE_PRIVATE_WS

[[ -d "$FORGE_ROOT/cmd/forge" ]] && path=("$FORGE_ROOT/cmd/forge" $path)

forge-local() {
    FORGE_API_URL="$FORGE_LOCAL_API_URL" forge "$@"
}

forge-root() {
    if [[ -d "$FORGE_ROOT" ]]; then
        cd "$FORGE_ROOT" || return
    else
        echo "FORGE_ROOT not found: $FORGE_ROOT" >&2
        return 1
    fi
}

forge-ready() {
    forge-local operator status
}

forge-prime-check() {
    forge-local operator status
    forge-local attention
    forge-local gate status
    forge-local task list
    forge-local agent list
}

forge-node-up-local() {
    forge-local node up --no-pull --skip-build "$@"
}

forge-restart() {
    local pane="${1:-forge:$(hostname -s)}"
    echo "Bootstrap restart in $pane: /clear then /continue"
    tmux send-keys -t "$pane" "/clear" Enter
    sleep 3
    tmux send-keys -t "$pane" "/continue" Enter
}

tailscale-start() {
    command -v tailscale >/dev/null 2>&1 || return 0
    tailscale status --json >/dev/null 2>&1 && return 0
    tailscale up --operator="$USER"
}

[[ "${DOTFILES_FORGE_AUTOSTART_TAILSCALE:-0}" == "1" ]] && tailscale-start &!

alias flocal='forge-local'
alias fr='forge-root'
alias fop='forge operator status'
alias flop='forge-local operator status'
alias fprime='forge-prime-check'
alias fattn='forge attention'
alias flattn='forge-local attention'
alias fgate='forge gate status'
alias flgate='forge-local gate status'
alias fstatus='forge status'
alias flstatus='forge-local status'
alias fal='forge agent list'
alias flal='forge-local agent list'
alias ftl='forge task list'
alias fltl='forge-local task list'
alias ftask='forge task'
alias fcreate='forge task create'
alias fctx='forge task context-pack'
alias fverify='forge task verify'
alias freconcile='forge task reconcile'
alias fdispatch='forge dispatch'
alias fmsg='forge message send'
alias fnode='forge node'
alias fup='forge-node-up-local'
alias fportfolio='forge portfolio status'
alias fcheck='forge check --fast'
