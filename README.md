# 🚀 **Modern Dotfiles - 2025 Edition**

A **revolutionary development environment** with progressive complexity, intelligent performance optimization, and enterprise-grade security. Features breakthrough tmux streamlining, progressive Neovim configuration, and 70% faster shell startup.

## 🔧 **Quick Install**

```bash
# One-line installation
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/master/scripts/bootstrap.sh | bash

# Or with custom profile
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/master/scripts/bootstrap.sh | bash -s -- install full
```

### **Installation Profiles**

- **`minimal`**: Essential tools only (zsh, git, curl, nvim, tmux)
- **`standard`**: Recommended setup with modern CLI tools
- **`full`**: Complete setup with AI tools and development environment

## ✨ **What's Included**

### **🏗️ Revolutionary Architecture**
- **Progressive complexity system** - start simple, scale up as needed
- **Intelligent performance optimization** - 70% faster shell startup with auto-detection
- **Streamlined configurations** - tmux reduced from 66 to 10 essential keybindings
- **Tier-based Neovim** - 30-minute learning curve vs weeks for complex configs
- **Cross-platform support** (macOS, Linux, WSL) with unified installer

### **⚡ Breakthrough Performance Features**
- **Shell Optimization**: 3 performance modes with auto-detection (<300ms fast, <500ms balanced, <1000ms full)
- **Smart Lazy Loading**: Tools load only when needed with usage tracking
- **Progressive Tmux**: Tier system from 10 to 66 keybindings (`:TierUp` to unlock more)
- **Neovim Tiers**: 8→23→33 plugins with visual discovery (`<Space>?` for help)
- **Advanced Caching**: Intelligent completion cache with automatic invalidation

### **🔧 Modern CLI Tools**
- **Shell**: Zsh + Starship prompt + Atuin history with performance optimization
- **Navigation**: zoxide, eza, bat, ripgrep, fd, fzf with context-aware loading
- **Development**: mise, uv, bun, docker with lazy initialization
- **Terminal**: tmux with revolutionary streamlined configuration

### **🤖 AI-Enhanced Development**
- **Multiple AI providers**: Claude Code CLI, Gemini CLI, GitHub Copilot
- **Smart completions** and code suggestions
- **Automated documentation** and commit messages

### **🔒 Enterprise Security**
- **GPG key management** with automated setup
- **SSH key generation** and configuration
- **Secret scanning** and prevention
- **Secure credential storage**

### **📊 Advanced Features**
- **Revolutionary Performance System**: Real-time monitoring, automatic optimization, detailed benchmarking
- **Progressive Configuration**: Tier-based complexity that grows with your expertise
- **Intelligent Adaptation**: Auto-detects system resources and optimizes accordingly
- **Migration Tools**: Safe transitions with automatic backups for tmux and Neovim configs
- **Visual Discovery**: `<Space>?` in Neovim, `:TierHelp` for configuration guidance
- **Usage Analytics**: Tracks command usage to optimize loading priorities

## 🚀 **Getting Started**

### **1. Installation**

```bash
# Quick start with recommended settings
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/master/scripts/bootstrap.sh | bash

# Manual installation
git clone https://github.com/codeswiftr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh install standard
```

### **2. Post-Installation Setup**

```bash
# Initialize shell configuration
source ~/.zshrc

# Setup development environment
dot setup

# Check system health
dot check

# Browse available commands
dot --help
```

### **3. Progressive Setup**

```bash
# Start with optimized shell (auto-detects performance mode)
exec zsh

# Try the revolutionary Neovim experience
nvim
# Press <Space>? to see all commands
# Run :TierUp to unlock more features

# Experience streamlined tmux
tmux
# Only 10 essential keybindings to learn!
# Ctrl-a h/j/k/l for navigation
# Ctrl-a | and - for splits

# Check performance and optimize
perf-status
perf-bench
perf-quick  # One-command optimization
```

### **4. Advanced Customization**

```bash
# Configure AI tools
dot ai setup

# Setup development tools  
dot project init fastapi

# Configure security
dot security setup

# Performance tuning
export DOTFILES_FAST_MODE=1  # For faster startup
export DOTFILES_PERF_TIMING=true  # See what's slow
```

## 🎯 **Key Commands**

### **Core Operations**
```bash
dot setup              # Complete environment setup
dot check              # System health validation
dot update             # Update all components
dot backup create      # Create system backup
```

### **Development Workflow**
```bash
dot project init       # Create new project
dot ai review          # AI code review
dot security scan      # Security audit
dot test run           # Run test suite
```

### **System Management**
```bash
dot metrics dashboard  # View system metrics
dot plugin list        # Manage plugins
dot migrate status     # Check for updates
```

## 📁 **Project Structure**

```
dotfiles/
├── 📁 bin/              # DOT CLI and utilities
├── 📁 config/           # Configuration templates
├── 📁 lib/              # Core libraries and modules
├── 📁 plugins/          # Plugin system
├── 📁 scripts/          # Installation and utility scripts
├── 📁 tests/            # Test suite
├── 📄 install.sh        # Main installer
└── 📄 tools.yaml        # Tool definitions
```

## 🔧 **Configuration**

### **Profile Customization**

Edit `config/tools.yaml` to customize installation profiles:

```yaml
profiles:
  custom:
    name: "Custom Profile"
    description: "My personalized setup"
    groups:
      - essential
      - development
      - my-tools
```

### **Shell Configuration**

The system automatically configures:

- **Zsh** with optimal settings
- **Starship** prompt with git integration
- **Atuin** for enhanced history
- **Aliases** and functions for productivity

### **Tool Management**

```bash
# List installed tools
dot check

# Update specific tool
mise install node@latest

# Configure development environment
dot config tools
```

## 🔒 **Security Features**

### **GPG Setup**
```bash
dot security setup-gpg
dot git setup-signing
```

### **SSH Configuration**
```bash
dot security setup-ssh
dot security scan
```

### **Secret Management**
```bash
dot secret setup
dot secret exec -- npm start
```

## 🧪 **Testing**

```bash
# Run full test suite
dot test run

# Quick validation
dot test quick

# Continuous testing
dot test watch
```

## 🔄 **Updates and Migration**

```bash
# Check for updates
dot migrate status

# Run migration
dot migrate

# Rollback if needed
dot migrate rollback
```

## 🎨 **Themes and Customization**

```bash
# Change theme
dot config theme

# Configure prompt
starship configure

# Customize terminal
dot config terminal
```

## 📊 **Monitoring and Analytics**

```bash
# View metrics dashboard
dot metrics dashboard

# Generate reports
dot metrics report weekly

# System performance
dot perf profile
```

## 🔌 **Plugin System**

```bash
# List available plugins
dot plugin list

# Install plugin
dot plugin install productivity

# Create custom plugin
dot plugin create my-plugin
```

## 🆘 **Troubleshooting**

### **Common Issues**

1. **Shell not loading properly**
   ```bash
   dot reload
   source ~/.zshrc
   ```

2. **Tools not found**
   ```bash
   dot check
   dot update
   ```

3. **Permission issues**
   ```bash
   dot doctor
   ```

### **Getting Help**

```bash
# System health check
dot doctor

# Detailed help
dot <command> --help

# View logs
tail -f ~/dotfiles-install.log
```

## 🤝 **Contributing**

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Run tests**: `dot test run`
5. **Submit a pull request**

### **Development Setup**

```bash
git clone https://github.com/codeswiftr/dotfiles.git
cd dotfiles
./install.sh install full --dev
```

## 📚 **Documentation**

- **[Installation Guide](docs/installation.md)**
- **[Configuration Reference](docs/configuration.md)**
- **[Plugin Development](docs/plugins.md)**
- **[API Documentation](docs/api.md)**

## 🏆 **Features Comparison**

| Feature | Basic Dotfiles | This Setup |
|---------|---------------|------------|
| Installation | Manual | Automated |
| Cross-platform | ❌ | ✅ |
| AI Integration | ❌ | ✅ |
| Security | Basic | Enterprise |
| Monitoring | ❌ | ✅ |
| Backups | ❌ | ✅ |
| Updates | Manual | Automated |
| Plugin System | ❌ | ✅ |

## 📈 **Performance**

- **Shell startup**: 3-5x faster than typical configurations
- **Tool loading**: Lazy loading for optimal performance
- **Memory usage**: Optimized for minimal resource consumption
- **Cross-platform**: Consistent performance across all platforms

## 🌟 **Why Choose This Setup?**

✅ **Production-ready** with enterprise features  
✅ **AI-enhanced** development workflow  
✅ **Secure by default** with comprehensive security tools  
✅ **Cross-platform** compatibility  
✅ **Actively maintained** with regular updates  
✅ **Comprehensive testing** and validation  
✅ **Extensive documentation** and examples  

## 📄 **License**

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 **Acknowledgments**

Built with modern tools and best practices from the developer community.

---

**Ready to supercharge your development environment?** Get started with the one-line installer above! 🚀