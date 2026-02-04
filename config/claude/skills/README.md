# User-Level Claude Code Skills

Generic skills available across all projects. These are stored at user-level (`~/.claude/skills/`) to be accessible in any working directory.

## Available Skills

| Skill | Description | Key Commands |
|-------|-------------|--------------|
| `handoff` | Save context and create handoff prompt for session continuity | Session end, agent transfer |
| `nano-banana-imagegen` | Image generation via Gemini API | `python generate.py "prompt"` |
| `gemini-researcher` | Deep research with Gemini CLI | `gemini -p "query"` |
| `repo-reviewer` | Codebase review with repomix | `npx repomix + gemini` |
| `git-committer` | Conventional commits workflow | `git commit -m "type: msg"` |
| `uv-dependency-keeper` | Python dependency management | `uv add/sync/lock` |

## Skill Structure Convention

Each skill follows this structure:
```
skill-name/
├── SKILL.md              # Required: Frontmatter + documentation
├── scripts/              # Optional: Automation scripts
│   └── main.py
└── prompts/              # Optional: Reusable prompt templates
```

### SKILL.md Frontmatter
```yaml
---
name: skill-name
description: One-line description for Claude auto-discovery
---
```

## When to Create User-Level vs Project-Level Skills

**User-Level (`~/.claude/skills/`):**
- Generic tools (git, dependencies, research)
- Cross-project utilities
- Personal workflow preferences

**Project-Level (`.claude/skills/`):**
- Project-specific workflows
- Team-shared processes
- Domain-specific expertise

## Best Practices Applied

1. **Single Responsibility**: Each skill does one thing well
2. **Clear Triggers**: "When to Use" section defines activation
3. **Prerequisites**: Document required tools/APIs
4. **Workflow Steps**: Numbered, actionable instructions
5. **Templates**: Reusable prompt patterns included
6. **Tips**: Edge cases and common pitfalls

## Adding New Skills

1. Create directory: `mkdir ~/.claude/skills/new-skill`
2. Add `SKILL.md` with frontmatter
3. Optional: Add `scripts/` for automation
4. Test by asking Claude to use the skill
