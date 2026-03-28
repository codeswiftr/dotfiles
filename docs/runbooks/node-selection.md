# Node Selection SOP

Standard Operating Procedure for selecting the optimal node for a given task.

## Decision Matrix

### Step 1: Classify Task Type

| Pattern | Recommended Node | Reason |
|---------|------------------|--------|
| `ios`, `swift`, `xcode`, `simulator` | **nova** | Only node with current Xcode |
| `migration`, `heavy`, `full-stack`, `test-suite` | **sati** | 64GB RAM handles large tasks |
| `doc`, `review`, `analysis`, `research` | **trinity** | Auxiliary node, good for light work |
| `education`, `family`, `kids`, `mobile-test` | **gaea** | Dedicated domain owner |
| `dispatch`, `coordinate`, `orchestrate` | **prya** | Hub operations |

### Step 2: Check Constraints

```
┌─────────────┬─────────────────────────────────────────────┐
│ Node        │ Constraints                                 │
├─────────────┼─────────────────────────────────────────────┤
│ trinity     │ ❌ No iOS (Ventura too old)                 │
│             │ ⚠️  Max 2 agents (16GB RAM)                 │
│             │ ⚠️  Avoid heavy computation                  │
├─────────────┼─────────────────────────────────────────────┤
│ gaea        │ ❌ Off-hours only (laptop)                  │
│             │ ⚠️  Submodule work only                      │
│             │ ⚠️  No main repo changes                     │
├─────────────┼─────────────────────────────────────────────┤
│ prya        │ ⚠️  Limited RAM (16GB)                      │
│             │ ✅ Best for coordination                     │
└─────────────┴─────────────────────────────────────────────┘
```

### Step 3: Verify Resources

```bash
# Check node resources before dispatch
node-ram          # Current node RAM
node-cpu          # Current node CPU
node-health       # Full health check
```

## Quick Commands

```bash
# Get recommendation
task-route "Implement iOS login with SwiftUI"
# Output: 🎯 Recommended Node: nova
#         Reason: Pattern match: ios|swift|swiftui

# Confirm and dispatch
task-route-confirm "Implement iOS login" nova

# Quick dispatch to specific node
route-nova "iOS task description"
route-sati "Heavy migration task"
route-trinity "Documentation update"
```

## Agent Selection Per Node

### Trinity (Auxiliary)
```bash
trinity-best-agent "documentation"    # → minimax (fast)
trinity-best-agent "backend"          # → glm (Python)
trinity-best-agent "review"           # → minimax (quick)
```

### Prya (Hub)
- **claude** - Lead orchestration
- **status** - System monitoring

### Sati (Workhorse)
- All agents available
- Best for resource-intensive tasks

### Nova (iOS)
- **claude** - iOS development
- **glm** - Backend iOS support

### Gaea (Education)
- Limited agents (off-hours)
- **minimax** - Quick tasks

## Examples

### Example 1: iOS Feature
```
Task: "Add SwiftUI onboarding screen with animations"

Classification: iOS, SwiftUI
Recommendation: nova
Agent: claude

Command:
  task-route-confirm "Add SwiftUI onboarding" nova
```

### Example 2: Heavy Migration
```
Task: "Migrate user database to new schema with backfill"

Classification: migration, heavy
Recommendation: sati
Agent: glm or claude

Command:
  task-route-confirm "Migrate user database" sati
```

### Example 3: Documentation
```
Task: "Write API documentation for new endpoints"

Classification: docs
Recommendation: trinity
Agent: minimax (fast for docs)

Command:
  task-route-confirm "Write API documentation" trinity
```

### Example 4: Quick Fix
```
Task: "Fix typo in README"

Classification: light, fix
Recommendation: current node (trinity if there)
Agent: minimax

Command:
  task-local "Fix typo in README"
```

## Decision Flowchart

```
                ┌─────────────────┐
                │  New Task       │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ iOS/Swift?      │──Yes──▶ nova
                └────────┬────────┘
                         │ No
                         ▼
                ┌─────────────────┐
                │ Heavy/Migration?│──Yes──▶ sati
                └────────┬────────┘
                         │ No
                         ▼
                ┌─────────────────┐
                │ Docs/Review?    │──Yes──▶ trinity
                └────────┬────────┘
                         │ No
                         ▼
                ┌─────────────────┐
                │ Education/Family│──Yes──▶ gaea (off-hours)
                └────────┬────────┘
                         │ No
                         ▼
                     Local node
```

## Checklist Before Dispatch

- [ ] Task type identified
- [ ] Target node confirmed
- [ ] Node resources checked (`node-ram`, `node-health`)
- [ ] Constraints respected (gaea off-hours, trinity no iOS)
- [ ] Appropriate agent selected
- [ ] Dispatch command executed
