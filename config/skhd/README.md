# Global hotkeys for monitor scripts (skhd)

Raycast cannot provision hotkeys from disk (encrypted prefs).
Karabiner-Elements needs a privileged installer (sudo).

**skhd** is the automatable path: a small hotkey daemon, brew formula, no pkg.

| Shortcut | Action |
|----------|--------|
| `⌥⌘U` | Switch monitor → USB-C |
| `⌥⌘H` | Switch monitor → HDMI |

## Enable (once per Mac)

```bash
brew install koekeishiya/formulae/skhd
chezmoi --source ~/dotfiles/home apply
skhd --start-service
```

Then: **System Settings → Privacy & Security → Accessibility** → enable **skhd**.

(First keypress may trigger the permission prompt.)

Logs: `/tmp/skhd_$USER.err.log`

## Config

`~/.skhdrc` → `config/skhd/skhdrc`. Edit keys there, then:

```bash
skhd --reload
```
