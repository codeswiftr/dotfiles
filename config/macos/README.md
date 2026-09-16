# macOS display input switching

One module: DDC switch via `m1ddc`, global hotkeys via `skhd`, optional Raycast search.

| Shortcut | Action |
|----------|--------|
| `⌥⌘U` | USB-C |
| `⌥⌘H` | HDMI |
| `⌥⌘I` | Toggle between them |

## Layout

| Path | Role |
|------|------|
| `scripts/switch-display.sh` | Single implementation (`usb-c` \| `hdmi` \| `toggle`) |
| `scripts/switch-monitor-*.sh` | Thin Raycast Script Command wrappers |
| `skhdrc` | Global hotkeys → `~/.skhdrc` |
| `~/raycast-scripts` | Chezmoi symlink to `scripts/` |

## Setup (once)

```bash
brew bundle --file=~/dotfiles/config/platform/Brewfile   # m1ddc, raycast, skhd
chezmoi --source ~/dotfiles/home apply
skhd --start-service
# System Settings → Privacy & Security → Accessibility → enable skhd
```

Optional: Raycast → Script Commands → Add Script Directory → `~/raycast-scripts`.

## Tweaks

- Other display: `export M1DDC_DISPLAY=2` in `~/.env.local`
- Other DDC codes: edit `switch-display.sh` (probe with `m1ddc display 1 get input`)
- Reload hotkeys after edits: `skhd --reload`
