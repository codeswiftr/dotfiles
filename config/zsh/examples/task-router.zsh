# =============================================================================
# Smart Task Router - Multi-Node Task Dispatch Template
# Automatically routes tasks to the optimal node based on type and capabilities.
#
# SETUP: Customize TASK_ROUTING_RULES, NODE_CAPABILITIES, and NODE_CONSTRAINTS
# below to match your fleet. Then copy to config/zsh/fleet-task-router.zsh
# and source it from your node config or ~/.zshrc.
# =============================================================================

# Skip in SSH sessions — task routing requires fleet connectivity
[[ -n "$DOTFILES_SSH" ]] && return 0

# -----------------------------------------------------------------------------
# Task Classification Rules — customize for your fleet
# Each entry: ["node-name"]="regex|patterns|to|match"
# -----------------------------------------------------------------------------

declare -A TASK_ROUTING_RULES=(
    # Example: route iOS tasks to your macOS node
    ["macos-node"]="ios|swift|xcode|simulator|testflight|swiftui"
    # Example: route heavy tasks to your high-RAM node
    ["powerhouse"]="migration|heavy|large|benchmark|train|ml|model|test.?suite"
    # Example: route documentation tasks to any node
    ["any"]="doc|review|readme|changelog|analysis|research|quick|fix|audit"
)

# Node capabilities (for fleet-status display)
declare -A NODE_CAPABILITIES=(
    ["hub"]="orchestration dispatch coordination"
    ["powerhouse"]="heavy migration testing ml"
    ["macos-node"]="ios swift xcode simulator"
    ["aux"]="docs review analysis light-tasks"
)

# Node constraints (for routing decisions)
declare -A NODE_CONSTRAINTS=(
    ["hub"]="limited_ram"
    ["powerhouse"]=""
    ["macos-node"]="ios_specialized"
    ["aux"]="no_ios max_2_agents"
)

# -----------------------------------------------------------------------------
# Main Router
# -----------------------------------------------------------------------------

task-route() {
    local task="$1"
    local force_node="${2:-}"

    if [[ -z "$task" ]]; then
        echo "Usage: task-route <task_description> [force_node]"
        echo ""
        echo "Examples:"
        echo "  task-route 'Implement iOS login flow'"
        echo "  task-route 'Migrate database schema'"
        echo "  task-route 'Review PR documentation'"
        return 1
    fi

    if [[ -n "$force_node" ]]; then
        echo "Forced dispatch to: $force_node"
        task-dispatch "$force_node" "$task"
        return $?
    fi

    local task_lower; task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    local recommended_node=""
    local match_reason=""

    for node patterns in ${(kv)TASK_ROUTING_RULES[@]}; do
        if [[ "$task_lower" =~ $patterns ]]; then
            recommended_node="$node"
            match_reason="Matched: $patterns"
            break
        fi
    done

    if [[ -z "$recommended_node" ]]; then
        recommended_node="$(hostname -s)"
        match_reason="No pattern match — defaulting to local"
    fi

    echo "Task: $task"
    echo "Recommended: $recommended_node"
    echo "Reason: $match_reason"
    echo ""

    if [[ "$recommended_node" != "$(hostname -s)" ]]; then
        echo "To dispatch: task-dispatch $recommended_node \"$task\""
    else
        echo "Handle locally on $(hostname -s)"
    fi
}

# Classify and return just the node name (useful for scripting)
task-route-suggest() {
    local task_lower; task_lower=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')
    for node patterns in ${(kv)TASK_ROUTING_RULES[@]}; do
        [[ "$task_lower" =~ $patterns ]] && echo "$node" && return 0
    done
    hostname -s
}

# -----------------------------------------------------------------------------
# Dispatch — create a queue task with an advisory target node.
# For named-agent overrides, write a brief and run:
#   forge dispatch send <agent> --file .forge/dispatches/<brief>.md
# -----------------------------------------------------------------------------

task-dispatch() {
    local node="$1"
    local task="$2"

    [[ -z "$node" || -z "$task" ]] && { echo "Usage: task-dispatch <node> <task>"; return 1; }

    echo "Creating queued task for $node: $task"

    if command -v forge >/dev/null 2>&1; then
        forge task create --node "$node" --title "$task" --description "$task"
    else
        echo "forge CLI not available"
        return 1
    fi
}

# Quick routing aliases — customize node names
alias tr='task-route'
alias trc='task-route-confirm'
alias td='task-dispatch'

task-route-confirm() {
    local task="$1"
    local node="${2:-$(task-route-suggest "$1")}"
    [[ -z "$task" ]] && { echo "Usage: task-route-confirm <task> [node]"; return 1; }
    echo "Dispatching to $node: $task"
    task-dispatch "$node" "$task"
}

# Show routing rules summary
task-rules() {
    echo "Task Routing Rules"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for node patterns in ${(kv)TASK_ROUTING_RULES[@]}; do
        echo "  $node → $patterns"
    done
    echo ""
    echo "Usage:"
    echo "  task-route 'Your task'           # Get recommendation"
    echo "  task-dispatch <node> 'Task'      # Direct dispatch"
}

export -f task-route task-route-suggest task-dispatch task-route-confirm task-rules
