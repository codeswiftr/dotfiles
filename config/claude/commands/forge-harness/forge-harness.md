# FORGE Harness - Autonomous Orchestrator Loop

Launch autonomous agent to complete FORGE MVP development with GitHub Issues, living-docs, and deployment automation.

## Usage

```
/forge-harness                    # Run single iteration
/forge-harness --iterations 100   # Run 100 iterations (overnight mode)
/forge-harness --focus voice-coach # Focus on specific project
```

## Orchestrator Loop Protocol

You are the **orchestrator**. You delegate, you don't implement.

### Each Iteration

#### 1. ASSESS (2 min)
```bash
# Check git status
git status --short | head -20

# Check available agents
for w in codex cursor opencode; do
  echo "=== forge:$w ==="
  tmux capture-pane -t forge:$w -p 2>/dev/null | tail -3
done

# Check recent session notes
cat docs/PROMPT.md | tail -30

# Check pending features
cat docs/00-portfolio-digest.md | head -50
```

#### 2. PRIORITIZE (1 min)
Identify top 3 priorities from:
- Blocking issues (CC-P0-xxx)
- Tech debt (failing tests, lint errors)
- Docs debt (outdated CLAUDE.md)
- Marketing debt (missing landing pages)
- Research (patterns to explore)
- Prototypes (new MVPs to scaffold)

#### 3. DELEGATE (dispatch to agents)
```bash
# Use CORRECT window pattern (not *-task sessions!)
tmux send-keys -t forge:codex "cd /path && codex exec 'task'" Enter
tmux send-keys -t forge:cursor "cd /path && agent --print 'task'" Enter
tmux send-keys -t forge:opencode "cd /path && opencode run -m cerebras/qwen-3-32b 'task'" Enter
```

#### 4. MONITOR (wait for completion)
```bash
# Check every 60s until agents finish
for w in codex cursor opencode; do
  tmux capture-pane -t forge:$w -p | tail -10
done
```

#### 5. REVIEW (use Task tool with code-reviewer agent)
```
Task(subagent_type="code-reviewer", prompt="Review changes in...")
```

#### 6. COMMIT (if review passes)
```bash
git add -A
git commit -m "feat: description

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push
```

#### 7. REFLECT (document learnings)
- Update `docs/PROMPT.md` with session notes
- Add patterns to `.forge_learning/patterns.json` if significant
- Identify what to improve next iteration

### Agent Availability

| Agent | Window | Credits | Use For |
|-------|--------|---------|---------|
| Codex | `forge:codex` | ✅ Free | Tests, quick code |
| Cursor | `forge:cursor` | ✅ Free | Frontend, UI |
| OpenCode | `forge:opencode` | ✅ Free (cerebras) | Backend APIs |
| Amp | - | ❌ Paid | Skip |
| Gemini | - | ❌ Quota | Skip |

### Priority Categories

1. **P0 Blockers**: Features blocking other features
2. **Tech Debt**: Failing tests, type errors, lint warnings
3. **Docs Debt**: Outdated docs, missing CLAUDE.md
4. **Marketing Debt**: Missing landing pages, content
5. **Research**: Patterns, integrations to explore
6. **Prototypes**: New MVPs to scaffold

### Safety Rules

- ❌ NEVER force push
- ❌ NEVER commit secrets
- ❌ NEVER delete production data
- ✅ Always review before commit
- ✅ Always document decisions
- ✅ Always update session notes

### Overnight Mode

For `--iterations 100`:
- Run continuously until iterations complete
- Take breaks between iterations (30s cooldown)
- If all agents blocked, wait 10 min then retry
- Document progress in `docs/PROMPT.md`
- Create summary at end of run

### Example Iteration

```
=== Iteration 42/100 ===

[ASSESS]
- forge:codex: idle
- forge:cursor: idle
- forge:opencode: idle
- Recent: Fixed emoticons in Command Center

[PRIORITIZE]
1. CC-P0-001: Implement /api/sessions/active
2. Tech debt: Fix TypeScript errors in Dashboard
3. Marketing: Create BabyBit landing page

[DELEGATE]
→ forge:opencode: "Implement /api/sessions/active endpoint..."
→ forge:codex: "Fix TypeScript errors in Dashboard.tsx..."
→ forge:cursor: "Create BabyBit landing page..."

[MONITOR]
... waiting 3 minutes ...
All agents completed.

[REVIEW]
→ code-reviewer: Reviewing 3 PRs...
All changes approved.

[COMMIT]
feat(command-center): add sessions API endpoint
feat(command-center): fix Dashboard type errors
feat(babybit): add landing page

[REFLECT]
- Pattern: OpenCode works well for backend endpoints
- Improvement: Could parallelize reviews
- Next: Implement CC-P0-002 (task dispatch)

=== Iteration 42 complete (4m 23s) ===
```
