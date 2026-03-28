# Task Dispatch Workflow

Standard Operating Procedure for dispatching tasks across the fleet.

## Overview

The dispatch system allows you to send work to any node in the fleet. Tasks are queued and executed by agents on the target node.

## Prerequisites

1. Forge CLI installed and configured
2. Target node online and in mesh
3. Appropriate agent available on target

## Dispatch Methods

### Method 1: Smart Routing (Recommended)

```bash
# Let the system decide
task-route "Your task description"

# Review recommendation, then confirm
task-route-confirm "Your task description"
```

### Method 2: Manual Dispatch

```bash
# Direct dispatch to specific node
task-dispatch sati "Run full test suite"

# Using quick aliases
route-nova "iOS task"
route-sati "Heavy task"
route-trinity "Docs task"
```

### Method 3: Forge CLI Direct

```bash
# Using forge dispatch directly
forge dispatch send sati "Task description"

# Check dispatch status
forge dispatch status
```

## Dispatch Workflow

### Step 1: Prepare Task

Write a clear, actionable task description:

```
✅ Good: "Implement user authentication with JWT tokens in the API"
✅ Good: "Fix null pointer exception in user service when email is empty"
✅ Good: "Add unit tests for payment processing module"

❌ Bad: "Fix the thing"
❌ Bad: "Do some work"
❌ Bad: "Help me"
```

### Step 2: Select Node

```bash
# Get recommendation
task-route "Your task"

# Or check node status first
fleet-status
```

### Step 3: Dispatch

```bash
# Confirm dispatch
task-route-confirm "Your task" <node>

# Or direct dispatch
task-dispatch <node> "Your task"
```

### Step 4: Monitor

```bash
# Check queue status
forge queue

# Check task status
forge task list

# Monitor agent activity
forge agent list
```

## Task Templates

### Feature Implementation

```bash
task-dispatch sati "Feature: Add user notifications

Requirements:
- Email notifications for important events
- In-app notification center
- User preferences for notification types

Acceptance:
- Tests passing
- Documentation updated
- Code review approved"
```

### Bug Fix

```bash
task-dispatch trinity "Fix: Login redirect broken on mobile

Context:
- Users on mobile devices not redirected after login
- Affects iOS Safari and Chrome

Reproduction:
1. Open mobile browser
2. Go to login page
3. Enter credentials
4. Submit - stays on login page

Expected: Redirect to dashboard"
```

### Code Review

```bash
task-dispatch trinity "Review: PR #123 - Payment refactoring

Focus areas:
- Security: No credentials exposed
- Performance: Query optimization
- Testing: Edge cases covered

Files: src/payment/*.py"
```

### Documentation

```bash
task-dispatch trinity "Docs: Update API documentation for v2

Changes:
- New authentication endpoints
- Rate limiting documentation
- Migration guide from v1"
```

## Monitoring Dispatched Tasks

### Check Queue

```bash
forge queue
# Shows: pending, running, completed, failed
```

### View Task Details

```bash
forge task get <task-id>
```

### View Agent Status

```bash
forge agent list
# Shows: name, status, current task, context usage
```

## Troubleshooting

### Task Not Starting

1. Check node is online: `forge node list`
2. Check agent is available: `forge agent list`
3. Check queue isn't blocked: `forge queue`
4. Check for errors: `forge task list --status failed`

### Task Running Too Long

1. Check agent context: `forge agent get <agent>`
2. Consider splitting task
3. Check for zombie processes: `forge doctor`

### Dispatch Failed

1. Verify node connectivity: `forge node status <node>`
2. Check node resources: `node-exec <node> node-health`
3. Try alternative node: `task-dispatch <alt-node> "task"`

## Best Practices

1. **Be Specific**: Clear task descriptions reduce back-and-forth
2. **Include Context**: Link related files, PRs, issues
3. **Set Priority**: Use `--priority` for urgent tasks
4. **Monitor Progress**: Check queue regularly
5. **Clean Up**: Cancel stale tasks with `forge task cancel <id>`

## Quick Reference

| Command | Description |
|---------|-------------|
| `task-route "desc"` | Get routing recommendation |
| `task-dispatch <node> "desc"` | Dispatch to specific node |
| `forge queue` | View task queue |
| `forge task list` | List all tasks |
| `forge agent list` | List agents |
| `fleet-status` | Full fleet overview |
