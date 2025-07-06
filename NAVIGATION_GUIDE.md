# 🧭 Enhanced Navigation Guide

## Overview
This guide covers the enhanced multi-pane navigation features added to your Neovim configuration. These features make it easy to work with multiple files, splits, and panes efficiently.

## 🚀 Quick Start

### Basic Navigation
- **`<C-h/j/k/l>`** - Navigate between panes (works seamlessly with tmux)
- **`<leader>wp`** - Window picker (visual window selection)
- **`<leader>ww`** - Cycle through all windows
- **`<leader>wi`** - Show window information

### Window Management
- **`<leader>sv`** - Split vertically
- **`<leader>sh`** - Split horizontally  
- **`<leader>se`** - Equalize window sizes
- **`<leader>sc`** - Close current window
- **`<leader>so`** - Close all other windows

### Multi-Pane Layouts
- **`<leader>mh`** - 3 horizontal splits
- **`<leader>mv`** - 3 vertical splits
- **`<leader>mg`** - 2x2 grid layout
- **`<leader>mc`** - Coding layout (main + sidebar + terminal)

## 🛠️ Advanced Features

### Window Resizing
- **`<C-w>+/-`** - Resize height by 5 lines
- **`<C-w>></`** - Resize width by 5 columns
- **`<leader>rh/rH`** - Resize height by 10 lines
- **`<leader>rw/rW`** - Resize width by 10 columns

### Window Movement
- **`<leader>wr`** - Rotate windows right
- **`<leader>wR`** - Rotate windows left
- **`<leader>wx`** - Exchange current window with next
- **`<leader>wH/J/K/L`** - Move window to far left/bottom/top/right

### Buffer Management
- **`<Tab>/<S-Tab>`** - Next/Previous buffer
- **`<leader>bn/bp`** - Next/Previous buffer
- **`<leader>bd`** - Delete buffer
- **`<leader>bo`** - Close all buffers except current
- **`<leader>bc`** - Pick buffer to close (with bufferline)
- **`<leader>bpi`** - Pick buffer to navigate

### Tab Management
- **`<leader>tn`** - New tab
- **`<leader>tc`** - Close tab
- **`<leader>tr/tl`** - Next/Previous tab
- **`<leader>1-9`** - Go to tab 1-9

## 📱 Session Management

### Session Commands
- **`<leader>ss`** - Restore session
- **`<leader>sl`** - Restore last session
- **`<leader>sd`** - Stop session recording

### Auto-Session Features
- Sessions are automatically saved every 15 minutes
- Sessions restore window layouts and buffer states
- Sessions persist across Neovim restarts

## 🎯 Productivity Tips

### Efficient Workflows

1. **Code Review Layout**:
   ```
   <leader>mg  # Create 2x2 grid
   # Open different files in each pane
   ```

2. **Development Layout**:
   ```
   <leader>mc  # Coding layout
   # Main code + sidebar for files + terminal
   ```

3. **Multi-file Editing**:
   ```
   <leader>mh  # 3 horizontal splits
   # Edit related files simultaneously
   ```

### Navigation Patterns

1. **Visual Window Selection**:
   - Use `<leader>wp` when you have many windows
   - Each window gets a letter overlay for quick selection

2. **Buffer Switching**:
   - Use `<Tab>/<S-Tab>` for quick buffer cycling
   - Use `<leader>bb` for fuzzy buffer search

3. **Window Information**:
   - Use `<leader>wi` to see all windows and their contents
   - Helpful when you lose track of what's open

## 🔧 Integration with Tmux

### Seamless Navigation
- `<C-h/j/k/l>` works across Neovim panes AND tmux panes
- No need to think about whether you're in Neovim or tmux
- Navigation commands automatically detect the context

### Tmux Session Shortcuts
From your shell (`.zshrc`):
- **`ts/tl`** - List tmux sessions
- **`ta <session>`** - Attach to session
- **`tn <session>`** - New session
- **`tk <session>`** - Kill session
- **`tm`** - Smart tmux sessionizer

## 🎨 Visual Indicators

### Window Highlights
- Current window has cursor line/column highlighting
- Use `<leader>wf` to toggle focus indicators
- Window borders show active/inactive states

### Buffer Line
- Visual buffer tabs at the top
- Shows modified indicators
- Click to switch buffers
- Color-coded by file type

## 📋 Keyboard Shortcuts Reference

### Essential Navigation
| Shortcut | Action |
|----------|--------|
| `<C-h/j/k/l>` | Navigate panes |
| `<leader>wp` | Window picker |
| `<leader>ww` | Cycle windows |
| `<Tab>/<S-Tab>` | Next/Prev buffer |

### Window Management
| Shortcut | Action |
|----------|--------|
| `<leader>sv/sh` | Split vertical/horizontal |
| `<leader>se` | Equalize sizes |
| `<leader>sc` | Close window |
| `<leader>so` | Close others |

### Multi-Pane Layouts
| Shortcut | Action |
|----------|--------|
| `<leader>mh` | 3 horizontal |
| `<leader>mv` | 3 vertical |
| `<leader>mg` | 2x2 grid |
| `<leader>mc` | Coding layout |

### Buffer Operations
| Shortcut | Action |
|----------|--------|
| `<leader>bd` | Delete buffer |
| `<leader>bo` | Close others |
| `<leader>bb` | Buffer picker |
| `<leader>bc` | Pick to close |

## 🚀 Next Steps

1. **Practice the basics**: Start with `<C-h/j/k/l>` and `<leader>wp`
2. **Try layouts**: Use `<leader>mc` for a coding session
3. **Explore sessions**: Save your work with automatic sessions
4. **Customize**: Modify keybindings in `~/.config/nvim/init.lua`

## 💡 Pro Tips

- **Muscle Memory**: Practice navigation shortcuts daily
- **Layout Consistency**: Use the same layout for similar tasks
- **Session Naming**: Use descriptive names for tmux sessions
- **Buffer Cleanup**: Regularly close unused buffers with `<leader>bo`
- **Window Information**: Use `<leader>wi` when lost in multiple panes

---

**Happy navigating!** 🧭✨