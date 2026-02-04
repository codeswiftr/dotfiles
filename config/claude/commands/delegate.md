# Delegate Task to External Agent

Dispatch a task to an external AI agent (Codex, Cursor, Amp, OpenCode, Gemini).

## Usage

```
/delegate <agent> <task description>
/delegate auto <task description>  # Auto-select best agent
```

## Available Agents

| Agent | Best For | Command |
|-------|----------|---------|
| `codex` | Tests, quick code gen, ETL pipelines | `codex exec 'prompt'` |
| `cursor` | Frontend UI, components, landing pages | `agent --print 'prompt'` |
| `amp` | Refactoring, migrations, complex changes | `echo 'prompt' \| amp --execute --dangerously-allow-all` |
| `opencode` | Backend APIs, Python services | `opencode run -m ollama/qwen2.5-coder:32b 'prompt'` |
| `gemini` | Research, documentation, analysis | `gemini -y 'prompt'` |

## Auto-Selection Rules

When using `/delegate auto`, the agent is selected based on keywords:

- **codex**: test, coverage, etl, pipeline, quick
- **cursor**: landing, ui, component, frontend, page, dashboard
- **amp**: refactor, migrate, consolidate, complex
- **opencode**: api, backend, endpoint, service, fastapi
- **gemini**: research, analyze, document, content, curriculum

## Implementation Steps

**IMPORTANT**: Use existing windows in the `forge` session, NOT new sessions.

1. **Use existing agent window** in forge session:
   ```bash
   # forge session has windows: codex, cursor, opencode, gemini
   tmux send-keys -t forge:codex "cd /path/to/project && codex exec 'prompt'" Enter
   tmux send-keys -t forge:cursor "cd /path && agent --print 'prompt'" Enter
   ```

2. **Update task tracking** to in_progress

3. **Monitor progress**:
   ```bash
   tmux capture-pane -t forge:codex -p | tail -20
   ```

### WRONG (Do Not Use)
```bash
# DON'T create separate *-task sessions
tmux new-session -d -s {agent}-task  # NO! Causes session sprawl
```

## Examples

```bash
# Direct dispatch
/delegate codex "Add unit tests for auth service in interview-simulator"

# Auto-select (routes to cursor based on "landing page")
/delegate auto "Create landing page for Graph-RAG Blueprint"

# Check all agents
/fleet-status
```

## Pre-flight Checks

Before dispatching, verify:
- [ ] Agent is available (not blocked by quota/model)
- [ ] Project path exists
- [ ] tmux session doesn't have running task

## Blocked Agent Handling

| Blocker | Recovery |
|---------|----------|
| Gemini quota | Wait ~7h or use fallback |
| OpenCode model missing | Run `ollama pull <model>` |
| Agent hung | `tmux send-keys -t {agent}-task C-c` then retry |
