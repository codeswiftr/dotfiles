# CLAUDE.md

Guidance for Claude Code in this repository. **Prefer [AGENTS.md](AGENTS.md)** for shared agent rules.

## Quick commands

```bash
just smoke
just test
just check
chezmoi --source "$HOME/dotfiles/home" apply
./install.sh install standard   # or: minimal | full | ai_focused
```

## Claude product surface

| Path | Role |
|------|------|
| `config/claude/commands/` | Slash commands (`/prime`, `/plan`, …) |
| `config/claude/agents/` | Subagent personas |
| `config/claude/skills/` | Skills |
| `config/claude/WORKFLOW_GUIDE.md` | Workflow detail |

These are linked into `~/.claude/` via chezmoi (`home/private_dot_claude/`). This file itself is `~/.claude/CLAUDE.md`.

## Architecture pointers

- Shell loader: `.zshrc` → `config/zsh/*`
- Modes: `DOTFILES_MODE=full|minimal|agent` (see `docs/agents.md`)
- Herdr: `config/herdr/config.toml` (prefix `Ctrl-a`)
- Neovim: tiered plugins under `config/nvim/` (`:TierUp` / `:TierDown`)
- Layout SSOT: [ARCHITECTURE.md](ARCHITECTURE.md)

## Do / don't

- **Do** run bats before large changes; use `DOTFILES_MODE=agent` in agent shells
- **Do** keep `bin/` script-only; tools go in `~/.local/bin` / mise / brew
- **Don't** commit secrets or API keys
- **Don't** treat `src/--help/*` as live CLI docs — use `./bin/dot --help`
