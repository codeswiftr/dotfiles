# 🎨 **Theme Guide - Catppuccin Integration**

Your development environment uses the **Catppuccin Mocha** color scheme - the most popular developer theme of 2025.

## 🌟 **Overview**

### **What is Catppuccin?**
Catppuccin is a community-driven pastel theme that aims to be the middle ground between low and high contrast themes. It consists of 4 soothing warm flavors with 26 eye-candy colors each.

### **Why Catppuccin?**
✅ **Most Popular 2025 Theme** - Trending across the developer community  
✅ **Unified Ecosystem** - 200+ official tool integrations  
✅ **Eye-Friendly** - Warm, low-contrast palette reduces eye strain  
✅ **Accessibility** - Designed with colorblind users in mind  
✅ **Modern Design** - Follows 2025 design trends and principles  

## 🎯 **Current Setup**

Your dotfiles use **Catppuccin Mocha** (dark theme) across:

### **Components Themed**
- ✅ **Starship Prompt** - Terminal prompt with Catppuccin colors
- ✅ **Neovim** - Editor theme with AI plugin integration
- ✅ **Tmux** - Terminal multiplexer status bars and windows
- ✅ **Terminal Colors** - Full terminal color palette
- ✅ **Git Delta** - Enhanced git diff colors

### **Color Palette Preview**
```bash
Background Colors:
├── Base:     #1e1e2e (main background)
├── Mantle:   #181825 (darker background)  
└── Crust:    #11111b (darkest background)

Text Colors:
├── Text:     #cdd6f4 (main text)
├── Subtext1: #bac2de (secondary text)
└── Subtext0: #a6adc8 (tertiary text)

Accent Colors:
├── Mauve:    #cba6f7 (primary accent - your prompt)
├── Blue:     #89b4fa (directories, keywords)
├── Sapphire: #74c7ec (paths, links)
├── Green:    #a6e3a1 (success, strings)
├── Yellow:   #f9e2af (warnings, numbers)
├── Red:      #f38ba8 (errors, deletion)
├── Peach:    #fab387 (operators, tags)
└── Lavender: #b4befe (git branches, functions)
```

## 🔄 **Switching Themes**

### **Available Flavors**
Catppuccin comes in 4 beautiful flavors:

1. **🌅 Latte** (Light) - For bright environments
2. **🪴 Frappé** (Soft dark) - Gentle on the eyes
3. **🌺 Macchiato** (Medium dark) - Balanced contrast
4. **🌙 Mocha** (Dark) - Current default, maximum contrast

### **How to Switch Flavors**

#### **1. Starship Prompt**
Edit `~/.config/starship.toml`:
```toml
# Change this line:
palette = "catppuccin_mocha"

# To one of:
palette = "catppuccin_latte"      # Light theme
palette = "catppuccin_frappe"     # Soft dark
palette = "catppuccin_macchiato"  # Medium dark
```

#### **2. Neovim Theme**
Edit `~/.config/nvim/init.lua`:
```lua
require("catppuccin").setup({
  flavour = "mocha", -- Change to: latte, frappe, macchiato, mocha
})
```

#### **3. Tmux Theme**
Edit `~/.tmux.conf`:
```bash
set -g @catppuccin_flavour 'mocha'  # Change to: latte, frappe, macchiato
```

#### **4. Apply Changes**
```bash
# Reload configurations
source ~/.zshrc
tmux source-file ~/.tmux.conf
# Restart Neovim to apply theme
```

## 🖥️ **Terminal Setup**

Your terminal emulator needs to support the Catppuccin color scheme for the full experience.

### **Recommended Terminal Emulators**

#### **macOS**
1. **iTerm2** (Recommended)
   - Download: [Catppuccin for iTerm2](https://github.com/catppuccin/iterm2)
   - Import the `.itermcolors` file
   - Set as default profile

2. **Alacritty** (Fast)
   ```yaml
   # Add to ~/.config/alacritty/alacritty.yml
   import:
     - ~/.config/alacritty/catppuccin-mocha.yml
   ```

3. **Wezterm** (Modern)
   ```lua
   -- Add to ~/.wezterm.lua
   local wezterm = require 'wezterm'
   return {
     color_scheme = 'Catppuccin Mocha',
   }
   ```

#### **Linux**
1. **Kitty**
   ```bash
   # Add to ~/.config/kitty/kitty.conf
   include catppuccin-mocha.conf
   ```

2. **GNOME Terminal**
   - Use the [Catppuccin GNOME Terminal](https://github.com/catppuccin/gnome-terminal) theme

3. **Konsole**
   - Import Catppuccin colorscheme from the [Konsole repository](https://github.com/catppuccin/konsole)

### **Installation Commands**
```bash
# Install terminal themes (automated)
# iTerm2
curl -L https://github.com/catppuccin/iterm2/raw/main/colors/catppuccin-mocha.itermcolors -o ~/Downloads/catppuccin-mocha.itermcolors

# Alacritty
mkdir -p ~/.config/alacritty
curl -L https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.yml -o ~/.config/alacritty/catppuccin-mocha.yml
```

## 🎨 **Customization Options**

### **Custom Color Overrides**

#### **Starship Prompt Customization**
```toml
# In ~/.config/starship.toml
[palettes.catppuccin_mocha]
# Override specific colors
custom_blue = "#74c7ec"
custom_mauve = "#cba6f7"

[character]
success_symbol = "[❯](custom_mauve)"
error_symbol = "[❯](red)"
```

#### **Neovim Color Customization**
```lua
-- In ~/.config/nvim/init.lua
require("catppuccin").setup({
  color_overrides = {
    mocha = {
      base = "#000000",        -- Pure black background
      mantle = "#010101",      -- Slightly lighter
      crust = "#020202",       -- Even lighter
    },
  },
  custom_highlights = {
    Comment = { fg = "#7287fd" },  -- Custom comment color
  },
})
```

### **Theme Variants**

#### **High Contrast Mode**
```bash
# For better visibility
export CATPPUCCIN_HIGH_CONTRAST=1
```

#### **Transparent Background**
```lua
-- Neovim transparent background
require("catppuccin").setup({
  transparent_background = true,
})
```

## 🔧 **Advanced Configuration**

### **Per-Project Themes**
Create project-specific color schemes:

```bash
# In project root, create .nvimrc
echo 'lua require("catppuccin").setup({flavour = "latte"})' > .nvimrc
echo 'lua vim.cmd.colorscheme("catppuccin")' >> .nvimrc
```

### **Time-Based Theme Switching**
Automatically switch between light/dark based on time:

```bash
# Add to ~/.zshrc
auto_theme_switch() {
    local hour=$(date +%H)
    if [[ $hour -ge 18 || $hour -le 6 ]]; then
        # Night time - dark theme
        export CATPPUCCIN_FLAVOUR="mocha"
    else
        # Day time - light theme
        export CATPPUCCIN_FLAVOUR="latte"
    fi
}

# Run on shell startup
auto_theme_switch
```

### **Team Standardization**
For teams, create a shared theme configuration:

```bash
# team-theme.sh
export TEAM_CATPPUCCIN_FLAVOUR="mocha"
export TEAM_CATPPUCCIN_ACCENT="mauve"

# Apply team settings
apply_team_theme() {
    # Update configs with team standards
    sed -i "s/flavour = .*/flavour = \"$TEAM_CATPPUCCIN_FLAVOUR\"/" ~/.config/nvim/init.lua
}
```

## 🎯 **Theme Integration Benefits**

### **Developer Experience**
- **Consistent Visual Language** - Same colors across all tools
- **Reduced Context Switching** - No jarring color changes between tools
- **Better Focus** - Harmonious colors reduce visual distractions
- **Professional Appearance** - Modern, clean aesthetic for presentations

### **Technical Benefits**
- **Performance** - Optimized color calculations
- **Accessibility** - WCAG compliant contrast ratios
- **Maintainability** - Centralized color definitions
- **Extensibility** - Easy to add new tool integrations

## 📊 **Theme Comparison**

| Flavor | Use Case | Lighting | Contrast | Eye Strain |
|--------|----------|----------|----------|------------|
| **Latte** | Bright offices | High ambient | Medium | Low |
| **Frappé** | Mixed lighting | Medium | Low-Medium | Very Low |
| **Macchiato** | Dim lighting | Low ambient | Medium-High | Low |
| **Mocha** | Dark rooms | Very low | High | Medium |

## 🆘 **Troubleshooting**

### **Colors Not Appearing**
```bash
# Check terminal true color support
echo $TERM
# Should be: screen-256color, xterm-256color, or similar

# Test true color support
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash
```

### **Inconsistent Colors Between Tools**
```bash
# Reload all configurations
source ~/.zshrc
tmux source-file ~/.tmux.conf
# Restart terminal application
```

### **Neovim Theme Not Loading**
```bash
# Check plugin status
nvim +Lazy

# Reinstall Catppuccin
nvim +Lazy! sync catppuccin/nvim +qall
```

### **Terminal Override Issues**
```bash
# Check for conflicting color settings
env | grep -i color
env | grep -i term

# Clear terminal color variables if needed
unset COLORTERM LS_COLORS
```

## 🎉 **Theme Showcase**

Your themed development environment now includes:

### **🎨 Visual Harmony**
- Unified purple/mauve accent color across all tools
- Consistent background shades (base, mantle, crust)
- Harmonious syntax highlighting in all editors

### **🔍 Improved Readability**
- Optimized contrast ratios for long coding sessions
- Distinct colors for different code elements
- Clear visual hierarchy in terminal output

### **⚡ Performance Optimized**
- Lightweight theme with minimal resource usage
- Fast color calculations and rendering
- No impact on shell or editor startup times

### **🤖 AI Integration**
- Theme works seamlessly with all AI plugins
- Consistent colors in AI chat interfaces  
- Visual distinction for AI-generated content

## 📚 **Resources**

- **Official Website**: https://catppuccin.com/
- **GitHub Organization**: https://github.com/catppuccin
- **All Ports**: https://github.com/catppuccin/catppuccin#-ports-and-more
- **Color Palette**: https://catppuccin.com/palette
- **Community Discord**: https://discord.gg/r6Mdz5dpFc

## 🎯 **Next Steps**

1. **Experiment with Flavors** - Try different themes for different times of day
2. **Customize Colors** - Override specific colors to match your preferences  
3. **Share with Team** - Standardize theme across your development team
4. **Extend Integration** - Add Catppuccin to other tools you use

Your development environment now features a **world-class, unified theme** that follows 2025 design trends and provides an optimal coding experience! 🎨✨

---

**Need more customization?** Check out the [Advanced Configuration Guide](advanced.md)