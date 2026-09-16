# Raycast Script Commands + global hotkeys

Tracked under `config/raycast/scripts/`, linked to `~/raycast-scripts` via chezmoi.

## Global hotkeys (automatic)

Raycast stores hotkeys in an encrypted DB — they **cannot** be set from
dotfiles. Defaults are applied via **Karabiner-Elements** instead:

| Shortcut | Action |
|----------|--------|
| `⌥⌘U` | Switch monitor → USB-C (DDC 27) |
| `⌥⌘H` | Switch monitor → HDMI (DDC 17) |

On `chezmoi apply`, the rule in
`config/karabiner/complex_modifications/monitor-input.json` is linked into
`~/.config/karabiner/assets/...` and enabled in `karabiner.json`.

Requires Karabiner running (Input Monitoring allowed). Change the keys by
editing that JSON and re-applying.

Optional: you can still assign Raycast hotkeys manually (`⌘K` → Configure
Command) if you prefer Raycast to own the binding.

## One-time Raycast setup (search / optional hotkeys)

1. `brew install m1ddc` (and Raycast / Karabiner if needed).
2. `chezmoi --source ~/dotfiles/home apply`
3. Raycast → **Settings → Extensions → Script Commands → Add Script Directory**
   → `~/raycast-scripts`

## Scripts

| File | DDC input | Typical port |
|------|-----------|--------------|
| `switch-monitor-usb-c.sh` | 27 | USB-C |
| `switch-monitor-hdmi.sh` | 17 | HDMI |

If your panel uses different codes: `m1ddc display 1 get input` while on each source.
