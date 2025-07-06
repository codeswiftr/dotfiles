# 🎨 **Modern Theme Guide - Catppuccin Integration**

## 🌟 **Overview**

Your dotfiles now use the **Catppuccin Mocha** color scheme - the most popular developer theme of 2025. This provides a unified, modern aesthetic across your entire development environment.

## 🎯 **What's Changed**

### **From Gruvbox to Catppuccin**
- **Old**: Gruvbox (classic but dated)
- **New**: Catppuccin Mocha (modern, trending, ecosystem-rich)

### **Benefits**
✅ **Unified Experience**: Same colors across terminal, Neovim, tmux, and 200+ tools  
✅ **Modern Aesthetics**: Soft, warm, low-contrast colors that reduce eye strain  
✅ **Ecosystem Support**: Official ports for virtually every development tool  
✅ **2025 Trends**: Pastel-based palettes with excellent readability  
✅ **Accessibility**: Designed with colorblind-friendly considerations  

## 🔧 **Components Updated**

### **1. Starship Prompt**
**Location**: `~/.config/starship.toml`
- Modern Nerd Font icons (󰊢, 󰌠, 󰎙, etc.)
- Catppuccin Mocha color palette
- Enhanced git status indicators
- Language-specific icons and colors

### **2. Neovim Theme**
**Location**: `~/.config/nvim/init.lua`
- Replaced `gruvbox.nvim` with `catppuccin/nvim`
- Integrated with all your AI plugins
- Enhanced treesitter highlighting
- Modern status line colors

### **3. Tmux Theme**
**Location**: `~/.tmux.conf`
- Added `catppuccin/tmux` plugin
- Modern status bar with CPU, battery, and directory info
- Consistent window styling
- Enhanced pane borders

### **4. Terminal Colors**
- Your terminal should be configured with Catppuccin colors
- Most terminals auto-detect from the configs
- For manual setup, see terminal-specific instructions below

## 🎨 **Catppuccin Mocha Color Palette**

```
Background Colors:
├── Base:     #1e1e2e (main background)
├── Mantle:   #181825 (darker background)
└── Crust:    #11111b (darkest background)

Text Colors:
├── Text:     #cdd6f4 (main text)
├── Subtext1: #bac2de (secondary text)
└── Subtext0: #a6adc8 (tertiary text)

Accent Colors:
├── Mauve:    #cba6f7 (primary accent)
├── Blue:     #89b4fa (links, keywords)
├── Sapphire: #74c7ec (directories)
├── Green:    #a6e3a1 (success, strings)
├── Yellow:   #f9e2af (warnings, numbers)
├── Red:      #f38ba8 (errors, deletion)
├── Peach:    #fab387 (operators, tags)
└── Lavender: #b4befe (functions, git)
```

## 📱 **Terminal Setup Instructions**

### **iTerm2 (macOS)**
1. Download the [Catppuccin iTerm2 theme](https://github.com/catppuccin/iterm2)
2. Import the `.itermcolors` file in iTerm2 Preferences → Profiles → Colors
3. Select "Catppuccin Mocha" from the preset dropdown

### **Terminal.app (macOS)**
1. Download the [Catppuccin Terminal.app theme](https://github.com/catppuccin/terminal.app)
2. Double-click the `.terminal` file to import
3. Set as default in Terminal Preferences

### **Alacritty**
Add to your `~/.config/alacritty/alacritty.yml`:
```yaml
import:
  - ~/.config/alacritty/catppuccin-mocha.yml
```

### **Wezterm**
Add to your `~/.wezterm.lua`:
```lua
local wezterm = require 'wezterm'
return {
  color_scheme = 'Catppuccin Mocha',
}
```

### **Kitty**
Add to your `~/.config/kitty/kitty.conf`:
```
include catppuccin-mocha.conf
```

## 🔧 **Advanced Customization**

### **Switching Flavors**
Catppuccin comes in 4 flavors. To switch:

1. **Latte** (light theme):
```bash
# In starship.toml
palette = "catppuccin_latte"

# In Neovim init.lua
flavour = "latte"

# In tmux.conf
set -g @catppuccin_flavour 'latte'
```

2. **Frappé** (soft dark):
```bash
palette = "catppuccin_frappe"
flavour = "frappe"
set -g @catppuccin_flavour 'frappe'
```

3. **Macchiato** (medium dark):
```bash
palette = "catppuccin_macchiato"
flavour = "macchiato"
set -g @catppuccin_flavour 'macchiato'
```

### **Custom Color Overrides**
You can customize specific colors:

**Starship**:
```toml
[palettes.catppuccin_mocha]
custom_blue = "#74c7ec"
```

**Neovim**:
```lua
color_overrides = {
  mocha = {
    base = "#000000", -- Pure black background
  },
}
```

## 🚀 **Installation Commands**

### **Fresh Install**
```bash
# Run the updated install script
./install.sh
```

### **Update Existing Setup**
```bash
# Pull latest changes
git pull

# Reload tmux config
tmux source-file ~/.tmux.conf

# Reload shell
source ~/.zshrc

# Restart Neovim to load new theme
```

### **Manual Theme Installation**
```bash
# Install tmux plugin
~/.tmux/plugins/tpm/bin/install_plugins

# Install Neovim plugin (auto-installs on next launch)
nvim +PackerSync +qall
```

## 🎯 **Verification**

### **Check Theme Status**
```bash
# Verify starship config
starship config

# Check tmux theme
tmux show-environment -g

# Test Neovim theme
nvim +checkhealth
```

### **Expected Results**
- **Prompt**: Purple mauve prompt character (❯)
- **Directories**: Sapphire blue paths
- **Git branches**: Lavender colored branch names
- **Status**: Green success, red error indicators
- **Tmux**: Mocha-themed status bar
- **Neovim**: Catppuccin color scheme active

## 🔗 **Resources**

- **Catppuccin Official**: https://catppuccin.com/
- **GitHub Organization**: https://github.com/catppuccin
- **Port Repository**: https://github.com/catppuccin/catppuccin
- **Starship Palettes**: https://starship.rs/config/#color-palettes
- **Tmux Plugin**: https://github.com/catppuccin/tmux
- **Neovim Plugin**: https://github.com/catppuccin/nvim

## 🎉 **What's Next?**

Your development environment now features a modern, unified theme that:
- Reduces eye strain with carefully chosen colors
- Provides consistent visual cues across all tools
- Integrates with 200+ other applications
- Follows 2025 design trends and accessibility standards

**Enjoy your beautiful, modern development setup!** 🎨✨