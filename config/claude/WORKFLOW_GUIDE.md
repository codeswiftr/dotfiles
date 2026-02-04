# Claude Code Workflow Guide

11 commands. 4 workflows. That's it.

**For autonomous development with compounding loops, see:**
- `harness/docs/AUTONOMOUS_WORKFLOW.md` - Full workflow with progressive disclosure
- `harness/docs/FLYWHEEL.md` - Compounding loops one-pager

## Commands

| Command | Purpose | Flags |
|---------|---------|-------|
| `/prime [project]` | Prime session with context | `--focus [area]` |
| `/plan [task]` | Research, design, create plan | |
| `/execute [plan]` | Implement with TDD | `--auto` |
| `/review [target]` | Code review | `--deep` |
| `/audit [target]` | Security audit | `--full` |
| `/debug [issue]` | Fix bugs | |
| `/fix-tests` | Fix failing tests | |
| `/deps` | Dependency security | |
| `/release [ver]` | Prepare release | |
| `/handoff` | Save context | |
| `/continue` | Resume work | |

## Workflows

### Feature Development
```
/prime [project] → /plan [feature] → /execute → /review → /release
```

### Bug Fix
```
/prime [project] → /debug [issue] → /fix-tests → /review
```

### Security
```
/audit --full → /deps
```

### Session
```
Start:  /prime [project] --focus [area]
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

## Skills

### User-Level (everywhere)
```
git-committer, uv-dependency-keeper, gemini-researcher,
repo-reviewer, docker-composer, api-service-scaffold,
dependency-auditor, test-coverage-analyzer, env-manager,
changelog-generator, nano-banana-imagegen
```

### Project-Level (FORGE)
```
living-docs, fastapi-service-template, pwa-frontend-lite,
frontend-design, llm-prompt-guardrails, compliance-playbook-writer,
content-library-producer, content-publisher, update-broadcaster,
research-digest-compiler, mvp-bootstrap-orchestrator, human-review-gate
```

## Quick Reference

```
┌─────────────────────────────────────────────┐
│            CLAUDE CODE COMMANDS             │
├─────────────────────────────────────────────┤
│                                             │
│  START     /prime [project] --focus [area]  │
│                                             │
│  PLAN      /plan [task]                     │
│                                             │
│  BUILD     /execute [plan]    --auto        │
│                                             │
│  QUALITY   /review [target]   --deep        │
│            /audit [target]    --full        │
│            /fix-tests                       │
│            /deps                            │
│                                             │
│  DEBUG     /debug [issue]                   │
│                                             │
│  SHIP      /release [version]               │
│                                             │
│  SESSION   /handoff  /continue              │
│                                             │
│  Focus areas: dev, content, ops, marketing  │
│               security, testing, design     │
└─────────────────────────────────────────────┘
```
