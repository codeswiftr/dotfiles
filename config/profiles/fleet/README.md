# Fleet profile (optional)

In-repo hooks for multi-node / agent-fleet tooling (OpenClaw, forge operators, etc.).

## Enable

```bash
# Option A — marker file (gitignored recommended per machine)
touch ~/dotfiles/config/profiles/fleet/.enabled

# Option B — env
export DOTFILES_PROFILE=fleet   # e.g. in ~/.zshrc.local
```

Then open a new shell. `.zshrc` sources `shell.zsh` when either condition is true.

## What belongs here

- Thin shell helpers and aliases
- Completions for fleet CLIs
- Docs for operators

## What does **not** belong here

- Secrets / API tokens → `~/.env.local`
- Large binaries → install via brew / mise / uv into `~/.local/bin`
- Portable core shell → `config/zsh/*`

## Related

- `config/zsh/forge.zsh` — FORGE operator helpers (loaded for non-SSH sessions)
- `docs/agents.md` — agent-safe shell mode
