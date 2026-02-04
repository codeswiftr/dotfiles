---
name: execute
description: Implement plan with pragmatic TDD. Use --auto for autonomous mode.
arguments: plan_path
---

# Execute: $ARGUMENTS

Implement the plan systematically. Add `--auto` to run autonomously without stopping.

## Modes

| Mode | Behavior |
|------|----------|
| Default | Pause at checkpoints for review |
| `--auto` | Continue until plan complete or blocked |

## Execution Loop

```
For each task:
1. Read task from plan
2. Assess: needs TDD? (business logic = yes, infra = no)
3. If TDD: write failing test first
4. Implement (spawn agent if annotated)
5. Run ALL tests
6. If pass: commit, mark done, next task
7. If fail: fix and retry
```

## TDD Decision

| Scenario | TDD? |
|----------|------|
| Business logic | Yes |
| API endpoint | Yes |
| Bug fix | Yes |
| Database migration | No |
| UI styling | No |
| Prototype | No |

## Agent Dispatch

| Annotation | Action |
|------------|--------|
| `backend-engineer` | Spawn backend agent |
| `frontend-builder` | Spawn frontend agent |
| `qa-test-guardian` | Spawn test agent |
| `-` or none | Execute directly |

## At Checkpoints

1. Run full test suite
2. Verify checkpoint criteria
3. Review for regressions
4. Commit checkpoint state

## Validation (End of Execution)

Before marking complete:
- [ ] All tests passing
- [ ] Success criteria met
- [ ] No regressions
- [ ] Code reviewed (or `/review` pending)

## Output Summary

```markdown
## Execution Summary

### Completed
- [x] Task 1.1: description
- [x] Task 1.2: description

### Commits
- `abc123` feat(api): Add endpoints

### Tests
- All passing: ✅
- Coverage: X%

### Next Steps
1. [Continue with Task X]
2. [Run /review if ready]
```
