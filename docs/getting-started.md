# 🚀 **Getting Started Guide**

Welcome to your modern 2025 development environment! This guide will get you up and running quickly.

## ✅ **Prerequisites Check**

First, verify your installation was successful:

```bash
# Check core tools
which zsh starship nvim tmux

# Run health check
df-health

# Test AI integration (optional)
ai-security-status
```

**Expected output**: All tools should be found, health check should be mostly green.

## 🎯 **Essential First Steps**

### **1. Learn the Basics (5 minutes)**

```bash
# 🚀 Start the interactive tutorial
dotfiles-tutor

# 📊 Check system status
df-health
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
df-health             # System health check
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

## 🎯 **Key Neovim Features**

Launch Neovim: `nvim file.py`

### **Essential Keybindings**
```bash
# File Navigation
<C-p>        # Find files (Telescope)
<leader>ff   # Find files (alternative)
<leader>fg   # Live grep search
<leader>fb   # Browse buffers

# AI Integration
<leader>aa   # AI Actions menu
<leader>ac   # AI Chat
<leader>acr  # AI Code Review (visual mode)
<leader>ace  # AI Explain Code (visual mode)
<leader>act  # AI Generate Tests (visual mode)

# LSP Features (Native)
gd           # Go to definition
gr           # Show references
K            # Hover documentation
<leader>ca   # Code actions
```

### **Terminal in Neovim**
```bash
<C-\>        # Toggle terminal
# AI integration works in terminal too!
```

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

### **This Week**
1. 📚 Read [Navigation Guide](navigation.md) for advanced shortcuts
2. 🤖 Explore [AI Workflows](ai-workflows.md) for development
3. ⚡ Review [Performance Guide](performance.md) for optimization
4. 🎨 Customize theme in [Theme Guide](themes.md)

### **Advanced (When Ready)**
1. 🔧 Learn [Advanced Configuration](advanced.md)
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
- 🆘 Run `df-health` for diagnostics
- 📚 Check other guides in `docs/`
- 🎓 Use `dotfiles-tutor` for interactive learning