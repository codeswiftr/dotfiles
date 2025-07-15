# 🔧 Troubleshooting Guide

## 🔄 Legacy Config Migration
- Migrating from older Neovim/tmux configs? See [Technical Debt & Migration](technical-debt.md) for migration plans and steps.
- If you encounter legacy config issues, please open an issue or PR and help document solutions!

## ⚡ Opt-in Features (Tmux Mouse Mode)
- Tmux mouse mode is now opt-in for pure keyboard workflows.
- To enable mouse mode: add `set -g mouse on` to your tmux config.
- To disable: remove/comment that line.
- See [Technical Debt & Migration](technical-debt.md) for more details and ongoing improvements.

Comprehensive guide to resolving common issues with the dotfiles environment.

## ❓ Frequently Asked Questions (FAQ)

**Q: Installation failed or tools missing?**
- Run `dot check` and `dot doctor` for diagnostics.
- See [Getting Started Guide](getting-started.md) for step-by-step install help.

**Q: Keyboard shortcuts not working (international layout)?**
- All shortcuts are designed for US, UK, and most EU layouts.
- For non-standard layouts, remap keys using Karabiner-Elements (macOS) or xmodmap (Linux).
- See [Navigation Guide](navigation.md#internationalization).

**Q: How do I use agentic workflows (Gemini CLI, AI commit, etc.)?**
- See [AI Workflows](ai-workflows.md) for setup and troubleshooting.
- Always run `gemini review --diff` before committing for best results.

**Q: Shell/terminal is slow or laggy?**
- Enable fast mode: `export DOTFILES_FAST_MODE=true; exec zsh`
- Profile startup: `perf-benchmark-startup`
- See "Slow Shell Startup" below.

**Q: How do I contribute or get help?**
- See [CONTRIBUTING.md](../CONTRIBUTING.md) and [docs/README.md](README.md).
- Friendly support: open an issue, join discussions, or check docs/ below.

## 🖥️ Platform Quirks, Accessibility & Internationalization

- **Accessibility Feedback:** If you use a non-standard keyboard layout or require accessibility features, please open an issue or PR with your feedback! We want to make this setup as inclusive as possible.
- **macOS:** Use Karabiner-Elements for custom keybindings. Check System Preferences > Keyboard for layout issues.
- **Linux:** Use xmodmap or your desktop environment's keyboard settings for remapping.
- **Remapping Example (macOS):**
  - Use Karabiner-Elements to remap Caps Lock to Ctrl, or remap other keys for easier tmux/Neovim navigation.
- **Remapping Example (Linux):**
  - Use `xmodmap -e 'keycode 66 = Control_L'` to remap Caps Lock to Ctrl.
- **High-Contrast Themes:**
  - Enable high-contrast mode in your terminal, and use the Catppuccin Latte or Macchiato themes for better visibility. See [Theme Guide](themes.md).
- **International Keyboards:** If a shortcut doesn't work, remap in your terminal emulator or OS settings. See [Navigation Guide](navigation.md#internationalization).
- **Terminal True Color:** For best theme support, ensure `$TERM` is `screen-256color` or similar.

## 🤖 Agentic Workflow Troubleshooting

- **Gemini CLI:**
  - Run `gemini quota status` and `gemini auth status` to check setup.
  - See "Gemini CLI Issues" below for more.
- **AI Commit/Review:**
  - If commit message generation fails, check security mode (`ai-security-status`) and staged changes.
  - See [AI Workflows](ai-workflows.md#troubleshooting).

---

## 🚨 Quick Diagnostics

```bash
# Run comprehensive system check
dot check

# Quick health assessment
dot doctor

# Performance diagnostics
perf-status

# Check specific components
tmux-diagnostic
nvim-diagnostic
zsh-diagnostic
```

... (rest of the original troubleshooting guide follows unchanged) ...
