# macOS display input switching

DDC via `m1ddc`, global hotkeys via `skhd`.

| Shortcut | Action |
|----------|--------|
| `⌥⌘U` | USB-C |
| `⌥⌘H` | HDMI |
| `⌥⌘I` | Toggle |

| Path | Role |
|------|------|
| `scripts/switch-display.sh` | `usb-c` \| `hdmi` \| `toggle` |
| `skhdrc` | → `~/.skhdrc` |
| (tree) | → `~/.config/macos` |

## Setup (once per Mac)

```bash
brew bundle --file=~/dotfiles/config/platform/Brewfile
chezmoi --source ~/dotfiles/home apply
skhd --start-service   # also run by ./install.sh on macOS
```

Then: **System Settings → Privacy & Security → Accessibility → enable skhd**.

## Tweaks

- Other display: `M1DDC_DISPLAY=2` in `~/.env.local`
- Probe codes: `m1ddc display 1 get input`
- Reload after edits: `skhd --reload`
- CLI: `just display usb-c|hdmi|toggle`
