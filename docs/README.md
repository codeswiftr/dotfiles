# 📚 **Complete Dotfiles Documentation**

Welcome to the comprehensive documentation for your modern 2025 development environment!

## 🎨 Code Style & Configuration Conventions

- **Shell (Zsh):** Use `shellcheck` and `shfmt` for linting/formatting. Prefer explicit, readable options. Document all custom aliases and functions.
- **Tmux:** Use Ctrl-a as prefix, enable true color and mouse support, start windows/panes at 1, keep config modular and well-commented.
- **Neovim (Lua):** Progressive tier system, modular config, language-specific tab/indent settings, document all custom commands/keymaps, provide user feedback.
- **General:** Group/sort imports and config sections, avoid unused imports/options, prefer explicit/documented configuration, keep functions small, document public APIs and user-facing commands.

See [AGENTS.md](../AGENTS.md) for full style guidelines and commit conventions.

## 🤖 Agentic Workflow Automation

- **Gemini CLI Review:**  
  Run `gemini review --diff` before every commit to get instant feedback and suggestions.
- **Commit Process:**  
  Use conventional commit messages and always reference Gemini review in your PRs.
- **Test/Lint Hooks:**  
  All commits are validated by automated hooks (security, syntax, structure, commit message, and testing).  
  Run `./tests/test_runner.sh`, `shellcheck`, and `yamllint` before committing.
  - **Install shellcheck and yamllint first:**
    ```bash
    brew install shellcheck yamllint   # macOS
    sudo apt install shellcheck yamllint  # Ubuntu/Debian
    ```
- **Documentation:**  
  See [AGENTS.md](../AGENTS.md) for full workflow details and commit conventions.

## 🌍 Accessibility & Internationalization

- All workflows are keyboard-first; mouse/trackpad is optional.
- Shortcuts are designed for US, UK, and most EU layouts. For non-standard layouts, remap keys using Karabiner-Elements (macOS) or xmodmap (Linux).
- High-contrast themes available (see [Theme Guide](themes.md)).
- If you spot accessibility or i18n issues, please open an issue or PR!

## 🏁 How to Contribute

- All contributions are welcome—bug fixes, docs, tests, refactors, and new features!
- If you're unsure where to start, open an issue or join a discussion.
- We value clear communication, kindness, and learning together.
- **See [CONTRIBUTING.md](../CONTRIBUTING.md) for onboarding and workflow details.**

### How to Help & Technical Debt
- Want to help improve this project? See [Technical Debt & Migration](technical-debt.md) for a list of legacy code, migration plans, and documentation debt.
- If you find outdated guides, legacy configs, or unclear instructions, please open an issue or PR and add them to technical-debt.md!

## 🚀 **Quick Start**

**New to these dotfiles?**
1. **[Getting Started](getting-started.md)** - First steps and basics
2. **[Troubleshooting Guide](troubleshooting.md)** - Common issues and diagnostics

**Legacy Docs & Migration:**
- See **[Legacy Documentation](legacy-backup-20250714/)** for archived, outdated guides and migration docs. These are for reference only and are no longer maintained.
- Migration from legacy configs (e.g., old Neovim/tmux paths) is ongoing—see [Technical Debt & Migration](technical-debt.md) for details and how you can help.

## 🚀 **Revolutionary Features (2025)**

### ⚡ Performance Breakthroughs
- **[Performance Guide](performance.md)** - 70% faster shell + editor optimizations (consolidated)
- **[Tmux Quick Reference](tmux-quick-reference.md)** - Streamlined from 66 to 10 essential keybindings

### 🏁 Progressive Complexity
- **Tier-based systems** - Start simple, scale up as you learn
- **Visual discovery** - `<Space>?` shows all commands in Neovim
- **Auto-optimization** - System adapts to your hardware and usage

## 📖 **Core Documentation**

### 🎨 Themes & Appearance
- **[Theme Guide](themes.md)** - Catppuccin setup and customization

### 🤖 AI Integration
- **[AI Workflow Guide](ai-workflows.md)** - Complete AI development setup
- **[Security Guide](security.md)** - Protect your code from AI exposure

### ⚡ Performance & Optimization
- **[Performance Guide](performance.md)** - Shell + editor performance (consolidated)

### 🛠️ Editor & Tools
- **[Neovim Guide](neovim.md)** - Modern Neovim configuration (includes Quick Reference)
- **[Tmux Quick Reference](tmux-quick-reference.md)** - Streamlined keybindings
- **[Navigation Guide](navigation.md)** - Keyboard shortcuts and workflows

### 🛡️ System Administration
- **[Modular Architecture](modular-architecture.md)** - Understanding the new config structure
- **[Configuration Reference](configuration.md)** - Where to change things
- **[Advanced Configuration](advanced.md)** - Expert customization
- **[CLI API](api.md)** - `dot` command structure
- **[Plugin Development](plugins.md)** - Extend the system

## 🏁 **Feature Guides**

| Feature | Quick Reference | Detailed Guide |
|---------|----------------|----------------|
| **AI Coding** | `<leader>aa` | [AI Workflows](ai-workflows.md) |
| **Project Switching** | `proj` | [Navigation](navigation.md) |
| **Smart Sessions** | `tm` | Navigation & Tmux |
| **Security Controls** | `ai-security-status` | [Security](security.md) |
| **Performance** | `perf-status` | [Performance](performance.md) |
| **Health Check** | `df-health` | System Health |

## 📋 **Quick Reference**

### **Essential Commands**
```bash
# Project Management
proj                    # Switch projects with fzf
tm <session-name>      # Smart tmux sessions
ta <session-name>      # Attach to session

# AI Integration
cc "question"          # Quick Claude query
gg "question"          # Quick Gemini query
ai-analyze overview    # Project analysis
claude-context "help"  # Context-aware AI

# Performance & Health
df-health             # System health check
perf-benchmark-startup # Measure shell performance
df-update             # Update dotfiles

# Security
ai-security-status    # View AI security settings
ai-security-strict    # Maximum security mode
```

### **Key Bindings**
```bash
# Shell Navigation
Ctrl+T               # FZF file finder
Ctrl+R               # FZF history search
Alt+C                # FZF directory change

# Neovim AI (in visual mode)
<leader>aa           # AI Actions menu
<leader>acr          # AI Code Review
<leader>ace          # AI Explain Code
<leader>act          # AI Generate Tests

# Tmux Sessions
Prefix + A           # AI development layout
Prefix + P           # Python development layout
Prefix + W           # Web development layout
```

## 🆘 **Need Help?**

### **Common Issues**
1. **Slow startup?** → [Performance Guide](performance.md)
2. **AI not working?** → [AI Troubleshooting](ai-workflows.md#troubleshooting)
3. **Theme issues?** → [Theme Guide](themes.md)
4. **Plugin errors?** → [Neovim Guide](neovim.md#troubleshooting)

### **Getting Support**
- **Health Check**: Run `df-health` for system diagnostics
- **Interactive Tutorial**: Use `dotfiles-tutor` for guided learning
- **Documentation**: All guides are in the `docs/` directory
- **Troubleshooting**: See [Troubleshooting Guide](troubleshooting.md) for common issues and diagnostics
- **Migration & Technical Debt**: See [Technical Debt & Migration](technical-debt.md) for help with legacy configs and ongoing improvements
- **Verification**: Use the verification commands in each guide

## 🎨 **Customization**

### **Popular Customizations**
- **[Change Theme Flavor](themes.md#switching-flavors)** - Light/dark variants
- **[Add Languages](neovim.md#adding-languages)** - New LSP servers
- **[Custom AI Prompts](ai-workflows.md#custom-prompts)** - Personalized AI functions
- **[Performance Tuning](performance.md#advanced-tuning)** - Optimize for your usage

### **Advanced Configuration**
- **[Modular Configs](advanced.md#modular-setup)** - Split large files
- **[Team Deployment](advanced.md#team-setup)** - Organization standards
- **[Security Policies](security.md#enterprise-setup)** - Corporate compliance

## 🏁 **Feature Matrix**

| Component | Status | Performance | Security | AI Integration |
|-----------|--------|-------------|----------|----------------|
| **Shell (ZSH)** | ✅ Modern | ⚡ Optimized | 🔒 Secure | 🤖 Full |
| **Editor (Neovim)** | ✅ Lua | ⚡ Native LSP | 🔒 Protected | 🤖 Advanced |
| **Terminal (Tmux)** | ✅ Enhanced | ⚡ Fast | 🔒 Safe | 🤖 Integrated |
| **Theme (Catppuccin)** | ✅ Unified | ⚡ Lightweight | 🔒 N/A | 🤖 Compatible |
| **Tools (Modern CLI)** | ✅ Latest | ⚡ Optimized | 🔒 Verified | 🤖 Connected |

## 🏆 **Your Development Environment**

**Congratulations!** You now have a **world-class development environment** featuring:

- ✅ **Modern 2025 tooling** with latest best practices
- ✅ **AI-enhanced workflows** with security protection
- ✅ **3-5x performance improvements** in startup and runtime
- ✅ **Unified theming** across all development tools
- ✅ **Enterprise-grade security** with configurable controls
- ✅ **Cross-platform compatibility** for macOS and Linux
- ✅ **Comprehensive documentation** with interactive tutorials

**Start exploring with the [Getting Started Guide](getting-started.md)!**

---

*Last updated: 2025-07-06 | Version: 2025.1.6 | [Legacy Documentation](legacy/)*
