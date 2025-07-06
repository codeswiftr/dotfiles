# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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