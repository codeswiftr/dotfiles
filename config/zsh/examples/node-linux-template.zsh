# =============================================================================
# Linux Node Configuration Template
# Copy to config/zsh/<your-hostname>.zsh and customize.
# =============================================================================

# ---- Customize these --------------------------------------------------------
export FORGE_NODE="${FORGE_NODE:-$(hostname -s)}"
export FORGE_NODE_ROLE="general"           # e.g., workhorse, server, auxiliary
export FORGE_NODE_MAX_AGENTS=2             # max concurrent AI agents
# -----------------------------------------------------------------------------

# Convenience aliases
alias node-info='node-info-local'
alias node-health='node-health-local'

# System info
node-info-local() {
    echo "Node: ${FORGE_NODE}"
    echo "Role: ${FORGE_NODE_ROLE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Hardware:"
    echo "  CPU: $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo 'Unknown')"
    echo "  RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo 'Unknown')"
    echo "  OS:  $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -sr)"
    echo "  Max agents: ${FORGE_NODE_MAX_AGENTS}"
}

# Health check
node-health-local() {
    local issues=0
    echo "Health check: ${FORGE_NODE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for tool in git nvim tmux; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool missing"
            ((issues++))
        fi
    done

    # Available memory
    local free_mb; free_mb=$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)
    [[ -n "$free_mb" ]] && echo "  Free RAM: ${free_mb} MB"

    echo ""
    [[ $issues -eq 0 ]] && echo "✅ All OK" || echo "⚠️  $issues issue(s)"
    return "$issues"
}

# ---- Project directory navigation (customize to your layout) ----------------
# alias cd-proj1='cd "${PROJECT_ROOT:-$HOME/work}/project-1"'

# ---- Node-specific PATH additions -------------------------------------------
# export PATH="$HOME/.local/node-specific/bin:$PATH"
