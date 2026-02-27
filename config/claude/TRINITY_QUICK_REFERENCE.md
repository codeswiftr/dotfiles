# Trinity Node - Quick Reference Guide

## TL;DR - Trinity in 30 Seconds

**Trinity is the auxiliary overflow node for lightweight tasks.**

- **OS:** macOS Ventura 13.x (older, NO iOS support)
- **RAM:** 16GB (max 1-2 agents)
- **Best for:** docs, code review, quick fixes
- **Avoid:** iOS work, heavy computation, large test suites
- **Dispatch iOS to nova, heavy work to sati**

---

## New Commands Available

### System Information
```bash
node-info      # Full Trinity node specs and capabilities
node-health    # Health check with tool verification
node-ram       # Detailed memory status
node-cpu       # CPU status and top consumers
```

### QMD Documentation Search
```bash
qs "topic"        # Fast BM25 search across FORGE docs
qf "pattern"      # Find files by filename pattern
qg qmd://...      # Get specific document
qv "complex"      # Vector search (slower, more accurate)
qu                # Update QMD index
qmd-help          # Show QMD help
```

### FORGE Quick Commands
```bash
forge-docs "topic"     # Search FORGE docs
forge-root             # Navigate to FORGE root
forge-ready            # Check environment readiness
fstatus                # Forge status (aliased)
ff                     # Forge fleet (aliased)
```

### Trinity Agent Helpers
```bash
t-status               # Show agent status and recommendations
t-review [files]       # Quick code review
t-docs "topic"        # Documentation task
t-analyze "target"     # Quick analysis
t-dispatch "task"      # Smart dispatch (auto-selects node)
trinity-best-agent "task"  # Suggest best agent for task
```

---

## QMD: Critical FORGE Documentation Tool

**QMD is installed and should be available.** If not:

```bash
npm install -g @forge/qmd
```

### When to Use QMD (Decision Matrix)

| Need | Command | Why |
|------|---------|-----|
| Find architecture docs | `qs "architecture"` | Fast BM25 search |
| Find specific file | `qf "CLAUDE.md"` | File pattern match |
| Get specific doc | `qg qmd://forge-docs/guide.md` | Direct access |
| Complex semantic search | `qv "multi-node orchestration"` | Vector reranker |
| Refresh index | `qu` | New docs added |

### Common QMD Searches

```bash
# Infrastructure understanding
qs "forge status"
qs "agent dispatch"
qs "orchestrator"
qs "node trinity"

# Workflow and processes
qs "git workflow"
qs "commit protocol"
qs "code quality"

# Revenue and strategy
qs "10k mrr"
qs "revenue unblock"
qs "interview simulator"
```

---

## Trinity Node Decision Tree

```
Task Type?
│
├─ iOS / Swift / Simulator?
│  └─ Dispatch to nova (iOS only works there)
│
├─ Heavy computation / Large test suite?
│  └─ Dispatch to sati (64GB RAM available)
│
├─ Documentation / Research?
│  └─ Use minimax on trinity (fast, lightweight)
│
├─ Code review / Quick fix?
│  └─ Use minimax on trinity
│
└─ Backend / API / Infrastructure?
   └─ Use glm on trinity
```

### Resource Check Before Spawning

```bash
# Check if we have enough RAM (default 4GB requirement)
trinity-can-spawn

# Check with custom requirement (2GB)
trinity-can-spawn 2048

# Get best agent for task type
trinity-best-agent "code review"
trinity-best-agent "backend api"
trinity-best-agent "documentation"

# Check if Trinity should handle this task
trinity-should-handle "ios app development"
trinity-should-handle "quick documentation fix"
```

---

## Fleet Node Reference

| Node | RAM | Role | Best For | Avoid |
|------|-----|------|----------|-------|
| **prya** | 16GB | Hub/CC | Command Center, coordination | Heavy work |
| **sati** | 64GB | Workhorse | Heavy work, test suites, OpenCode | Quick tasks |
| **nova** | 48GB | Power/iOS | iOS builds, power sessions | Light work (waste of capacity) |
| **trinity** | 16GB | Auxiliary | Docs, review, quick fixes | iOS, heavy work |

### Dispatch Commands

```bash
# Dispatch to specific node
forge dispatch send sati "run full test suite"
forge dispatch send nova "build iOS app"
forge dispatch send prya "check Command Center status"

# Smart dispatch (auto-selects node)
t-dispatch "quick documentation fix"    # Handles on trinity
t-dispatch "iOS build and test"           # Sends to nova
t-dispatch "comprehensive test suite"     # Sends to sati
```

---

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `FORGE_NODE` | `trinity` | Current node identification |
| `FORGE_NODE_ROLE` | `auxiliary` | Role in fleet |
| `FORGE_NODE_MAX_AGENTS` | `2` | Max concurrent agents |
| `FORGE_NODE_OSRULE` | `Ventura 13.x` | OS version note |
| `FORGE_ROOT` | `~/work/FORGE` | Portfolio root |

---

## Troubleshooting

### QMD not found

```bash
# Check installation
which qmd

# Install if missing
npm install -g @forge/qmd

# Verify version
qmd --version
```

### Forge CLI not found

```bash
# Check installation
which forge

# Should be in ~/.local/bin or FORGE_ROOT/.local/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$FORGE_ROOT/.local/bin:$PATH"
```

### Low memory warning

```bash
# Check current memory
node-ram

# Check system memory
trinity-ram

# If < 4GB free, consider:
# 1. Waiting for memory to free
# 2. Dispatching heavy work to sati
# 3. Closing unused applications
```

### Agent not available

```bash
# Check agent status
t-status

# Check installed agents
command -v minimax
command -v glm
command -v claude
```

---

## Getting Started Checklist

When starting a session on Trinity:

1. **Check system health**
   ```bash
   node-health
   ```

2. **Verify QMD is working**
   ```bash
   qs "architecture"
   ```

3. **Check memory before spawning**
   ```bash
   trinity-can-spawn
   ```

4. **Search for relevant docs**
   ```bash
   qs "your task topic"
   ```

5. **Decide: handle locally or dispatch?**
   ```bash
   trinity-should-handle "your task"
   t-dispatch "your task"  # Smart dispatch
   ```

---

## Key Files

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config |
| `config/zsh/forge-tools.zsh` | QMD, forge CLI integration |
| `config/zsh/trinity.zsh` | Node-specific config |
| `config/agents/trinity.zsh` | Agent helpers |
| `TRINITY_IMPROVEMENT_PLAN.md` | Full improvement plan |

---

## See Also

- `CLAUDE.md` - FORGE portfolio instructions
- `docs/QMD_QUICK_REFERENCE.md` - QMD documentation
- `docs/INFRASTRUCTURE_MAP.md` - Fleet architecture
- `AGENTS.md` - Agent fleet documentation
