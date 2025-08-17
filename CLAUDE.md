# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modern, enterprise-grade dotfiles repository featuring progressive complexity, intelligent performance optimization, and comprehensive development tools. The system supports multiple platforms (macOS, Linux, WSL) with tier-based configurations for shell, tmux, and Neovim.

## Common Development Commands

### Installation and Setup
```bash
# Install with default profile
./install.sh install standard

# Install specific profile
./install.sh install minimal     # Essential tools only
./install.sh install full        # Complete setup with AI tools
./install.sh install ai_focused  # AI-enhanced development

# Preview installation (dry run)
./install.sh --dry-run install standard

# Link dotfiles only (skip tool installation)
./install.sh link
```

### DOT CLI - Main Interface
```bash
# Core operations
dot setup              # Idempotent environment setup
dot check              # Comprehensive health validation
dot update             # Update all components
dot reload             # Reload shell configuration

# Development workflow
dot project init       # Create new project
dot ai review          # AI code review  
dot security scan      # Security audit

# System management
dot metrics dashboard  # View system metrics
dot plugin list        # Manage plugins
dot migrate status     # Check for updates
```

### Testing and Quality Assurance
```bash
# Run comprehensive test suite
./tests/test_runner.sh

# Quick validation
dot test quick

# Run specific test categories
./tests/test_runner.sh --category infrastructure

# Linting
find . -name "*.sh" -exec shellcheck {} \;
find . -name "*.yaml" -o -name "*.yml" | xargs yamllint
```

### Build and Validation Commands
```bash
# Health check and validation
dot check                    # Full system health check
dot doctor                   # Diagnose issues
dot test run                 # Run all tests

# Performance monitoring
perf-status                  # Check performance
perf-bench                   # Run benchmarks
perf-quick                   # One-command optimization
```

## Architecture Overview

### Core Structure
- **`bin/`** - DOT CLI and utilities (main interface)
- **`config/`** - Configuration templates and core configs
- **`lib/`** - Core libraries organized by functionality
- **`plugins/`** - Modular plugin system
- **`scripts/`** - Installation and utility scripts
- **`tests/`** - Comprehensive testing framework

### Key Components

#### DOT CLI System
The main interface is the `dot` command located in `bin/dot`. It orchestrates all operations through modular CLI libraries in `lib/cli/`:
- `core.sh` - Setup, check, update commands
- `ai.sh` - AI integration and code assistance
- `security.sh` - Security scanning and hardening
- `project.sh` - Project initialization and management
- `testing.sh` - Test execution and reporting

#### Configuration Management
- **Declarative approach**: All tools defined in `config/tools.yaml`
- **Profile-based installation**: minimal, standard, full, ai_focused
- **Platform detection**: Automatic OS/distro detection with appropriate package managers
- **Tier-based complexity**: Progressive feature unlocking for shell, tmux, and Neovim

#### Plugin Architecture
- **Core plugins**: `plugins/core/` - Essential functionality
- **Community plugins**: `plugins/community/` - External contributions  
- **Local plugins**: `plugins/local/` - User customizations
- **Plugin template**: Use `plugins/local/hello-world/` as reference

### Neovim Configuration
Tier-based system with progressive complexity:
- **Tier 1**: 8 essential plugins for basic functionality
- **Tier 2**: 23 plugins for enhanced development
- **Tier 3**: 33+ plugins for advanced features

Configuration structure:
- `config/nvim/init.lua` - Main entry point
- `config/nvim/lua/core/` - Core configurations and tier management
- `config/nvim/lua/tiers/` - Tier-specific plugin definitions
- `config/nvim/lua/languages/` - Language-specific settings

### Tmux Configuration
Streamlined from 66 to 10 essential keybindings with tier system:
- `config/tmux/tmux.conf` - Main configuration
- `config/tmux/core.conf` - Core keybindings and settings
- Essential bindings: Ctrl-a prefix, hjkl navigation, | and - for splits

### Shell Environment
Optimized Zsh configuration with performance tiers:
- `config/zsh/` - Modular shell configuration
- Performance modes: fast (<300ms), balanced (<500ms), full (<1000ms)
- Auto-detection of system resources and optimization
- Enhanced autosuggestions and history management

## Development Workflows

### Adding New Tools
1. Edit `config/tools.yaml` to define the tool
2. Add to appropriate group (essential, development, optional)
3. Test with `./install.sh --dry-run install standard`
4. Run tests: `./tests/test_runner.sh`

### Creating Plugins
1. Copy `plugins/local/hello-world/` as template
2. Implement required functions in `lib/core.sh`
3. Define plugin metadata in `plugin.yaml`
4. Test with `dot plugin install <plugin-name>`

### Testing Changes
1. Always run the full test suite: `./tests/test_runner.sh`
2. Test specific components: `dot test <component>`
3. Validate linting: shellcheck and yamllint
4. Check cross-platform compatibility

### Security Considerations
- All secrets handled through `dot secret` commands
- GPG and SSH key management automated
- Secret scanning with gitleaks integration
- Global git hooks with pre-commit validation

## Important File Locations

### Configuration Files
- `config/tools.yaml` - Tool definitions and installation profiles
- `config/gitconfig` - Git configuration template
- `config/shellcheckrc` - Shellcheck linting rules
- `config/yamllint.yml` - YAML linting configuration

### Key Scripts
- `install.sh` - Main installer (declarative, idempotent)
- `scripts/bootstrap.sh` - One-line installation entry point
- `tests/test_runner.sh` - Comprehensive testing framework
- `bin/dot` - Main CLI interface

### Documentation
- `README.md` - Complete user guide and feature overview
- `docs/` - Extensive documentation covering all aspects
- `CONTRIBUTING.md` - Guidelines for contributors
- `docs/technical-debt.md` - Current gaps and improvement opportunities

## Performance and Optimization

The system includes advanced performance optimization:
- Shell startup times: 3-5x faster than typical configurations
- Lazy loading for all tools and completions
- Intelligent caching with automatic invalidation
- Resource-aware configuration based on system capabilities
- Progressive complexity that scales with user needs

## Platform Support

Full cross-platform compatibility:
- **macOS**: Homebrew-based installation
- **Linux**: APT (Ubuntu/Debian), Pacman (Arch), YAY (AUR)
- **WSL**: Windows Subsystem for Linux support
- **CI/CD**: Agent mode for non-interactive environments