# Architecture Decisions

Decided: 2026-04-22

## Canonical File Layout

All configuration source-of-truth lives in `config/`. Root-level `.zshrc` is a thin loader that sources `config/zsh`.

### Managed File Manifest

| Source (in repo) | Target (on machine) | Type |
|---|---|---|
| `.zshrc` | `~/.zshrc` | Loader → sources `config/zsh/*.zsh` |
| `config/zsh/.zshenv` | `~/.zshenv` | Symlink |
| `config/zsh/.zprofile` | `~/.zprofile` | Symlink |
| `config/nvim/` | `~/.config/nvim` | Symlink (directory) |
| `config/starship.toml` | `~/.config/starship.toml` | Symlink |
| `completions/_herdr` | `~/.local/share/zsh/completions/_herdr` | Symlink |
| `hooks/` | `~/.config/git/hooks` | Symlink (directory) — single hooks tree (no `git/hooks/`) |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Symlink (repo-root agent notes) |
| `config/claude/{agents,commands,skills,output-styles,WORKFLOW_GUIDE.md,starship-statusline.sh}` | `~/.claude/{...}` | Symlinks via chezmoi `home/private_dot_claude/` |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Symlink via chezmoi `home/dot_config/herdr/` (file only) |

### Not Managed (machine-local)

| Path | Managed by |
|---|---|
| `~/.local/bin/*` | mise, uv, brew — NOT linked from repo `bin/` |
| `~/.gitconfig` | Generated from `config/gitconfig` template during install |
| `~/.claude/settings.json` | Claude Code owns this; template applied once if missing |
| `~/.config/herdr/{session.json,*.sock,*.log}` | Herdr runtime — never symlink the whole directory |

### `bin/` Policy

`bin/` contains **only repo-owned scripts**:
- `ai` — AI tool launcher
- `cursor` — PATH shim (skips `~/.local/bin/cursor`, finds real Cursor IDE)
- `_agent` and `_claude` / `_codex` / … — agent launch wrappers
- `setup` (repo root) — memorable `./setup` → `install.sh install standard`

Task interface is **`just`** (`check`, `update`, `reload`, `smoke`, `test`). There is no `bin/dot`.

All other executables (tool binaries, uv entrypoints) are managed by package managers (mise, uv, brew) and live in **`~/.local/bin/`** (a real directory), mise shims, or Homebrew paths. They are NOT tracked in git.

**Never** make `~/.local/bin` a symlink to this repo’s `bin/`. That dumps tool installs into the git tree.

`bin/` is on `$PATH` via `config/zsh/defaults.zsh` (after `~/.local/bin`).

## Linking Strategy

**Primary:** chezmoi (`home/` directory). Required — `install.sh` has no fallback linker.

chezmoi manages:
- Symlinks: .zshrc, .zshenv, .zprofile, nvim, starship.toml, herdr, hooks, completions
- Templates: .gitconfig (with machine-specific name/email/credential helper)
- Scripts: run_onchange for git hooksPath configuration

**Machine-specific config:** `~/.config/chezmoi/chezmoi.toml` stores name, email (set on first init via prompts or pre-created).

## Tool Management

| Source | Owns |
|--------|------|
| **`mise.toml`** | Version-pinned CLIs + runtimes (rg, bat, fd, fzf, starship, zoxide, atuin, delta, jq, yq, gh, security scanners, node, python, …). |
| **`config/platform/Brewfile`** | macOS platform packages + AI casks — no mise-owned CLI duplicates |
| **`config/platform/apt.txt` / `pacman.txt`** | Linux platform packages |
| **`scripts/install-*.sh`** | Cross-OS helpers (herdr, mosh) |
| **uv / npm / brew** | Language tools and casks not covered by mise |

**State tracking:** `~/.dotfiles-state/` tracks only:
- Which post-install hooks have run (avoid re-running chsh, usermod, etc.)
- Last successful install timestamp

No custom `versions.json`. Package managers already know what's installed.

## Shell Modes

**Primary knob:** `DOTFILES_MODE=full|minimal|agent`
- Auto when unset: SSH → `minimal`, else `full`
- `FORGE_AGENT_TYPE` / `CI` force `agent` → `DOTFILES_AGENT_SAFE=1`
- Tools file: `full` → `tools-optimized.zsh`; `minimal`/`agent` → `tools-minimal.zsh`
- Modern aliases only in `aliases.zsh` (tools modules are init-only)
- Override in the environment or `~/.zshrc.local`
- Optional fleet: `config/profiles/fleet/` when `DOTFILES_PROFILE=fleet` or `.enabled` marker

## Testing

**Framework:** bats-core.
- `tests/bats/smoke.bats` — CLI, install, shell syntax, agent-safe, bin hygiene
- `tests/bats/infrastructure.bats` — paths, contracts, bindings, tiers, performance
- Run: `bats tests/bats/*.bats` or `just test`

## Neovim Tiers

**Two tiers:**
- Essential (~12 plugins): current Tier 1 + lualine + bufferline + gitsigns
- Full (~30 plugins): current Tier 2 + Tier 3 merged
- AI plugins loaded via feature flags, not tier gating
