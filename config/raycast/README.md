# Raycast Script Commands + global hotkeys

Tracked under `config/raycast/scripts/`, linked to `~/raycast-scripts` via chezmoi.

## Global hotkeys (automatic via skhd)

| Shortcut | Action |
|----------|--------|
| `⌥⌘U` | Switch monitor → USB-C (DDC 27) |
| `⌥⌘H` | Switch monitor → HDMI (DDC 17) |

Config: `config/skhd/skhdrc` → `~/.skhdrc`. See [config/skhd/README.md](../skhd/README.md).

Raycast’s own hotkeys can’t be set from dotfiles (encrypted DB). Karabiner needs
a sudo installer — skhd is the path that applies cleanly from brew + chezmoi.

## One-time Raycast setup (search / optional)

1. `brew install m1ddc koekeishiya/formulae/skhd`
2. `chezmoi --source ~/dotfiles/home apply && skhd --start-service`
3. Enable **skhd** under System Settings → Privacy & Security → Accessibility
4. Optional: Raycast → Script Commands → Add Script Directory → `~/raycast-scripts`

## Scripts

| File | DDC input | Typical port |
|------|-----------|--------------|
| `switch-monitor-usb-c.sh` | 27 | USB-C |
| `switch-monitor-hdmi.sh` | 17 | HDMI |

If your panel uses different codes: `m1ddc display 1 get input` while on each source.
