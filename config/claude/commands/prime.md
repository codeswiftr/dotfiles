---
name: prime
description: Prime session with context from the current repo
---

# Prime Session

Load this repository and suggest a few next moves. Works in any project. Do not assume Forge, a portfolio layout, or files that are not here.

## Usage

```
/prime                  # current repo, general
/prime --focus [area]   # same repo, one area
```

`/prime [project]` is only useful if that project is the current working directory (or a nested path you can `cd` into). Do not invent sibling repos.

## 1. Load context (always)

Read whatever exists, in this order. Skip missing files; do not fetch substitutes.

1. `AGENTS.md` (shared agent rules)
2. `CLAUDE.md` (Claude-specific notes)
3. `README.md`
4. `ARCHITECTURE.md` if present

Then:

```bash
git status
git branch -v
git log --oneline -5
```

If `DOTFILES_MODE` / agent-safe guidance appears in those files, follow it.

## 2. Detect how this repo works

From the files above (not from memory of other projects):

- Test command (e.g. `just smoke`, `just test`, `pytest`)
- Lint / check command
- How links or installs are applied

Optional: if `command -v forge` succeeds **and** this tree is clearly a Forge project (Forge docs, `forge` in `AGENTS.md`, or a `.forge` dir), you may use `forge context load`. Otherwise ignore Forge.

## 3. Focus (optional)

| Area | Look at |
|------|---------|
| `dev` | Recent diffs, main source, open TODOs |
| `ops` | Install, CI, linking, PATH |
| `testing` | Test runner, last failures |
| `security` | Secrets, hooks, env templates |
| `docs` | README and agent instruction files |
| `agents` | `AGENTS.md`, `CLAUDE.md`, skills/commands if this repo owns them |

## 4. Output

```
Primed for: [directory name]
Focus: [area or general]
Branch: [branch]
Recent: [one-line summary of last commits + dirty files]

Priorities:
1. [most useful next step in this repo]
2. …
3. …

Next: /plan [priority], or say what to implement
```

Keep priorities grounded in git status and the files you read. If the tree is clean and docs say a modernization is done, do not reopen it.
