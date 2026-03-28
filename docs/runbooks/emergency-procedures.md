# Emergency Procedures

Troubleshooting and recovery procedures for fleet operations.

## Common Issues

### Issue: Node Offline

**Symptoms:**
- `forge node list` shows node as offline
- Dispatch to node fails
- Cannot execute remote commands

**Diagnosis:**
```bash
# Check node status
forge node status <node>

# Check Tailscale connectivity
tailscale ping <node>

# Check if daemon running on node
node-exec <node> "forge daemon status"
```

**Resolution:**
```bash
# Bring node online
forge node up <node>

# Or manually on the node:
forge node join
forge daemon start
```

### Issue: Agent Stuck/Unresponsive

**Symptoms:**
- Agent shows "running" but no progress
- Context usage stuck at same level
- Task in queue but not processed

**Diagnosis:**
```bash
# Check agent status
forge agent get <agent>

# Check queue for stuck tasks
forge queue

# Check for zombie processes
forge doctor
```

**Resolution:**
```bash
# Kill stuck agent
forge agent kill <agent>

# Restart agent
forge agent start <agent>

# Or restart all on node
forge recover
```

### Issue: Queue Blocked

**Symptoms:**
- No tasks being processed
- Queue shows tasks but none running
- All agents idle but queue full

**Diagnosis:**
```bash
# Check queue status
forge queue

# Check for locks
forge recover --check-locks

# Check daemon
forge daemon status
```

**Resolution:**
```bash
# Clear stuck locks
forge recover --clear-locks

# Restart daemon
forge daemon restart

# Force queue process
forge queue process --force
```

### Issue: High Memory/Resource Usage

**Symptoms:**
- Node slow or unresponsive
- Out of memory errors
- Task failures

**Diagnosis:**
```bash
# Check local resources
node-ram
node-cpu

# Check remote node
node-exec <node> "node-ram"
```

**Resolution:**
```bash
# Kill resource-heavy processes
forge agent kill <heavy-agent>

# Free memory
forge recover --gc

# Reduce max agents on node
# Edit FORGE_NODE_MAX_AGENTS in config
```

### Issue: Dispatch Not Working

**Symptoms:**
- `task-dispatch` fails silently
- Tasks not appearing in queue
- No error messages

**Diagnosis:**
```bash
# Check forge CLI
forge --version

# Check daemon
forge daemon status

# Check webhook
forge config get webhook_url
```

**Resolution:**
```bash
# Restart daemon
forge daemon restart

# Re-initialize if needed
forge init

# Test dispatch
forge dispatch send local "Test dispatch"
```

### Issue: Merge Conflicts/Stuck Git State

**Symptoms:**
- Cannot commit or push
- Git operations hang
- Merge conflict markers in files

**Resolution:**
```bash
# Use forge recover
forge recover

# Or manual:
git status
git diff --name-only --diff-filter=U  # List conflicted files
git checkout --theirs <file>          # Accept theirs
git checkout --ours <file>            # Accept ours
git add <resolved-files>
git rebase --continue
```

## Recovery Procedures

### Full Fleet Recovery

```bash
# 1. Check all nodes
fleet-health

# 2. Bring offline nodes online
forge node up <offline-node>

# 3. Clear all locks and stale state
forge recover --all

# 4. Restart daemon
forge daemon restart

# 5. Verify
fleet-status
```

### Single Node Recovery

```bash
# On the affected node:

# 1. Check state
forge doctor

# 2. Clear locks
forge recover

# 3. Restart daemon
forge daemon restart

# 4. Rejoin mesh
forge node join

# 5. Verify
forge status
```

### Reset Agent

```bash
# Kill and restart specific agent
forge agent kill <agent>
forge agent start <agent> --fresh

# Or all agents on node
forge agent restart --all
```

## Diagnostic Commands

```bash
# Full health check
forge doctor

# Queue status
forge queue

# Node status
forge node status

# Agent list with details
forge agent list --verbose

# Recent errors
forge task list --status failed --limit 10

# System resources
fleet-resources
```

## Escalation Path

1. **Self-Service**: Try commands in this runbook
2. **Recovery**: Run `forge recover` or `fleet-recover`
3. **Investigation**: Check logs with `forge logs`
4. **Manual Fix**: SSH/tmux to affected node
5. **Full Reset**: Last resort - reinitialize node

## Prevention

1. **Regular Health Checks**: Run `fleet-health` daily
2. **Monitor Queue**: Check `forge queue` before dispatch
3. **Resource Awareness**: Use `task-route` for optimal routing
4. **Clean State**: Run `forge recover` periodically
5. **Keep Updated**: Run `dot update` regularly
