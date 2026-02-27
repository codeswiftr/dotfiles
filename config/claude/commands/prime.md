---
name: prime
description: Prime session with context, optionally focus on project/function
---

# Prime Session

Load context and prepare for focused work.

## Quick Start (CLI)

```bash
# General context load
forge context load

# Project-focused
forge context load --project voice-coach

# With focus area
forge context load --project voice-coach --focus dev

# Machine-readable
forge context load --json
```

If you need LLM-generated priorities or deeper analysis, continue with the manual workflow below.

## Usage

```
/prime                           # General session, auto-detect focus
/prime [project]                 # Focus on specific project
/prime [project] --focus [area]  # Focus on project + business function
/prime --focus [area]            # Focus on business function across portfolio
```

## Focus Areas

| Area | Description | Key Files |
|------|-------------|-----------|
| `dev` | Development, coding, features | `PLAN.md`, `progress.md`, tests |
| `content` | Blog posts, marketing copy, docs | `content/`, `blog/`, marketing-template |
| `ops` | DevOps, deployment, infrastructure | Dockerfile, CI/CD, Railway/Cloudflare |
| `marketing` | Landing pages, SEO, analytics | marketing-template, PostHog, content.json |
| `security` | Auth, compliance, audits | CLAUDE.md gates, auth code, HIPAA/COPPA |
| `testing` | Test coverage, QA, quality | tests/, pytest, vitest |
| `design` | UI/UX, components, styling | frontend/, components/, Tailwind |

## 1. Load Context (always)

Read in order:
- Root `CLAUDE.md` - portfolio rules
- `AGENTS.md` - skill/agent guidance
- `docs/PLAN.md` - current sprint

If project specified:
- `{domain}/CLAUDE.md` - domain rules
- `{domain}/{project}/CLAUDE.md` - project rules
- `{domain}/{project}/docs/` - project docs

## 2. Check State

```bash
git status           # Working tree
git branch -v        # Current branch
git log --oneline -5 # Recent commits
```

If focus area specified, also check:
- `dev`: Recent test failures, open PRs
- `content`: Content calendar, draft posts
- `ops`: Deployment status, infrastructure issues
- `marketing`: Analytics, conversion metrics
- `security`: Recent auth changes, compliance status
- `testing`: Coverage reports, flaky tests

## 3. Generate Priorities

Based on project and focus, suggest 3 priorities:

| Priority | Task | Area | Effort |
|----------|------|------|--------|
| 1 | [Most urgent for focus] | [area] | S/M/L |
| 2 | [Second priority] | [area] | S/M/L |
| 3 | [Third priority] | [area] | S/M/L |

## 4. Output Summary

```
Primed for: [project or "FORGE portfolio"]
Focus: [area or "general"]
Branch: [current branch]
Recent: [last activity summary]

Priorities:
1. [P1 - with context]
2. [P2 - with context]
3. [P3 - with context]

Next: /plan [priority] or ask about specific task
```

## Examples

```
/prime
→ General portfolio overview, suggests top priorities across all projects

/prime interview-simulator
→ Focuses on Interview Simulator, loads codeswiftr-com context

/prime interview-simulator --focus testing
→ Interview Simulator testing: coverage gaps, failing tests, test backlog

/prime --focus content
→ Content work across portfolio: blog posts, landing pages, marketing copy

/prime code-atlas --focus ops
→ Code Atlas deployment/infrastructure: Railway, Cloudflare, CI/CD
```
