# Modern Dotfiles — Cross-Platform Development Environment

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-1f425f.svg)](https://www.zsh.org/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20WSL-blue.svg)](#platform-support)

Declarative, modular dotfiles for macOS and Linux. One install path, Herdr workspaces, mise-pinned CLIs, agent-safe shell modes.

**[Install](#install)** · **[Daily commands](#daily-commands)** · **[Docs](docs/README.md)** · **[Agents](AGENTS.md)**

---

## Install

### One command (remember this)

```bash
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/main/scripts/bootstrap.sh | bash
```

That clones into `~/dotfiles`, installs the **standard** profile (zsh, Herdr, Mosh, Tailscale, mise CLIs, links), and finishes. Open a new shell when it completes.

### Already cloned

```bash
cd ~/dotfiles && ./setup
```

Same as `./install.sh` / `./install.sh install standard`. Other profile: `./setup minimal`.

### Fork of this repo

```bash
export DOTFILES_REPO_URL="https://github.com/<you>/dotfiles.git"
curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/scripts/bootstrap.sh | bash
```

Then copy `.env.local.example` → `~/.env.local`. See [PERSONALIZATION.md](PERSONALIZATION.md).

### Profiles

| Profile | Good for |
|---------|----------|
| `minimal` | Servers — zsh, git, nvim, Herdr, chezmoi |
| `standard` | **Default** — modern CLIs, Tailscale, Mosh, daily AI agents |

### Platform support

| Platform | Package manager |
|----------|-----------------|
| macOS | Homebrew |
| Ubuntu / Debian / WSL2 | apt |
| Arch | pacman |
| Alpine | apk (core) |

---

## Daily commands

```bash
just check          # health
just smoke          # fast bats
just update --self  # pull + relink
ha / hw / hl        # Herdr attach / workspaces / agents
ai                  # default coding agent (claude)
```

Phone: Tailscale + [Moshi](https://getmoshi.app/) (connection **Auto**). Mosh is installed by `standard`.

---

## What's included

- **Shell**: modular `config/zsh/` · `DOTFILES_MODE=full|minimal|agent`
- **Herdr**: multiplexer (prefix `Ctrl-a`) · config in `config/herdr/`
- **mise**: version-pinned CLIs in `mise.toml`
- **Neovim**: 2 tiers (`:TierUp` / `:TierDown`)
- **just**: `setup` `check` `update` `reload` `smoke` `test` `link`

Layout SSOT: [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Documentation

| Doc | For |
|-----|-----|
| [AGENTS.md](AGENTS.md) | Agent entry + conventions |
| [docs/README.md](docs/README.md) | Doc hub |
| [docs/getting-started.md](docs/getting-started.md) | First hour |
| [docs/agents.md](docs/agents.md) | Agent-safe shell, Moshi |
| [docs/troubleshooting.md](docs/troubleshooting.md) | Common fixes |
| [CONTRIBUTING.md](CONTRIBUTING.md) | PRs / quality gates |

```bash
just smoke && just check
```
