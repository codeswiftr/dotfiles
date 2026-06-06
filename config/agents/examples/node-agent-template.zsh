# =============================================================================
# Trinity Node Agent Helpers
# Optimized for auxiliary/overflow work on macOS Ventura 13.x
# =============================================================================

# -----------------------------------------------------------------------------
# Resource-Aware Agent Operations
# -----------------------------------------------------------------------------

# Check if we have enough resources for another agent
trinity-can-spawn() {
    local required_mb="${1:-2000}"  # Default 2GB requirement (Trinity is auxiliary node)
    local free_mb=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.0f", ($1*$ps)/1024/1024')

    if [[ $free_mb -lt $required_mb ]]; then
        echo "❌ Insufficient memory: ${free_mb}MB free, ${required_mb}MB required"
        return 1
    fi

    echo "✅ Memory OK: ${free_mb}MB free"
    return 0
}

# Resource-aware agent spawn with recommendations
trinity-spawn() {
    local agent="${1:-minimax}"
    local task="$2"

    # First check if we should be doing this work
    if ! trinity-should-handle "$task"; then
        return 1
    fi

    # Check memory
    if ! trinity-can-spawn; then
        echo "💡 Suggestion: queue for sati (more RAM available)"
        echo "   Command: forge task create --node sati --title \"$task\" --description \"$task\""
        return 1
    fi

    echo "🚀 Spawning $agent on trinity"
    # Actual spawn logic would go here
    # This is a template for the expected interface
}

# Decide if Trinity should handle this task
trinity-should-handle() {
    local task="$1"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Tasks Trinity should NOT handle
    local exclude_patterns=(
        "ios" "swift" "xcode" "simulator" "app store"
        "heavy" "large.*implement" "comprehensive.*test"
        "full.*stack" "database.*migration"
    )

    for pattern in "${exclude_patterns[@]}"; do
        if [[ "$task_lower" =~ $pattern ]]; then
            echo "⚠️  Task not suitable for trinity: $task"
            echo "   Reason: Matches exclusion pattern '$pattern'"
            return 1
        fi
    done

    return 0
}

# -----------------------------------------------------------------------------
# Quick Agent Selection Helper
# -----------------------------------------------------------------------------

# Suggest the best agent for a task on Trinity
trinity-best-agent() {
    local task="$1"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Lightweight/quick tasks - use fastest agent
    if [[ "$task_lower" =~ (doc|review|analysis|research|quick|small|fix) ]]; then
        echo "minimax"
        return 0
    fi

    # Backend/Python tasks - use GLM
    if [[ "$task_lower" =~ (backend|api|python|infra|server|endpoint) ]]; then
        echo "glm"
        return 0
    fi

    # Default to minimax
    echo "minimax"
    return 0
}

# -----------------------------------------------------------------------------
# Agent Workflow Shortcuts
# -----------------------------------------------------------------------------

# Quick code review on Trinity
t-review() {
    local files="${@:-.}"
    echo "🔍 Quick code review on trinity"

    # Use minimax for fast review
    if command -v minimax >/dev/null 2>&1; then
        minimax --review "$files"
    else
        echo "❌ minimax agent not found"
        return 1
    fi
}

# Quick documentation task
t-docs() {
    local topic="$1"
    echo "📚 Documentation task on trinity: $topic"

    if command -v minimax >/dev/null 2>&1; then
        minimax "Document: $topic"
    else
        echo "❌ minimax agent not found"
        return 1
    fi
}

# Quick analysis task
t-analyze() {
    local target="$1"
    echo "🔬 Analyzing on trinity: $target"

    if command -v minimax >/dev/null 2>&1; then
        minimax "Analyze: $target"
    else
        echo "❌ minimax agent not found"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Task Dispatch (send to other nodes if needed)
# -----------------------------------------------------------------------------

# Smart dispatch - handle locally or forward to appropriate node
t-dispatch() {
    local task="$1"
    local target_node="${2:-auto}"

    if [[ "$target_node" == "auto" ]]; then
        # Auto-select based on task type
        if [[ "$task" =~ (ios|swift|xcode) ]]; then
            target_node="nova"
        elif [[ "$task" =~ (heavy|large|test.*suite|migration) ]]; then
            target_node="sati"
        else
            # Handle on trinity
            local agent=$(trinity-best-agent "$task")
            echo "🎯 Handling on trinity with $agent: $task"
            return 0
        fi
    fi

    echo "📤 Queueing for $target_node: $task"
    if command -v forge >/dev/null 2>&1; then
        forge task create --node "$target_node" --title "$task" --description "$task"
    else
        echo "❌ forge CLI not available"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Trinity Agent Status
# -----------------------------------------------------------------------------

# Show active agents on Trinity
t-status() {
    echo "🤖 Trinity Agent Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check for running agent sessions
    if tmux has-session 2>/dev/null; then
        echo "Tmux sessions:"
        tmux list-sessions 2>/dev/null | grep -i "agent\|claude\|minimax\|glm" || echo "  (no agent sessions found)"
    else
        echo "  Tmux not running"
    fi

    echo ""
    echo "Available agents:"
    command -v minimax >/dev/null 2>&1 && echo "  ✅ minimax" || echo "  ❌ minimax"
    command -v glm >/dev/null 2>&1 && echo "  ✅ glm" || echo "  ❌ glm"
    command -v claude >/dev/null 2>&1 && echo "  ✅ claude" || echo "  ❌ claude"
    echo ""

    echo "Recommended for trinity:"
    echo "  • minimax - Quick edits, docs, review"
    echo "  • glm - Backend, infrastructure"
    echo ""
    echo "NOT recommended for trinity:"
    echo "  • iOS work → use nova"
    echo "  • Heavy tasks → use sati"
}

# -----------------------------------------------------------------------------
# Export Functions
# -----------------------------------------------------------------------------

export -f trinity-can-spawn trinity-spawn trinity-should-handle
export -f trinity-best-agent t-review t-docs t-analyze
export -f t-dispatch t-status
