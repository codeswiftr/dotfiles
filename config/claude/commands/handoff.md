---
name: handoff
description: Save context and create handoff prompt for session continuity
---

# Handoff / Checkpoint

Save current state and generate a prompt for continuing in a new session.

## Quick Start (CLI)

```bash
# Full clean handoff (create + save + commit)
forge handoff clean

# With options
forge handoff clean --agent kimi --reason context --skip-commit
```

If you need more control or LLM-generated summaries, continue with the manual workflow below.

Use this:
- At end of session
- Before context gets too large
- When switching tasks
- As a checkpoint during long work

## Gather Current State

### 1. Project Context
- Project name and purpose
- Tech stack
- Current branch and recent commits
- Overall project status

### 2. Current Work Status
- What was being worked on
- What's completed
- What's in progress
- What's blocked

### 3. Key Files and Locations
- Main entry points
- Configuration files
- Current focus files
- Test locations

### 4. Active Plan
- Current plan file location
- Current phase and task
- Next steps

### 5. Important Context
- Recent decisions made
- Gotchas discovered
- Patterns to follow
- Things to avoid

## Output: docs/PROMPT.md

```markdown
# Agent Continuation Prompt

## Project Overview
**Project**: [Name]
**Purpose**: [One sentence]
**Tech Stack**: [Languages, frameworks, tools]
**Repository**: [Path or URL]

---

## Current State

### Branch
`[branch-name]` - [Brief description of branch purpose]

### Recent Progress
- ✅ [Completed item 1]
- ✅ [Completed item 2]
- 🔄 [In progress item]

### Current Focus
[Describe what was being worked on]

### Blockers/Issues
- [Any blocking issues]
- [Any failing tests]

---

## Active Plan
**Plan File**: `docs/PLAN.md`
**Current Phase**: [Phase X: Name]
**Current Task**: [Task X.Y: Description]
**Status**: [In Progress / Blocked / Ready for next]

### Immediate Next Steps
1. [Specific next action]
2. [Following action]
3. [Following action]

---

## Key Context

### Important Files
| File | Purpose |
|------|---------|
| `src/main.py` | Application entry point |
| `src/feature/handler.py` | Current work focus |
| `tests/test_feature.py` | Tests for current work |
| `docs/PLAN.md` | Implementation plan |

### Recent Decisions
- **[Decision 1]**: [Why this choice was made]
- **[Decision 2]**: [Why this choice was made]

### Gotchas Discovered
- ⚠️ [Thing that's not obvious but important]
- ⚠️ [Another non-obvious thing]

### Patterns to Follow
- [Pattern 1]: [How it works]
- [Pattern 2]: [How it works]

### Things to Avoid
- ❌ [Anti-pattern or mistake to avoid]
- ❌ [Another thing to avoid]

---

## Commands to Run

### Verify Environment
```bash
[Command to verify setup]
```

### Run Tests
```bash
[Test command]
```

### Start Development
```bash
[Dev server or build command]
```

---

## Instructions for New Agent

### Mindset
You are a pragmatic senior engineer continuing implementation. Your approach:
- Apply Pareto principle - 20% effort for 80% value
- Test-driven development for business logic
- YAGNI - don't build what isn't needed
- Clean architecture with clear separation

### Workflow
1. Read this context and the plan file
2. Run tests to verify current state
3. Continue from the current task
4. Commit after each completed task
5. Update plan status as you progress

### Quality Gates
After each change:
1. Run affected tests
2. Ensure no regressions
3. Commit with conventional message
4. Continue to next task

### If Stuck
- Use `/debug` for complex issues
- Use `/feedback` to review approach
- Check related tests for expected behavior
- Ask for clarification if requirements unclear

---

## Resume Command

To continue work, start with:
```
Read docs/PROMPT.md and docs/PLAN.md, verify tests pass, then continue with Task [X.Y].
DO NOT STOP! Continue with the plan like an empowered, pragmatic senior engineer.
```
```

## Save Location
Save the generated prompt to `docs/PROMPT.md`
