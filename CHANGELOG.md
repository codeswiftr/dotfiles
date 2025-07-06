# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2025.1.3] - 2025-01-07

### Added
- 🎓 **Interactive Tutorial**: Complete hands-on learning experience like `vimtutor`
- 📚 **Tutorial Guide**: Comprehensive documentation for the tutorial system
- 🚀 **10 Progressive Lessons**: From basics to advanced workflows
- 🎯 **Practice Environment**: Safe sandbox with sample projects
- 📱 **Menu-Driven Interface**: Choose lessons or follow sequential path
- ✨ **Command Verification**: Interactive learning with feedback
- 📎 **Global Access**: `dotfiles-tutor` command available anywhere
- 🗋 **Step-by-Step Learning**: Modern CLI tools, AI integration, navigation

### Enhanced
- 📦 **Installation Process**: Automatic tutorial setup during dotfiles installation
- 📚 **Documentation**: Updated README with tutorial prominence
- 🔄 **User Onboarding**: Interactive learning replaces static documentation
- 🎯 **Practical Training**: Real command practice vs theoretical learning

### Tutorial Curriculum
1. **Welcome & Setup** - Environment introduction
2. **Modern CLI Tools** - eza, bat, ripgrep, fd basics
3. **Smart Navigation** - zoxide, fzf mastery
4. **Project Management** - Switching and organization
5. **AI Integration** - AI-powered development workflows
6. **Tmux Sessions** - Terminal multiplexing mastery
7. **Neovim Navigation** - Multi-pane window management
8. **Development Workflow** - Complete practical session
9. **Advanced Features** - Power-user techniques
10. **Graduation** - Mastery certification and next steps

### Learning Experience
- **Interactive Practice**: Type real commands, get immediate feedback
- **Progressive Difficulty**: Build skills from basic to advanced
- **Visual Design**: Color-coded, emoji-enhanced interface
- **Self-Contained**: Complete practice environment included
- **Resumable**: Pick up where you left off

## [2025.1.2] - 2025-01-07

### Added
- 🐧 **Cross-Platform Support**: Full Ubuntu support alongside macOS
- 📱 **OS Detection**: Automatic detection of macOS vs Ubuntu systems
- 📦 **Ubuntu Package Management**: APT-based installation with proper dependency handling
- 🔧 **Platform-Specific Tool Installation**: Homebrew for macOS, APT + direct installs for Ubuntu
- 🛠️ **Enhanced Neovim Navigation**: Comprehensive multi-pane window management
- 🧭 **Navigation Guide**: Complete documentation for enhanced pane navigation
- 🔄 **Robust Installation**: Improved error handling and PATH management
- ✅ **Symlink Management**: Proper handling of Ubuntu-specific binary names (fd/bat)

### Enhanced
- 🚀 **Single-Command Installation**: Now works on both clean Ubuntu and clean macOS
- 📋 **Buffer Management**: Visual buffer line with enhanced navigation shortcuts
- 🎯 **Window Layouts**: Multi-pane preset layouts (horizontal, vertical, grid, coding)
- 🔧 **Session Management**: Advanced session persistence with project awareness
- 📚 **Documentation**: Updated README with cross-platform installation instructions

### Technical Improvements
- **OS-Specific Installation Paths**: Proper tool installation for each platform
- **PATH Management**: Enhanced PATH handling across different systems
- **Error Recovery**: Better error handling and rollback capabilities
- **Version Compatibility**: Maintained compatibility with existing configurations

### Installation Methods
- **Ubuntu**: APT packages + official installers + GitHub releases
- **macOS**: Homebrew packages (unchanged)
- **Cross-Platform**: mise, uv, bun work on both systems

## [2025.1.1] - 2025-01-07

### Fixed
- 🔧 **LSP Deprecation Warnings**: Fixed `ruff_lsp is deprecated, use ruff instead` warning
- 🔧 **TypeScript LSP**: Fixed `tsserver is deprecated, use ts_ls instead` warning
- 🔧 **Mason Configuration**: Updated LSP server names in mason-lspconfig
- 🔧 **Conform Setup**: Updated ruff formatter configuration for new server
- 🔄 **Migration System**: Added automatic migration for LSP server updates

### Changed
- ⬆️ **LSP Servers**: Updated from `ruff_lsp` → `ruff` and `tsserver` → `ts_ls`
- ⬆️ **Python Formatting**: Updated conform configuration for new ruff setup
- 📚 **Documentation**: Updated LSP server references in comments

### Migration Notes
- Existing installations will automatically migrate deprecated LSP servers
- No manual intervention required - migration runs automatically on update
- Old LSP servers are cleanly removed and replaced with new ones

## [2025.1.0] - 2025-01-07

### Added
- 🚀 Complete modern dotfiles setup with AI integration
- 🤖 Claude Code CLI and Gemini CLI integration
- 🐍 Modern Python development environment (uv, ruff, mise)
- 📦 Node.js/Bun development setup
- 🍎 Swift/iOS development support
- ✏️ Neovim with native LSP and AI integration
- 🖥️ Tmux with AI-powered session management
- 🔧 Modern CLI tools (starship, zoxide, eza, bat, ripgrep, fd, fzf)
- 🎯 Smart project switching and session management
- 📊 Git enhancements with delta and modern workflow
- 🔄 One-command installation system
- 🛡️ Automatic backup and recovery system
- ✅ Comprehensive verification and testing

### Features
- **AI Integration**: Context-aware AI prompting with Claude Code and Gemini
- **Multi-AI Comparison**: Compare responses from different AI models
- **Project Intelligence**: Automatic project type detection and setup
- **Smart Navigation**: Enhanced file operations and directory jumping
- **Session Management**: Tmux sessions optimized for different project types
- **Modern Shell**: Starship prompt with enhanced history and completion
- **Development Tools**: Language-specific optimizations for Python, JS, Swift

### Installation
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/master/install.sh)"
```

### Breaking Changes
- N/A (Initial release)

### Migration Notes
- N/A (Initial release)