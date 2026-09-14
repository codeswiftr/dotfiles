---
name: handoff
description: Save context for session continuity
---

# Handoff / Checkpoint

Write a short handoff so another session (or harness) can resume this repo. Do not require Forge.

Use at session end, before a reboot (`just status` nudge), or when switching tasks.

## Where to write

Write **`HANDOFF.md` at the repository root**. Do not commit it unless the user asks.

If a legacy `docs/PROMPT.md` already exists and is what this project uses, update that instead of creating a second file.

Optional: if `command -v forge` succeeds and this is a Forge tree, you may also run `forge handoff clean`. Never fail the handoff because Forge is missing.

## Gather

- Repo name, purpose, current branch, last few commits
- What shipped this session vs still open
- Files that matter (paths that exist)
- Commands to verify (from `AGENTS.md` / README)
- Decisions, gotchas, what not to redo

## Template

```markdown
# Handoff

**Repo**: [path]
**Branch**: [branch]
**Date**: [ISO date]

## Goal
[one paragraph]

## Done
- …

## Open
- [ ] [next action — first item is the resume point]

## Verify
```bash
[test or check command]
```

## Files
| Path | Why |
|------|-----|
| `AGENTS.md` | agent rules |

## Notes
- Decisions:
- Gotchas:
- Do not:
```

Keep it short enough that the next agent can act without re-reading the whole session.

## After writing

Tell the user the path. Suggest `/continue` (or `just status` after a reboot) as the way back in.
