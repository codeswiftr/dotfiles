# Claude Code Commands

11 slash commands. They run in **whatever repo is cwd**. They must not assume Forge or files that are not in that tree.

## Core Commands

| Command | Purpose | Flags |
|---------|---------|-------|
| `/prime` | Load this repo (`AGENTS.md`, git, tests) | `--focus [area]` |
| `/plan [task]` | Research, design, write a plan | |
| `/execute [plan]` | Implement with TDD | `--auto` |
| `/review [target]` | Code review | `--deep` |
| `/audit [target]` | Security audit | `--full` |
| `/debug [issue]` | Investigate and fix bugs | |
| `/fix-tests` | Systematically fix failing tests | |
| `/deps` | Audit dependencies | |
| `/release [version]` | Changelog / version bump | |
| `/handoff` | Write `HANDOFF.md` at repo root | |
| `/continue` | Resume from `HANDOFF.md` | |

Repo commands (dotfiles example): `just smoke`, `just check`. Use that project's `AGENTS.md` everywhere else.

If `forge` is on PATH **and** the current tree is a Forge project, Forge CLI is an optional shortcut — never a requirement.

## Focus Areas (`/prime --focus`)

| Area | Description |
|------|-------------|
| `dev` | Features, source, open diffs |
| `ops` | Install, CI, linking, PATH |
| `testing` | Test runner and failures |
| `security` | Secrets, hooks, auth |
| `docs` | README and agent instruction files |
| `agents` | Skills, commands, `AGENTS.md` / `CLAUDE.md` |

## Workflows

### Feature
```
/prime → /plan [feature] → /execute → /review
```

### Bug
```
/prime → /debug [issue] → /fix-tests → /review
```

### Session
```
Start:  /prime [--focus area]
End:    /handoff          → HANDOFF.md
Resume: /continue
```

## Flags

| Flag | Command | Effect |
|------|---------|--------|
| `--focus [area]` | `/prime` | Narrow what to inspect |
| `--auto` | `/execute` | Run without pausing for obvious steps |
| `--deep` | `/review` | Use the code-reviewer agent |
| `--full` | `/audit` | Broader security pass |
