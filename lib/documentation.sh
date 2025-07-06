#!/usr/bin/env bash
# =============================================================================
# Comprehensive Documentation System
# Advanced documentation generation, management, and interactive help
# =============================================================================

# Documentation configuration
DOCS_DIR="$DOTFILES_DIR/docs"
DOCS_BUILD_DIR="$DOCS_DIR/_build"
DOCS_CACHE_DIR="$HOME/.cache/dotfiles/docs"
DOCS_CONFIG_FILE="$DOCS_DIR/config.yaml"

# Documentation structure
declare -A DOC_CATEGORIES=(
    ["getting-started"]="Getting Started Guide"
    ["installation"]="Installation Instructions"
    ["configuration"]="Configuration Guide"
    ["cli-reference"]="CLI Command Reference"
    ["troubleshooting"]="Troubleshooting Guide"
    ["development"]="Development Guide"
    ["api"]="API Documentation"
    ["examples"]="Examples and Tutorials"
    ["changelog"]="Change Log"
    ["contributing"]="Contributing Guide"
)

# Initialize documentation system
init_documentation() {
    mkdir -p "$DOCS_DIR" "$DOCS_BUILD_DIR" "$DOCS_CACHE_DIR"
    
    # Create documentation config if it doesn't exist
    if [[ ! -f "$DOCS_CONFIG_FILE" ]]; then
        create_docs_config
    fi
    
    # Initialize documentation structure
    create_docs_structure
}

# Create documentation configuration
create_docs_config() {
    cat > "$DOCS_CONFIG_FILE" << EOF
# Documentation Configuration
project:
  name: "Modern Dotfiles"
  version: "2025.1.0"
  description: "Comprehensive development environment setup"
  author: "$USER"
  repository: "https://github.com/$USER/dotfiles"

build:
  output_dir: "_build"
  theme: "modern"
  syntax_highlighting: true
  search_enabled: true
  
navigation:
  - Getting Started: "getting-started.md"
  - Installation: "installation.md" 
  - Configuration: "configuration.md"
  - CLI Reference: "cli-reference.md"
  - Troubleshooting: "troubleshooting.md"
  
features:
  auto_generate: true
  include_examples: true
  generate_api_docs: true
  interactive_help: true
  
formats:
  - markdown
  - html
  - pdf
EOF
}

# Create documentation structure
create_docs_structure() {
    # Create main documentation directories
    for category in "${!DOC_CATEGORIES[@]}"; do
        mkdir -p "$DOCS_DIR/$category"
    done
    
    # Create additional directories
    mkdir -p "$DOCS_DIR"/{assets,templates,examples,api}
}

# Generate comprehensive documentation
generate_documentation() {
    local format="${1:-markdown}"
    local category="${2:-all}"
    
    echo "📚 Generating documentation (format: $format, category: $category)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case "$category" in
        "all")
            generate_all_documentation "$format"
            ;;
        "cli")
            generate_cli_documentation "$format"
            ;;
        "api")
            generate_api_documentation "$format"
            ;;
        "examples")
            generate_examples_documentation "$format"
            ;;
        *)
            generate_category_documentation "$category" "$format"
            ;;
    esac
    
    echo "✅ Documentation generation complete"
}

# Generate all documentation
generate_all_documentation() {
    local format="$1"
    
    # Generate main documentation files
    generate_getting_started_docs
    generate_installation_docs
    generate_configuration_docs
    generate_cli_documentation "$format"
    generate_troubleshooting_docs
    generate_development_docs
    generate_api_documentation "$format"
    generate_examples_documentation "$format"
    generate_changelog_docs
    
    # Generate index/README
    generate_main_readme
    
    # Build documentation site if HTML format
    if [[ "$format" == "html" ]]; then
        build_html_documentation
    fi
}

# Generate getting started documentation
generate_getting_started_docs() {
    echo "📖 Generating getting started guide..."
    
    cat > "$DOCS_DIR/getting-started.md" << EOF
# Getting Started with Modern Dotfiles

Welcome to your modern development environment! This guide will help you get up and running quickly.

## Quick Start

\`\`\`bash
# Clone and install
git clone https://github.com/$USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh install standard
\`\`\`

## What's Included

### 🔧 Modern CLI Tools
- **Starship**: Cross-shell prompt
- **Zoxide**: Smart directory navigation
- **Eza**: Modern ls replacement
- **Bat**: Cat with syntax highlighting
- **Ripgrep**: Fast text search
- **FZF**: Fuzzy finder

### 🤖 AI Integration
- AI-powered code review
- Smart commit messages
- Automated test generation
- Code explanation and optimization

### 🎯 Development Features
- Multi-language version management (mise)
- Modern package managers (uv, bun)
- Comprehensive testing framework
- Performance monitoring

### 🖥️ Cross-Platform Support
- macOS (Intel & Apple Silicon)
- Linux (Ubuntu, Arch, RHEL)
- Windows (WSL)

## First Steps

1. **Explore the CLI**: Run \`dot --help\` to see all available commands
2. **Customize**: Edit configurations in \`config/\` directory
3. **Add Tools**: Modify \`config/tools.yaml\` to add your preferred tools
4. **Set up AI**: Configure AI providers with \`dot ai setup\`
5. **Monitor Performance**: Use \`dot perf analyze\` to optimize your setup

## Next Steps

- [Installation Guide](installation.md) - Detailed installation options
- [Configuration Guide](configuration.md) - Customize your environment
- [CLI Reference](cli-reference.md) - Complete command documentation
- [Examples](examples/) - Common use cases and workflows
EOF
}

# Generate installation documentation
generate_installation_docs() {
    echo "📖 Generating installation guide..."
    
    cat > "$DOCS_DIR/installation.md" << EOF
# Installation Guide

Comprehensive installation instructions for all platforms and configurations.

## System Requirements

- **Operating System**: macOS 10.15+, Ubuntu 20.04+, or Windows 10+ (WSL)
- **Shell**: Bash 4.0+ or Zsh 5.0+
- **Git**: Version 2.20+
- **Storage**: 500MB free space

## Installation Methods

### 🚀 Automated Installation (Recommended)

\`\`\`bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/$USER/dotfiles/main/install.sh | bash
\`\`\`

### 📦 Manual Installation

\`\`\`bash
# Clone repository
git clone https://github.com/$USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run installer
./install.sh install standard
\`\`\`

### 🎯 Installation Profiles

- **minimal**: Essential tools only
- **standard**: Full featured setup (recommended)
- **development**: Development-focused with AI tools
- **ai_focused**: AI-enhanced development environment

\`\`\`bash
# Install specific profile
./install.sh install ai_focused
\`\`\`

## Platform-Specific Setup

### macOS

\`\`\`bash
# Install Xcode command line tools
xcode-select --install

# Install Homebrew (if not present)
/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Run dotfiles installer
./install.sh install standard
\`\`\`

### Linux (Ubuntu/Debian)

\`\`\`bash
# Update package lists
sudo apt update

# Install required packages
sudo apt install -y git curl build-essential

# Run dotfiles installer
./install.sh install standard
\`\`\`

### Windows (WSL)

\`\`\`bash
# Install WSL2 and Ubuntu
wsl --install -d Ubuntu

# Update and install packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential

# Run dotfiles installer
./install.sh install standard
\`\`\`

## Configuration

### Environment Variables

\`\`\`bash
# Optional: Set custom dotfiles location
export DOTFILES_DIR="/path/to/dotfiles"

# Optional: Enable fast mode for quicker startup
export DOTFILES_FAST_MODE=1

# Optional: Set AI provider
export DOTFILES_AI_PROVIDER="claude"
\`\`\`

### Post-Installation

1. **Restart your shell** or run \`dot reload\`
2. **Run health check**: \`dot check\`
3. **Configure AI**: \`dot ai setup\`
4. **Optimize performance**: \`dot perf optimize\`

## Troubleshooting

### Common Issues

- **Permission denied**: Run with appropriate permissions
- **Command not found**: Ensure \`~/.dotfiles/bin\` is in PATH
- **Slow startup**: Enable fast mode or run \`dot perf optimize\`

### Getting Help

- Run \`dot check\` for system diagnostics
- Check logs in \`~/.local/share/dotfiles/logs/\`
- Visit [troubleshooting guide](troubleshooting.md)
EOF
}

# Generate configuration documentation
generate_configuration_docs() {
    echo "📖 Generating configuration guide..."
    
    cat > "$DOCS_DIR/configuration.md" << EOF
# Configuration Guide

Customize your dotfiles environment to match your preferences and workflow.

## Configuration Structure

\`\`\`
config/
├── tools.yaml          # Tool installation and configuration
├── ai.yaml             # AI provider settings
├── aliases.yaml        # Custom aliases
├── environment.yaml    # Environment variables
├── templates.yaml      # Template processing rules
├── themes/             # Color schemes and themes
├── platform/           # Platform-specific configs
└── user/               # User-specific overrides
\`\`\`

## Key Configuration Files

### 🔧 tools.yaml

Define which tools to install and their configurations:

\`\`\`yaml
tools:
  development:
    - name: "node"
      version: "lts"
      manager: "mise"
    - name: "python"
      version: "3.11"
      manager: "mise"
  
  utilities:
    - name: "ripgrep"
      manager: "brew"
    - name: "bat"
      manager: "brew"
\`\`\`

### 🤖 ai.yaml

Configure AI providers and settings:

\`\`\`yaml
ai:
  default_provider: "claude"
  providers:
    claude:
      api_key: "\${ANTHROPIC_API_KEY}"
      model: "claude-3-5-sonnet-20241022"
    openai:
      api_key: "\${OPENAI_API_KEY}"
      model: "gpt-4"
\`\`\`

### 🎨 Themes

Customize your shell appearance:

\`\`\`bash
# Switch themes
dot config theme

# Available themes: default, minimal, vibrant, professional
dot config theme vibrant
\`\`\`

## Customization Examples

### Custom Aliases

\`\`\`yaml
# config/aliases.yaml
aliases:
  development:
    - alias: "gp"
      command: "git push"
    - alias: "gs"
      command: "git status"
  
  navigation:
    - alias: "ll"
      command: "eza -la"
    - alias: "tree"
      command: "eza --tree"
\`\`\`

### Environment Variables

\`\`\`yaml
# config/environment.yaml
environment:
  development:
    EDITOR: "nvim"
    BROWSER: "firefox"
    PAGER: "bat"
  
  performance:
    DOTFILES_FAST_MODE: "1"
    HOMEBREW_NO_AUTO_UPDATE: "1"
\`\`\`

### Platform-Specific Settings

\`\`\`yaml
# config/platform/macos.yaml
platform:
  macos:
    defaults:
      - domain: "com.apple.dock"
        key: "autohide"
        value: "true"
    
    packages:
      - "rectangle"  # Window manager
      - "raycast"    # Spotlight replacement
\`\`\`

## Advanced Configuration

### Template Processing

Create dynamic configurations using templates:

\`\`\`bash
# Create template
dot template create ~/.gitconfig

# Process all templates
dot template process
\`\`\`

### Profile Management

Switch between different configuration profiles:

\`\`\`bash
# Available profiles: minimal, standard, development, ai_focused
dot config profile development
\`\`\`

### User Overrides

Create user-specific configurations that won't be tracked:

\`\`\`yaml
# config/user/local.yaml (git-ignored)
user:
  git:
    name: "Your Name"
    email: "your.email@example.com"
  
  ai:
    preferred_provider: "claude"
\`\`\`

## Configuration Management

### Backup and Restore

\`\`\`bash
# Backup current configuration
dot config backup

# Restore from backup
dot config restore
\`\`\`

### Validation

\`\`\`bash
# Validate configuration files
dot config validate

# Check for syntax errors
dot template validate
\`\`\`

### Synchronization

\`\`\`bash
# Sync configuration across machines
dot config sync

# Export portable configuration
dot config export
\`\`\`
EOF
}

# Generate CLI documentation
generate_cli_documentation() {
    local format="$1"
    echo "📖 Generating CLI reference..."
    
    cat > "$DOCS_DIR/cli-reference.md" << EOF
# CLI Reference

Comprehensive reference for all DOT CLI commands.

## Core Commands

### dot setup
Initialize and configure the development environment.

\`\`\`bash
dot setup                    # Interactive setup
dot setup --profile standard # Use specific profile
dot setup --force           # Force reinstall
\`\`\`

### dot check
Validate system health and configuration.

\`\`\`bash
dot check                    # Full system check
dot check --quick           # Quick health check
dot check --fix             # Auto-fix issues
\`\`\`

### dot update
Update the entire development environment.

\`\`\`bash
dot update                   # Update everything
dot update --tools-only     # Update tools only
dot update --config-only    # Update configs only
\`\`\`

## Development Commands

### dot project
Project management and scaffolding.

\`\`\`bash
dot project init fastapi     # Create FastAPI project
dot project list             # List available templates
dot project switch           # Switch between projects
\`\`\`

### dot ai
AI-powered development assistance.

\`\`\`bash
dot ai review src/main.py    # AI code review
dot ai commit                # Generate commit message
dot ai test src/             # Generate tests
dot ai explain function_name # Explain code
\`\`\`

### dot test
Testing framework integration.

\`\`\`bash
dot test run                 # Run all tests
dot test quick              # Quick smoke tests
dot test watch              # Watch mode
dot test coverage           # Generate coverage report
\`\`\`

## Performance Commands

### dot perf
Performance monitoring and optimization.

\`\`\`bash
dot perf analyze            # Performance analysis
dot perf optimize           # Apply optimizations
dot perf benchmark          # Benchmark startup time
dot perf monitor            # Start monitoring
\`\`\`

## Security Commands

### dot secret
Secret management.

\`\`\`bash
dot secret get API_KEY      # Retrieve secret
dot secret exec -- npm start # Run with secrets
\`\`\`

### dot security
Security operations.

\`\`\`bash
dot security scan           # Security audit
dot security deps           # Check dependencies
dot security code           # Static analysis
\`\`\`

## Configuration Commands

### dot config
Interactive configuration management.

\`\`\`bash
dot config theme            # Change theme
dot config tools            # Configure tools
dot config backup           # Backup configuration
\`\`\`

### dot template
Template processing and management.

\`\`\`bash
dot template process        # Process all templates
dot template create file    # Create template from file
dot template validate       # Validate templates
\`\`\`

## Global Options

- \`-h, --help\`: Show help message
- \`-v, --version\`: Show version information
- \`--verbose\`: Enable verbose output
- \`--dry-run\`: Show what would be done
- \`--force\`: Force operation
- \`--quiet\`: Suppress output

## Environment Variables

- \`DOTFILES_DIR\`: Custom dotfiles location
- \`DOTFILES_FAST_MODE\`: Enable fast mode
- \`DOTFILES_AI_PROVIDER\`: Default AI provider
- \`DOTFILES_PROFILE\`: Configuration profile
- \`DOTFILES_LOG_LEVEL\`: Logging level

## Exit Codes

- \`0\`: Success
- \`1\`: General error
- \`2\`: Invalid arguments
- \`3\`: Permission denied
- \`4\`: Not found
- \`5\`: Configuration error
EOF
}

# Generate troubleshooting documentation
generate_troubleshooting_docs() {
    echo "📖 Generating troubleshooting guide..."
    
    cat > "$DOCS_DIR/troubleshooting.md" << EOF
# Troubleshooting Guide

Common issues and solutions for the Modern Dotfiles environment.

## Quick Diagnostics

\`\`\`bash
# Run comprehensive health check
dot check

# Check system performance
dot perf analyze

# Validate configuration
dot config validate
\`\`\`

## Common Issues

### Installation Problems

#### Permission Denied
**Problem**: Permission errors during installation

**Solution**:
\`\`\`bash
# Fix permissions
sudo chown -R \$USER ~/.dotfiles
chmod +x ~/.dotfiles/install.sh
\`\`\`

#### Command Not Found
**Problem**: \`dot\` command not found after installation

**Solution**:
\`\`\`bash
# Add to PATH
echo 'export PATH="\$HOME/.dotfiles/bin:\$PATH"' >> ~/.zshrc
source ~/.zshrc
\`\`\`

### Performance Issues

#### Slow Shell Startup
**Problem**: Shell takes too long to start

**Solution**:
\`\`\`bash
# Enable fast mode
export DOTFILES_FAST_MODE=1

# Optimize performance
dot perf optimize

# Profile startup time
dot perf benchmark
\`\`\`

#### High Memory Usage
**Problem**: Excessive memory consumption

**Solution**:
\`\`\`bash
# Check resource usage
dot perf monitor

# Clean up caches
dot perf cache clean

# Optimize system
dot perf optimize
\`\`\`

### Configuration Issues

#### Missing Environment Variables
**Problem**: Tools not finding required variables

**Solution**:
\`\`\`bash
# Check environment
dot config validate

# Reload configuration
dot reload

# Set missing variables
echo 'export VARIABLE_NAME="value"' >> ~/.zshrc
\`\`\`

#### Template Processing Errors
**Problem**: Template processing fails

**Solution**:
\`\`\`bash
# Validate templates
dot template validate

# Check syntax
dot template list

# Process with verbose output
dot template process --verbose
\`\`\`

### AI Integration Issues

#### API Key Not Found
**Problem**: AI commands fail with authentication errors

**Solution**:
\`\`\`bash
# Configure AI provider
dot ai setup

# Set API key
export ANTHROPIC_API_KEY="your-key"

# Test connection
dot ai test
\`\`\`

#### Rate Limiting
**Problem**: API rate limits exceeded

**Solution**:
\`\`\`bash
# Check usage
dot ai status

# Switch provider
dot ai provider openai

# Wait and retry
sleep 60 && dot ai commit
\`\`\`

## Platform-Specific Issues

### macOS

#### Homebrew Issues
**Problem**: Homebrew installation or update failures

**Solution**:
\`\`\`bash
# Update Homebrew
brew update && brew upgrade

# Clean up
brew cleanup

# Fix permissions
sudo chown -R \$(whoami) \$(brew --prefix)/*
\`\`\`

#### Xcode Command Line Tools
**Problem**: Missing development tools

**Solution**:
\`\`\`bash
# Install Xcode CLI tools
xcode-select --install

# Accept license
sudo xcodebuild -license accept
\`\`\`

### Linux

#### Package Manager Issues
**Problem**: Package installation failures

**Solution**:
\`\`\`bash
# Update package lists
sudo apt update

# Fix broken packages
sudo apt --fix-broken install

# Clean cache
sudo apt clean
\`\`\`

#### Missing Dependencies
**Problem**: Build tools not found

**Solution**:
\`\`\`bash
# Install build essentials
sudo apt install build-essential

# Install development headers
sudo apt install libssl-dev libffi-dev
\`\`\`

### Windows (WSL)

#### WSL Configuration
**Problem**: WSL environment issues

**Solution**:
\`\`\`bash
# Update WSL
wsl --update

# Reset WSL instance
wsl --terminate Ubuntu
wsl
\`\`\`

## Advanced Troubleshooting

### Log Analysis

\`\`\`bash
# Check installation logs
tail -f ~/.local/share/dotfiles/logs/install.log

# Monitor performance logs
tail -f ~/.local/share/dotfiles/logs/performance.log

# View error logs
grep ERROR ~/.local/share/dotfiles/logs/*.log
\`\`\`

### Debug Mode

\`\`\`bash
# Enable debug logging
export DOTFILES_DEBUG=1

# Run with verbose output
dot check --verbose

# Trace execution
bash -x ~/.dotfiles/install.sh
\`\`\`

### Recovery

\`\`\`bash
# Backup current state
dot backup create

# Reset to clean state
dot reset --hard

# Restore from backup
dot backup restore
\`\`\`

## Getting Help

### Self-Diagnosis

1. Run \`dot check\` for automated diagnosis
2. Check logs in \`~/.local/share/dotfiles/logs/\`
3. Validate configuration with \`dot config validate\`
4. Test performance with \`dot perf analyze\`

### Community Support

- **GitHub Issues**: Report bugs and request features
- **Discussions**: Ask questions and share solutions
- **Documentation**: Check the latest docs
- **Examples**: Browse real-world configurations

### Useful Commands

\`\`\`bash
# System information
dot version
uname -a

# Environment check
echo \$SHELL
echo \$PATH
env | grep DOTFILES

# Tool versions
git --version
zsh --version
python3 --version
\`\`\`
EOF
}

# Generate development documentation
generate_development_docs() {
    echo "📖 Generating development guide..."
    
    cat > "$DOCS_DIR/development.md" << EOF
# Development Guide

Contribute to and extend the Modern Dotfiles project.

## Development Setup

\`\`\`bash
# Clone repository
git clone https://github.com/$USER/dotfiles.git
cd dotfiles

# Install development dependencies
./install.sh install development

# Set up pre-commit hooks
dot setup dev-hooks
\`\`\`

## Project Structure

\`\`\`
.
├── bin/                    # Executable scripts
│   └── dot                # Main CLI entry point
├── config/                # Configuration files
│   ├── tools.yaml        # Tool definitions
│   ├── ai.yaml           # AI provider settings
│   └── templates.yaml    # Template processing
├── lib/                   # Core libraries
│   ├── cli/              # CLI command modules
│   ├── core.sh           # Core functionality
│   ├── platform.sh       # Platform detection
│   └── templating.sh     # Template engine
├── templates/             # Configuration templates
├── docs/                  # Documentation
├── tests/                 # Test suites
└── hooks/                 # Git hooks
\`\`\`

## Architecture

### Core Components

1. **CLI System**: Modular command structure
2. **Platform Detection**: Cross-platform compatibility
3. **Template Engine**: Dynamic configuration generation
4. **AI Integration**: Provider abstraction layer
5. **Performance Monitoring**: Optimization framework

### Design Principles

- **Modularity**: Each component is self-contained
- **Extensibility**: Easy to add new features
- **Cross-platform**: Works on macOS, Linux, Windows
- **Performance**: Optimized for fast startup
- **User-friendly**: Clear documentation and help

## Development Workflow

### Testing

\`\`\`bash
# Run all tests
dot test run

# Run specific test suite
dot test run unit

# Run tests in watch mode
dot test watch

# Generate coverage report
dot test coverage
\`\`\`

### Code Quality

\`\`\`bash
# Lint shell scripts
shellcheck lib/**/*.sh

# Format code
shfmt -w lib/**/*.sh

# Security scan
dot security scan
\`\`\`

### Documentation

\`\`\`bash
# Generate documentation
dot docs generate

# Serve documentation locally
dot docs serve

# Update CLI reference
dot docs cli-reference
\`\`\`

## Adding New Features

### CLI Commands

1. Create command module in \`lib/cli/\`
2. Add command to \`bin/dot\` dispatcher
3. Write tests in \`tests/\`
4. Update documentation

### Example: Adding a new command

\`\`\`bash
# Create command module
cat > lib/cli/example.sh << 'EOF'
#!/usr/bin/env bash
# Example command implementation

dot_example() {
    echo "Hello from example command!"
}
EOF

# Add to main CLI
# In bin/dot, add:
#   "example")
#       load_cli_lib "example"
#       dot_example "\$@"
#       ;;
\`\`\`

### Platform Support

1. Add platform detection in \`lib/platform.sh\`
2. Create platform-specific configurations
3. Update installation scripts
4. Test on target platform

### AI Providers

1. Implement provider interface in \`lib/ai-integration.sh\`
2. Add provider configuration to \`config/ai.yaml\`
3. Update AI command handlers
4. Test API integration

## Testing

### Test Structure

\`\`\`
tests/
├── unit/                  # Unit tests
│   ├── core_test.sh      # Core functionality
│   └── platform_test.sh  # Platform detection
├── integration/           # Integration tests
│   ├── cli_test.sh       # CLI commands
│   └── ai_test.sh        # AI integration
├── e2e/                   # End-to-end tests
│   └── install_test.sh   # Installation workflow
└── fixtures/              # Test data
\`\`\`

### Writing Tests

\`\`\`bash
# Test template
cat > tests/unit/example_test.sh << 'EOF'
#!/usr/bin/env bash
# Example test

source "\$(dirname "\$0")/../../lib/core.sh"
source "\$(dirname "\$0")/test_helpers.sh"

test_example_function() {
    # Test implementation
    local result=\$(example_function "input")
    assert_equals "expected" "\$result"
}

run_tests
EOF
\`\`\`

## Performance Optimization

### Profiling

\`\`\`bash
# Profile shell startup
dot perf benchmark

# Monitor resource usage
dot perf monitor

# Analyze bottlenecks
dot perf analyze
\`\`\`

### Optimization Strategies

1. **Lazy Loading**: Load modules on demand
2. **Caching**: Cache expensive operations
3. **Parallel Processing**: Use background jobs
4. **Minimal Dependencies**: Reduce startup overhead

## Release Process

### Version Management

\`\`\`bash
# Update version
echo "2.0.0" > VERSION

# Create release
git tag -a v2.0.0 -m "Release v2.0.0"
git push origin v2.0.0
\`\`\`

### Release Checklist

- [ ] Update VERSION file
- [ ] Update CHANGELOG.md
- [ ] Run full test suite
- [ ] Test on all platforms
- [ ] Update documentation
- [ ] Create GitHub release
- [ ] Update installation scripts

## Contributing

### Pull Request Process

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Update documentation
5. Submit pull request

### Code Style

- Follow existing conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Test all new functionality

### Commit Messages

\`\`\`
feat: add new AI provider support
fix: resolve shell startup performance issue
docs: update installation guide
test: add unit tests for templating engine
\\`\\`\\`

## Getting Help

- Run \\\\`dot <command> --help\\\\` for command-specific help
- Check [Troubleshooting Guide](troubleshooting.md) for common issues
- Use \\\\`dot ai explain <file>\\\\` for AI-powered code explanations

Welcome to your enhanced development environment! 🚀
EOF
}

# Generate installation documentation
generate_installation_docs() {
    echo "📖 Generating installation guide..."
    
    cat > "$DOCS_DIR/installation.md" << EOF
# Installation Guide

Complete installation instructions for all supported platforms.

## Prerequisites

### macOS
- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools: \`xcode-select --install\`
- Homebrew (will be installed automatically if missing)

### Linux
- Ubuntu 20.04+, Arch Linux, or RHEL 8+
- Git and curl installed
- Sudo access for package installation

### Windows
- Windows 10/11 with WSL2
- Git for Windows (if not using WSL)

## Installation Methods

### Standard Installation (Recommended)

\`\`\`bash
# Clone repository
git clone https://github.com/$USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install with standard profile
./install.sh install standard
\`\`\`

### Installation Profiles

#### Minimal Profile
Basic tools and configuration:
\`\`\`bash
./install.sh install minimal
\`\`\`

#### Standard Profile (Recommended)
Complete development environment:
\`\`\`bash
./install.sh install standard
\`\`\`

#### Full Profile
Everything including optional tools:
\`\`\`bash
./install.sh install full
\`\`\`

#### AI-Focused Profile
AI-enhanced development setup:
\`\`\`bash
./install.sh install ai_focused
\`\`\`

## Platform-Specific Installation

### macOS Installation

\`\`\`bash
# Apple Silicon (M1/M2/M3) Macs
arch -arm64 ./install.sh install standard

# Intel Macs
arch -x86_64 ./install.sh install standard
\`\`\`

### Linux Installation

#### Ubuntu/Debian
\`\`\`bash
# Update package manager
sudo apt update

# Install dotfiles
./install.sh install standard
\`\`\`

#### Arch Linux
\`\`\`bash
# Update system
sudo pacman -Syu

# Install dotfiles
./install.sh install standard
\`\`\`

#### RHEL/CentOS/Fedora
\`\`\`bash
# Update system
sudo dnf update  # or yum update

# Install dotfiles
./install.sh install standard
\`\`\`

### Windows (WSL) Installation

\`\`\`bash
# In WSL terminal
git clone https://github.com/$USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh install standard
\`\`\`

## Post-Installation

### Verify Installation
\`\`\`bash
# Check health
dot check

# Run tests
dot test quick
\`\`\`

### Configure Tools
\`\`\`bash
# Set up Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Configure AI (optional)
dot ai setup
\`\`\`

### Install Git Hooks
\`\`\`bash
# Enable quality gates
./scripts/setup-hooks.sh install
\`\`\`

## Customization

### Tool Selection
Edit \`config/tools.yaml\` to customize which tools are installed:

\`\`\`yaml
profiles:
  custom:
    description: "My custom profile"
    groups: ["essential", "modern_cli"]
    tools:
      - custom_tool_name
\`\`\`

### Configuration Templates
Use templates for dynamic configuration:

\`\`\`bash
# Generate custom config
dot template generate zshrc ~/.zshrc

# Process all templates
dot template process custom
\`\`\`

## Troubleshooting

### Common Issues

1. **Permission Errors**
   \`\`\`bash
   # Fix script permissions
   chmod +x install.sh
   chmod +x scripts/*.sh
   \`\`\`

2. **Missing Dependencies**
   \`\`\`bash
   # Check system requirements
   ./scripts/health-check.sh
   \`\`\`

3. **Installation Fails**
   \`\`\`bash
   # Try dry run first
   ./install.sh --dry-run install standard
   
   # Check logs
   tail -f ~/dotfiles-install.log
   \`\`\`

### Platform-Specific Issues

#### macOS
- **Homebrew Issues**: Run \`brew doctor\`
- **Permissions**: \`sudo chown -R \$(whoami) /usr/local\`
- **Xcode**: Ensure Command Line Tools are installed

#### Linux
- **Package Manager**: Ensure system is updated
- **Missing Tools**: Install build essentials
- **Permissions**: Check sudo access

For more troubleshooting, see [Troubleshooting Guide](troubleshooting.md).

## Uninstallation

\`\`\`bash
# Remove symlinks
dot config restore

# Remove installed packages (manual)
# Dotfiles don't automatically uninstall packages for safety

# Remove dotfiles directory
rm -rf ~/.dotfiles
\`\`\`

## Next Steps

- [Configuration Guide](configuration.md) - Customize your setup
- [CLI Reference](cli-reference.md) - Learn available commands
- [Examples](examples/) - See common workflows
EOF
}

# Generate CLI documentation
generate_cli_documentation() {
    local format="$1"
    
    echo "📖 Generating CLI reference..."
    
    cat > "$DOCS_DIR/cli-reference.md" << EOF
# CLI Reference

Complete reference for all \`dot\` command-line interface commands.

## Overview

The \`dot\` command is your unified interface for managing your development environment.

\`\`\`bash
dot <command> [options]
\`\`\`

## Core Commands

### Setup and Management

#### \`dot setup\`
Idempotent environment setup and configuration.

\`\`\`bash
dot setup [--force] [--minimal]
\`\`\`

**Options:**
- \`--force\`: Force setup even if already configured
- \`--minimal\`: Minimal setup only

#### \`dot check\`
Comprehensive health validation of your environment.

\`\`\`bash
dot check [--fix] [--verbose] [--json]
\`\`\`

**Options:**
- \`--fix\`: Attempt to fix issues automatically
- \`--verbose\`: Detailed output
- \`--json\`: JSON output format

#### \`dot update\`
Update entire system including tools and configurations.

\`\`\`bash
dot update [--all] [--tools] [--configs]
\`\`\`

**Options:**
- \`--all\`: Update everything
- \`--tools\`: Update tools only  
- \`--configs\`: Update configs only

#### \`dot reload\`
Reload shell configuration.

\`\`\`bash
dot reload
\`\`\`

## Development Commands

### Project Management

#### \`dot project\`
Project management and scaffolding.

\`\`\`bash
dot project <subcommand> [options]
\`\`\`

**Subcommands:**
- \`init [type]\`: Create new project from template
- \`list\`: List available templates
- \`switch\`: Switch between projects

**Examples:**
\`\`\`bash
dot project init fastapi my-api
dot project init react my-app
dot project list
\`\`\`

### Process Management

#### \`dot run\`
Process management for development environments.

\`\`\`bash
dot run <environment>
\`\`\`

**Environments:**
- \`dev\`: Start development environment
- \`test\`: Start test environment
- \`prod\`: Production simulation

## Testing Framework

#### \`dot test\`
Comprehensive testing framework integration.

\`\`\`bash
dot test <command> [options]
\`\`\`

**Commands:**
- \`run [category]\`: Run test suite
- \`quick\`: Quick smoke tests
- \`infrastructure\`: Infrastructure tests
- \`watch\`: Continuous testing
- \`coverage\`: Generate coverage report

**Examples:**
\`\`\`bash
dot test run all
dot test quick
dot test infrastructure
dot test watch --filter api
\`\`\`

## AI Integration

#### \`dot ai\`
AI-powered development assistance.

\`\`\`bash
dot ai <command> [options]
\`\`\`

**Commands:**
- \`review [files]\`: AI code review
- \`commit\`: Generate smart commit messages
- \`test [file]\`: Generate tests
- \`explain [file]\`: Explain code
- \`docs [path]\`: Generate documentation

**Examples:**
\`\`\`bash
dot ai review src/main.py
dot ai commit --auto
dot ai test src/utils.py
dot ai explain complex_function.py
\`\`\`

## Performance Management

#### \`dot perf\`
Performance monitoring and optimization.

\`\`\`bash
dot perf <command> [options]
\`\`\`

**Commands:**
- \`measure [target]\`: Measure performance
- \`optimize [type]\`: Apply optimizations
- \`monitor [action]\`: Performance monitoring
- \`report\`: Generate performance report

**Examples:**
\`\`\`bash
dot perf measure shell
dot perf optimize auto
dot perf monitor start
dot perf report
\`\`\`

## Configuration Management

#### \`dot config\`
Interactive configuration management.

\`\`\`bash
dot config <command>
\`\`\`

**Commands:**
- \`theme\`: Switch themes
- \`tools\`: Configure tool integrations
- \`security\`: Adjust security settings

#### \`dot template\`
Advanced configuration templating.

\`\`\`bash
dot template <command> [options]
\`\`\`

**Commands:**
- \`generate <template> <output>\`: Generate config from template
- \`process [profile]\`: Process all templates
- \`create <source> <name>\`: Create template from file
- \`validate\`: Validate templates
- \`list\`: List available templates

**Examples:**
\`\`\`bash
dot template generate zshrc ~/.zshrc
dot template process development
dot template create ~/.gitconfig gitconfig
\`\`\`

## Security Commands

#### \`dot secret\`
Secret management with multiple providers.

\`\`\`bash
dot secret <command> [options]
\`\`\`

**Commands:**
- \`setup\`: Configure secret provider
- \`get <key>\`: Retrieve secret
- \`exec -- <cmd>\`: Execute with injected secrets

#### \`dot security\`
Security operations and auditing.

\`\`\`bash
dot security <command>
\`\`\`

**Commands:**
- \`scan\`: Full security audit
- \`deps\`: Check dependency vulnerabilities
- \`code\`: Static code analysis

## Database Management

#### \`dot db\`
Database management with Docker.

\`\`\`bash
dot db <command>
\`\`\`

**Commands:**
- \`setup\`: Setup local databases
- \`start\`: Start database services
- \`seed\`: Load test data
- \`reset\`: Reset to clean state

## Git Operations

#### \`dot git\`
Enhanced git operations.

\`\`\`bash
dot git <command>
\`\`\`

**Commands:**
- \`setup-signing\`: Configure commit signing
- \`verify\`: Verify commit signatures

## DevContainer Management

#### \`dot devcontainer\`
Development container management.

\`\`\`bash
dot devcontainer <command>
\`\`\`

**Commands:**
- \`init [template]\`: Initialize devcontainer
- \`build\`: Build container image
- \`up\`: Start development container

## Global Options

All commands support these global options:

- \`-h, --help\`: Show help message
- \`-v, --version\`: Show version information
- \`--verbose\`: Enable verbose output
- \`--dry-run\`: Show what would be done

## Examples

### Common Workflows

#### New Project Setup
\`\`\`bash
dot project init fastapi my-api
cd my-api
dot run dev
\`\`\`

#### Code Review Workflow
\`\`\`bash
dot ai review src/
dot test run unit
dot ai commit --auto
\`\`\`

#### Performance Optimization
\`\`\`bash
dot perf measure shell
dot perf optimize auto
dot perf monitor start
\`\`\`

#### Security Audit
\`\`\`bash
dot security scan
dot security deps
dot ai review --security
\`\`\`

## Getting Help

- Use \`dot <command> --help\` for command-specific help
- Run \`dot --help\` for complete command overview
- Check examples in the \`examples/\` directory
- Use \`dot ai explain\` for AI-powered explanations

EOF
}

# Generate configuration documentation
generate_configuration_docs() {
    echo "📖 Generating configuration guide..."
    
    cat > "$DOCS_DIR/configuration.md" << EOF
# Configuration Guide

Learn how to customize and configure your modern dotfiles environment.

## Configuration Structure

\`\`\`
config/
├── tools.yaml          # Tool installation configuration
├── templates.yaml      # Template processing rules
├── zsh/               # ZSH configuration files
├── platform/          # Platform-specific configs
└── ai/                # AI integration settings
\`\`\`

## Tool Configuration

### tools.yaml
Central configuration for all development tools:

\`\`\`yaml
profiles:
  minimal:
    description: "Basic tools only"
    groups: ["essential"]
  
  custom:
    description: "My custom setup"
    groups: ["essential", "modern_cli", "development"]
    tools:
      - my_custom_tool

tools:
  my_custom_tool:
    description: "My custom development tool"
    category: "development"
    install:
      macos: "brew install my-tool"
      ubuntu: "apt install my-tool"
    verify: "my-tool --version"
\`\`\`

### Adding New Tools

1. **Define the tool** in \`tools.yaml\`:
   \`\`\`yaml
   tools:
     newtool:
       description: "Description of the tool"
       category: "development"
       install:
         macos: "brew install newtool"
         ubuntu: "sudo apt install newtool"
         arch: "sudo pacman -S newtool"
       verify: "newtool --version"
   \`\`\`

2. **Add to profile**:
   \`\`\`yaml
   profiles:
     myprofile:
       tools:
         - newtool
   \`\`\`

3. **Install**:
   \`\`\`bash
   ./install.sh install myprofile
   \`\`\`

## Shell Configuration

### ZSH Configuration Files

- \`config/zsh/config.zsh\`: Main ZSH configuration
- \`config/zsh/aliases.zsh\`: Custom aliases
- \`config/zsh/functions.zsh\`: Custom functions
- \`config/zsh/completions.zsh\`: Tab completions
- \`config/zsh/ai-enhanced.zsh\`: AI integration

### Platform-Specific Configuration

- \`config/platform/macos.zsh\`: macOS-specific settings
- \`config/platform/linux.zsh\`: Linux-specific settings

### Custom Configuration

Create \`~/.zshrc.local\` for personal customizations:

\`\`\`bash
# Personal aliases
alias myalias='echo "Hello World"'

# Custom environment variables
export MY_VAR="custom_value"

# Personal functions
my_function() {
    echo "This is my custom function"
}
\`\`\`

## Template Configuration

### Template System

Templates allow dynamic configuration generation:

\`\`\`yaml
# config/templates.yaml
profiles:
  development:
    variables:
      EDITOR: "nvim"
      DEBUG_MODE: "true"
    templates:
      - name: "vscode_settings"
        source: "templates/vscode.json.template"
        target: "~/.config/Code/User/settings.json"
\`\`\`

### Creating Templates

1. **Create template file**:
   \`\`\`bash
   # templates/myconfig.template
   # Generated for {{USER}} on {{DATE}}
   export EDITOR="{{EDITOR}}"
   
   {{#if OS == 'macos'}}
   export HOMEBREW_PREFIX="{{HOMEBREW_PREFIX}}"
   {{/if}}
   \`\`\`

2. **Add to configuration**:
   \`\`\`yaml
   templates:
     - name: "myconfig"
       source: "templates/myconfig.template"
       target: "~/.myconfig"
   \`\`\`

3. **Generate**:
   \`\`\`bash
   dot template process
   \`\`\`

## AI Configuration

### Setting Up AI Providers

\`\`\`bash
# Configure AI providers
dot ai setup

# Set default provider
export AI_PROVIDER="claude"
\`\`\`

### AI Configuration File

\`\`\`yaml
# ~/.config/ai/config.yaml
default_provider: claude
providers:
  claude:
    model: claude-3-sonnet-20240229
    temperature: 0.1
  openai:
    model: gpt-4
    temperature: 0.1

features:
  code_review: true
  commit_messages: true
  test_generation: true
\`\`\`

## Performance Configuration

### Performance Monitoring

\`\`\`yaml
# ~/.config/dotfiles/performance/config.yaml
monitoring:
  enabled: true
  collect_metrics: true

thresholds:
  shell_startup: 2000  # ms
  command_response: 1000  # ms

optimization:
  auto_optimize: false
  backup_before_optimize: true
\`\`\`

### Optimization Settings

\`\`\`bash
# Enable performance monitoring
dot perf monitor start

# Set custom thresholds
export SHELL_STARTUP_THRESHOLD=1500
export COMMAND_RESPONSE_THRESHOLD=800
\`\`\`

## Git Configuration

### Global Git Settings

Configured via templates in \`templates/gitconfig.template\`:

\`\`\`ini
[user]
    name = {{GIT_NAME}}
    email = {{GIT_EMAIL}}

[core]
    editor = {{EDITOR}}
    autocrlf = false

[init]
    defaultBranch = main
\`\`\`

### Git Hooks Configuration

\`\`\`bash
# Install hooks
./scripts/setup-hooks.sh install

# Configure hook behavior
export HOOK_STRICT_MODE=true
export HOOK_AUTO_FIX=false
\`\`\`

## Testing Configuration

### Test Framework Settings

\`\`\`yaml
# Project-specific testing
testing:
  frameworks:
    - pytest
    - playwright
    - bruno
  
  coverage:
    enabled: true
    threshold: 80
  
  performance:
    enabled: true
    benchmark: true
\`\`\`

### CI/CD Configuration

GitHub Actions configuration in \`.github/workflows/test.yml\`:

\`\`\`yaml
name: Dotfiles Testing
on: [push, pull_request]

jobs:
  test-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: ./tests/test_runner.sh
\`\`\`

## Environment Variables

### Important Environment Variables

\`\`\`bash
# Dotfiles configuration
export DOTFILES_DIR="$HOME/dotfiles"
export DOTFILES_PROFILE="standard"

# AI configuration
export AI_PROVIDER="claude"
export AI_CACHE_DIR="$HOME/.cache/ai"

# Performance configuration
export PERF_MONITORING_ENABLED=true
export SHELL_STARTUP_THRESHOLD=2000

# Platform configuration
export PLATFORM_OS="macos"
export PACKAGE_MANAGER="brew"
\`\`\`

### Setting Environment Variables

1. **Global**: Add to \`config/zsh/config.zsh\`
2. **Local**: Add to \`~/.zshrc.local\`
3. **Template**: Use in templates with \`{{VARIABLE}}\`

## Customization Examples

### Custom Aliases

\`\`\`bash
# config/zsh/aliases.zsh
alias ll='eza -la'
alias cat='bat'
alias grep='rg'
alias find='fd'

# Git aliases
alias gs='git status'
alias gp='git push'
alias gl='git pull'

# Development aliases
alias dev='dot run dev'
alias test='dot test quick'
alias review='dot ai review'
\`\`\`

### Custom Functions

\`\`\`bash
# config/zsh/functions.zsh
# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick project setup
newproject() {
    local name="$1"
    local type="${2:-python}"
    dot project init "$type" "$name"
    cd "$name"
    dot run dev
}

# AI-powered commit
commit() {
    if [[ $# -eq 0 ]]; then
        dot ai commit
    else
        git commit -m "$*"
    fi
}
\`\`\`

## Best Practices

### Configuration Management

1. **Version Control**: Keep configurations in version control
2. **Templates**: Use templates for dynamic content
3. **Profiles**: Create profiles for different environments
4. **Documentation**: Document custom configurations

### Security

1. **Secrets**: Never commit secrets to version control
2. **Permissions**: Set appropriate file permissions
3. **Validation**: Use git hooks for validation
4. **Encryption**: Use secret management for sensitive data

### Performance

1. **Monitoring**: Enable performance monitoring
2. **Optimization**: Regular performance optimization
3. **Profiling**: Profile shell startup regularly
4. **Cleanup**: Regular cleanup of caches and logs

## Troubleshooting Configuration

### Common Issues

1. **Syntax Errors**: Use \`dot template validate\`
2. **Missing Variables**: Check template variables
3. **Permission Issues**: Fix file permissions
4. **Path Issues**: Verify PATH configuration

### Debugging

\`\`\`bash
# Check configuration
dot check --verbose

# Validate templates
dot template validate

# Test performance
dot perf measure shell

# View logs
tail -f ~/.local/share/dotfiles/logs/dotfiles.log
\`\`\`

For more help, see [Troubleshooting Guide](troubleshooting.md).
EOF
}

# Generate troubleshooting documentation
generate_troubleshooting_docs() {
    echo "📖 Generating troubleshooting guide..."
    
    cat > "$DOCS_DIR/troubleshooting.md" << EOF
# Troubleshooting Guide

Common issues and solutions for your modern dotfiles environment.

## Quick Diagnostics

### Health Check
\`\`\`bash
# Run comprehensive health check
dot check --verbose

# Fix common issues automatically
dot check --fix
\`\`\`

### Performance Check
\`\`\`bash
# Check startup performance
dot perf measure shell

# Full system analysis
dot perf analyze
\`\`\`

## Installation Issues

### Permission Errors

**Problem**: Permission denied errors during installation
\`\`\`
Permission denied: /usr/local/bin/some-tool
\`\`\`

**Solution**:
\`\`\`bash
# Fix script permissions
chmod +x install.sh
chmod +x scripts/*.sh

# macOS: Fix Homebrew permissions
sudo chown -R \$(whoami) /usr/local

# Linux: Ensure sudo access
sudo -v
\`\`\`

### Missing Dependencies

**Problem**: Installation fails due to missing dependencies

**Solution**:
\`\`\`bash
# macOS: Install Xcode Command Line Tools
xcode-select --install

# Ubuntu/Debian: Install build essentials
sudo apt update
sudo apt install build-essential curl git

# Arch: Install base development tools
sudo pacman -S base-devel git curl

# RHEL/CentOS: Install development tools
sudo dnf groupinstall "Development Tools"
\`\`\`

### Package Manager Issues

**Problem**: Package manager not found or broken

**Solutions**:

#### macOS - Homebrew Issues
\`\`\`bash
# Install Homebrew
/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Fix Homebrew issues
brew doctor

# Reset Homebrew
rm -rf /opt/homebrew  # Apple Silicon
rm -rf /usr/local/Homebrew  # Intel
# Then reinstall
\`\`\`

#### Linux - Package Manager Issues
\`\`\`bash
# Ubuntu: Fix broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a

# Arch: Fix keyring issues
sudo pacman -S archlinux-keyring
sudo pacman -Syu

# RHEL: Clear cache
sudo dnf clean all
sudo dnf makecache
\`\`\`

## Shell Issues

### Slow Startup Times

**Problem**: Shell takes too long to start (>2 seconds)

**Diagnosis**:
\`\`\`bash
# Measure startup time
dot perf measure shell 10

# Profile zsh startup
zsh -i -c 'zprof'
\`\`\`

**Solutions**:
\`\`\`bash
# Optimize shell performance
dot perf optimize shell

# Disable slow plugins temporarily
# Edit ~/.zshrc and comment out slow plugins

# Clear completion cache
rm -f ~/.zcompdump*
autoload -Uz compinit && compinit

# Use lazy loading for heavy tools
# Add to ~/.zshrc.local:
# eval "\$(mise activate zsh)" # Only when needed
\`\`\`

### Command Not Found

**Problem**: Commands installed by dotfiles not found

**Diagnosis**:
\`\`\`bash
# Check PATH
echo \$PATH

# Find command location
which command_name
type command_name
\`\`\`

**Solutions**:
\`\`\`bash
# Reload shell configuration
dot reload

# Add to PATH manually
export PATH="/path/to/tool:\$PATH"

# Verify installation
dot check

# Reinstall specific tool
./install.sh install standard --force
\`\`\`

### Completion Not Working

**Problem**: Tab completion not working

**Solutions**:
\`\`\`bash
# Rebuild completion cache
rm -f ~/.zcompdump*
autoload -Uz compinit && compinit -u

# Check completion configuration
ls -la ~/.oh-my-zsh/completions/  # Oh My Zsh
ls -la /usr/local/share/zsh/site-functions/  # Homebrew

# Reload completions
source ~/.zshrc
\`\`\`

## Git Issues

### Git Hooks Not Working

**Problem**: Git hooks not executing

**Diagnosis**:
\`\`\`bash
# Check hook installation
ls -la .git/hooks/

# Check permissions
ls -la .git/hooks/pre-commit
\`\`\`

**Solutions**:
\`\`\`bash
# Reinstall hooks
./scripts/setup-hooks.sh install

# Fix permissions
chmod +x .git/hooks/*

# Test hooks manually
.git/hooks/pre-commit
\`\`\`

### Commit Message Validation Fails

**Problem**: Commit message hook rejects valid messages

**Solutions**:
\`\`\`bash
# Check commit message format
# Expected: type(scope): description

# Bypass validation temporarily
git commit --no-verify -m "your message"

# Fix commit message format
git commit -m "feat: add new feature"
git commit -m "fix: resolve startup issue"
\`\`\`

## AI Integration Issues

### AI Provider Not Working

**Problem**: AI commands fail or return errors

**Diagnosis**:
\`\`\`bash
# Check AI status
dot ai status

# Check available providers
dot ai setup
\`\`\`

**Solutions**:
\`\`\`bash
# Install Claude CLI
pip install claude-cli

# Install GitHub Copilot
gh extension install github/gh-copilot

# Configure API keys
export OPENAI_API_KEY="your_key"
export ANTHROPIC_API_KEY="your_key"

# Test AI integration
dot ai explain README.md
\`\`\`

### AI Commands Slow

**Problem**: AI commands take too long

**Solutions**:
\`\`\`bash
# Check network connectivity
ping api.anthropic.com

# Use local AI if available
export AI_PROVIDER="local"

# Enable caching
export AI_CACHE_ENABLED=true
\`\`\`

## Performance Issues

### High CPU Usage

**Problem**: Shell or tools consuming high CPU

**Diagnosis**:
\`\`\`bash
# Check system performance
dot perf analyze

# Monitor processes
top -p \$(pgrep -f zsh)
htop
\`\`\`

**Solutions**:
\`\`\`bash
# Optimize performance
dot perf optimize auto

# Disable resource-heavy plugins
# Edit shell configuration files

# Clear caches
rm -rf ~/.cache/dotfiles/
\`\`\`

### Memory Issues

**Problem**: High memory usage

**Solutions**:
\`\`\`bash
# Check memory usage
free -h  # Linux
vm_stat  # macOS

# Clear system caches
# macOS
sudo purge

# Linux
sudo sysctl vm.drop_caches=3

# Optimize tool memory usage
export PYTHONDONTWRITEBYTECODE=1
export NODE_OPTIONS="--max-old-space-size=4096"
\`\`\`

## Testing Issues

### Tests Failing

**Problem**: Dotfiles tests fail unexpectedly

**Diagnosis**:
\`\`\`bash
# Run specific test categories
dot test infrastructure
dot test quick

# Check test logs
ls -la tests/results/
cat tests/results/test_run_*.log
\`\`\`

**Solutions**:
\`\`\`bash
# Update test dependencies
# Python
pip install -U pytest playwright

# Node.js
npm update

# Fix test environment
dot test setup

# Run tests with verbose output
dot test run --verbose
\`\`\`

### CI/CD Pipeline Fails

**Problem**: GitHub Actions or other CI fails

**Solutions**:
\`\`\`bash
# Check workflow syntax
yamllint .github/workflows/test.yml

# Test locally with act
act -P ubuntu-latest=nektos/act-environments-ubuntu:18.04

# Update workflow dependencies
# Check .github/workflows/test.yml
\`\`\`

## Platform-Specific Issues

### macOS Issues

#### Homebrew Architecture Issues
\`\`\`bash
# Check architecture
uname -m

# Apple Silicon: Use arm64 Homebrew
arch -arm64 brew install package

# Intel: Use x86_64 Homebrew
arch -x86_64 brew install package

# Switch architecture
env /usr/bin/arch -x86_64 /bin/zsh
\`\`\`

#### macOS Security Issues
\`\`\`bash
# Allow unsigned binaries
sudo spctl --master-disable

# Fix quarantine issues
xattr -dr com.apple.quarantine /path/to/app

# Reset security settings
sudo spctl --master-enable
\`\`\`

### Linux Issues

#### Snap Package Issues
\`\`\`bash
# Refresh snap packages
sudo snap refresh

# Remove broken snaps
sudo snap remove broken-package
sudo snap install broken-package
\`\`\`

#### AppImage Issues
\`\`\`bash
# Fix AppImage permissions
chmod +x application.AppImage

# Install FUSE if needed
sudo apt install fuse
\`\`\`

## Template Issues

### Template Processing Fails

**Problem**: Template generation produces errors

**Diagnosis**:
\`\`\`bash
# Validate templates
dot template validate

# Check template variables
dot template vars
\`\`\`

**Solutions**:
\`\`\`bash
# Fix template syntax
# Check for unmatched blocks in templates/

# Define missing variables
export MISSING_VAR="value"

# Recreate template from source
dot template create ~/.existing_config new_template
\`\`\`

## Recovery Procedures

### Complete Reset

If all else fails, perform a complete reset:

\`\`\`bash
# Backup current configuration
cp -r ~/.dotfiles ~/.dotfiles.backup
cp ~/.zshrc ~/.zshrc.backup

# Clean install
rm -rf ~/.dotfiles
git clone https://github.com/\$USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh install standard

# Restore personal configurations
cp ~/.zshrc.backup ~/.zshrc.local
\`\`\`

### Selective Recovery

Restore specific components:

\`\`\`bash
# Restore specific configurations
dot template generate zshrc ~/.zshrc
dot template generate gitconfig ~/.gitconfig

# Reinstall specific tools
./install.sh install minimal
dot config tools
\`\`\`

## Getting Help

### Built-in Help
\`\`\`bash
# Command help
dot --help
dot <command> --help

# AI-powered help
dot ai explain "how to fix shell startup issues"
\`\`\`

### Logs and Debugging
\`\`\`bash
# Check logs
tail -f ~/dotfiles-install.log
tail -f ~/.local/share/dotfiles/logs/dotfiles.log

# Enable verbose mode
export DEBUG=1
dot <command> --verbose
\`\`\`

### Community Support
- GitHub Issues: Report bugs and get help
- Documentation: Check latest docs for updates
- AI Assistant: Use \`dot ai\` for intelligent help

## Prevention

### Regular Maintenance
\`\`\`bash
# Weekly maintenance
dot update
dot perf optimize
dot check --fix

# Monthly maintenance
dot test run all
dot security scan
dot perf report
\`\`\`

### Monitoring
\`\`\`bash
# Enable monitoring
dot perf monitor start

# Check health regularly
dot check

# Update dependencies
./install.sh install standard
\`\`\`

Remember: Most issues can be prevented with regular maintenance and monitoring!
EOF
}

# Generate API documentation
generate_api_documentation() {
    local format="$1"
    
    echo "📖 Generating API documentation..."
    
    # Create API documentation structure
    mkdir -p "$DOCS_DIR/api"
    
    # Generate main API index
    cat > "$DOCS_DIR/api/README.md" << EOF
# API Documentation

This section contains API documentation for the dotfiles framework.

## Modules

- [Core Functions](core.md) - Core dotfiles functionality
- [Platform](platform.md) - Platform detection and compatibility
- [Performance](performance.md) - Performance monitoring
- [AI Integration](ai.md) - AI integration framework
- [Templating](templating.md) - Configuration templating
- [Testing](testing.md) - Testing framework

## CLI Modules

- [AI CLI](cli-ai.md) - AI command interface
- [Performance CLI](cli-performance.md) - Performance command interface
- [Testing CLI](cli-testing.md) - Testing command interface

## Usage

The dotfiles framework provides both shell functions and CLI commands:

\`\`\`bash
# Shell function usage
source "\$DOTFILES_DIR/lib/platform.sh"
detect_platform
echo \$PLATFORM_OS

# CLI usage
dot ai review src/
dot perf measure shell
dot test run all
\`\`\`
EOF

    # Generate individual API docs
    generate_core_api_docs
    generate_platform_api_docs
    generate_performance_api_docs
}

# Generate core API documentation
generate_core_api_docs() {
    cat > "$DOCS_DIR/api/core.md" << EOF
# Core API Documentation

Core functions and utilities for the dotfiles framework.

## Functions

### \`init_dotfiles()\`
Initialize the dotfiles environment.

**Usage:**
\`\`\`bash
init_dotfiles
\`\`\`

**Description:**
Sets up the dotfiles environment, loads configuration, and initializes all modules.

### \`load_config()\`
Load dotfiles configuration from YAML files.

**Usage:**
\`\`\`bash
load_config [config_file]
\`\`\`

**Parameters:**
- \`config_file\` (optional): Path to configuration file

**Returns:**
- 0 on success, 1 on error

### \`log_message(level, message)\`
Log a message with specified level.

**Usage:**
\`\`\`bash
log_message "INFO" "Starting installation"
log_message "ERROR" "Installation failed"
\`\`\`

**Parameters:**
- \`level\`: Log level (DEBUG, INFO, WARN, ERROR)
- \`message\`: Message to log

## Variables

### Global Variables

- \`DOTFILES_DIR\`: Path to dotfiles directory
- \`CONFIG_FILE\`: Path to main configuration file
- \`LOG_FILE\`: Path to log file
- \`BACKUP_DIR\`: Path to backup directory

### Environment Variables

- \`DEBUG\`: Enable debug output (0/1)
- \`VERBOSE\`: Enable verbose output (0/1)
- \`DRY_RUN\`: Enable dry run mode (0/1)

## Configuration

### tools.yaml Structure

\`\`\`yaml
tools:
  tool_name:
    description: "Tool description"
    category: "category"
    install:
      macos: "brew install tool"
      ubuntu: "apt install tool"
    verify: "tool --version"

profiles:
  profile_name:
    description: "Profile description"
    groups: ["group1", "group2"]
    tools: ["tool1", "tool2"]
\`\`\`

## Examples

### Basic Usage

\`\`\`bash
#!/bin/bash
source "\$DOTFILES_DIR/lib/core.sh"

# Initialize dotfiles
init_dotfiles

# Load configuration
load_config

# Log a message
log_message "INFO" "Dotfiles initialized successfully"
\`\`\`

### Advanced Usage

\`\`\`bash
#!/bin/bash
source "\$DOTFILES_DIR/lib/core.sh"

# Check if tool is installed
if command -v git >/dev/null 2>&1; then
    log_message "INFO" "Git is available"
else
    log_message "ERROR" "Git not found"
    exit 1
fi

# Backup existing configuration
backup_file "\$HOME/.zshrc"

# Install new configuration
install_config "zshrc"
\`\`\`
EOF
}

# Generate examples documentation
generate_examples_documentation() {
    local format="$1"
    
    echo "📖 Generating examples documentation..."
    
    mkdir -p "$DOCS_DIR/examples"
    
    cat > "$DOCS_DIR/examples/README.md" << EOF
# Examples and Tutorials

Common use cases and workflows for your modern dotfiles environment.

## Quick Start Examples

### [New Project Setup](new-project.md)
Complete workflow for setting up a new development project.

### [Daily Development Workflow](daily-workflow.md)
Common daily tasks and optimizations.

### [AI-Enhanced Development](ai-workflow.md)
Using AI integration for enhanced productivity.

### [Performance Optimization](performance-optimization.md)
Optimizing your development environment performance.

### [Custom Configuration](custom-configuration.md)
Creating and managing custom configurations.

## Advanced Examples

### [Plugin Development](plugin-development.md)
Creating custom plugins and extensions.

### [Template Creation](template-creation.md)
Building custom configuration templates.

### [Cross-Platform Setup](cross-platform.md)
Managing configurations across multiple platforms.

### [CI/CD Integration](cicd-integration.md)
Integrating dotfiles with CI/CD pipelines.

## Troubleshooting Examples

### [Common Issues](common-issues.md)
Solutions for frequently encountered problems.

### [Performance Issues](performance-issues.md)
Diagnosing and fixing performance problems.

### [Platform-Specific Issues](platform-issues.md)
Platform-specific troubleshooting guides.
EOF

    # Generate specific example files
    generate_workflow_examples
}

# Generate workflow examples
generate_workflow_examples() {
    cat > "$DOCS_DIR/examples/daily-workflow.md" << EOF
# Daily Development Workflow

Common daily tasks and workflows using your modern dotfiles environment.

## Morning Setup

Start your development day with these commands:

\`\`\`bash
# Check system health
dot check

# Update tools and configurations
dot update

# Start performance monitoring
dot perf monitor start
\`\`\`

## Project Work

### Starting a New Feature

\`\`\`bash
# Create feature branch
git checkout -b feature/new-feature

# Run AI code review on current state
dot ai review src/

# Start development environment
dot run dev
\`\`\`

### Code Development Cycle

\`\`\`bash
# Write code...

# AI-powered test generation
dot ai test src/new_feature.py

# Run tests
dot test quick

# AI code review
dot ai review src/new_feature.py

# Smart commit with AI
dot ai commit
\`\`\`

### Code Review and Collaboration

\`\`\`bash
# Before creating PR
dot test run all
dot security scan
dot ai review --comprehensive

# Create PR with AI-generated description
gh pr create --title "feat: new feature" --body "\$(dot ai docs --pr-description)"
\`\`\`

## Daily Maintenance

### Performance Monitoring

\`\`\`bash
# Check performance metrics
dot perf report

# Optimize if needed
dot perf optimize auto

# Monitor shell startup time
dot perf measure shell
\`\`\`

### Security and Health

\`\`\`bash
# Daily security scan
dot security scan

# Check for vulnerabilities
dot security deps

# Health check
dot check --fix
\`\`\`

## End of Day

\`\`\`bash
# Final commit with AI
dot ai commit --summary

# Push changes
git push

# Generate daily report
dot perf report --today

# Stop monitoring
dot perf monitor stop
\`\`\`

## Productivity Tips

### AI-Enhanced Workflows

\`\`\`bash
# Explain complex code
dot ai explain complex_function.py

# Get help with errors
dot ai help "TypeError: 'NoneType' object is not subscriptable"

# Generate documentation
dot ai docs src/ --output docs/
\`\`\`

### Template Usage

\`\`\`bash
# Quick project setup
dot project init fastapi my-api
cd my-api

# Generate custom configs
dot template generate .env.template .env
\`\`\`

### Performance Optimization

\`\`\`bash
# Weekly performance review
dot perf analyze --weekly

# Optimize shell startup
dot perf optimize shell

# Clean up caches
dot cache clean
\`\`\`
EOF
}

# Generate main README
generate_main_readme() {
    echo "📖 Generating main README..."
    
    cat > "$DOCS_DIR/README.md" << EOF
# Modern Dotfiles Documentation

Welcome to the comprehensive documentation for your modern development environment.

## 🚀 Quick Start

New to dotfiles? Start here:

1. [Getting Started](getting-started.md) - Quick setup and introduction
2. [Installation](installation.md) - Detailed installation guide
3. [Configuration](configuration.md) - Customize your environment

## 📚 Documentation Categories

### Essential Guides
- **[Getting Started](getting-started.md)** - New user introduction
- **[Installation](installation.md)** - Complete installation instructions
- **[Configuration](configuration.md)** - Customization and settings
- **[CLI Reference](cli-reference.md)** - Complete command documentation

### Advanced Topics
- **[Development](development.md)** - Contributing and extending
- **[API Documentation](api/)** - Function and module reference
- **[Examples](examples/)** - Common workflows and use cases
- **[Troubleshooting](troubleshooting.md)** - Problem solving guide

### Reference
- **[Changelog](changelog.md)** - Version history and updates
- **[Contributing](contributing.md)** - How to contribute

## 🔧 Key Features

### Modern Development Tools
- **Shell Enhancement**: Starship prompt, Zoxide navigation, modern CLI tools
- **Version Management**: mise for multi-language version management
- **Package Management**: uv (Python), bun (JavaScript), platform package managers
- **AI Integration**: Code review, commit messages, test generation, documentation

### Cross-Platform Support
- **macOS**: Intel and Apple Silicon support
- **Linux**: Ubuntu, Arch, RHEL, and more
- **Windows**: WSL and native support
- **Containers**: DevContainer and Docker integration

### Developer Experience
- **Performance Monitoring**: Startup time optimization and system monitoring
- **Testing Framework**: Multi-framework testing with CI/CD integration
- **Security**: Automated security scanning and vulnerability detection
- **Configuration**: Template-based dynamic configuration management

## 🎯 Common Use Cases

### New Project Setup
\`\`\`bash
dot project init fastapi my-api
cd my-api
dot run dev
\`\`\`

### AI-Enhanced Development
\`\`\`bash
dot ai review src/
dot ai commit
dot ai test src/main.py
\`\`\`

### Performance Optimization
\`\`\`bash
dot perf analyze
dot perf optimize auto
dot perf monitor start
\`\`\`

### Security and Quality
\`\`\`bash
dot security scan
dot test run all
dot check --fix
\`\`\`

## 🔍 Finding Information

### By Topic
- **Installation Issues**: [Installation Guide](installation.md) → [Troubleshooting](troubleshooting.md)
- **Configuration Help**: [Configuration Guide](configuration.md) → [Examples](examples/)
- **Command Reference**: [CLI Reference](cli-reference.md)
- **API Usage**: [API Documentation](api/)

### By Platform
- **macOS**: [Installation](installation.md#macos-installation) → [Platform Config](configuration.md#platform-specific-configuration)
- **Linux**: [Installation](installation.md#linux-installation) → [Platform Config](configuration.md#platform-specific-configuration)
- **Windows**: [Installation](installation.md#windows-wsl-installation)

### By Use Case
- **Development**: [Examples](examples/) → [Development Guide](development.md)
- **Customization**: [Configuration](configuration.md) → [Template System](configuration.md#template-configuration)
- **Troubleshooting**: [Troubleshooting Guide](troubleshooting.md)

## 🆘 Getting Help

### Built-in Help
\`\`\`bash
# Command help
dot --help
dot <command> --help

# AI-powered assistance
dot ai explain "how to optimize shell startup"
dot ai help "git hook errors"
\`\`\`

### Documentation
- **Quick Reference**: [CLI Reference](cli-reference.md)
- **Step-by-Step**: [Examples](examples/)
- **Problem Solving**: [Troubleshooting](troubleshooting.md)

### Health Check
\`\`\`bash
# Diagnose issues
dot check --verbose

# Performance analysis
dot perf analyze

# Security audit
dot security scan
\`\`\`

## 📈 Staying Updated

### Updates
\`\`\`bash
# Update dotfiles
dot update

# Check for new features
dot changelog

# Health check after updates
dot check
\`\`\`

### Documentation
- This documentation is generated automatically and stays in sync with your dotfiles
- Run \`dot docs generate\` to regenerate documentation
- Check [Changelog](changelog.md) for recent updates

## 🤝 Contributing

We welcome contributions! See the [Contributing Guide](contributing.md) for:
- How to report issues
- How to suggest improvements
- How to contribute code
- Development setup

---

**Need immediate help?** Run \`dot check --help\` or \`dot ai help "your question"\`
EOF
}

# Build HTML documentation
build_html_documentation() {
    echo "🌐 Building HTML documentation..."
    
    # Check if we have a static site generator available
    if command -v mkdocs >/dev/null 2>&1; then
        build_mkdocs_site
    elif command -v hugo >/dev/null 2>&1; then
        build_hugo_site
    else
        echo "No static site generator found, HTML build skipped"
        echo "Install mkdocs or hugo for HTML documentation"
    fi
}

# Generate interactive help
generate_interactive_help() {
    echo "📖 Generating interactive help..."
    
    cat > "$DOCS_DIR/interactive-help.sh" << 'EOF'
#!/bin/bash
# Interactive Help System

show_interactive_help() {
    local topic="${1:-main}"
    
    case "$topic" in
        "main")
            show_main_help_menu
            ;;
        "installation")
            show_installation_help
            ;;
        "configuration")
            show_configuration_help
            ;;
        "troubleshooting")
            show_troubleshooting_help
            ;;
        *)
            echo "Unknown help topic: $topic"
            show_main_help_menu
            ;;
    esac
}

show_main_help_menu() {
    cat << 'HELP'
🚀 Modern Dotfiles - Interactive Help

Choose a topic:
1. Installation and Setup
2. Configuration and Customization  
3. CLI Commands and Usage
4. Troubleshooting and Support
5. AI Integration
6. Performance Optimization
7. Examples and Workflows

Enter number (1-7) or 'q' to quit:
HELP

    read -r choice
    case "$choice" in
        1) show_installation_help ;;
        2) show_configuration_help ;;
        3) show_cli_help ;;
        4) show_troubleshooting_help ;;
        5) show_ai_help ;;
        6) show_performance_help ;;
        7) show_examples_help ;;
        q|Q) exit 0 ;;
        *) echo "Invalid choice. Try again."; show_main_help_menu ;;
    esac
}

show_installation_help() {
    cat << 'HELP'
📦 Installation Help

Quick Installation:
  git clone https://github.com/$USER/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles
  ./install.sh install standard

Profiles:
  minimal   - Basic tools only
  standard  - Recommended setup  
  full      - Everything included
  ai_focused - AI-enhanced setup

Platform-specific help:
  m) macOS installation
  l) Linux installation  
  w) Windows (WSL) installation
  b) Back to main menu

Choose: 
HELP

    read -r choice
    case "$choice" in
        m) show_macos_installation_help ;;
        l) show_linux_installation_help ;;
        w) show_windows_installation_help ;;
        b) show_main_help_menu ;;
        *) show_installation_help ;;
    esac
}

# Export function
export -f show_interactive_help
EOF

    chmod +x "$DOCS_DIR/interactive-help.sh"
}

# Documentation CLI interface
docs_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "generate"|"gen")
            generate_documentation "$@"
            ;;
        "build")
            local format="${1:-html}"
            generate_documentation "$format" "all"
            ;;
        "serve")
            serve_documentation "$@"
            ;;
        "search")
            search_documentation "$@"
            ;;
        "interactive"|"help")
            source "$DOCS_DIR/interactive-help.sh"
            show_interactive_help "$@"
            ;;
        "init")
            init_documentation
            echo "✅ Documentation system initialized"
            ;;
        "clean")
            rm -rf "$DOCS_BUILD_DIR"
            echo "✅ Documentation build directory cleaned"
            ;;
        "help"|*)
            cat << 'EOF'
📚 Documentation System

USAGE:
    docs <command> [options]

COMMANDS:
    generate [format] [category]  Generate documentation
    build [format]               Build complete documentation
    serve [port]                 Serve documentation locally
    search <query>              Search documentation
    interactive                 Interactive help system
    init                        Initialize documentation system
    clean                       Clean build directory

EXAMPLES:
    docs generate               # Generate all markdown docs
    docs build html             # Build HTML documentation
    docs serve 8000             # Serve docs on port 8000
    docs search "git hooks"     # Search for git hooks
    docs interactive            # Launch interactive help

EOF
            ;;
    esac
}

# Initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_documentation
fi

# Export functions
export -f generate_documentation docs_cli init_documentation