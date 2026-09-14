# Claude Code Workflow Guide

11 commands. 4 workflows. Commands run in the **current repo** and must not assume Forge.

## Commands

| Command | Purpose | Flags |
|---------|---------|-------|
| `/prime` | Prime session from this repo | `--focus [area]` |
| `/plan [task]` | Research, design, create plan | |
| `/execute [plan]` | Implement with TDD | `--auto` |
| `/review [target]` | Code review | `--deep` |
| `/audit [target]` | Security audit | `--full` |
| `/debug [issue]` | Fix bugs | |
| `/fix-tests` | Fix failing tests | |
| `/deps` | Dependency security | |
| `/release [ver]` | Prepare release | |
| `/handoff` | Write `HANDOFF.md` | |
| `/continue` | Resume from `HANDOFF.md` | |

## Workflows

### Feature Development
```
/prime → /plan [feature] → /execute → /review → /release
```

### Bug Fix
```
/prime → /debug [issue] → /fix-tests → /review
```

### Security
```
/audit --full → /deps
```

### Session
```
Start:  /prime [--focus area]
End:    /handoff
Resume: /continue
```

## Agents

Use agents for complex subtasks during `/execute`:

| Agent | Use For |
|-------|---------|
| `backend-engineer` | API, database, business logic |
| `frontend-builder` | UI, components, styling |
| `qa-test-guardian` | Test creation, coverage |
| `security-auditor` | Security review |
| `debug-detective` | Complex bug investigation |
| `architect-advisor` | System design decisions |
| `performance-optimizer` | Performance issues |
| `devops-deployer` | Deployment, CI/CD |

## Skills (user-level, `~/.claude/skills/`)

```
git-committer, uv-dependency-keeper, gemini-researcher,
repo-reviewer, docker-composer,
dependency-auditor, test-coverage-analyzer, env-manager,
changelog-generator, nano-banana-imagegen, handoff,
perplexity-researcher
```

Project-only skills stay in that project (or a fleet profile). Do not load Forge portfolio skills unless this tree is a Forge project.

## Quick Reference

```
┌─────────────────────────────────────────────┐
│            CLAUDE CODE COMMANDS             │
├─────────────────────────────────────────────┤
│  START     /prime [--focus area]            │
│  PLAN      /plan [task]                     │
│  BUILD     /execute [plan]    --auto        │
│  QUALITY   /review [target]   --deep        │
│            /audit [target]    --full        │
│            /fix-tests  /deps                │
│  DEBUG     /debug [issue]                   │
│  SHIP      /release [version]               │
│  SESSION   /handoff  /continue              │
│  Focus:    dev, ops, testing, security,     │
│            docs, agents                     │
└─────────────────────────────────────────────┘
```
