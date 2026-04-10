# Personalization Guide

This file explains what to customize after forking and cloning these dotfiles.

## 1. Git identity

Create `~/.gitconfig.local` (gitignored, never committed):

```ini
[user]
    name = Your Name
    email = you@example.com

[github]
    user = your-github-username
```

The main `config/gitconfig` includes this file automatically via `[include]`.

## 2. Secrets and machine-local config

Copy `.env.local.example` to `~/.env.local` and fill in your values:

```bash
cp .env.local.example ~/.env.local
$EDITOR ~/.env.local
```

This file is gitignored. It's sourced by `.zshrc` at startup.

## 3. Node-specific shell config

If you have a machine with a specific hostname, create
`config/zsh/<hostname>.zsh` — it will be sourced automatically.

See `config/zsh/examples/` for templates:

| Template | Use when |
|----------|---------|
| `node-macos-template.zsh` | macOS workstation |
| `node-linux-template.zsh` | Linux server or workstation |

```bash
# Copy the right template for your machine
cp config/zsh/examples/node-macos-template.zsh config/zsh/$(hostname -s).zsh
# Edit it
$EDITOR config/zsh/$(hostname -s).zsh
```

## 4. Fleet setup (multi-machine)

If you run multiple machines connected via Tailscale:

1. Copy `config/zsh/examples/fleet-dashboard.zsh` → `config/zsh/fleet-dashboard.zsh`
2. Edit the node list and roles at the top of the file
3. Copy `config/zsh/examples/task-router.zsh` if you want automatic task routing
4. Set `DOTFILES_FLEET_NODES` in `~/.env.local`

## 5. Bootstrap URL

If you want the one-liner install to point to your fork, set `DOTFILES_REPO_URL`:

```bash
export DOTFILES_REPO_URL="https://github.com/YOUR_USERNAME/dotfiles.git"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/bootstrap.sh)"
```

Or just clone manually — the bootstrap script is optional.

## 6. Tool versions

Edit `mise.toml` to pin your preferred tool versions:

```toml
[tools]
node = "22"
python = "3.12"
# ... add/remove tools
```

## 7. Install profile

The default install profile is `standard`. Change it in `config/tools.yaml`
under `profiles.default`, or pass it explicitly:

```bash
./install.sh install full        # all tools
./install.sh install minimal     # symlinks only
```

## 8. Tmux node accent color

In `config/tmux/tmux.conf`, add your hostname to get a unique status bar color:

```tmux
if-shell "echo '#H' | grep -qxE 'your-hostname'" \
    'set -g @node-accent "#a6e3a1"; set -g @node-accent-dim "#94b877"'
```

Colors follow the Catppuccin Mocha palette.

## 9. Neovim tier

Set your preferred Neovim startup tier (1-3) in `~/.env.local`:

```bash
export NVIM_TIER=2   # 1=minimal, 2=enhanced, 3=full
```

Or promote/demote interactively with `:TierUp` / `:TierDown`.

## What NOT to commit

- `~/.env.local` — secrets and machine-specific overrides
- `~/.gitconfig.local` — your personal git identity
- `config/zsh/<hostname>.zsh` if it contains private paths or tokens

If you use this as a public repo, also review:
- `config/zsh/examples/` — generalize or remove personal project references
- `docs/forge.md` — remove if not using the FORGE workflow
