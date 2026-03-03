#!/bin/bash

# Claude Code Status Line - Starship-inspired with Test Results
# Based on user's Starship configuration with Catppuccin Mocha theme

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON input
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# === THE KEY TRICK: export context % to sidecar file for FSM hooks ===
FORGE_DIR="${FORGE_ROOT:-$HOME/work/FORGE}"
if [[ "$current_dir" == "$FORGE_DIR"* ]] && [[ "$ctx_pct" =~ ^[0-9]+$ ]]; then
    echo "$ctx_pct" > "$FORGE_DIR/.forge/heartbeat/context_percent" 2>/dev/null
fi

# Get basic system info
username=$(whoami)
hostname=$(hostname -s)

# Test results cache file
TEST_CACHE="$HOME/.claude/test_results_cache.txt"

# Process directory path - show last 3 components like Starship truncation_length = 3
dir_display() {
    local dir="$1"
    # Replace home directory with ~
    dir="${dir/#$HOME/~}"
    
    # Split path and show last 3 components
    IFS='/' read -ra parts <<< "$dir"
    local num_parts=${#parts[@]}
    
    if [[ $num_parts -le 3 ]]; then
        echo "$dir"
    else
        local start=$((num_parts - 3))
        local result=""
        for ((i=start; i<num_parts; i++)); do
            if [[ $i -eq $start ]]; then
                result="${parts[i]}"
            else
                result="${result}/${parts[i]}"
            fi
        done
        echo ".../$result"
    fi
}

# Get git information if in a git repository
git_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null || echo "detached")
        local status=""
        
        # Check for git status indicators
        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            status=" [modified]"
        fi
        
        printf " 󰊢 %s%s" "$branch" "$status"
    fi
}

# Detect language/environment context
lang_context() {
    local context=""

    # Check for Python
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        context="${context} 󰌠 py"
    fi

    # Check for Node.js
    if [[ -f "package.json" ]]; then
        context="${context} 󰎙 node"
    fi

    # Check for Rust
    if [[ -f "Cargo.toml" ]]; then
        context="${context} 󱘗 rust"
    fi

    # Check for Go
    if [[ -f "go.mod" ]]; then
        context="${context} 󰟓 go"
    fi

    # Check for Docker
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
        context="${context} 󰡨 docker"
    fi

    echo "$context"
}

# Get test results from cache
test_results() {
    # Check if cache file exists and is recent (less than 1 hour old)
    if [[ -f "$TEST_CACHE" ]]; then
        local cache_age=$(($(date +%s) - $(stat -f %m "$TEST_CACHE" 2>/dev/null || echo 0)))

        # If cache is less than 1 hour old, use it
        if [[ $cache_age -lt 3600 ]]; then
            local passed=$(grep "^PASSED=" "$TEST_CACHE" 2>/dev/null | cut -d= -f2)
            local failed=$(grep "^FAILED=" "$TEST_CACHE" 2>/dev/null | cut -d= -f2)
            local errors=$(grep "^ERRORS=" "$TEST_CACHE" 2>/dev/null | cut -d= -f2)
            local total=$(grep "^TOTAL=" "$TEST_CACHE" 2>/dev/null | cut -d= -f2)

            # Only display if we have valid data
            if [[ -n "$passed" ]] && [[ -n "$total" ]] && [[ "$total" -gt 0 ]]; then
                local pass_rate=$(awk "BEGIN {printf \"%.0f\", ($passed/$total)*100}")

                # Build test result string with color indicators
                local test_str=" 󰙨 "

                # Show pass/total
                test_str="${test_str}${passed}/${total}"

                # Add failures if any
                if [[ "$failed" -gt 0 ]]; then
                    test_str="${test_str} ✗${failed}"
                fi

                # Add errors if any
                if [[ "$errors" -gt 0 ]]; then
                    test_str="${test_str} !${errors}"
                fi

                # Add pass rate
                test_str="${test_str} (${pass_rate}%)"

                echo "$test_str"
            fi
        fi
    fi
}

# Build the status line
dir_short=$(dir_display "$current_dir")
git_branch=$(git_info)
lang_ctx=$(lang_context)
test_info=$(test_results)

# Format similar to Starship with dimmed colors (since status line is dimmed)
printf "%s@%s %s%s%s%s ctx:%s%% ❯ %s" \
    "$username" \
    "$hostname" \
    "$dir_short" \
    "$git_branch" \
    "$lang_ctx" \
    "$test_info" \
    "$ctx_pct" \
    "$model_name"