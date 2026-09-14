# Getting started

After install, verify and learn the daily loop.

## Install reminder

```bash
# Fresh machine (one command)
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/main/scripts/bootstrap.sh | bash

# Or after clone
cd ~/dotfiles && ./setup          # same as ./install.sh
```

Open a **new shell** when it finishes.

## Verify

```bash
which zsh starship nvim herdr mosh-server
just check          # or: just check
just smoke
```

## Daily loop

```bash
ha                  # attach Herdr (or: herdr)
hw                  # workspaces
hl                  # agents
nvim                # <Space>? for discovery
ai                  # default coding agent
just update --self   # pull + relink on other machines
```

**Herdr prefix:** `Ctrl-a` (see shortcut table below).  
**Phone:** Tailscale + [Moshi](https://getmoshi.app/) connection type **Auto**. Details: [agents.md](agents.md).

## Agent mode

```bash
DOTFILES_MODE=agent zsh
agent-doctor
_claude             # wrapper forces agent mode
```

See [agents.md](agents.md) for `_cat` / `_herdr` escape hatches.

## Shortcuts

### Shell

| Shortcut | Action |
|----------|--------|
| Ctrl-T | fzf files |
| Ctrl-R | fzf history |
| Alt-C | fzf directories |

### Herdr (Prefix: Ctrl-A)

| Shortcut | Action |
|----------|--------|
| Prefix + c / n | New tab |
| Prefix + 1-9 | Switch tab |
| Prefix + Shift+1-9 | Switch workspace |
| Prefix + h/j/k/l | Panes |
| Prefix + Shift+h/j/k/l | Resize |
| Prefix + z | Zoom |
| Prefix + s / w | Workspace picker |
| Prefix + d / q | Detach |

### Neovim

| Shortcut | Action |
|----------|--------|
| `<Space>?` | Command discovery |
| `:TierUp` / `:TierDown` | Plugin tiers |
| `<C-p>` | Find files |

## Personalize

1. `cp .env.local.example ~/.env.local` — API keys  
2. `config/zsh/$(hostname -s).zsh` — machine overrides ([PERSONALIZATION.md](../PERSONALIZATION.md))  
3. `mise.toml` — pin tool versions  

## Help

| Problem | Doc |
|---------|-----|
| Install / links | [troubleshooting.md](troubleshooting.md) |
| Agents / Moshi | [agents.md](agents.md) |
| Layout | [ARCHITECTURE.md](../ARCHITECTURE.md) |
| Debt / cleanup | [technical-debt.md](technical-debt.md) |
