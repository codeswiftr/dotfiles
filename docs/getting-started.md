# 🚀 **Getting Started Guide**

Welcome to your modern 2025 development environment! This guide will get you up and running quickly.

## ✅ **Prerequisites Check**

First, verify your installation was successful:

```bash
# Check core tools
which zsh starship nvim tmux

# Run health check
dot-health

# Test AI integration (optional)
ai-security-status
```

**Expected output**: All tools should be found, health check should be mostly green.

If you encounter issues, see the [Troubleshooting Guide](troubleshooting.md) and [Technical Debt & Migration](technical-debt.md) for help with legacy configs and ongoing improvements.

## 🎯 **Essential First Steps**

### **Daily Workflow (Human)**
```bash
# Initialize configuration and run basic health
cd ~/dotfiles
./bin/dot init

# Start coding
nvim   # Press <Space>? for command discovery
tmux   # Minimal essential keybindings

# Quick health
./scripts/health-check.sh --json | jq .  # or: dot-health
```

### **Agent Mode (Headless / CI / Servers)**
```bash
# Non-interactive install preview
DOTFILES_MODE=agent ./install.sh --dry-run install standard

# Health in JSON for machines
./scripts/health-check.sh --json

# Check for shell state that can confuse coding agents
agent-doctor
```

See [Agent Guide](agents.md) for predictable command names, underscore escape
aliases such as `_cat`, and wrappers such as `_claude` and `_codex`.

### **1. Learn the Basics (5 minutes)**

```bash
# 🚀 Start the interactive tutorial
dotfiles-tutor

# 📊 Check system status
dot-health
perf-status

# 🎨 Verify theme is working
echo "Your prompt should be colorful with modern icons!"
```

### **2. Set Up Your First Project (10 minutes)**

```bash
# Create a sample project
mkdir -p ~/projects/sample-app
cd ~/projects/sample-app
echo "print('Hello, modern development!')" > main.py

# Test project switching
proj  # Should show your project in the list

# Create a smart tmux session
tm sample-app  # Creates optimized development layout
```

### **3. Test AI Integration (5 minutes)**

**⚠️ Security First**: AI functions will ask for confirmation before sending code to external services.

```bash
# Test basic AI (no code sharing)
cc "What's the weather like in San Francisco?"

# Test AI with security (will prompt for confirmation)
explain main.py

# Check security settings
ai-security-status
```

## 🛠️ **Essential Commands You'll Use Daily**

### **🔄 Project & Session Management**
```bash
proj                    # Switch between projects (fuzzy finder)
tm <project-name>      # Smart tmux session for project
ta <session-name>      # Attach to existing session
ts                     # List all tmux sessions
```

### **🤖 AI-Powered Development**
```bash
cc "question"          # Quick Claude query
gg "question"          # Quick Gemini query
ai-analyze overview    # Analyze current project
explain file.py        # Explain code with AI (secure)
ai-commit             # Generate commit messages (secure)
```

### **⚡ Performance & Maintenance**
```bash
dot-health             # System health check
df-update             # Update dotfiles
perf-benchmark-startup # Check shell performance
src                   # Reload shell config
```

## 🎨 **Customization Basics**

### **Theme Switching**
Your setup uses Catppuccin Mocha (dark). To switch flavors:

**For Terminal Prompt**:
```bash
# Edit ~/.config/starship.toml and change:
palette = "catppuccin_latte"  # Light theme
# or
palette = "catppuccin_macchiato"  # Medium dark
```

**For Neovim**:
```bash
# Edit ~/.config/nvim/init.lua and change:
flavour = "latte"  # Light theme
```

### **Security Configuration**
```bash
# For work/corporate environments
ai-security-strict

# For personal/open-source projects
ai-security-permissive

# Check current settings
ai-security-status
```

### **Performance Tuning**
```bash
# Enable fast mode for frequently used terminals
enable-fast-mode

# Check current performance
perf-status

# Benchmark startup time
perf-benchmark-startup
```

## 📚 **Learn Your New Workflow**

### **Python Development**
```bash
# Navigate to Python project
cd ~/projects/python-app

# Create optimized development session
tm python-dev  # Multi-pane layout with Python REPL

# In Neovim (opens automatically):
# - Native LSP provides autocompletion
# - <leader>aa opens AI actions menu
# - <leader>acr gives AI code review (visual mode)
```

### **Web Development**
```bash
# Navigate to web project
cd ~/projects/web-app

# Create web development session
tm web-dev  # Layout with dev server pane

# Modern aliases available:
bun install     # Fast package manager
bun run dev     # Development server
```

### **Git Workflow with AI**
```bash
# Stage changes
git add .

# Generate AI commit message (secure)
ai-commit  # Will ask for confirmation

# Review branch before push (secure)
ai-review-branch  # Compares with main branch
```

## 🚀 Advanced Workflows & Power User Tips

### 🤖 Agentic Coding & AI Automation

- **Gemini CLI Review:**  
  Before every commit, run `gemini review` to get instant feedback and suggestions.  
  Example:
  ```bash
  gemini review --diff
  ```
- **AI Commit & Review:**  
  Use `ai-commit` to generate secure, context-aware commit messages.  
  Use `ai-review-branch` to review your branch before pushing.
  ```bash
  git add .
  ai-commit
  ai-review-branch
  ```
- **Security Modes:**  
  - `ai-security-strict` for work/corporate environments
  - `ai-security-permissive` for personal/open-source
  - Always check with `ai-security-status`
- **Best Practices:**  
  - Always review AI suggestions before applying.
  - Use local LLMs for sensitive code (see [AI Workflows](ai-workflows.md#security-best-practices)).
  - Reference Gemini review in your PRs.

### ⌨️ Keyboard Navigation Mastery

- **Shell Shortcuts:**
  | Shortcut      | Action                        |
  |--------------|-------------------------------|
  | Ctrl-T       | fzf file finder               |
  | Ctrl-R       | fzf history search            |
  | Alt-C        | fzf directory changer         |
  | Ctrl-A       | Beginning of line             |
  | Ctrl-E       | End of line                   |
  | Ctrl-W       | Delete word backward          |
  | Ctrl-U       | Delete line backward          |

- **Tmux (Prefix: Ctrl-A):**
  | Shortcut      | Action                        |
  |--------------|-------------------------------|
  | Prefix + c   | New window                    |
  | Prefix + 1-9 | Switch window                 |
  | Prefix + h/j/k/l | Navigate panes            |
  | Prefix + z   | Zoom pane                     |
  | Prefix + s   | Session selector              |

- **Neovim:**
  | Shortcut      | Action                        |
  |--------------|-------------------------------|
  | <C-p>        | File finder (Telescope)        |
  | <leader>fg   | Grep search                    |
  | <leader>fb   | Buffer browser                 |
  | gd           | Go to definition               |
  | K            | Documentation                  |
  | <C-h/j/k/l>  | Window navigation              |
  | <leader>aa   | AI Actions menu                |
  | <leader>acr  | AI Code Review (visual mode)   |

- **International Keyboard Tips:**
  - All shortcuts are designed to work with US, UK, and most EU layouts.
  - For non-standard layouts, remap keys in your terminal emulator or use platform tools (e.g., Karabiner-Elements on macOS).
  - See [Navigation Guide](navigation.md#internationalization) for more.

### 🌍 Internationalization & Accessibility

- **Remapping Keys:**
  - On macOS, use Karabiner-Elements for custom keybindings.
  - On Linux, use `xmodmap` or your desktop environment's keyboard settings.
- **Accessibility:**
  - All workflows are keyboard-first; mouse/trackpad is optional.
  - High-contrast themes available (see [Theme Guide](themes.md)).
  - If you encounter accessibility issues, please open an issue or PR!

### 🎓 Interactive Tutorials & Help

- Run `dotfiles-tutor` for guided onboarding and advanced tips.
- Explore [AI Workflows](ai-workflows.md) and [Navigation Guide](navigation.md) for more.
- For troubleshooting, see [Troubleshooting](troubleshooting.md) and FAQ below.

---

## 🔧 **Troubleshooting Common Issues**

### **Slow Shell Startup**
```bash
# Check startup time
perf-benchmark-startup

# If > 1 second, enable fast mode
enable-fast-mode

# Profile detailed timing
perf-profile-startup
```

### **AI Functions Not Working**
```bash
# Check if CLI tools are installed
which claude gemini

# Check security settings
ai-security-status

# Try basic test
cc "hello world"
```

### **Theme Issues**
```bash
# Check terminal true color support
echo $TERM

# Should be "screen-256color" or similar
# Restart terminal if theme doesn't appear
```

### **Neovim Plugin Issues**
```bash
# Reinstall plugins
nvim +Lazy! sync +qall

# Check health
nvim +checkhealth +qall
```

## 🎓 **Next Steps**

### **Immediate (First Hour)**
1. ✅ Complete this getting started guide
2. ✅ Run `dotfiles-tutor` interactive tutorial
3. ✅ Set up your first project with `tm`
4. ✅ Test AI integration safely

If you encounter issues or are migrating from legacy configs, see the [Troubleshooting Guide](troubleshooting.md) and [Technical Debt & Migration](technical-debt.md). Contributors are encouraged to help document and improve migration steps!

### **This Week**
1. 📚 Read [Navigation Guide](navigation.md) for advanced shortcuts
2. 🤖 Explore [AI Workflows](ai-workflows.md) for development
3. ⚡ Review [Performance Guide](performance.md) for optimization
4. 🎨 Customize theme in [Theme Guide](themes.md)

### **Advanced (When Ready)**
1. 🛠️ Learn [Advanced Configuration](advanced.md)
2. 🛠️ Set up language-specific workflows
3. 👥 Configure for team use
4. 🔒 Implement enterprise security policies

## 🎉 **You're Ready!**

You now have access to a **world-class development environment** with:

- ✅ **Modern tooling** that's 3-5x faster than traditional setups
- ✅ **AI assistance** with enterprise-grade security
- ✅ **Unified theming** across all your development tools
- ✅ **Smart workflows** that adapt to your project types
- ✅ **Performance optimization** that scales with your usage

**Happy coding!** 🚀

---

**Need help?** 
- 🆘 Run `dot-health` for diagnostics
- 📚 Check other guides in `docs/`
- 🎓 Use `dotfiles-tutor` for interactive learning
- 🛠️ See [Troubleshooting Guide](troubleshooting.md) and [Technical Debt & Migration](technical-debt.md) for migration help and ways to contribute
