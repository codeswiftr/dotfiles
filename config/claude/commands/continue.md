---
name: continue
description: Resume work from a handoff prompt - read context and continue execution
---

# Continue From Handoff

Resume work from a previous session using the context in docs/PROMPT.md.

## Startup Sequence

### 1. Load Context
```bash
# Load all context in one command (reads CLAUDE.md, PLAN.md, PROMPT.md, git status, handoffs)
forge context load

# Or load with project focus
forge context load --project voice-coach --focus dev

# Read the latest handoff if available
forge handoff read <latest-id>
```

### 2. Verify Environment
```bash
# Check tests pass
[test command from PROMPT.md]

# Verify build works
[build command from PROMPT.md]
```

### 3. Identify Resume Point
From the plan, find:
- Current phase
- Current task (🔄 In Progress or next ⏳ Pending)
- Any blockers noted

### 4. Begin Execution

```
DO NOT STOP! Continue with the plan like an empowered, pragmatic senior engineer.

As a master CLI/terminal power user, execute safe commands as needed.
```

## Execution Mode

### Mindset
- You are a pragmatic senior engineer
- Apply Pareto principle - 20% effort for 80% value
- TDD for business logic
- YAGNI - don't build what isn't needed
- Clean architecture with clear separation

### Workflow Loop
```
1. Read current task from plan
2. Think about approach
3. Write test (if TDD appropriate)
4. Implement solution
5. Verify (tests, lint)
6. Commit with conventional message
7. Update plan status
8. Continue to next task
9. DO NOT STOP
```

### Agent Delegation
Use subagents for complex tasks to avoid context rot:
- `backend-engineer` → API, database, business logic
- `frontend-builder` → UI components
- `qa-test-guardian` → Test creation
- `security-auditor` → Security review

### Quality Gates
After every change:
- Run affected tests
- Ensure no regressions
- Commit with descriptive message
- Update plan status

## Progress Tracking

Update plan as you work:
```markdown
| Task | Status |
|------|--------|
| X.1 | ✅ Done |
| X.2 | 🔄 In Progress |
| X.3 | ⏳ Pending |
```

## When to Stop

Only stop when:
1. Plan fully implemented (all tasks ✅)
2. Tests passing (full suite green)
3. Committed and pushed
4. Plan updated with completion status

OR when encountering:
- Truly blocking issues requiring human decision
- Security-critical decisions
- Ambiguous requirements that need clarification

## Output on Completion

```markdown
## ✅ Session Complete

### Progress Made
- ✅ [Completed task 1]
- ✅ [Completed task 2]
- 🔄 [In progress task] - [status]

### Commits
- `abc123` feat(x): description
- `def456` test(x): description

### Tests
- All passing: ✅
- Coverage: XX%

### Next Session
[What to pick up next]
```

## Quick Start Command

```
Read docs/PROMPT.md, verify tests pass, then continue from the current task.

When the plan is clear, proceed as a senior engineer.
When clarity needed, check docs or ask.

DO NOT STOP until plan is complete or blocked.
```
