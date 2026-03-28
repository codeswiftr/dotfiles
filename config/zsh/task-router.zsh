# =============================================================================
# Smart Task Router - Intelligent Multi-Node Task Dispatch
# Automatically routes tasks to the optimal node based on type, resources,
# and current fleet state
# =============================================================================

# -----------------------------------------------------------------------------
# Task Classification Rules
# -----------------------------------------------------------------------------

# Define task routing rules (node => patterns)
declare -A TASK_ROUTING_RULES=(
    # iOS tasks always go to nova
    ["nova"]="ios|swift|xcode|simulator|app.?store|testflight|swiftui|uikit"
    # Heavy tasks go to sati (64GB RAM)
    ["sati"]="migration|heavy|large|comprehensive|full.?stack|database.?mig|test.?suite|benchmark|train|ml|model"
    # Documentation and review tasks go to trinity
    ["trinity"]="doc|review|readme|changelog|analysis|research|investigate|light|quick|small|fix|audit"
    # Education and family apps go to gaea (off-hours)
    ["gaea"]="education|family|kids|baby|mumchef|bright.*harbor|allergen|meal"
)

# Node capabilities
declare -A NODE_CAPABILITIES=(
    ["prya"]="hub orchestration dispatch coordination"
    ["sati"]="heavy migration testing fullstack ml"
    ["nova"]="ios swift xcode simulator apple"
    ["trinity"]="docs review analysis research light"
    ["gaea"]="education family mobile testing"
)

# Node constraints
declare -A NODE_CONSTRAINTS=(
    ["prya"]="limited_ram"
    ["sati"]=""
    ["nova"]="ios_only_heavy"
    ["trinity"]="no_ios limited_ram max_2_agents"
    ["gaea"]="off_hours_only submodule_only"
)

# -----------------------------------------------------------------------------
# Main Router - Classify and dispatch task
# -----------------------------------------------------------------------------

task-route() {
    local task="$1"
    local force_node="${2:-}"

    if [[ -z "$task" ]]; then
        echo "Usage: task-route <task_description> [force_node]"
        echo ""
        echo "Examples:"
        echo "  task-route 'Implement iOS login flow'       # → nova"
        echo "  task-route 'Migrate database to new schema' # → sati"
        echo "  task-route 'Review PR documentation'        # → trinity"
        echo "  task-route 'Fix allergen detection'         # → gaea"
        return 1
    fi

    # If force node specified, use it
    if [[ -n "$force_node" ]]; then
        echo "🎯 Forced dispatch to: $force_node"
        task-dispatch "$force_node" "$task"
        return $?
    fi

    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    local recommended_node=""
    local match_reason=""

    # Classification logic
    for node patterns in ${(kv)TASK_ROUTING_RULES[@]}; do
        if [[ "$task_lower" =~ $patterns ]]; then
            recommended_node="$node"
            match_reason="Pattern match: $patterns"
            break
        fi
    done

    # Default fallback based on current node
    if [[ -z "$recommended_node" ]]; then
        recommended_node="auto"
        match_reason="No specific pattern - auto-select"
    fi

    # Display recommendation
    echo "📋 Task: $task"
    echo "🎯 Recommended Node: $recommended_node"
    echo "   Reason: $match_reason"
    echo ""

    # Check if we should proceed
    if [[ "$recommended_node" != "auto" ]] && [[ "$recommended_node" != "$(hostname)" ]]; then
        echo "📤 Ready to dispatch to $recommended_node"
        echo "   Run: task-dispatch $recommended_node \"$task\""
        echo "   Or confirm with: task-route-confirm \"$task\" $recommended_node"
    else
        echo "✅ Task can be handled locally on $(hostname)"
        echo "   Run: task-local \"$task\""
    fi
}

# -----------------------------------------------------------------------------
# Confirm and Dispatch
# -----------------------------------------------------------------------------

task-route-confirm() {
    local task="$1"
    local node="${2:-auto}"

    if [[ -z "$task" ]]; then
        echo "Usage: task-route-confirm <task> [node]"
        return 1
    fi

    # If no node specified, route first
    if [[ "$node" == "auto" ]]; then
        node=$(task-route-suggest "$task")
    fi

    echo "🚀 Dispatching to $node: $task"
    task-dispatch "$node" "$task"
}

# -----------------------------------------------------------------------------
# Get suggested node (for scripting)
# -----------------------------------------------------------------------------

task-route-suggest() {
    local task="$1"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    for node patterns in ${(kv)TASK_ROUTING_RULES[@]}; do
        if [[ "$task_lower" =~ $patterns ]]; then
            echo "$node"
            return 0
        fi
    done

    # Default to current node
    echo "$(hostname)"
}

# -----------------------------------------------------------------------------
# Task Dispatch - Send to specific node
# -----------------------------------------------------------------------------

task-dispatch() {
    local node="$1"
    local task="$2"

    if [[ -z "$node" ]] || [[ -z "$task" ]]; then
        echo "Usage: task-dispatch <node> <task>"
        return 1
    fi

    echo "📤 Dispatching task to $node"
    echo "   Task: $task"
    echo ""

    # Use forge dispatch if available
    if command -v forge >/dev/null 2>&1; then
        forge dispatch send "$node" "$task" 2>/dev/null
        local status=$?
        if [[ $status -eq 0 ]]; then
            echo "✅ Task dispatched successfully"
        else
            echo "⚠️  Dispatch returned status: $status"
        fi
        return $status
    else
        echo "⚠️  Forge CLI not available"
        echo "   Alternative: Use tmux to send to node session"
        echo "   tmux send-keys -t $node \"$task\" Enter"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Local Task Execution
# -----------------------------------------------------------------------------

task-local() {
    local task="$1"

    if [[ -z "$task" ]]; then
        echo "Usage: task-local <task>"
        return 1
    fi

    echo "🔧 Executing task locally on $(hostname)"
    echo "   Task: $task"
    echo ""

    # Use forge task create if available
    if command -v forge >/dev/null 2>&1; then
        forge task create --title "$task" 2>/dev/null
        return $?
    else
        echo "⚠️  Forge CLI not available - manual execution required"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Quick Routing Aliases
# -----------------------------------------------------------------------------

# Route to specific nodes
alias route-nova='task-dispatch nova'
alias route-sati='task-dispatch sati'
alias route-trinity='task-dispatch trinity'
alias route-gaea='task-dispatch gaea'
alias route-prya='task-dispatch prya'

# Quick routing helpers
alias tr='task-route'
alias trc='task-route-confirm'
alias td='task-dispatch'

# -----------------------------------------------------------------------------
# Routing Rules Display
# -----------------------------------------------------------------------------

task-rules() {
    echo "📋 Task Routing Rules"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Node Assignments:"
    echo "  nova    → iOS, Swift, Xcode, Simulator, App Store"
    echo "  sati    → Migrations, Heavy tasks, Full-stack, ML, Test suites"
    echo "  trinity → Docs, Review, Analysis, Research, Quick fixes"
    echo "  gaea    → Education, Family apps, Mobile testing (off-hours)"
    echo "  prya    → Hub operations, Orchestration, Coordination"
    echo ""
    echo "Node Constraints:"
    echo "  trinity → No iOS, Max 2 agents, 16GB RAM"
    echo "  gaea    → Off-hours only, Submodule work only"
    echo "  prya    → Limited RAM (16GB) - hub operations"
    echo ""
    echo "Usage:"
    echo "  task-route 'Your task description'           # Get recommendation"
    echo "  task-route-confirm 'Task' nova               # Dispatch to node"
    echo "  route-sati 'Heavy migration task'            # Quick dispatch"
    echo ""
}

# -----------------------------------------------------------------------------
# Export Functions
# -----------------------------------------------------------------------------

export -f task-route task-route-confirm task-route-suggest
export -f task-dispatch task-local task-rules
