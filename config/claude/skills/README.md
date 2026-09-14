# User-Level Claude Code Skills

Generic skills available across projects via `~/.claude/skills/` (chezmoi →
`config/claude/skills/`).

## Available Skills

| Skill | Description |
|-------|-------------|
| `handoff` | Write `HANDOFF.md` for session continuity (same contract as `/handoff`) |
| `git-committer` | Conventional commits workflow |
| `uv-dependency-keeper` | Python deps with uv |
| `test-coverage-analyzer` | Coverage gaps |
| `repo-reviewer` | repomix + Gemini review |
| `perplexity-researcher` | Perplexity research |
| `nano-banana-imagegen` | Gemini image generation |
| `gemini-researcher` | Gemini CLI research |
| `env-manager` | Env / secrets patterns |
| `docker-composer` | Dockerfiles / compose |
| `dependency-auditor` | Dependency security audit |
| `changelog-generator` | Changelog from commits |

## Not in this tree

App scaffolds, fleet dashboards, and FORGE orchestrator skills belong in
project repos (e.g. forge-mono) — not user-global dotfiles skills.

## Structure

```
skill-name/
├── SKILL.md       # Required frontmatter + docs
└── scripts/       # Optional helpers
```
