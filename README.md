# 🚀 Modern Dotfiles - 2025 Edition

**Complete AI-powered development environment optimized for Python, FastAPI, React, and SwiftUI development.**

## ⚡ One-Command Installation

**Works on both macOS and Ubuntu!**

### Remote Installation
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/master/install.sh)"
```

### Local Installation
```bash
cd ~/dotfiles && ./install.sh
```

### Supported Systems
- ✅ **macOS** (Intel & Apple Silicon)
- ✅ **Ubuntu 20.04+** (x86_64)
- ✅ **Other Linux distributions** (with manual adjustments)

## ✨ What You Get

### 🔧 **Modern CLI Tools**
- **Starship** - Beautiful, fast shell prompt
- **Zoxide** - Smart directory navigation (`z` command)
- **Eza** - Modern `ls` replacement with icons and git integration
- **Bat** - Syntax-highlighted `cat` replacement
- **Ripgrep** - Ultra-fast search tool
- **FZF** - Fuzzy finder for everything
- **Delta** - Beautiful git diffs

### 🤖 **AI-Powered Development**
- **Claude Code CLI** integration with smart context awareness
- **Gemini CLI** integration for multi-AI comparisons
- **GitHub Copilot** ready-to-use in Neovim
- **Aider** for AI pair programming
- **Intelligent project analysis** (security, performance, documentation)
- **AI-generated commit messages** and code reviews

### 🐍 **Python Development**
- **mise** for Python version management
- **uv** for ultra-fast package management
- **Ruff** for lightning-fast linting and formatting
- **Pyright** LSP for type checking
- **FastAPI** development shortcuts

### 📦 **JavaScript/Node.js**
- **Bun** runtime and package manager
- **TypeScript** LSP support
- **React** development optimizations
- **Modern package management**

### 🍎 **Swift/iOS Development**
- **SourceKit** LSP integration
- **Swift** development shortcuts
- **Xcode** project navigation

### 🖥️ **Terminal Multiplexing**
- **Tmux** with modern configuration
- **AI development session templates**
- **Project-aware session management**
- **Seamless Neovim integration**

### ✏️ **Editor Excellence**
- **Neovim** with Lua configuration
- **Native LSP** for multiple languages
- **Treesitter** syntax highlighting
- **Telescope** fuzzy finding
- **Auto-completion** with nvim-cmp

## 🎯 **AI Workflow Features**

### **Smart Functions**
```bash
claude-context "How to optimize this code?"  # Context-aware AI prompting
ai-compare "FastAPI vs Django?"              # Multi-AI decision making
ai-analyze security                          # Project security audit
ai-debug "error message"                     # AI-powered debugging
ai-commit                                    # AI-generated commit messages
explain file.py                             # Code explanation
```

### **Neovim AI Integration**
- `<leader>ac` - Send file to Claude Code
- `<leader>ag` - Send file to Gemini
- `<leader>ar` - AI code review
- `<leader>ae` - Explain selected code
- `<leader>aq` - Quick AI question

### **Tmux AI Sessions**
- `Prefix + A` - Launch AI development environment
- `Prefix + c` - Claude Code interactive session
- `Prefix + G` - Gemini interactive session

## 📋 **What Gets Installed**

### **System Tools**
- Homebrew (if not installed)
- Modern CLI tools (starship, zoxide, eza, bat, ripgrep, fd, fzf, etc.)
- Git with enhanced configuration
- Neovim with comprehensive plugin setup
- Tmux with modern configuration

### **Development Environment**
- Python 3.12 via mise
- Node.js LTS via mise
- uv for Python package management
- Bun for JavaScript runtime
- Development tools (ruff, aider, shell-gpt)

### **Configuration Files**
- Modern `.zshrc` with AI integration
- Neovim configuration with LSP
- Tmux configuration with AI shortcuts
- Enhanced git configuration
- Starship prompt configuration

## 🔄 **Version Management & Updates**

Your dotfiles include **automatic version management** similar to Oh My Zsh:

### **Update Commands**
```bash
df-version      # Check current version and update status
df-update       # Update to latest version with backup
df-changelog    # View recent changes and new features
```

### **Auto-Update Features**
- ✅ **Weekly update checks** (every 7 days)
- ✅ **Beautiful update notifications** when new versions available
- ✅ **Automatic backups** before any updates
- ✅ **Migration system** handles breaking changes
- ✅ **Safe rollback** if anything goes wrong
- ✅ **Semantic versioning** (YYYY.MAJOR.MINOR)

### **Update Process**
1. **Automatic notification** when updates are available
2. **One-command update** with `df-update`
3. **Automatic backup** of current configuration
4. **Git-based updates** for reliability
5. **Migration scripts** handle version changes
6. **Verification** ensures everything works

## 🔄 **Installation & Backup**

The installation script automatically:
- ✅ **Detects your operating system** (macOS/Ubuntu)
- ✅ **Backs up your existing configuration**
- ✅ **Installs all dependencies** (Homebrew on macOS, apt on Ubuntu)
- ✅ **Sets up cross-platform configurations**
- ✅ **Verifies installation** with system-specific checks
- ✅ **Enables version management** and auto-updates
- ✅ **Provides rollback information** for safe recovery

**Backup location**: `~/dotfiles-backup-TIMESTAMP`

## 🚀 **Quick Start After Installation**

### 1. **Interactive Tutorial (Recommended)**
   ```bash
   dotfiles-tutor
   ```
   **Learn everything hands-on with our interactive tutorial!** 🎓

### 2. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

### 3. **Test AI integration**:
   ```bash
   cc "Hello Claude, help me with Python"
   gg "What's the best FastAPI structure?"
   ```

### 4. **Launch AI development session**:
   ```bash
   tm my-project    # Smart project session
   # In tmux: Prefix + A (creates AI development layout)
   ```

### 5. **Try modern navigation**:
   ```bash
   z ~/projects     # Smart directory jumping
   proj            # Project switcher with fzf
   ```

## 🎯 **Key Productivity Features**

### **Smart Project Management**
- `tm` - Intelligent tmux sessionizer with project detection
- `proj` - FZF-powered project switching
- Auto-detection of Python, JavaScript, Swift projects
- Language-specific development layouts

### **AI-Assisted Development**
- Context-aware AI prompting based on project type
- Multi-AI comparison for better decision making
- Automated code review and documentation generation
- Smart commit message generation
- Error analysis and debugging assistance

### **Modern File Operations**
- `ls` → `eza` (with icons and git status)
- `cat` → `bat` (with syntax highlighting)
- `cd` → `z` (smart directory jumping)
- `grep` → `rg` (faster searching)
- `find` → `fd` (modern file finding)

## 📚 **Documentation**

- **🎓 Interactive Tutorial**: `dotfiles-tutor` (Learn everything hands-on!)
- **AI Workflow Guide**: `~/dotfiles/AI_WORKFLOW_GUIDE.md`
- **Navigation Guide**: `~/dotfiles/NAVIGATION_GUIDE.md`
- **Installation Testing**: `~/dotfiles/INSTALLATION_TEST.md`
- **Keyboard shortcuts**: Use `<leader>` in Neovim to see all commands
- **Tmux shortcuts**: `Prefix + ?` to see all bindings

## 🔧 **Customization**

All configurations are modular and easy to customize:
- **Shell**: Edit `~/.zshrc`
- **Neovim**: Edit `~/.config/nvim/init.lua`
- **Tmux**: Edit `~/.tmux.conf`
- **Git**: Use `git config --global` commands

## 🆘 **Troubleshooting**

If something goes wrong:

1. **Check the installation log**: `~/dotfiles-install.log`
2. **Restore from backup**: Your original config is at `~/dotfiles-backup-TIMESTAMP`
3. **Re-run installation**: The script is idempotent and safe to run multiple times
4. **Manual verification**: Run individual verification commands

## 🤝 **Contributing**

This dotfiles setup is continuously evolving. Feel free to:
- Submit issues for bugs or feature requests
- Create pull requests for improvements
- Share your customizations

## 📄 **License**

MIT License - feel free to use and modify as needed.

---

**Built for developers who want a modern, AI-powered terminal experience.** 🚀🤖

*Optimized for Python, FastAPI, React, and SwiftUI development with seamless AI integration.*