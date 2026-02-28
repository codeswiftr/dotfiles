# =============================================================================
# Gaea Node Configuration
# macOS M1 Pro, 16GB RAM
# Role: Education apps, lightweight tasks, mobile testing (off-hours only)
# =============================================================================

# -----------------------------------------------------------------------------
# Node Identification
# -----------------------------------------------------------------------------
export FORGE_NODE="${FORGE_NODE:-gaea}"
export FORGE_NODE_ROLE="education-mobile"
export FORGE_NODE_MAX_AGENTS=3
export FORGE_NODE_OSRULE="macOS M1"

# -----------------------------------------------------------------------------
# Gaea-Specific Aliases
# -----------------------------------------------------------------------------

alias node-info='gaea-info'
alias node-health='gaea-health'
alias node-ram='gaea-ram'
alias node-cpu='gaea-cpu'

# -----------------------------------------------------------------------------
# Gaea System Information
# -----------------------------------------------------------------------------

gaea-info() {
    echo "🖥️  Gaea Node"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Role: Education/Mobile (off-hours auxiliary)"
    echo "Purpose: Lightweight tasks, mobile testing, education apps"
    echo "Constraints:"
    echo "  • OFF-HOURS ONLY (laptop, available when user active)"
    echo "  • Submodule work only (no main repo changes)"
    echo "  • Max 2-3 agents (16GB RAM)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Assigned Domains:"
    echo "  • thebrightharbor-com/ (study-flow, kiddo-rewards, etc.)"
    echo "  • mumchef-io/ (allergen-guardian, meal-planner, etc.)"
    echo "  • babybit-es/ (allergen-coach-mvp, mealsync, etc.)"
    echo "  • bogdanveliscu-com/ (septica)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Hardware:"
    local cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple M1 Pro")
    local ram=$(sysctl -n hw.memsize | awk '{printf "%.0f GB", $1/1024/1024/1024}')
    echo "  CPU: $cpu"
    echo "  RAM: $ram"
    echo "  OS: macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
    echo "  Arch: $(uname -m)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Fleet Position:"
    echo "  prya   - Hub/Command Center (16GB RAM)"
    echo "  sati   - Workhorse (64GB RAM)"
    echo "  nova   - Power/iOS (48GB RAM)"
    echo "  trinity- Auxiliary (16GB RAM)"
    echo "  gaea   - Education/Mobile (16GB RAM) ← YOU ARE HERE"
    echo ""
    echo "Best for: Education apps, family apps, mobile testing"
    echo "Avoid: Heavy computation (use sati), main repo changes"
}

# -----------------------------------------------------------------------------
# Gaea Health Check
# -----------------------------------------------------------------------------

gaea-health() {
    local root="${FORGE_ROOT:-$HOME/work/FORGE}"
    local issues=0

    echo "🩺 Gaea Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Critical tools
    echo "Critical Tools:"
    command -v qmd >/dev/null 2>&1 && echo "  ✅ QMD" || (echo "  ❌ QMD missing" && ((issues++)))
    command -v uv >/dev/null 2>&1 && echo "  ✅ uv" || (echo "  ❌ uv missing" && ((issues++)))
    command -v python3 >/dev/null 2>&1 && echo "  ✅ Python3" || (echo "  ❌ Python3 missing" && ((issues++)))
    command -v forge >/dev/null 2>&1 && echo "  ✅ Forge CLI" || echo "  ⚠️  Forge CLI (optional)"
    echo ""

    # Resources
    echo "Resources:"
    local free_gb=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.1f", ($1*$ps)/1024/1024/1024')
    echo "  Free RAM: ${free_gb} GB"

    if (( $(echo "$free_gb < 2" | bc -l 2>/dev/null || [[ $(echo "$free_gb < 2") == true ]) )); then
        echo "  ⚠️  Low memory - consider dispatching elsewhere"
        ((issues++))
    else
        echo "  ✅ Memory OK"
    fi
    echo ""

    # FORGE connectivity
    echo "FORGE Connectivity:"
    if [[ -d "$root" ]]; then
        echo "  ✅ FORGE_ROOT accessible"
    else
        echo "  ❌ FORGE_ROOT not found"
        ((issues++))
    fi
    echo ""

    # Capabilities
    echo "Capabilities:"
    echo "  ✅ M1 native performance"
    echo "  ✅ iOS Simulator"
    echo "  ✅ Mobile testing"
    echo "  ✅ Education/family apps"
    echo "  ⚠️  Off-hours only"
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

gaea-ram() {
    local pagesize=$(vm_stat | head -1 | sed 's/.*page size of \([0-9]*\).*/\1/')
    echo "📊 Gaea Memory Status"
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
    printf \"\n\";
    if (\$available < 2) {
        print \"  ⚠️  Low available memory\n\";
    } else {
        print \"  ✅ Memory OK\n\";
    }
}
"
}

gaea-cpu() {
    echo "⚡ Gaea CPU Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Model: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'Apple M1 Pro')"
    echo "  Cores: $(sysctl -n hw.physicalcpu) physical, $(sysctl -n hw.ncpu) logical"
    echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    echo "  Top CPU consumers:"
    ps -Ao pid,pcpu,comm | sort -k2 -rn | head -5 | awk '{printf "    %s %s %s\n", $1, $2, $3}'
}

# -----------------------------------------------------------------------------
# Domain Navigation Shortcuts
# -----------------------------------------------------------------------------

# Quick navigation to assigned domains
alias cd-bright='cd "${FORGE_ROOT:-$HOME/work/FORGE}/thebrightharbor-com"'
alias cd-mum='cd "${FORGE_ROOT:-$HOME/work/FORGE}/mumchef-io"'
alias cd-baby='cd "${FORGE_ROOT:-$HOME/work/FORGE}/babybit-es"'
alias cd-bog='cd "${FORGE_ROOT:-$HOME/work/FORGE}/bogdanveliscu-com"'

# Export functions
export -f gaea-info gaea-health gaea-ram gaea-cpu
