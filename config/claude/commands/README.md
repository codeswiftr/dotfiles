# Claude Code Commands

11 commands covering 95% of workflows.

## Core Commands

| Command | Purpose | Flags |
|---------|---------|-------|
| `/prime [project]` | Prime session with context | `--focus [area]` |
| `/plan [task]` | Research, design, create implementation plan | |
| `/execute [plan]` | Implement with TDD | `--auto` |
| `/review [target]` | Code review | `--deep` |
| `/audit [target]` | Security audit | `--full` |
| `/debug [issue]` | Investigate and fix bugs | |
| `/fix-tests` | Systematically fix failing tests | |
| `/deps` | Audit dependencies for security | |
| `/release [version]` | Prepare release with changelog | |
| `/handoff` | Save context for session continuity | |
| `/continue` | Resume from handoff | |

## Focus Areas

Use with `/prime [project] --focus [area]`:

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
/prime [project] → /plan [feature] → /execute → /review → /release
```

### Bug Fix
```
/prime [project] → /debug [issue] → /fix-tests → /review
```

### Security Check
```
/audit --full → /deps
```

### Session Management
```
Start:  /prime [project] --focus [area]
End:    /handoff
Resume: /continue
```

## Command Flags

| Flag | Command | Effect |
|------|---------|--------|
| `--focus [area]` | `/prime` | Focus on business function |
| `--auto` | `/execute` | Run autonomously without pausing |
| `--deep` | `/review` | Agent-powered thorough review |
| `--full` | `/audit` | Full codebase health check |

## That's It

11 commands. Covers:
- Session priming with focus
- Planning & architecture
- Implementation with TDD
- Code review
- Security audit
- Bug fixing
- Test fixing
- Dependency audit
- Release preparation
- Context handoff
