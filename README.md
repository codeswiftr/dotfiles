# Modern Dotfiles — Cross-Platform Development Environment

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-1f425f.svg)](https://www.zsh.org/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20WSL-blue.svg)](#platform-support)

A declarative, modular dotfiles system built for developers who work across multiple machines. Installs reproducibly, degrades gracefully on SSH sessions, and scales from a minimal server setup to a full AI-assisted development environment.

**[Quick Start](#quick-start)** · **[What's Included](#whats-included)** · **[Configuration](#configuration)** · **[Documentation](#documentation)**

---

## Key Features

- **Declarative install**: all tools defined in `config/tools.yaml` — add a tool once, installs everywhere
- **Profile-based**: `minimal` for servers, `standard` for daily use, `full` for power users
- **SSH-aware**: heavy tools skip on SSH sessions; shell stays fast everywhere
- **mise-powered**: all runtimes and CLI tools version-pinned in `mise.toml`
- **Tiered Neovim**: ~17 → ~30 plugins, promoted with `:TierUp`
- **Modern CLI**: starship, eza, bat, ripgrep, fzf, atuin, zoxide — all optional with fallbacks

## Quick Start

> **Step 0 — Fork first.** Click **Fork** on GitHub, then replace `YOUR_USERNAME` below with your GitHub handle.
> After cloning, copy `.env.local.example` → `~/.env.local` and fill in your API keys.
> See [PERSONALIZATION.md](PERSONALIZATION.md) for the full checklist.

### One-line install

```bash
# Fork this repo first, then:
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh install standard
```

Or use the bootstrap script (fetches and runs the installer):

```bash
export DOTFILES_REPO_URL="https://github.com/YOUR_USERNAME/dotfiles.git"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/bootstrap.sh)"
```

### Installation profiles

| Profile | Description | Good for |
|---------|-------------|----------|
| `minimal` | Symlinks only (zsh, tmux, nvim, git) | Servers, containers |
| `standard` | + Modern CLI tools (starship, eza, bat, fzf, atuin) | Most developers |
| `full` | + AI tools, security scanners, optional extras | Power users |
| `ai_focused` | + AI coding agents (claude, aider, opencode) | AI-assisted dev |

```bash
./install.sh install minimal      # Bare essentials
./install.sh install standard     # Recommended default
./install.sh install full
./install.sh --dry-run install standard   # Preview without changes
```

### Platform support

| Platform | Status | Package manager |
|----------|--------|----------------|
| macOS (Apple Silicon / Intel) | Full | Homebrew |
| Ubuntu / Debian | Full | apt |
| Arch Linux | Full | pacman |
| Alpine Linux | Core tools | apk |
| WSL2 | Full | apt |

## What's Included

### Shell (Zsh)

- Modular config in `config/zsh/` — each file is a separate concern
- SSH-aware: loads `tools-minimal.zsh` on remote sessions, `tools-optimized.zsh` locally
- Per-node config auto-loaded based on hostname: `config/zsh/<hostname>.zsh`
- Fish-like autosuggestions via `history-enhanced.zsh`
- Background update check — notifies if dotfiles are behind `origin/main`

### Modern CLI replacements

```
starship    → cross-shell prompt
zoxide      → smarter cd (z command)
eza         → ls with icons and git status
bat         → cat with syntax highlighting
ripgrep     → fast grep replacement
fd          → fast find replacement
fzf         → fuzzy finder
atuin       → shell history with search
delta       → better git diffs
```

Human shells may alias common names like `cat` to these tools. Native escape
hatches such as `_cat`, `_grep`, `_find`, `_ls`, and `_tmux` are always
available. Agent shells should use `DOTFILES_MODE=agent`; see
[docs/agents.md](docs/agents.md).

### Tmux

- Prefix: `Ctrl-a`
- ~25 essential bindings (hjkl navigation, `|`/`-` splits, `Tab` last window)
- Per-node status bar accent color (defined in `tmux.conf`)
- SSH indicator: status bar moves to top with red `SSH` label on remote sessions
- F12 to toggle key passthrough for nested sessions
- Plugins: `tmux-resurrect` + `tmux-continuum` (auto-save every 15 min)

### Neovim (tier-based)

| Tier | Plugins | Startup | Features |
|------|---------|---------|----------|
| 1 | ~17 | <250ms | LSP, file tree, treesitter, catppuccin |
| 2 | ~30 | <600ms | + Telescope, DAP, AI assist, git signs, Noice, mini suite |

Promote with `:TierUp`, demote with `:TierDown`, check with `:TierInfo`.

Auto-detects tier from `$NVIM_TIER` env var or system resources (RAM + cores).

### AI development tools

```bash
# Aliases defined in config/agents/agents.zsh
c       → claude (Claude Code)
cu      → cursor
aa      → aider
oc      → opencode
```

See `config/agents/agents.zsh` for AI workflow functions (`ai-review`, `ai-doc`, `ai-explain`).

### `dot` CLI

The `bin/dot` CLI is the main interface:

```bash
dot setup          # Idempotent environment setup (safe to re-run)
dot check          # System health check
dot update         # Pull latest dotfiles and re-link
dot reload         # Reload shell config
```

## Configuration

### Personalize

1. **Identity**: set git name/email via `~/.gitconfig.local` (not tracked):
   ```ini
   [user]
       name = Your Name
       email = you@example.com
   ```

2. **Secrets and machine-local overrides**: copy `.env.local.example` → `~/.env.local`:
   ```bash
   cp .env.local.example ~/.env.local
   # then edit ~/.env.local — it's gitignored
   ```

3. **Node-specific config**: create `config/zsh/<your-hostname>.zsh` for machine-specific aliases, paths, and tools. See `config/zsh/examples/` for templates.

4. **Tool versions**: edit `mise.toml` to pin your preferred versions.

5. **Install profile**: edit `config/tools.yaml` or pass `--profile` to `install.sh`.

### Adding tools

Edit `config/tools.yaml`:
```yaml
tools:
  my_group:
    my_tool:
      description: "My tool"
      macos: "brew install my-tool"
      ubuntu: "apt-get install -y my-tool"
      verify: "my-tool --version"
```

Then re-run `./install.sh install standard` (idempotent, only installs missing tools).

### Multi-machine fleet

If you have multiple machines on a shared network (Tailscale recommended):

1. Create `config/zsh/<hostname>.zsh` for each node
2. Optionally copy `config/zsh/examples/fleet-dashboard.zsh` and adapt
3. Set `DOTFILES_FLEET_NODES` in `~/.env.local`

See `config/zsh/examples/README.md` for the full fleet setup guide.

## Architecture

```
dotfiles/
├── bin/                  # dot CLI and utilities
├── config/
│   ├── zsh/              # Modular zsh config (sourced by .zshrc)
│   │   └── examples/     # Node-specific templates (not loaded automatically)
│   ├── agents/           # AI agent aliases and per-node config
│   ├── nvim/             # Neovim tier-based config
│   ├── tmux/             # Tmux config
│   ├── claude/           # Claude Code integration (commands, skills, agents)
│   └── tools.yaml        # Declarative tool definitions
├── lib/                  # Shell libraries used by dot CLI
├── scripts/              # Install, health-check, bootstrap utilities
├── tests/                # Test suite
├── mise.toml             # Version-pinned tool manifest
└── install.sh            # Main installer
```

## Security

- Secrets in `~/.env.local` (gitignored, never committed)
- Global git hooks via `hooks/` → `~/.config/git/hooks` (chezmoi)
- GPG signing configured via `dot security setup-gpg`
- Secret scanning with gitleaks and trufflehog (in `full` profile)

```bash
# Setup GPG signing
dot security setup-gpg

# Setup SSH key
dot security setup-ssh
```

## Testing

```bash
bats tests/bats/*.bats              # Full test suite
bats tests/bats/smoke.bats          # Smoke tests only
find . -name "*.sh" | xargs shellcheck -S warning
```

## Documentation

| Guide | Purpose |
|-------|---------|
| [Personalization](PERSONALIZATION.md) | **Start here** — fork setup, API keys, profiles |
| [Installation](docs/INSTALL-DECLARATIVE.md) | Detailed install instructions |
| [Configuration](docs/configuration.md) | All configuration options |
| [Neovim](docs/neovim.md) | Neovim tier system |
| [Tmux](docs/tmux-quick-reference.md) | Tmux keybindings reference |
| [AI Workflows](docs/ai-workflows.md) | AI tool integration |
| [Git Hooks](docs/git-hooks.md) | Pre-commit hook setup |
| [Security](docs/security.md) | GPG, SSH, secret management |
| [Troubleshooting](docs/troubleshooting.md) | Common issues |
| [Performance](docs/performance.md) | Shell startup optimization |

## Contributing

1. Fork and clone
2. Make changes (run `shellcheck` on any shell scripts you edit)
3. Test: `bats tests/bats/*.bats`
4. Open a PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT — see [LICENSE](LICENSE).
