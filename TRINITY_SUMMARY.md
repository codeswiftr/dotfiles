# Trinity Node Dotfiles - Summary & Next Steps

## What I Found

### FORGE Infrastructure - Big Picture

**Portfolio Scale:** 95 projects across 11 domains targeting $10K MRR

**Fleet Architecture:**
```
┌────────────┬──────────┬──────────┬────────────────┐
│   prya     │   sati   │   nova   │    trinity    │
├────────────┼──────────┼──────────┼────────────────┤
│ 16GB RAM   │ 64GB RAM │ 48GB RAM │ 16GB RAM      │
│ Hub/CC     │Workhorse │ Power/iOS │ Auxiliary     │
│ 2 agents   │ 5-6      │ 3-4      │ 1-2           │
└────────────┴──────────┴──────────┴────────────────┘
```

**Current Revenue Path:**
- Live: Interview Simulator (CodeSwiftr)
- Target: $10K MRR via CodeSwiftr → BrandFocus → NeoForge
- 3 Human Gates blocking: Code Atlas, Voice Coach, IS Content
- After gates: 8% → 80% product development focus

### Trinity Node Specifics

**Constraints:**
- macOS Ventura 13.x (older version)
- NO iOS support (Xcode incompatibility)
- 16GB RAM limit (max 1-2 lightweight agents)
- Best for: docs, review, quick fixes

**What Works:**
- Python/backend development ✅
- Documentation and research ✅
- Code review and analysis ✅
- Lightweight edits ✅

**What Doesn't:**
- iOS builds (use nova) ❌
- Heavy computation (use sati) ❌
- Large test suites (use sati) ❌

### Dotfiles Assessment

**Strengths:**
- Excellent modular architecture
- Performance-optimized shell (lazy loading, fast mode)
- Comprehensive modern CLI tooling (eza, bat, fd, rg, fzf)
- Cross-platform support
- AI agent integration (Claude, OpenCode, Aider)

**Gaps I Addressed:**
1. QMD not integrated → Added `forge-tools.zsh`
2. Forge CLI not tracked → Added to Brewfile notes
3. No node-specific config → Created `trinity.zsh`
4. No agent helpers → Created `agents/trinity.zsh`
5. FORGE integration disabled → Created conflict-free version

---

## Files Created

| File | Purpose |
|------|---------|
| `config/zsh/forge-tools.zsh` | QMD and forge CLI integration |
| `config/zsh/trinity.zsh` | Node-specific config and health checks |
| `config/agents/trinity.zsh` | Agent helpers and resource awareness |
| `config/claude/TRINITY_QUICK_REFERENCE.md` | Quick reference guide |
| `TRINITY_IMPROVEMENT_PLAN.md` | Detailed improvement plan |
| `TRINITY_SUMMARY.md` | This summary |

---

## New Commands Available

After updating `.zshrc`, you'll have these new commands:

### System Info
```bash
node-info      # Full Trinity specs
node-health    # Health check
node-ram       # Memory status
node-cpu       # CPU status
```

### Documentation Search (QMD)
```bash
qs "topic"     # Fast search across FORGE docs
qf "pattern"   # Find files by name
qv "complex"   # Vector search (slower, more accurate)
qu             # Update index
```

### Agent Helpers
```bash
t-status               # Show agent status
t-review [files]       # Quick code review
t-dispatch "task"      # Smart dispatch to appropriate node
trinity-best-agent "task"  # Suggest best agent
```

---

## Installation Steps

### 1. Reload Shell
```bash
source ~/.zshrc
```

### 2. Verify QMD
```bash
which qmd
qmd --version
```

If QMD is missing:
```bash
npm install -g @forge/qmd
```

### 3. Test New Commands
```bash
node-health
qs "architecture"
t-status
```

### 4. Update Brewfile (Optional)
The Brewfile now has QMD documented as an npm install. If you want to install it via homebrew, add:
```rb
brew "qmd"
```

---

## For Agents Working on Trinity

### Before Starting Work
```bash
# 1. Check system health
node-health

# 2. Check memory availability
trinity-can-spawn

# 3. Search for relevant documentation
qs "your topic"

# 4. Decide: handle locally or dispatch?
trinity-should-handle "your task description"
```

### Dispatch Decision Matrix

| Task Type | Handle On |
|-----------|-----------|
| Documentation/research | trinity (minimax) |
| Code review/quick fix | trinity (minimax) |
| Backend/Python/API | trinity (glm) |
| iOS/Swift/Simulator | nova (iOS only) |
| Heavy implementation | sati (more RAM) |
| Full test suite | sati (more CPU/RAM) |

---

## QMD Integration Details

**Why QMD Matters:**
- QMD provides BM25 full-text search across all FORGE `.md` docs
- Reduces research time from minutes to seconds
- Critical for agents to understand architecture quickly

**Installation:**
```bash
npm install -g @forge/qmd
```

**Usage:**
```bash
# Fast search (use this 90% of the time)
qs "agent dispatch protocol"

# File search
qf "CLAUDE.md"

# Vector search for complex queries
qv "how does cross-node orchestration work"
```

---

## Future Enhancements

### Short-term (Next Sprint)
1. Python 3.12 pinning for compatibility
2. XNode integration for cross-node messaging
3. Agent-specific workflow templates

### Longer-term
1. Resource-aware auto-scaling
2. Node-specific agent configurations
3. Automated task routing based on load

---

## Key Takeaways

1. **QMD is critical** - It's the primary way to find FORGE docs. I've integrated it into the dotfiles.

2. **Trinity has clear constraints** - NO iOS, max 1-2 agents, lightweight tasks only.

3. **Smart dispatch is key** - Use `t-dispatch` to automatically route tasks to the right node.

4. **Dotfiles are now node-aware** - Configuration adapts based on which node you're on.

5. **Agents have tools now** - Resource checking, agent suggestions, health monitoring.

---

## Questions or Issues?

If anything isn't working as expected:

1. Check the quick reference: `cat config/claude/TRINITY_QUICK_REFERENCE.md`
2. Run health check: `node-health`
3. Verify QMD: `which qmd`
4. Reload shell: `source ~/.zshrc`

---

**Related Documentation:**
- `CLAUDE.md` - Full FORGE instructions
- `docs/QMD_QUICK_REFERENCE.md` - QMD documentation
- `docs/INFRASTRUCTURE_MAP.md` - Fleet architecture
- `AGENTS.md` - Agent fleet documentation
