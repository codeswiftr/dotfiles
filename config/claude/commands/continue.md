---
name: continue
description: Resume work from a handoff in the current repo
---

# Continue From Handoff

Resume the current repository from a saved handoff. Do not assume Forge or `docs/PROMPT.md`.

## 1. Find a handoff

Look in this order; use the first file that exists:

1. `HANDOFF.md` (repo root) — preferred
2. `docs/PROMPT.md` — legacy name some sessions used
3. Newest `docs/handoffs/*`
4. Newest `.forge_sessions/handoff_*`

If none exist, say so, run `/prime` (or the prime steps), and wait for a goal. Do not invent a plan.

## 2. Load repo context

Read `AGENTS.md`, then `CLAUDE.md`, then `README.md` when present. Then:

```bash
git status
git log --oneline -5
```

Re-read any files the handoff names; they may have changed.

## 3. Verify

Use the test/check command from the handoff or `AGENTS.md`. Examples this repo uses:

```bash
bats tests/bats/smoke.bats
./bin/dot check
```

In other repos, use that project's documented command. Skip tools that are not installed.

## 4. Resume

Continue from the handoff's **exact next action**. Treat the rest of the handoff as stale hints until you verify files and git.

Stop and ask when:

- The handoff's next step is gone or contradicts the working tree
- You would need a human decision (secrets, force-push, unrelated refactors)
- There is no handoff and no clear request

Do not "keep going until the whole backlog is done." Finish the stated next action, then report.

## 5. Output when you pause or finish

```
## Session

### Done
- …

### Still open
- …

### Verify
- [command] [pass/fail/not run]

### Next
[one concrete step]
```
