# AI Agent Configuration

Daily agent launchers live in `bin/ai` and `bin/_agent` wrappers.
Shell aliases for Herdr / modern tools live in `config/zsh/aliases.zsh`.

## Daily set (standard profile)

| Agent | Launch |
|-------|--------|
| Claude Code | `ai claude` / `_claude` |
| Cursor | `ai cursor` / `_cursor` |
| OpenCode | `ai opencode` / `_opencode` |
| Pi | `ai pi` / `_pi` |
| Kimi | `ai kimi` / `_kimi` |
| Codex | `ai codex` / `_codex` |

```bash
ai                  # default (claude)
ai --list
ai cursor
```

## Host overrides

Optional per-machine file: `config/agents/<hostname>.zsh` (sourced from `.zshrc`).

## Keys

Put API keys in `~/.env.local` or `~/.zshrc.local` — never commit them.

## Related

- Agent-safe shell: [docs/agents.md](../../docs/agents.md)
- Claude commands/skills: `config/claude/`
- Herdr: `hw` / `ha` / `hl` (prefix `Ctrl-a`)
