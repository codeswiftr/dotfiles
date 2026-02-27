# =============================================================================
# Trinity Node Configuration
# macOS Ventura 13.x, 16GB RAM, 4-core i7-7920HQ
# Role: Auxiliary overflow node for lightweight tasks
# =============================================================================

# -----------------------------------------------------------------------------
# Node Identification
# -----------------------------------------------------------------------------
# These are set based on the host to help agents understand their environment
export FORGE_NODE="${FORGE_NODE:-trinity}"
export FORGE_NODE_ROLE="auxiliary"
export FORGE_NODE_MAX_AGENTS=2
export FORGE_NODE_OSRULE="Ventura 13.x"

# -----------------------------------------------------------------------------
# Trinity-Specific Aliases
# -----------------------------------------------------------------------------

alias node-info='trinity-info'
alias node-health='trinity-health'
alias node-ram='trinity-ram'
alias node-cpu='trinity-cpu'

# -----------------------------------------------------------------------------
# Trinity System Information
# -----------------------------------------------------------------------------

trinity-info() {
    echo "🖥️  Trinity Node"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Role: Auxiliary overflow node"
    echo "Purpose: Lightweight tasks, overflow from prya/sati"
    echo "Constraints:"
    echo "  • NO iOS support (Ventura too old for recent Xcode)"
    echo "  • Max 1-2 agents (16GB RAM limit)"
    echo "  • Best for: docs, code review, light edits"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Hardware:"
    local cpu=$(sysctl -n machdep.cpu.brand_string)
    local cores=$(sysctl -n hw.physicalcpu)
    local threads=$(sysctl -n hw.ncpu)
    local ram=$(sysctl -n hw.memsize | awk '{printf "%.1f GB", $1/1024/1024/1024}')
    echo "  CPU: $cpu"
    echo "  Cores: $cores physical, $threads logical"
    echo "  RAM: $ram"
    echo "  OS: macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
    echo "  Arch: $(uname -m)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Status:"
    echo "  Uptime: $(uptime | awk '{print $3,$4,$5}' | sed 's/,//g' | sed 's/load average://')"
    echo "  Disk: $(df -h / | awk 'NR==2{print $3 " used, " $4 " free (" $5 ")"}')"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Fleet Position:"
    echo "  prya   - Hub/Command Center (16GB RAM)"
    echo "  sati   - Workhorse (64GB RAM)"
    echo "  nova   - Power/iOS (48GB RAM)"
    echo "  trinity- Auxiliary (16GB RAM) ← YOU ARE HERE"
    echo ""
    echo "For iOS work: Dispatch to nova"
    echo "For heavy work: Dispatch to sati"
}

# -----------------------------------------------------------------------------
# Trinity Health Check
# -----------------------------------------------------------------------------

trinity-health() {
    local root="${FORGE_ROOT:-$HOME/work/FORGE}"
    local issues=0

    echo "🩺 Trinity Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Critical tools
    echo "Critical Tools:"
    command -v qmd >/dev/null 2>&1 && echo "  ✅ QMD ($(qmd --version 2>/dev/null || echo 'installed'))" || (echo "  ❌ QMD missing" && ((issues++)))
    command -v uv >/dev/null 2>&1 && echo "  ✅ uv ($(uv --version 2>/dev/null || echo 'installed'))" || (echo "  ❌ uv missing" && ((issues++)))
    # Check python3 or python (macOS uses python3)
    if command -v python3 >/dev/null 2>&1; then
        echo "  ✅ Python ($(python3 --version 2>/dev/null || echo 'installed'))"
    elif command -v python >/dev/null 2>&1; then
        echo "  ✅ Python ($(python --version 2>/dev/null || echo 'installed'))"
    elif command -v uv >/dev/null 2>&1; then
        # uv can run python even if not in PATH
        echo "  ✅ Python (via uv)"
    else
        echo "  ❌ Python missing"
        ((issues++))
    fi
    command -v forge >/dev/null 2>&1 && echo "  ✅ Forge CLI" || echo "  ⚠️  Forge CLI not found (optional)"
    echo ""

    # Resources
    echo "Resources:"
    local free_gb=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.1f", ($1*$ps)/1024/1024/1024')
    local free_mb=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.0f", ($1*$ps)/1024/1024')
    echo "  Free RAM: ${free_gb} GB"

    # Trinity is auxiliary node - 2GB minimum is acceptable for lightweight work
    if (( $(echo "$free_gb < 2" | bc -l 2>/dev/null || echo "$free_gb < 2") )); then
        echo "  ⚠️  Low memory - consider waiting or dispatching elsewhere"
        ((issues++))
    elif (( $(echo "$free_gb < 3" | bc -l 2>/dev/null || echo "$free_gb < 3") )); then
        echo "  ⚡ Memory getting low - lightweight tasks only"
    else
        echo "  ✅ Memory OK"
    fi
    echo ""

    # FORGE connectivity
    echo "FORGE Connectivity:"
    if [[ -d "$root" ]]; then
        echo "  ✅ FORGE_ROOT accessible: $root"
    else
        echo "  ❌ FORGE_ROOT not found"
        ((issues++))
    fi

    if [[ -n "$FORGE_WEBHOOK_TOKEN" ]]; then
        echo "  ✅ Webhook token set"
    else
        echo "  ⚠️  Webhook token not set (Command Center access limited)"
    fi
    echo ""

    # Node capabilities
    echo "Capabilities:"
    echo "  ✅ Python/Backend development"
    echo "  ✅ Documentation and research"
    echo "  ✅ Code review and analysis"
    echo "  ✅ Lightweight edits"
    echo "  ❌ iOS development (use nova)"
    echo "  ⚠️  Heavy computation (consider sati)"
    echo ""

    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ $issues -eq 0 ]]; then
        echo "✅ All systems healthy"
        return 0
    else
        echo "⚠️  $issues issue(s) found"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Resource Checkers
# -----------------------------------------------------------------------------

trinity-ram() {
    local pagesize=$(vm_stat | head -1 | sed 's/.*page size of \([0-9]*\).*/\1/')
    echo "📊 Trinity Memory Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    vm_stat | perl -ne "
BEGIN {
    \$pagesize = $pagesize;
    \$page_to_gb = \$pagesize / (1024 * 1024 * 1024);
}
/Pages free:\s+(\d+)/ and \$free = \$1;
/Pages active:\s+(\d+)/ and \$active = \$1;
/Pages inactive:\s+(\d+)/ and \$inactive = \$1;
/Pages speculative:\s+(\d+)/ and \$speculative = \$1;
/Pages wired:\s+(\d+)/ and \$wired = \$1;
END {
    \$available = (\$free + \$inactive + \$speculative) * \$page_to_gb;
    \$used = (\$active + \$wired) * \$page_to_gb;
    printf \"  Free:      %.2f GB\n\", \$free * \$page_to_gb;
    printf \"  Available: %.2f GB\n\", \$available;
    printf \"  Active:    %.2f GB\n\", \$active * \$page_to_gb;
    printf \"  Wired:     %.2f GB\n\", \$wired * \$page_to_gb;
    printf \"  Used:      %.2f GB\n\", \$used;
    printf \"\n\";
    if (\$available < 2) {
        print \"  ⚠️  Low available memory\n\";
    } elsif (\$available < 3) {
        print \"  ⚡  Memory getting low - lightweight tasks only\n\";
    } else {
        print \"  ✅ Memory OK\n\";
    }
}
"
}

trinity-cpu() {
    echo "⚡ Trinity CPU Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Model: $(sysctl -n machdep.cpu.brand_string)"
    echo "  Cores: $(sysctl -n hw.physicalcpu) physical, $(sysctl -n hw.ncpu) logical"
    echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    # Top CPU consumers
    echo "  Top CPU consumers:"
    ps -Ao pid,pcpu,comm | sort -k2 -rn | head -5 | awk '{printf "    %s %s %s\n", $1, $2, $3}'
}

# -----------------------------------------------------------------------------
# Node-Specific Agent Recommendations
# -----------------------------------------------------------------------------

trinity-suggest-agent() {
    local task_type="$1"

    case "$task_type" in
        "docs"|"documentation"|"research")
            echo "minimax - Fast for documentation tasks"
            ;;
        "review"|"code-review"|"audit")
            echo "minimax - Fast for code review"
            ;;
        "backend"|"api"|"python"|"infrastructure")
            echo "glm - Good for Python/backend work"
            ;;
        "heavy"|"implementation"|"large-features")
            echo "❌ Recommend dispatching to sati (more RAM available)"
            return 1
            ;;
        "ios"|"swift"|"simulator"|"xcode")
            echo "❌ iOS work not supported on Trinity"
            echo "   Dispatch to nova for iOS development"
            return 1
            ;;
        *)
            echo "minimax - Default for lightweight tasks"
            ;;
    esac
}

# Export functions
export -f trinity-info trinity-health trinity-ram trinity-cpu trinity-suggest-agent
