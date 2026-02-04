---
name: review
description: Code review. Use --deep for agent-powered thorough review.
arguments: target
---

# Review: $ARGUMENTS

Review code for security, performance, and quality. Add `--deep` for principal-engineer-level review using code-reviewer agent.

## Modes

| Mode | Depth | Time |
|------|-------|------|
| Default | Checklist-based | 5-10 min |
| `--deep` | Agent-powered thorough | 20-30 min |

## Review Checklist

### 1. Security
- [ ] Input validation on user inputs
- [ ] No SQL/XSS injection vulnerabilities
- [ ] Auth/authz properly implemented
- [ ] Secrets not hardcoded

### 2. Performance
- [ ] No N+1 query problems
- [ ] Efficient loops
- [ ] Proper caching
- [ ] Async where beneficial

### 3. Code Quality
- [ ] Clear naming
- [ ] DRY principle
- [ ] Single responsibility
- [ ] Proper error handling

### 4. Tests
- [ ] Unit tests for new code
- [ ] Edge cases covered
- [ ] Error scenarios tested

## Deep Review (--deep flag)

Spawn `code-reviewer` agent for:
- Design & architecture review
- Race condition analysis
- Maintainability assessment
- Security deep-dive

## Output Format

```markdown
## Review: [Target]

### Summary
- **Assessment**: APPROVE | REQUEST CHANGES
- **Risk**: Low | Medium | High

### Critical Issues
**[CRITICAL-1]** `file:line` - Issue
- Suggested fix: [code]

### Important Suggestions
**[IMPORTANT-1]** `file:line` - Suggestion

### Minor Notes
- `file:line` - Minor suggestion

### Positive
- Clean separation of concerns
- Good error handling
```

## Severity Levels

| Level | Action |
|-------|--------|
| CRITICAL | Must fix before merge |
| IMPORTANT | Strongly recommended |
| MINOR | Nice to have |
