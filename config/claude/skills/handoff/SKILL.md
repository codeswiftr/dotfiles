---
name: handoff
description: Save context and create HANDOFF.md for session continuity
---

# Handoff Skill

Save session context so another session (or agent) can resume. Prefer the
`/handoff` slash command when available — this skill is the same contract.

## When to Use

- End of a coding session
- Before switching tasks or agents
- Before reboot / Herdr restore (`just status` afterward)

## Where to write

Write **`HANDOFF.md` at the repository root**. Do not commit it unless asked.

Legacy fallbacks (only if already in use): `docs/PROMPT.md`, `docs/handoffs/*`.
Do **not** create `.forge_sessions/` unless this is already a Forge tree and
the user expects that path.

Optional: if `forge` is on PATH **and** cwd is a Forge project, you may also
run `forge handoff clean`. Never fail because Forge is missing.

## Workflow

1. Gather: `git status`, `git log --oneline -5`, branch, goal
2. Write short `HANDOFF.md` (template below)
3. Tell the user the path; suggest `/continue` to resume

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
just smoke
just check
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
