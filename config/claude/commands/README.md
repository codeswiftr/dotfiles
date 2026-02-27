# Claude Code Commands

11 slash commands covering 95% of workflows. Each has a `forge` CLI equivalent for cross-agent portability.

## Core Commands

| Command | Purpose | CLI Equivalent | Flags |
|---------|---------|----------------|-------|
| `/prime [project]` | Prime session with context | `forge context load` | `--focus [area]` |
| `/plan [task]` | Research, design, create plan | `forge plan` | |
| `/execute [plan]` | Implement with TDD | (direct coding) | `--auto` |
| `/review [target]` | Code review | `forge quality check` | `--deep` |
| `/audit [target]` | Security audit | `forge quality check --security` | `--full` |
| `/debug [issue]` | Investigate and fix bugs | (direct coding) | |
| `/fix-tests` | Systematically fix failing tests | (direct coding) | |
| `/deps` | Audit dependencies for security | `forge quality deps` | |
| `/release [version]` | Prepare release with changelog | `forge ship --release` | |
| `/handoff` | Save context for session continuity | `forge handoff clean` | |
| `/continue` | Resume from handoff | `forge context load` + `forge handoff read` | |

## CLI-First Principle

All operations should be accessible via `forge` CLI so any agent (Claude, Kimi, OpenCode, Gemini) can use them. Slash commands add LLM context on top.

```
Agent → forge CLI (universal) → does work
Agent → Slash command (thin wrapper) → forge CLI → does work
```

## Focus Areas

Use with `/prime [project] --focus [area]` or `forge context load --focus [area]`:

| Area | Description |
|------|-------------|
| `dev` | Development, coding, features |
| `content` | Blog posts, marketing copy, docs |
| `ops` | DevOps, deployment, infrastructure |
| `marketing` | Landing pages, SEO, analytics |
| `security` | Auth, compliance, audits |
| `testing` | Test coverage, QA, quality |
| `design` | UI/UX, components, styling |

## Workflows

### Feature Development
```
forge context load -p PROJECT → forge plan → /execute → forge quality check → forge ship
```

### Bug Fix
```
forge context load -p PROJECT → /debug [issue] → /fix-tests → forge quality check
```

### Security Check
```
forge quality check --security → forge quality deps
```

### Session Management
```
Start:  forge context load -p PROJECT --focus dev
End:    forge handoff clean
Resume: forge context load (reads handoffs automatically)
```

## Command Flags

| Flag | Command | Effect |
|------|---------|--------|
| `--focus [area]` | `/prime`, `forge context load` | Focus on business function |
| `--auto` | `/execute` | Run autonomously without pausing |
| `--deep` | `/review` | Agent-powered thorough review |
| `--full` | `/audit` | Full codebase health check |
| `--json` | Most `forge` commands | Machine-readable output |

## That's It

11 slash commands + 50+ `forge` CLI commands. Covers:
- Session priming with focus
- Planning & architecture
- Implementation with TDD
- Code review & quality checks
- Security audit
- Bug fixing & test fixing
- Dependency audit
- Release & deployment
- Context handoff & recovery
- Fleet management & dispatch
