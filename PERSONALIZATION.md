# Personalization Guide

This file explains what to customize after forking and cloning these dotfiles.

## 1. Git identity

On first `./setup`, chezmoi prompts for your git name/email and stores them in
`~/.config/chezmoi/chezmoi.toml` (outside the repo). Headless installs take the
defaults silently; pre-seed them with env vars or an existing global git config:

```bash
GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./setup --headless
# later: chezmoi init --source ~/dotfiles/home --prompt   # re-ask
```

If neither is set, `~/.gitconfig` is written without a `[user]` block. Anything
else machine-specific goes in `~/.gitconfig.local` (gitignored, auto-included):

```ini
[github]
    user = your-github-username
```

## 2. Secrets and machine-local config

Copy `.env.local.example` to `~/.env.local` and fill in your values:

```bash
cp .env.local.example ~/.env.local
$EDITOR ~/.env.local
```

This file is gitignored. It's sourced by `.zshrc` at startup.

## 3. Raycast display scripts (macOS)

`~/raycast-scripts` → `config/raycast/scripts/` (m1ddc input switchers).
Global defaults **`⌥⌘U`** / **`⌥⌘H`** via **skhd** (`config/skhd/skhdrc`).
One-time: `skhd --start-service` and allow Accessibility. Details:
[config/skhd/README.md](config/skhd/README.md).

## 4. Node-specific shell config

If a machine needs host-local overrides, create `config/zsh/<hostname>.zsh`
(gitignored if it holds secrets). It is sourced automatically when present.

```bash
hostname -s   # e.g. nova
$EDITOR config/zsh/$(hostname -s).zsh
```

Keep it tiny: PATH tweaks, host aliases, machine-only env. Do not commit secrets.

## 5. Fleet / multi-machine

Fleet helpers are on probation (`config/profiles/fleet/`). Prefer Tailscale +
Herdr + `DOTFILES_MODE` over bespoke dashboards. Set host lists in `~/.env.local`
only if you still maintain a private fleet snippet outside this repo.

## 6. Bootstrap URL

This repo’s default one-liner already points at `codeswiftr/dotfiles`:

```bash
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/main/scripts/bootstrap.sh | bash
```

For a fork, override the URL:

```bash
export DOTFILES_REPO_URL="https://github.com/<you>/dotfiles.git"
curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/scripts/bootstrap.sh | bash
```

Or clone and run `./setup` (same as `./install.sh install standard`).

## 7. Tool versions

Edit `mise.toml` to pin your preferred tool versions:

```toml
[tools]
node = "22"
python = "3.12"
# ... add/remove tools
```

## 8. Install profile

The default install profile is `standard`. Pass another explicitly:

```bash
./setup                     # standard (default)
./setup minimal
```

## 9. Herdr

Config lives at `config/herdr/config.toml` (prefix `Ctrl-a`). Daily aliases: `hw`, `ha`, `hl`.

## 10. Neovim tier

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
- FORGE operator shell: lives in forge-mono (`shell/forge.zsh`); remove
  `config/zsh/forge.zsh` loader if you never use that tree
- Host-local `config/zsh/<hostname>.zsh` files before publishing