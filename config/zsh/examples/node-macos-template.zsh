# =============================================================================
# macOS Node Configuration Template
# Copy to config/zsh/<your-hostname>.zsh and customize.
# =============================================================================

# ---- Customize these --------------------------------------------------------
export FORGE_NODE="${FORGE_NODE:-$(hostname -s)}"
export FORGE_NODE_ROLE="general"           # e.g., workhorse, ios, education
export FORGE_NODE_MAX_AGENTS=2             # max concurrent AI agents
# -----------------------------------------------------------------------------

# Convenience aliases pointing to this node's functions
alias node-info='node-info-local'
alias node-health='node-health-local'

# System info function — shows hardware and role summary
node-info-local() {
    echo "Node: ${FORGE_NODE}"
    echo "Role: ${FORGE_NODE_ROLE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Hardware:"
    local cpu; cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
    local ram; ram=$(sysctl -n hw.memsize | awk '{printf "%.0f GB", $1/1024/1024/1024}' 2>/dev/null || echo "Unknown RAM")
    echo "  CPU: $cpu"
    echo "  RAM: $ram"
    echo "  OS:  macOS $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
    echo "  Max agents: ${FORGE_NODE_MAX_AGENTS}"
}

# Health check — verify required tools and resources
node-health-local() {
    local issues=0
    echo "Health check: ${FORGE_NODE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Required tools (customize this list)
    for tool in git nvim tmux; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool missing"
            ((issues++))
        fi
    done

    # Available memory
    local free_gb
    free_gb=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.1f", ($1*$ps)/1073741824')
    if [[ -n "$free_gb" ]]; then
        echo "  Free RAM: ${free_gb} GB"
    fi

    echo ""
    [[ $issues -eq 0 ]] && echo "✅ All OK" || echo "⚠️  $issues issue(s)"
    return "$issues"
}

# ---- Project directory navigation (customize to your layout) ----------------
# alias cd-proj1='cd "${PROJECT_ROOT:-$HOME/work}/project-1"'
# alias cd-proj2='cd "${PROJECT_ROOT:-$HOME/work}/project-2"'

# ---- Node-specific PATH additions -------------------------------------------
# export PATH="$HOME/.local/node-specific/bin:$PATH"
