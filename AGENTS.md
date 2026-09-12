# Agent Guide

Short instructions for coding agents working in this repository.

## Read first

| Doc | Use for |
|-----|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Layout, bin policy, linking (chezmoi), PATH |
| [docs/agents.md](docs/agents.md) | Agent-safe shell, wrappers (`_claude`, `ai`) |
| [docs/testing.md](docs/testing.md) | bats suite details |
| [README.md](README.md) | Human install / features |

Claude-specific slash commands and skills live under `config/claude/` (see thin [CLAUDE.md](CLAUDE.md)).

## Layout (high level)

```
bin/           # repo-owned scripts only (dot, ai, _agent wrappers) — no binaries
config/zsh/    # shell modules sourced by .zshrc
config/nvim/   # neovim
home/          # chezmoi source (symlinks + templates)
lib/cli/       # dot CLI modules
scripts/       # install helpers (not on PATH by default)
tests/bats/    # bats-core tests
```

## Commands

```bash
# Daily (canonical task runner)
just smoke                  # fast bats
just test                   # full bats suite
just check                  # ./bin/dot check
just lint                   # shellcheck + yamllint + ruff when installed
just --list

# Links
chezmoi --source "$HOME/dotfiles/home" apply
# or: just link

# Local multiplexer is Herdr (prefix Ctrl-a). Attach / inspect:
hw                          # herdr workspace list
ha                          # attach default session
hl                          # herdr agent list
```

## Shell modes

| Mode | When | Behavior |
|------|------|----------|
| `full` | default interactive | tools-optimized, aliases, AI helpers |
| `minimal` | SSH default | lighter tools init |
| `agent` | `DOTFILES_MODE=agent`, `FORGE_AGENT_TYPE`, `CI` | predictable POSIX commands, pagers=`cat` |

```bash
DOTFILES_MODE=agent zsh
_claude          # wrapper forces agent mode
ai claude        # unified launcher also sets agent mode
agent-safe-status
```

Human shells may alias `cat`/`ls`/… to modern tools. Prefer explicit `bat`, `rg`, `fd`, or agent mode.

## bin/ policy

- Tracked scripts only (see `.gitignore` whitelist).
- **Never** install package-manager binaries into `bin/`.
- `~/.local/bin` must be a **real directory** for tools (mise/uv/brew), not a symlink to this repo.
- PATH: `~/.local/bin` (tools) + `$DOTFILES_DIR/bin` (scripts). See `config/zsh/defaults.zsh`.

## Linking

Chezmoi source: `~/dotfiles/home` (configured in `~/.config/chezmoi/chezmoi.toml`).  
Edit files under the repo; apply with chezmoi. Do not hand-edit only the home-side symlinks.

## Conventions

- Conventional commits: `feat(scope):`, `fix(scope):`, `docs:`, `refactor:`
- Minimal diffs; match existing style
- Explore with `rg`; avoid `git reset --hard` / force-push
- No secrets in git — use `~/.env.local` / `~/.zshrc.local`

## Optional fleet profile

Forge/OpenClaw extras: `config/profiles/fleet/` — enable with `DOTFILES_PROFILE=fleet` or `config/profiles/fleet/.enabled` (gitignored marker).
