# 🚀 **Declarative Installation System**

The new declarative installation system provides a modern, configurable, and reproducible way to install your dotfiles and development tools.

## 🎯 **Key Features**

- **📝 Declarative Configuration** - All tools defined in `config/tools.yaml`
- **🎭 Installation Profiles** - Choose minimal, standard, full, or AI-focused setups
- **🔍 Dry Run Mode** - Preview what will be installed without making changes
- **✅ Verification** - Check current installation status
- **🔄 Cross-Platform** - Supports macOS, Ubuntu, and Arch Linux
- **📦 Smart Dependencies** - Handles package managers and prerequisites
- **🛡️ Safe Defaults** - Backs up existing configurations

## 🚀 **Quick Start**

```bash
# Standard installation (recommended)
./install.sh install standard

# Preview what would be installed
./install.sh --dry-run install full

# Check current status
./install.sh verify

# See available profiles
./install.sh profiles
```

## 📋 **Installation Profiles**

| Profile | Description | Tools Included |
|---------|-------------|----------------|
| **minimal** | Basic functionality only | zsh, git, curl, nvim, tmux |
| **standard** | Complete development environment | minimal + modern CLI tools + development tools |
| **full** | Everything including optional tools | standard + AI tools + optional utilities |
| **ai_focused** | AI-enhanced development | standard + AI tools (optimized for AI workflows) |

## 🛠️ **Tool Categories**

### **Essential Tools**
Core tools required for basic functionality:
- **zsh** - Modern shell with advanced features
- **git** - Version control system
- **curl** - Data transfer tool
- **nvim** - Modern text editor
- **tmux** - Terminal multiplexer

### **Modern CLI Tools**
Enhanced replacements for traditional commands:
- **starship** - Cross-shell prompt
- **zoxide** - Smart directory jumping
- **eza** - Modern ls replacement
- **bat** - Enhanced cat with syntax highlighting
- **ripgrep** - Fast text search
- **fd** - User-friendly find alternative
- **fzf** - Command-line fuzzy finder
- **atuin** - Magical shell history

### **Development Tools**
Version managers and development utilities:
- **mise** - Multi-language version manager
- **uv** - Fast Python package manager
- **bun** - JavaScript runtime and package manager
- **docker** - Containerization platform

### **AI Tools** (Optional)
AI-powered development assistance:
- **aider** - AI pair programming
- **gh_copilot** - GitHub Copilot CLI

### **Optional Tools**
Nice-to-have utilities:
- **tree** - Directory tree display
- **htop** - Interactive process viewer
- **jq** - JSON processor
- **yq** - YAML processor
- **delta** - Git diff syntax highlighting

## ⚙️ **Configuration**

### **Main Configuration File**
`config/tools.yaml` contains the complete tool definitions:

```yaml
tools:
  nvim:
    description: "Neovim - Modern text editor"
    category: "editor"
    install:
      macos: "brew install neovim"
      ubuntu: "sudo snap install nvim --classic"
      arch: "sudo pacman -S neovim"
    verify: "nvim --version"
```

### **Custom Profiles**
You can define custom installation profiles:

```yaml
profiles:
  my_custom:
    description: "My custom development setup"
    groups: ["essential", "modern_cli", "my_tools"]
```

### **Platform-Specific Commands**
Different installation commands for each platform:

```yaml
install:
  macos: "brew install tool-name"
  ubuntu: "sudo apt install tool-name"
  arch: "sudo pacman -S tool-name"
```

## 🔧 **Advanced Usage**

### **Dry Run Mode**
Preview installations without making changes:

```bash
# See what would be installed
./install.sh --dry-run install full

# Verbose dry run with detailed logging
./install.sh --dry-run --verbose install standard
```

### **Force Installation**
Reinstall tools even if they already exist:

```bash
# Force reinstall all tools
./install.sh --force install standard

# Force with verbose output
./install.sh --force --verbose install minimal
```

### **Custom Tool Installation**
Install individual tools or groups:

```bash
# Install specific tools (would require extending the script)
./install.sh install-tool nvim

# Install specific groups
./install.sh install-group development
```

### **Status and Verification**
Check your current setup:

```bash
# Detailed status of all tools
./install.sh verify

# List all available tools
./install.sh tools

# Show profiles
./install.sh profiles
```

## 🐛 **Troubleshooting**

### **Installation Failures**
1. **Check the log file**: `~/dotfiles-install.log`
2. **Verify package manager**: Ensure brew/apt/pacman is working
3. **Network connectivity**: Some tools require internet access
4. **Permissions**: Some installations may require sudo access

### **Tool Not Found**
1. **Check OS compatibility**: Tool may not be available on your platform
2. **Update package managers**: Run system updates first
3. **Manual installation**: Install missing prerequisites manually

### **Configuration Issues**
1. **YAML syntax**: Validate `config/tools.yaml` syntax
2. **Missing sections**: Ensure all required sections are present
3. **Tool definitions**: Verify tool install commands are correct

## 📈 **Benefits Over Legacy Install.sh**

| Feature | Legacy install.sh | Declarative System |
|---------|-------------------|-------------------|
| **Configuration** | Hardcoded in script | External YAML config |
| **Profiles** | Single installation | Multiple profiles available |
| **Dry Run** | Not available | Full preview mode |
| **Verification** | Manual checking | Automated verification |
| **Extensibility** | Requires script editing | Add to YAML config |
| **Maintainability** | Monolithic script | Modular, data-driven |
| **Platform Support** | Limited | Full cross-platform |

## 🔄 **Migration from Legacy**

To migrate from the legacy `install.sh`:

1. **Backup your current setup**:
   ```bash
   cp install.sh install.sh.backup
   ```

2. **Use the new declarative installer**:
   ```bash
   ./install.sh verify  # Check current status
   ./install.sh --dry-run install standard  # Preview
   ./install.sh install standard  # Install
   ```

3. **Update your workflows** to use the new system

## 🎯 **Next Steps**

1. **Try the verification**: `./install.sh verify`
2. **Preview an installation**: `./install.sh --dry-run install full`
3. **Explore profiles**: `./install.sh profiles`
4. **Customize the config**: Edit `config/tools.yaml` for your needs
5. **Create custom profiles**: Add your own installation profiles

## 🤝 **Contributing**

To add new tools or improve the system:

1. **Add tool definitions** to `config/tools.yaml`
2. **Test installation** with `--dry-run` mode
3. **Verify functionality** works across platforms
4. **Update documentation** as needed

Your dotfiles now have a **modern, declarative installation system** that's maintainable, extensible, and user-friendly! 🚀

---

**Related Documentation:**
- 📖 [Main Documentation](docs/README.md)
- 🏗️ [Modular Architecture](docs/modular-architecture.md)
- ⚡ [Performance Guide](docs/performance.md)