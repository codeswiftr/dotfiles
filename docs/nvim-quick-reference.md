# 🚀 Neovim Quick Reference - Streamlined Edition

## 🎯 Essential Commands (Tier 1) - Master These First

### File Operations (The Big 5)
| Command | Action | Memory Aid |
|---------|--------|------------|
| `<Space>ff` | Find files | **f**ind **f**iles |
| `<Space>fg` | Find text (grep) | **f**ind **g**rep |
| `<Space>e` | File explorer | **e**xplorer |
| `<Space>w` | Save file | **w**rite |
| `<Space>q` | Quit | **q**uit |

### Navigation (Essential Movement)
| Command | Action | Memory Aid |
|---------|--------|------------|
| `<C-h/j/k/l>` | Navigate windows | **Vim directions** |
| `<Space>b` | Buffer list | **b**uffers |
| `<Space>/` | Search in file | **/** = search |

### Code Actions (Development Core)
| Command | Action | Memory Aid |
|---------|--------|------------|
| `gd` | Go to definition | **g**o **d**efinition |
| `gr` | Go to references | **g**o **r**eferences |
| `<Space>ca` | Code actions | **c**ode **a**ctions |
| `<Space>f` | Format code | **f**ormat |
| `<Space>?` | Show all keybindings | **?** = help |

**⏱️ Learning Goal**: Master these 15 commands in 30 minutes!

---

## 🔧 Tier Management Commands

| Command | Action |
|---------|--------|
| `:TierUp` | Upgrade to next tier |
| `:TierDown` | Downgrade to previous tier |
| `:TierStatus` | Show current tier info |
| `:TierHelp` | Show detailed tier help |

---

## 📈 Progressive Learning Path

### Week 1: Foundation (Tier 1)
- ✅ **8 essential plugins** - fast startup (<500ms)
- ✅ **15 key shortcuts** - manageable learning curve
- ✅ **Core editing** - files, navigation, basic code actions
- ✅ **Discovery system** - `<Space>?` shows all commands

**Goals**: 
- Find and open files instantly
- Navigate between windows/buffers
- Basic code navigation (definition, references)
- Format and save code

### Week 2: Enhancement (Tier 2)
```vim
:TierUp
```
- ✅ **+15 plugins** - git integration, debugging, statusline
- ✅ **+20 shortcuts** - enhanced workflows
- ✅ **IDE features** - proper debugging, git blame, terminal

**New capabilities**:
- Git integration with gitsigns
- Debug adapter protocol (DAP)
- Enhanced status line with file info
- Terminal integration
- Advanced text objects

### Week 3: Mastery (Tier 3)
```vim
:TierUp
```
- ✅ **+10 plugins** - AI integration, advanced tools
- ✅ **+20 shortcuts** - power user workflows
- ✅ **AI features** - GitHub Copilot, ChatGPT integration

**Advanced features**:
- AI-powered code completion
- Advanced git workflows
- REST client for API testing
- Code outline and structure views

---

## 🎓 Tier Comparison

| Feature | Tier 1 | Tier 2 | Tier 3 |
|---------|--------|--------|--------|
| **Plugins** | 8 | 23 | 33 |
| **Keybindings** | 15 | 35 | 55 |
| **Startup Time** | <500ms | <800ms | <1200ms |
| **Best For** | Beginners | Full Development | Power Users |
| **Learning Time** | 30 minutes | 2-3 hours | 1-2 days |

---

## 🚨 Emergency & Essential Commands

### Quick Escape Routes
| Situation | Solution |
|-----------|----------|
| **Lost in insert mode** | `jk` or `jj` to escape |
| **Can't find commands** | `<Space>?` for help |
| **Need to quit fast** | `<Space>Q` (force quit all) |
| **Broken config** | `:source $MYVIMRC` to reload |
| **Wrong tier** | `:TierDown` to simplify |

### File Recovery
| Command | Action |
|---------|--------|
| `<Space>W` | Save all buffers |
| `<Space>R` | Reload configuration |
| `:e!` | Reload current file (lose changes) |
| `:qa!` | Force quit all (lose all changes) |

---

## 🔧 Customization & Advanced Usage

### Personal Configuration
Create `~/.config/nvim/lua/user/init.lua` for personal customizations:

```lua
-- Personal keymaps
vim.keymap.set("n", "<leader>t", ":terminal<cr>", { desc = "Terminal" })

-- Personal options
vim.opt.wrap = true  -- Enable line wrapping

-- Custom commands
vim.api.nvim_create_user_command("MyCommand", function()
  print("Hello from my command!")
end, {})
```

### Project-Specific Settings
Create `.nvimrc` in project root:

```lua
-- Project-specific settings
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
```

### Performance Monitoring
```bash
# Check startup time
NVIM_PROFILE=1 nvim

# Profile specific tier
vim.g.nvim_tier = 1  # Test Tier 1 performance
```

---

## 🆚 Migration from Complex Config

### Before (Complex Setup)
- ❌ **1000+ lines** in single file
- ❌ **37+ plugins** loaded at startup
- ❌ **100+ keybindings** to memorize
- ❌ **2-5 second** startup time
- ❌ **Overwhelming** for new users

### After (Progressive Setup)
- ✅ **Modular architecture** (easy to understand)
- ✅ **Progressive complexity** (Tier 1→2→3)
- ✅ **Visual discovery** (`<Space>?` help system)
- ✅ **Fast startup** (<500ms for essentials)
- ✅ **30-minute learning curve**

---

## 🔄 Migration Guide

### Safe Migration
```bash
# Run the migration script
~/dotfiles/scripts/nvim-migrate.sh

# Your old config is automatically backed up
# New progressive config is installed
# Choose your starting tier
```

### Manual Migration
```bash
# Backup current config
mv ~/.config/nvim ~/.config/nvim-backup

# Install new config
cp -r ~/dotfiles/config/nvim ~/.config/

# Choose your tier in init.lua
vim ~/.config/nvim/init.lua
# Edit: vim.g.nvim_tier = 1  (or 2, 3)
```

### Rollback (if needed)
```bash
rm -rf ~/.config/nvim
mv ~/.config/nvim-backup ~/.config/nvim
```

---

## 💡 Pro Tips

### Discovery & Learning
1. **Use `<Space>?` frequently** - see all available commands
2. **Start with Tier 1** - build muscle memory first
3. **Upgrade gradually** - only when comfortable with current tier
4. **Customize progressively** - add personal touches to `user/init.lua`

### Performance Optimization
1. **Monitor startup time** - use `NVIM_PROFILE=1 nvim`
2. **Stay in appropriate tier** - don't over-engineer
3. **Disable unused features** - edit tier files to remove unwanted plugins
4. **Use lazy loading** - plugins load only when needed

### Team Collaboration
1. **Share tier level** - team can standardize on same tier
2. **Document customizations** - keep `user/init.lua` in version control
3. **Progressive onboarding** - new team members start at Tier 1

---

## 📚 Further Learning

### Resources
- **Built-in help**: `:TierHelp` for detailed information
- **Telescope**: `<Space>ff` to explore configuration files
- **Which-key**: `<Space>?` for command discovery
- **LSP**: `K` for hover information, `gd` for definitions

### Next Steps
1. **Master Tier 1** (week 1)
2. **Upgrade to Tier 2** when comfortable
3. **Explore customization** with `user/init.lua`
4. **Share with team** for consistent experience

---

**Remember**: The goal is productivity through progressive enhancement, not complexity for its own sake! 🚀