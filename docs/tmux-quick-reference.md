# 🚀 Tmux Quick Reference - Streamlined Edition

## 🎯 Essential Commands (Tier 1) - Learn These First

| Command | Action | Memory Aid |
|---------|--------|------------|
| `Ctrl-a \|` | Split horizontal | **\|** looks like a vertical line |
| `Ctrl-a -` | Split vertical | **-** looks like a horizontal line |
| `Ctrl-a h/j/k/l` | Navigate panes | **Vim navigation** (left/down/up/right) |
| `Ctrl-a c` | New window | **c**reate window |
| `Ctrl-a x` | Close pane | e**x**it pane |
| `Ctrl-a d` | Detach session | **d**etach from tmux |
| `Ctrl-a s` | Session picker | **s**ession list |
| `Ctrl-a r` | Reload config | **r**eload settings |
| `Ctrl-a ?` | Help menu | **?** = help in most programs |

### Titles
| Command | Action |
|---------|--------|
| auto    | Terminal tab shows `session:window` |
| `,`     | Rename current window (updates title) |

**⏱️ Learning Goal**: Master these 9 commands in 15 minutes!

---

## 🔧 Intermediate Commands (Tier 2) - When Ready for More

### Pane Management
| Command | Action |
|---------|--------|
| `Ctrl-a z` | Zoom/unzoom current pane |
| `Ctrl-a Space` | Cycle through layouts |
| `Ctrl-a !` | Break pane to new window |
| `Ctrl-a H/J/K/L` | Resize panes (repeatable) |

### Copy & Paste
| Command | Action |
|---------|--------|
| `Ctrl-a [` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `y` | Copy selection and exit |
| `Ctrl-a ]` | Paste |

### Window Navigation
| Command | Action |
|---------|--------|
| `Ctrl-a Tab` | Switch to last window |
| `Ctrl-a ,` | Rename current window |
| `Ctrl-a w` | Window picker |

---

---

## 🖱️ Mouse Support

| Action | Result |
|--------|--------|
| **Click pane** | Switch to pane |
| **Drag text** | Select and copy |
| **Double-click** | Select word |
| **Triple-click** | Select line |
| **Scroll** | Navigate history |

---

## 🎓 Learning Path

### Getting Started
- Master the 25 keybindings in `config/tmux/tmux.conf`
- Practice pane navigation with `h/j/k/l`
- Use mouse for quick tasks
- Learn copy/paste workflow

---

## 🚨 Emergency Commands

| Situation | Solution |
|-----------|----------|
| **Tmux frozen** | `Ctrl-a d` (detach) then `tmux attach` |
| **Wrong command** | `Ctrl-c` to cancel |
| **Lost in copy mode** | `Escape` to exit |
| **Pane too small** | `Ctrl-a z` to zoom |
| **Forgot shortcuts** | `Ctrl-a ?` for help |

---

---

## 📊 Performance Comparison

### Before (Complex Config):
- ❌ **66 key bindings** to remember
- ❌ **393 lines** of configuration
- ❌ **No discovery system**
- ❌ **Overwhelming for beginners**

### After (Streamlined Config):
- ✅ **9 essential commands** to start
- ✅ **Progressive complexity** (9 → 24 → 44)
- ✅ **Built-in help system**
- ✅ **Visual feedback**
- ✅ **15-minute learning curve**

---

## 🎯 Pro Tips

1. **Start Small**: Don't enable all tiers at once
2. **Use Help**: `Ctrl-a ?` is your friend
3. **Practice Daily**: Muscle memory takes time
4. **Customize**: Create `~/.tmux.local.conf` for personal shortcuts
5. **Share**: Teach others the essential commands

---

**Remember**: The goal is productivity, not complexity. Master the essentials first! 🚀