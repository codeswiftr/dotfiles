# Trinity Node Dotfiles Improvement Plan
## FORGE Fleet Optimization - macOS Ventura (13.x)

### Executive Summary

**Trinity Node Profile:**
- **Role:** Auxiliary compute node (overflow work, lightweight tasks)
- **OS:** macOS Ventura 13.x (older, Xcode limitations)
- **Hardware:** 16GB RAM, 4-core i7-7920HQ (8 threads)
- **Constraints:** NO iOS support (Ventura too old for recent Xcode/simulators)
- **Capacity:** 1-2 lightweight agents maximum

**Current State Assessment:**
- ✅ Excellent modular dotfiles architecture
- ✅ Performance-optimized shell startup (lazy loading)
- ✅ Comprehensive modern CLI tooling
- ❌ QMD not integrated (critical FORGE documentation tool)
- ❌ FORGE integration disabled (conflicts)
- ❌ No node-specific optimizations
- ❌ Forge CLI not tracked in Brewfile

---

## Critical Findings

### 1. FORGE Infrastructure Context

**Node Fleet Architecture:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    FORGE Multi-Node Fleet                      │
├────────────┬────────────┬────────────┬─────────────────────────┤
│   prya     │    sati    │    nova    │       trinity          │
├────────────┼────────────┼────────────┼─────────────────────────┤
│ 16GB RAM   │ 64GB RAM   │ 48GB RAM   │ 16GB RAM               │
│ Hub/CC     │ Workhorse  │ Power/iOS  │ Auxiliary               │
│ 2 agents   │ 5-6 agents │ 3-4 agents │ 1-2 agents            │
│ Claude/Kimi│ OpenCode   │ Worktree   │ Overflow/Lightweight    │
└────────────┴────────────┴────────────┴─────────────────────────┘
```

**Road to 10k MRR Path:**
- **Current:** 1 live product (Interview Simulator)
- **Target:** $10K MRR via CodeSwiftr → BrandFocus → NeoForge → LeanVibe
- **Blockers:** 3 human gates (Code Atlas, Voice Coach, IS Content)
- **Focus:** 60% CodeSwiftr → 25% infra → 15% governance

### 2. Tooling Inventory

| Tool | Status | For Trinity | Priority |
|------|--------|-------------|----------|
| **QMD** | ✅ Installed (v1.0.7) | ❌ Not in PATH | 🔴 CRITICAL |
| **Forge CLI** | ✅ Installed | ❌ Not in Brewfile | 🔴 HIGH |
| **uv** | ✅ In dotfiles | ✅ Works | 🟢 GOOD |
| **mise** | ✅ In dotfiles | ✅ Works | 🟢 GOOD |
| **Python 3.13** | ⚠️ Issues | ❌ Some packages incompatible | 🟡 MEDIUM |
| **XNode tools** | ❌ Missing | ❌ Not integrated | 🟡 MEDIUM |
| **Agent helpers** | ⚠️ Basic | ⚠️ Could improve | 🟢 NICE |

---

## Recommendations

### Phase 1: Critical Integrations (Immediate)

#### 1.1 QMD Integration

**Problem:** QMD is the primary documentation search tool for FORGE but not integrated.

**Solution:** Add QMD to dotfiles PATH and Brewfile.

```zsh
# config/zsh/forge-tools.zsh (NEW FILE)
# =============================================================================
# FORGE-specific Tools Integration
# =============================================================================

# QMD - FORGE documentation search (critical for architecture understanding)
if [[ -f "$HOME/.npm-global/bin/qmd" ]]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Forge CLI - FORGE fleet management
if [[ -f "$HOME/.local/bin/forge" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
```

```rb
# config/platform/Brewfile - ADDITIONS
brew "qmd"                # FORGE documentation search (npm: @forge/qmd)
```

**Why this matters:**
- QMD provides BM25 full-text search across all FORGE `.md` docs
- Critical for agents to understand architecture/workflows quickly
- Reduces research time from minutes to seconds

#### 1.2 Re-enable FORGE Integration (Fixed)

**Problem:** `forge.zsh` is disabled due to conflicts.

**Solution:** Create conflict-free version with prefixed aliases.

```zsh
# config/zsh/forge-tools.zsh (CONTINUED)

# FORGE project navigation (prefix with 'f' to avoid conflicts)
alias fforge='forge'
alias fdom='fdom'
alias fenv='forge-env'
alias fapi='forge-api'
alias fweb='forge-web'
alias fstatus='forge-status'

# Quick QMD shortcuts
alias qs='qmd search'
alias qf='qmd search --files'
alias qg='qmd get'
alias qu='qmd update'
```

### Phase 2: Node-Specific Optimizations (Short-term)

#### 2.1 Trinity-Specific Configuration

**Create:** `config/zsh/trinity.zsh`

```zsh
# =============================================================================
# Trinity Node - Auxiliary Compute Node Configuration
# macOS Ventura 13.x, 16GB RAM, 4-core i7-7920HQ
# =============================================================================

# Node identification
export FORGE_NODE="trinity"
export FORGE_NODE_ROLE="auxiliary"
export FORGE_NODE_MAX_AGENTS=2

# Trinity-specific aliases
alias node-info='trinity-info'
alias node-health='trinity-health'

# Trinity system info
trinity-info() {
    echo "🖥️  Trinity Node (macOS Ventura)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Role: Auxiliary overflow node"
    echo "Capacity: 1-2 lightweight agents"
    echo "Constraints: NO iOS support (Ventura too old)"
    echo ""
    echo "Hardware:"
    echo "  CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "  Cores: $(sysctl -n hw.ncpu) threads"
    echo "  RAM: $(sysctl -n hw.memsize | awk '{printf "%.1f GB", $1/1024/1024/1024}')"
    echo "  Disk: $(df -h / | awk 'NR==2{print $4 " free"}')"
    echo ""
    echo "Status:"
    echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "  Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
}

# Quick health check
trinity-health() {
    echo "🩺 Trinity Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check critical tools
    echo "Critical Tools:"
    command -v qmd >/dev/null && echo "  ✅ QMD" || echo "  ❌ QMD missing"
    command -v forge >/dev/null && echo "  ✅ Forge CLI" || echo "  ❌ Forge CLI missing"
    command -v uv >/dev/null && echo "  ✅ uv" || echo "  ❌ uv missing"
    echo ""

    # Check resources
    echo "Resources:"
    local free_mem=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.1f GB\n", ($1*$ps)/1024/1024/1024')
    echo "  Free RAM: $free_mem"
    echo "  Disk: $(df -h / | awk 'NR==2{print $4 " free"}')"
    echo ""

    # Check FORGE connectivity
    if [[ -d "$FORGE_ROOT" ]]; then
        echo "  ✅ FORGE_ROOT accessible"
    else
        echo "  ❌ FORGE_ROOT not found"
    fi

    if [[ -n "$FORGE_WEBHOOK_TOKEN" ]]; then
        echo "  ✅ Webhook token set"
    else
        echo "  ⚠️  Webhook token not set"
    fi
}
```

#### 2.2 Agent-Specific Helpers

**Create:** `config/agents/trinity.zsh`

```zsh
# =============================================================================
# Trinity Node Agent Helpers
# Optimized for auxiliary/overflow work
# =============================================================================

# Lightweight task dispatch (for overflow from prya/sati)
trinity-dispatch() {
    local task="$1"
    local agent="${2:-minimax}"  # Default to fast agent

    echo "📤 Dispatching to trinity: $task"
    echo "   Agent: $agent"

    # Check if agent is available
    if ! command -v "$agent" >/dev/null 2>&1; then
        echo "❌ Agent not available: $agent"
        return 1
    fi

    # Run with resource awareness
    "$agent" "$task"
}

# Context-aware agent selection
select-agent() {
    local task_type="$1"

    case "$task_type" in
        "docs"|"review"|"analysis")
            echo "minimax"  # Fast for docs
            ;;
        "backend"|"api"|"infra")
            echo "glm"      # Good for Python/backend
            ;;
        "heavy"|"implementation")
            echo "Recommend dispatching to sati (more RAM)"
            return 1
            ;;
        *)
            echo "minimax"  # Default
            ;;
    esac
}

# Resource-aware agent spawn
trinity-spawn() {
    local agent_type="${1:-minimax}"

    # Check available RAM
    local free_mb=$(vm_stat | perl -ne '/page size of (\d+)/ and $ps=$1; /Pages free:\s+(\d+)/ and printf "%.0f", ($1*$ps)/1024/1024')

    if [[ $free_mb -lt 4000 ]]; then
        echo "⚠️  Low memory: ${free_mb}MB free"
        echo "   Consider waiting or dispatching to another node"
        return 1
    fi

    echo "✅ Spawning $agent_type (RAM OK: ${free_mb}MB free)"
    # Spawn logic here
}
```

### Phase 3: Python Version Management (Medium-term)

#### 3.1 Python 3.13 Compatibility

**Problem:** Python 3.13 has compatibility issues with some packages (librosa→numba→llvmlite).

**Solution:** Use mise to pin Python 3.12 for Trinity.

```zsh
# config/zsh/python-version.zsh (NEW FILE)
# =============================================================================
# Python Version Management for Trinity
# =============================================================================

# Trinity-specific: Pin to Python 3.12 for compatibility
# Python 3.13 has issues with numba/llvmlite chain
if [[ "$FORGE_NODE" == "trinity" ]]; then
    export MISE_PYTHON_DEFAULT="3.12"

    # Alias to ensure we're using compatible version
    alias python-check='mise exec python -- python --version'
    alias python-fix='mise use -g python@3.12'
fi

# Quick Python environment info
pyenv-info() {
    echo "🐍 Python Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "System: $(/usr/bin/python3 --version 2>/dev/null || echo 'N/A')"
    echo "Active: $(python --version 2>/dev/null || echo 'N/A')"
    echo "uv: $(uv --version 2>/dev/null || echo 'N/A')"
    echo ""
    echo "Virtual Environments:"
    if [[ -d "$HOME/.local/share/uv/venvs" ]]; then
        ls -1 "$HOME/.local/share/uv/venvs" 2>/dev/null | head -10
    fi
}
```

### Phase 4: Cross-Node Tools (Longer-term)

#### 4.1 XNode Integration

**Create:** `config/zsh/xnode.zsh`

```zsh
# =============================================================================
# XNode Cross-Node Communication
# FORGE fleet messaging system
# =============================================================================

# Quick XNode status
xnode-status() {
    local inbox_dir="${FORGE_ROOT:-$HOME/work/FORGE}/.forge/xnode/lead-inbox"
    local node="${FORGE_NODE:-$(hostname)}"

    echo "🔗 XNode Status for $node"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ -d "$inbox_dir" ]]; then
        local pending=$(ls -1 "$inbox_dir/$node"*.jsonl 2>/dev/null | wc -l | tr -d ' ')
        echo "  Pending messages: $pending"
    else
        echo "  ❌ XNode directory not found"
    fi
}

# Send message to another node
xnode-send() {
    local target_node="$1"
    local message="$2"

    if [[ -z "$target_node" ]] || [[ -z "$message" ]]; then
        echo "Usage: xnode-send <target-node> <message>"
        return 1
    fi

    echo "📤 Sending to $target_node: $message"
    # Actual forge lead send command
    forge lead send --to-node "$target_node" --message "$message"
}
```

---

## Implementation Priority Matrix

| Priority | Item | Effort | Impact | Timeline |
|----------|------|--------|--------|----------|
| 🔴 P0 | QMD integration | Low | Very High | Immediate |
| 🔴 P0 | Forge CLI to Brewfile | Low | High | Immediate |
| 🟡 P1 | Trinity-specific config | Low | High | This week |
| 🟡 P1 | Re-enable FORGE integration | Low | Medium | This week |
| 🟢 P2 | Agent helpers | Low | Medium | Next sprint |
| 🟢 P2 | Python 3.12 pinning | Low | Medium | Next sprint |
| 🟢 P3 | XNode integration | Medium | Medium | Future |

---

## File Structure Changes

```
/Users/moltbot/dotfiles/
├── config/
│   ├── zsh/
│   │   ├── forge-tools.zsh      # NEW: QMD, forge integration
│   │   ├── trinity.zsh          # NEW: Node-specific config
│   │   └── python-version.zsh   # NEW: Python management
│   ├── agents/
│   │   └── trinity.zsh          # NEW: Agent helpers
│   ├── platform/
│   │   └── Brewfile             # UPDATE: Add qmd
│   └── claude/
│       └── TRINITY_GUIDE.md     # NEW: Agent usage guide
└── .zshrc                       # UPDATE: Source new files
```

---

## Testing Checklist

- [ ] QMD accessible via `qmd` command
- [ ] Forge CLI accessible via `forge` command
- [ ] `trinity-info` shows correct specs
- [ ] `trinity-health` checks all critical tools
- [ ] Agent helpers work correctly
- [ ] No conflicts with existing dotfiles
- [ ] Shell startup time acceptable
- [ ] Cross-node messaging works

---

## Success Metrics

1. **Time to Documentation:** < 2 seconds to find FORGE docs (QMD)
2. **Agent Spawn Time:** < 5 seconds with resource check
3. **Shell Startup:** < 1 second (current baseline)
4. **Tool Discovery:** 100% of critical tools available on login
5. **Node Role Clarity:** Clear indication of Trinity's constraints

---

## Next Steps

1. Review and approve this plan
2. Create new configuration files
3. Update Brewfile
4. Test on trinity node
5. Document changes for other nodes
6. Roll out similar configs to prya/sati/nova

---

**Related Documentation:**
- `CLAUDE.md` - FORGE project instructions
- `docs/ORCHESTRATOR_CONVENTION.md` - Lead orchestrator rules
- `docs/INFRASTRUCTURE_MAP.md` - Full fleet overview
- `AGENTS.md` - Agent fleet documentation
