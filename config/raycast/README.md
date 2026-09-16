# Raycast Script Commands

Tracked under `config/raycast/scripts/`, linked to `~/raycast-scripts` via chezmoi.

## One-time Raycast setup

1. Install deps: `brew install m1ddc` (and Raycast if needed).
2. Apply links: `chezmoi --source ~/dotfiles/home apply`
3. Raycast → **Settings → Extensions → Script Commands → Add Script Directory**
   → pick `~/raycast-scripts`
4. Assign global hotkeys (works even when Raycast isn’t focused):
   - Open Raycast, find **Switch Monitor → USB-C**
   - `⌘K` → **Configure Command** → **Record Hotkey**
   - Repeat for HDMI

Suggested hotkeys (pick anything free): `⌥⌘U` (USB-C), `⌥⌘H` (HDMI).

Manage all hotkeys later: Raycast **Settings → Shortcuts**.

## Scripts

| File | DDC input | Typical port |
|------|-----------|--------------|
| `switch-monitor-usb-c.sh` | 27 | USB-C |
| `switch-monitor-hdmi.sh` | 17 | HDMI |

If your panel uses different codes: `m1ddc display 1 get input` while on each source.
