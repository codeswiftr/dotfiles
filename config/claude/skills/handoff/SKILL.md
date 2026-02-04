---
name: handoff
description: Save context and create handoff prompt for session continuity
---

# Handoff Skill

Save session context and create a handoff prompt for resuming work later or transferring to another agent.

## When to Use

- End of coding session
- Before switching to another task/project
- When transferring work to another agent
- Before system restart or maintenance

## Prerequisites

- Active session with work in progress
- Clear understanding of current task state

## Workflow

### 1. Analyze Current State

```bash
# Check uncommitted changes
git status

# Check recent commits
git log --oneline -5

# Check active branches
git branch -v
```

### 2. Create Handoff Document

Create a handoff document at `.forge_sessions/handoff_YYYY-MM-DD_HH-MM.md`:

```markdown
# Handoff - [TIMESTAMP]

## Current Focus
[Main task or goal being worked on]

## Progress Summary
- [x] Completed item 1
- [x] Completed item 2
- [ ] In progress item
- [ ] Blocked item (with blocker details)

## Key Decisions Made
- Decision 1: Rationale
- Decision 2: Rationale

## Active Changes
\`\`\`bash
# Uncommitted changes
[Output of git status]
\`\`\`

## Next Steps
1. [Immediate next action]
2. [Follow-up action]
3. [Verification/testing needed]

## Context for Resume
**Files Modified:**
- `/path/to/file1.py` - Purpose of changes
- `/path/to/file2.ts` - Purpose of changes

**Dependencies:**
- API endpoint X depends on database migration Y
- Feature A blocks feature B

**Environment Notes:**
- Environment variables needed
- Services that must be running
- Known issues or workarounds

## Handoff Prompt

To resume this work, use:

> Continue work on [task description]. Current focus is [specific area].
> Recent changes include [brief summary]. Next step: [immediate action].
> See `.forge_sessions/handoff_YYYY-MM-DD_HH-MM.md` for full context.
```

### 3. Update Session Log

Append a session summary to `docs/sessions/YYYY-MM-DD.md`:

```markdown
## Session N - HH:MM
**Focus**: [Main task/goal]
**Agents**: [Active agents involved, e.g., forge:codex, claude:desktop]
**Changes**:
- [Key modification 1]
- [Key modification 2]
**Decisions**:
- [Important choice made with rationale]
**Next**: [Continuation points]
**Handoff**: `.forge_sessions/handoff_YYYY-MM-DD_HH-MM.md`
```

### 4. Optional: Commit Progress

If appropriate (stable state, meaningful checkpoint):

```bash
# Stage changes
git add [specific files]

# Create WIP commit
git commit -m "WIP: [brief description]

Current state:
- [Status item 1]
- [Status item 2]

Next: [what comes next]
"
```

### 5. Generate Resume Command

Output a resume command for easy restart:

```bash
# For Claude Code:
claude "Continue work on [task]. See .forge_sessions/handoff_YYYY-MM-DD_HH-MM.md"

# For FORGE agents:
tmux attach -t forge:[agent-name]
# Then paste the handoff prompt
```

## Session Logging

After creating the handoff document:

1. **Locate today's session log**: `docs/sessions/YYYY-MM-DD.md`
2. **Create if missing**: Use template from initial session log
3. **Append session summary** with:
   - Session number and time
   - Focus area
   - Key changes made
   - Decisions and rationale
   - Next steps
   - Link to handoff document

## Best Practices

### DO:
- Be specific about what's complete vs. in-progress
- Document blockers with clear context
- Include file paths (absolute paths preferred)
- Note environment requirements
- Reference related issues/PRs
- Keep handoff prompt concise (<3 sentences)

### DON'T:
- Create handoff for trivial changes
- Include sensitive data (API keys, passwords)
- Make WIP commits to main branch
- Leave uncommitted breaking changes
- Skip session log update

## Example Output

```
Handoff created successfully:

📄 Handoff document: .forge_sessions/handoff_2026-01-27_14-30.md
📝 Session log updated: docs/sessions/2026-01-27.md

Resume with:
  Continue work on Command Center fleet control. Current focus is backend
  API endpoints for agent registration. See .forge_sessions/handoff_2026-01-27_14-30.md
```

## Integration with Other Skills

- **`context-loader`**: Reads handoff docs on session start
- **`git-committer`**: Can commit handoff state if needed
- **`living-docs`**: Updates living docs based on handoff decisions
- **`fleet-save`**: Saves multi-agent state including handoffs

## File Locations

| Path | Purpose |
|------|---------|
| `.forge_sessions/handoff_*.md` | Detailed handoff documents |
| `docs/sessions/YYYY-MM-DD.md` | Daily session logs |
| `.git/` | Git state for uncommitted changes |

## Troubleshooting

**No changes to handoff:**
- Review what was actually accomplished
- Consider if session warrants a handoff
- Simple tasks may not need formal handoff

**Can't find session log:**
- Check date format matches YYYY-MM-DD
- Verify `docs/sessions/` directory exists
- Create new session log from template

**Handoff too complex:**
- Break into multiple focused handoffs
- Create separate docs for different work streams
- Use task tracking for detailed items
