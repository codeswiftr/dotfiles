# Architecture Decisions

Decided: 2026-04-22

## Canonical File Layout

All configuration source-of-truth lives in `config/`. Root-level dotfiles (`.zshrc`, `.tmux.conf`) are thin loaders that source from `config/`.

### Managed File Manifest

| Source (in repo) | Target (on machine) | Type |
|---|---|---|
| `.zshrc` | `~/.zshrc` | Loader → sources `config/zsh/*.zsh` |
| `config/zsh/.zshenv` | `~/.zshenv` | Symlink |
| `config/zsh/.zprofile` | `~/.zprofile` | Symlink |
| `.tmux.conf` | `~/.tmux.conf` | Loader → sources `config/tmux/tmux.conf` |
| `config/nvim/` | `~/.config/nvim` | Symlink (directory) |
| `config/starship.toml` | `~/.config/starship.toml` | Symlink |
| `completions/_dot` | `~/.local/share/zsh/completions/_dot` | Symlink |
| `hooks/` | `~/.config/git/hooks` | Symlink (directory) |

### Not Managed (machine-local)

| Path | Managed by |
|---|---|
| `~/.local/bin/*` | mise, uv, brew — NOT linked from repo `bin/` |
| `~/.gitconfig` | Generated from `config/gitconfig` template during install |
| `~/.claude/` | Claude Code owns this; template applied once during install |

### `bin/` Policy

`bin/` contains **only repo-owned scripts**:
- `dot` — main CLI
- `ai` — AI tool launcher
- `cursor` — cursor launcher
- `viman` — vim man pages
- `dotfiles-tutor` — interactive tutor
- `tmux-versions` — tmux version helper

All other executables (tool symlinks, binaries) are managed by their respective package managers (mise, uv, brew) and live in `~/.local/bin/`, mise shims, or Homebrew paths. They are NOT tracked in git and NOT symlinked from this repo.

`bin/` is added to `$PATH` via `.zshrc`/`defaults.zsh` — no symlinking of the directory to `~/.local/bin`.

## Linking Strategy

**Primary:** chezmoi (`home/` directory with `.chezmoiroot`).

chezmoi manages:
- Symlinks: .zshrc, .tmux.conf, .zshenv, .zprofile, nvim, starship.toml, hooks, completions
- Templates: .gitconfig (with machine-specific name/email/credential helper)
- Scripts: run_onchange for git hooksPath configuration

**Fallback:** If chezmoi is not installed, `install.sh` falls back to hand-rolled `link_dotfiles()`.

**Machine-specific config:** `~/.config/chezmoi/chezmoi.toml` stores name, email (set on first init via prompts or pre-created).

## Tool Management

**Version ownership:** mise.toml for runtime versions. brew/uv/npm for packages. `tools.yaml` defines what to install per profile but does NOT track versions.

**State tracking:** `~/.dotfiles-state/` tracks only:
- Which post-install hooks have run (avoid re-running chsh, usermod, etc.)
- Last successful install timestamp

No custom `versions.json`. Package managers already know what's installed.

## Shell Modes

**One knob:** `DOTFILES_MODE=full|minimal`
- SSH defaults to `minimal` (auto-detected via `$SSH_CONNECTION`)
- Can be overridden explicitly: `DOTFILES_MODE=minimal` in `.zshrc.local`
- Replaces: `DOTFILES_FAST_MODE`, `DOTFILES_PERFORMANCE_MODE`, `DOTFILES_SSH`

## Testing

**Direction:** Adopt bats-core incrementally.
- New smoke/integration tests written in bats-core
- Existing tests stabilized, then migrated gradually
- Custom test framework (`test_runner.sh`, `enhanced_test_runner.sh`) retired once bats covers critical paths

## Neovim Tiers

**Two tiers:**
- Essential (~12 plugins): current Tier 1 + lualine + bufferline + gitsigns
- Full (~30 plugins): current Tier 2 + Tier 3 merged
- AI plugins loaded via feature flags, not tier gating
