# =============================================================================
# Fleet Dashboard - Unified Multi-Node Operations
# Provides comprehensive fleet visibility and management
# =============================================================================

# Skip in SSH sessions — fleet tools require Tailscale and are local-only
[[ -n "$DOTFILES_SSH" ]] && return 0

# -----------------------------------------------------------------------------
# Fleet Status - All nodes at a glance
# -----------------------------------------------------------------------------

fleet-status() {
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                    FLEET STATUS DASHBOARD                         ║"
    echo "║                    $(date '+%Y-%m-%d %H:%M:%S')                            ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""

    # Get forge status
    if command -v forge >/dev/null 2>&1; then
        echo "📊 FORGE Control Plane"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        forge status 2>/dev/null | head -20
        echo ""
    fi

    # Node mesh status
    echo "🌐 XNode Mesh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if command -v forge >/dev/null 2>&1; then
        forge node list 2>/dev/null || echo "  No nodes in mesh"
    else
        echo "  ⚠️  Forge CLI not available"
    fi
    echo ""

    # Local node info
    echo "🖥️  Local Node: $(hostname)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  FORGE_NODE: ${FORGE_NODE:-not set}"
    echo "  FORGE_NODE_ROLE: ${FORGE_NODE_ROLE:-not set}"
    echo "  FORGE_ROOT: ${FORGE_ROOT:-not set}"
    echo ""

    # Quick agent summary
    echo "🤖 Available Agents"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local agents=("claude" "aider" "cursor" "opencode" "gemini" "kimi" "glm" "minimax" "pi" "codex")
    for agent in "${agents[@]}"; do
        if command -v "$agent" >/dev/null 2>&1; then
            echo "  ✅ $agent"
        fi
    done
    echo ""

    # Pending work
    echo "📋 Pending Work"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if command -v forge >/dev/null 2>&1; then
        forge task list 2>/dev/null | head -15 || echo "  No active tasks"
    fi
    echo ""
}

# -----------------------------------------------------------------------------
# Fleet Health - Deep health check across all nodes
# -----------------------------------------------------------------------------

fleet-health() {
    echo "🩺 Fleet Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local issues=0

    # Local checks
    echo "📍 Local Node ($(hostname))"
    echo "  Checking critical services..."

    # Check forge daemon
    if command -v forge >/dev/null 2>&1; then
        if forge daemon status 2>/dev/null | grep -q "running"; then
            echo "  ✅ Forge daemon running"
        else
            echo "  ⚠️  Forge daemon not running"
            ((issues++))
        fi
    fi

    # Check tailscale
    if command -v tailscale >/dev/null 2>&1; then
        if tailscale status --json 2>/dev/null | grep -q "Online"; then
            echo "  ✅ Tailscale connected"
        else
            echo "  ⚠️  Tailscale not connected"
            ((issues++))
        fi
    fi

    # Check QMD
    if command -v qmd >/dev/null 2>&1; then
        echo "  ✅ QMD available"
    else
        echo "  ⚠️  QMD not available"
        ((issues++))
    fi

    echo ""

    # Mesh connectivity
    echo "🌐 Mesh Connectivity"
    if command -v forge >/dev/null 2>&1; then
        local nodes=$(forge node list 2>/dev/null | tail -n +2 | grep -c "online" || echo "0")
        echo "  $nodes node(s) online in mesh"
    fi
    echo ""

    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ $issues -eq 0 ]]; then
        echo "✅ All systems healthy"
        return 0
    else
        echo "⚠️  $issues issue(s) found"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Fleet Resources - Resource usage across nodes
# -----------------------------------------------------------------------------

fleet-resources() {
    echo "📊 Fleet Resources"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Local resources
    echo "📍 $(hostname) (local)"
    if [[ "$(uname)" == "Darwin" ]]; then
        local free_gb=$(vm_stat 2>/dev/null | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.1f", ($1*$ps)/1024/1024/1024')
        local total_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1024/1024/1024}')
        local load=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}')
        echo "  RAM: ${free_gb}GB free / ${total_gb}GB total"
        echo "  Load: ${load}"
    else
        free -h 2>/dev/null | head -2
        uptime 2>/dev/null
    fi
    echo ""

    # Node definitions (static - update as fleet changes)
    echo "📋 Fleet Node Reference"
    echo "  ┌─────────┬──────────┬─────────────────────────────────────┐"
    echo "  │ Node    │ RAM      │ Role                                │"
    echo "  ├─────────┼──────────┼─────────────────────────────────────┤"
    echo "  │ prya    │ 16GB     │ Hub/Command Center, Lead Orchestr.  │"
    echo "  │ sati    │ 64GB     │ Workhorse - heavy tasks, migrations │"
    echo "  │ nova    │ 48GB     │ iOS/Power - Swift, Xcode, simulator │"
    echo "  │ trinity │ 16GB     │ Auxiliary - docs, review, light ed. │"
    echo "  │ gaea    │ 16GB     │ Education/Mobile - off-hours only   │"
    echo "  └─────────┴──────────┴─────────────────────────────────────┘"
    echo ""
}

# -----------------------------------------------------------------------------
# Fleet Agents - Agent status across fleet
# -----------------------------------------------------------------------------

fleet-agents() {
    echo "🤖 Fleet Agent Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if command -v forge >/dev/null 2>&1; then
        forge agent list 2>/dev/null
    else
        echo "  Forge CLI not available"
    fi
    echo ""
}

# -----------------------------------------------------------------------------
# Quick Fleet Commands
# -----------------------------------------------------------------------------

# Alias for fleet-status
alias fs='fleet-status'

# Quick task check
alias fq='forge task list 2>/dev/null'

# Quick task list
alias ftl='forge task list 2>/dev/null'

# Quick dispatch
alias fd='forge dispatch'

# -----------------------------------------------------------------------------
# Node Quick Switch - Send command to another node
# -----------------------------------------------------------------------------

# Send an orchestrator message to another node.
node-exec() {
    local node="$1"
    local cmd="$2"

    if [[ -z "$node" ]] || [[ -z "$cmd" ]]; then
        echo "Usage: node-exec <node> <command>"
        echo "Example: node-exec trinity 'node-health'"
        return 1
    fi

    echo "📤 Sending to $node: $cmd"
    forge message send "$node" "$cmd"
}

# -----------------------------------------------------------------------------
# Export Functions
# -----------------------------------------------------------------------------

export -f fleet-status fleet-health fleet-resources fleet-agents node-exec
