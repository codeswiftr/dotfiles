# Fleet Status - External Agent Overview

Display the status of all external AI agents in the FORGE fleet.

## Usage

```
/fleet-status
/fleet-status --verbose  # Include last 10 lines of output
```

## Output Format

```
┌─────────────────────────────────────────────────────┐
│ FORGE Agent Fleet Status                            │
├──────────┬─────────┬────────────────────────────────┤
│ Agent    │ Status  │ Current Task                   │
├──────────┼─────────┼────────────────────────────────┤
│ Codex    │ 🟢 BUSY │ [task description]             │
│ Cursor   │ 🟡 IDLE │ Available                      │
│ Amp      │ 🟢 BUSY │ [task description]             │
│ OpenCode │ 🔴 BLOCK│ [blocker reason]               │
│ Gemini   │ 🔴 BLOCK│ Quota resets in Xh             │
└──────────┴─────────┴────────────────────────────────┘
```

## Status Indicators

| Status | Meaning | Action |
|--------|---------|--------|
| 🟢 BUSY | Agent working on task | Monitor progress |
| 🟡 IDLE | Available for work | Dispatch new task |
| 🔴 BLOCK | Cannot accept tasks | Check blocker |
| ⚪ OFF | No tmux session | Create session |

## Check Commands

```bash
# Check agent windows in forge session (CORRECT)
tmux list-windows -t forge

# Check specific agent window
tmux capture-pane -t forge:codex -p | tail -20
tmux capture-pane -t forge:cursor -p | tail -20
tmux capture-pane -t forge:opencode -p | tail -20
tmux capture-pane -t forge:gemini -p | tail -20

# Check all agents at once
for w in codex cursor opencode gemini; do
  echo "=== $w ===" && tmux capture-pane -t forge:$w -p | tail -5
done

# Check if agent process is running
ps aux | grep -E "codex|agent|amp|opencode|gemini"
```

## Common Blockers

| Agent | Blocker | Resolution |
|-------|---------|------------|
| Gemini | Quota exceeded | Wait for reset (~7h) |
| OpenCode | Model not found | `ollama pull qwen2.5-coder:32b` |
| Cursor | API key expired | Re-authenticate |
| Any | Hung process | `tmux send-keys -t {agent}-task C-c` |

## Recovery Actions

```bash
# Cancel stuck agent (use forge session windows)
tmux send-keys -t forge:codex C-c
tmux send-keys -t forge:cursor C-c

# Re-dispatch task (use existing windows, NOT new sessions)
tmux send-keys -t forge:codex "cd /path && codex exec 'prompt'" Enter
tmux send-keys -t forge:cursor "cd /path && agent --print 'prompt'" Enter

# If window doesn't exist, create in forge session (rare)
tmux new-window -t forge -n codex
```
