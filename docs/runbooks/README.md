# Fleet Operations Runbooks

Standard Operating Procedures (SOPs) for the FORGE multi-node development fleet.

## Quick Reference

| Scenario | Runbook | Quick Command |
|----------|---------|---------------|
| Choose node for task | [Node Selection](./node-selection.md) | `task-route "description"` |
| Dispatch task to node | [Task Dispatch](./task-dispatch.md) | `task-dispatch <node> "task"` |
| Check fleet health | [Fleet Status](./fleet-status.md) | `fleet-status` |
| Sync across nodes | [Inter-Node Sync](./inter-node-sync.md) | `fleet-sync` |
| System issues | [Emergency Procedures](./emergency-procedures.md) | `fleet-recover` |

## Fleet Overview

### Nodes

| Node | RAM | Role | Best For | Constraints |
|------|-----|------|----------|-------------|
| **prya** | 16GB | Hub/Command Center | Lead orchestration, dispatch, coordination | Limited RAM |
| **sati** | 64GB | Workhorse | Heavy tasks, migrations, full-stack, ML, testing | None |
| **nova** | 48GB | Power/iOS | iOS, Swift, Xcode, Simulator | iOS-focused |
| **trinity** | 16GB | Auxiliary | Docs, review, analysis, research, light edits | No iOS, max 2 agents |
| **gaea** | 16GB | Education/Mobile | Family apps, education, mobile testing | Off-hours only |

### Agents

| Agent | Best For | Avoid On |
|-------|----------|----------|
| **claude** | Complex reasoning, code review, architecture | gaea (off-hours) |
| **glm** | Backend, Python, infrastructure | - |
| **minimax** | Quick docs, light edits, fast review | Heavy tasks |
| **gemini** | Research, web-based tasks | - |
| **kimi** | Chinese language tasks | - |

## Common Workflows

### Starting a New Task

```bash
# 1. Check where the task should run
task-route "Your task description"

# 2. If different node recommended, dispatch
task-route-confirm "Your task description" <node>

# 3. If local, just run
task-local "Your task description"
```

### Checking Fleet Health

```bash
# Quick status
fleet-status

# Deep health check
fleet-health

# Resources overview
fleet-resources

# Agent status
fleet-agents
```

### Emergency Recovery

```bash
# Full fleet recovery
fleet-recover

# Local node recovery
forge recover

# Check for issues
forge doctor
```

## Related Documentation

- [Node Selection SOP](./node-selection.md) - Detailed node selection guidelines
- [Task Dispatch Workflow](./task-dispatch.md) - How to dispatch tasks
- [Inter-Node Sync](./inter-node-sync.md) - Keeping nodes in sync
- [Emergency Procedures](./emergency-procedures.md) - Troubleshooting and recovery
