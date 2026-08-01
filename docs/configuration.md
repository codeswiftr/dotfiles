# Configuration Reference

Where to change things. Prefer editing files under the repo; chezmoi / install links them into `$HOME`.

## Shell (Zsh)

| Path | Role |
|------|------|
| `.zshrc` | Thin loader only |
| `config/zsh/defaults.zsh` | PATH, core env |
| `config/zsh/core.zsh` | setopts, editor |
| `config/zsh/tools-optimized.zsh` | full-mode tool init |
| `config/zsh/tools-minimal.zsh` | minimal/agent tool init |
| `config/zsh/aliases.zsh` | Human aliases (SSOT) |
| `config/zsh/agent-safe.zsh` | Agent-safe unaliases + pagers |
| `config/zsh/<hostname>.zsh` | Host-specific (e.g. `nova.zsh`) |
| `config/profiles/fleet/` | Optional fleet profile |
| `~/.zshrc.local`, `~/.env.local` | Secrets / machine overrides (not in git) |

**Modes:** `DOTFILES_MODE=full|minimal|agent` — see [agents.md](agents.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).

## Tmux

- Single config: `config/tmux/tmux.conf` (prefix `Ctrl-a`)
- Loader: root `.tmux.conf` → sources the above

## Neovim

- Entry: `config/nvim/init.lua`
- Tiers: `config/nvim/lua/tiers/tier1.lua`, `tier2.lua`
- Core: `config/nvim/lua/core/*`
- Promote/demote: `:TierUp` / `:TierDown`

## Tools and install

| File | Role |
|------|------|
| `mise.toml` | Pinned CLIs + runtimes |
| `config/tools.yaml` | Platform packages + profiles (`minimal` / `standard` / `full` / `ai_focused`) |
| `./install.sh install <profile>` | Orchestrates mise + packages + chezmoi apply |

## Linking

- Chezmoi source: `home/` (`sourceDir` in `~/.config/chezmoi/chezmoi.toml`)
- Apply: `chezmoi apply` or `./install.sh link`

## Git hooks

- Repo: `hooks/*` → linked to `~/.config/git/hooks`
- Docs: [git-hooks.md](git-hooks.md)

## Claude Code

- `config/claude/{commands,agents,skills}/` → `~/.claude/` via chezmoi

## Themes

- Prompt: `config/starship.toml`
- Neovim / tmux: Catppuccin-oriented defaults in their configs
