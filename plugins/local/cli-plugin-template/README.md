# CLI Plugin Template

A comprehensive template and example implementation for creating CLI plugins within the modern dotfiles framework.

## 🎯 Purpose

This plugin serves as both a working example and a comprehensive template for creating CLI plugins. It demonstrates:

- **Plugin Architecture**: Complete plugin structure and organization
- **Command System**: Command registration, routing, and execution
- **Integration Patterns**: DOT CLI integration and plugin lifecycle
- **Best Practices**: Error handling, configuration, testing, and documentation
- **Development Workflow**: From creation to deployment

## 📦 Installation

```bash
# This template plugin is included by default in plugins/local/
# Enable it to see the examples:
dot plugin enable cli-plugin-template

# Or create your own plugin based on this template:
dot plugin create my-cli-tool cli
```

## 🚀 Usage Examples

### Basic Commands

```bash
# See the complete demonstration
dot template-demo

# Try the example commands
dot example hello
dot example hello Alice
dot example hello Bob Howdy

# Check plugin status and health
dot example status
dot example config

# Run self-tests
dot example test

# Get help
dot example help
```

### Plugin Management

```bash
# List all plugins
dot plugin list

# Show plugin information
dot plugin info cli-plugin-template

# Disable the example plugin
dot plugin disable cli-plugin-template

# Re-enable it
dot plugin enable cli-plugin-template
```

## 🏗️ Plugin Structure

```
cli-plugin-template/
├── plugin.yaml              # Plugin metadata and configuration
├── lib/
│   └── core.sh              # Main plugin implementation
├── config/                   # Default configuration files
├── docs/                     # Plugin documentation
├── tests/                    # Plugin test files
├── install.sh               # Installation script (optional)
├── uninstall.sh            # Uninstallation script (optional)
└── README.md               # This documentation
```

### plugin.yaml Structure

```yaml
---
name: my-plugin-name           # Unique plugin identifier
version: "1.0.0"              # Semantic version
description: "Brief description of what this plugin does"
author: "Your Name"           # Plugin author
license: "MIT"                # License type
homepage: "https://..."       # Plugin homepage (optional)
repository: "https://..."     # Source repository (optional)

type: productivity            # Plugin type: productivity, development, utility, etc.
category: git                 # Category: git, project, system, etc.
tags:                         # Searchable tags
  - "git"
  - "workflow"

dependencies:                 # System dependencies
  - "git"
  - "curl"
plugin_dependencies: []      # Other plugins this depends on

platforms:                   # Supported platforms
  - "macos"
  - "linux"

config:
  auto_enable: false         # Enable automatically after install
  priority: 90               # Loading priority (higher = earlier)

commands:                    # Commands this plugin provides
  - name: "my-command"
    description: "What this command does"
    function: "my_plugin_command_function"

hooks:                       # Plugin lifecycle hooks
  pre-install: []
  post-install: []
  pre-uninstall: []
  post-uninstall: []
```

### Core Implementation Pattern

```bash
#!/usr/bin/env bash
# Plugin implementation template

# Plugin constants and configuration
MY_PLUGIN_VERSION="1.0.0"
MY_PLUGIN_CONFIG_DIR="${HOME}/.config/dotfiles/plugins/my-plugin"
MY_PLUGIN_DATA_DIR="${HOME}/.local/share/dotfiles/plugins/my-plugin"

# Plugin initialization (called when plugin is enabled)
my_plugin_init() {
    echo "🔌 My Plugin initialized"
    mkdir -p "$MY_PLUGIN_CONFIG_DIR" "$MY_PLUGIN_DATA_DIR"
    # Additional setup here
}

# Plugin cleanup (called when plugin is disabled)
my_plugin_cleanup() {
    echo "🔌 My Plugin cleaned up"
    # Cleanup resources if needed
}

# Main command function
my_plugin_main() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        "action1")
            my_plugin_action1 "$@"
            ;;
        "action2")
            my_plugin_action2 "$@"
            ;;
        "help"|"-h"|"--help"|"")
            my_plugin_help
            ;;
        *)
            echo "❌ Unknown command: $subcommand"
            echo "Run 'dot my-command help' for available commands"
            return 1
            ;;
    esac
}

# Export functions for plugin system
export -f my_plugin_init my_plugin_cleanup my_plugin_main
```

## 🛠️ Development Guide

### 1. Creating a New Plugin

```bash
# Use the DOT CLI to create a new plugin
dot plugin create my-awesome-tool cli

# Or copy the template manually
cp -r plugins/local/cli-plugin-template plugins/local/my-plugin
cd plugins/local/my-plugin

# Update plugin.yaml with your plugin details
vim plugin.yaml

# Implement your plugin functionality
vim lib/core.sh
```

### 2. Plugin Naming Conventions

- **Plugin names**: Use lowercase with hyphens (kebab-case): `my-awesome-tool`
- **Function names**: Use underscore-separated with plugin prefix: `my_tool_function`
- **Variables**: Use uppercase with plugin prefix: `MY_TOOL_VERSION`
- **Commands**: Use descriptive names that won't conflict: `my-tool`, `awesome`

### 3. Command Implementation

```bash
# Command function template
my_plugin_command() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        "subcommand1")
            # Implement subcommand
            my_plugin_subcommand1 "$@"
            ;;
        "help"|"-h"|"--help"|"")
            # Always provide help
            my_plugin_command_help
            ;;
        *)
            echo "❌ Unknown subcommand: $subcommand"
            echo "Run 'dot my-command help' for available subcommands"
            return 1
            ;;
    esac
}
```

### 4. Error Handling Best Practices

```bash
# Check arguments
if [[ -z "$required_arg" ]]; then
    echo "❌ Required argument missing"
    echo "Usage: dot my-command action <required_arg>"
    return 1
fi

# Check dependencies
if ! command -v required_tool >/dev/null 2>&1; then
    echo "❌ Required tool not found: required_tool"
    echo "Install with: brew install required_tool"
    return 1
fi

# Validate state
if [[ ! -d "$important_directory" ]]; then
    echo "❌ Directory not found: $important_directory"
    echo "Run 'dot my-command setup' first"
    return 1
fi
```

### 5. Configuration Management

```bash
# Create configuration
setup_my_plugin_config() {
    if [[ ! -f "$MY_PLUGIN_CONFIG_DIR/config.yaml" ]]; then
        cat > "$MY_PLUGIN_CONFIG_DIR/config.yaml" << 'EOF'
my_plugin:
  setting1: "default_value"
  setting2: true
  features:
    - "feature1"
    - "feature2"
EOF
    fi
}

# Load configuration (requires yq or fallback parsing)
load_my_plugin_config() {
    if command -v yq >/dev/null 2>&1; then
        MY_PLUGIN_SETTING1=$(yq eval '.my_plugin.setting1' "$MY_PLUGIN_CONFIG_DIR/config.yaml")
    else
        # Fallback parsing
        MY_PLUGIN_SETTING1=$(grep "setting1:" "$MY_PLUGIN_CONFIG_DIR/config.yaml" | cut -d'"' -f2)
    fi
}
```

### 6. Testing Integration

```bash
# Self-test function
my_plugin_test() {
    echo "🧪 Running plugin tests..."
    
    local tests_passed=0
    local total_tests=3
    
    # Test 1: Basic functionality
    echo -n "Testing basic functionality... "
    if my_plugin_basic_function | grep -q "expected_output"; then
        echo "✅ PASS"
        ((tests_passed++))
    else
        echo "❌ FAIL"
    fi
    
    # Add more tests...
    
    echo "Results: $tests_passed/$total_tests passed"
    [[ $tests_passed -eq $total_tests ]]
}
```

## 📚 Advanced Features

### Command Aliases

You can register multiple command names for the same function in `plugin.yaml`:

```yaml
commands:
  - name: "my-command"
    description: "Primary command"
    function: "my_plugin_main"
  - name: "my-cmd"
    description: "Short alias for my-command"
    function: "my_plugin_main"
```

### Plugin Dependencies

Specify other plugins your plugin depends on:

```yaml
plugin_dependencies:
  - "git-flow"
  - "project-init"
```

### Installation Hooks

Use hooks for complex setup/teardown:

```bash
# hooks/post-install
#!/bin/bash
echo "Setting up additional configuration..."
# Complex setup logic here
```

### Platform-Specific Code

Handle different platforms in your plugin:

```bash
case "$(uname -s)" in
    "Darwin")
        # macOS-specific code
        ;;
    "Linux")
        # Linux-specific code
        ;;
    *)
        echo "❌ Unsupported platform: $(uname -s)"
        return 1
        ;;
esac
```

## 🔧 Testing Your Plugin

### Manual Testing

```bash
# Install and enable your plugin
dot plugin install ./my-plugin
dot plugin enable my-plugin

# Test commands
dot my-command help
dot my-command action1
dot my-command test

# Check plugin status
dot plugin info my-plugin
dot plugin list enabled
```

### Automated Testing

Create test files in `tests/` directory:

```bash
# tests/basic_test.sh
#!/bin/bash
source "../lib/core.sh"

# Test plugin initialization
my_plugin_init
[[ -d "$MY_PLUGIN_CONFIG_DIR" ]] || exit 1

# Test command execution
output=$(my_plugin_main hello)
[[ "$output" =~ "Hello" ]] || exit 1

echo "All tests passed"
```

## 📋 Plugin Publishing

### Local Sharing

```bash
# Package your plugin
tar -czf my-plugin-1.0.0.tar.gz my-plugin/

# Install from package
dot plugin install my-plugin-1.0.0.tar.gz
```

### Git Repository

```bash
# Create repository
git init
git add .
git commit -m "Initial plugin implementation"
git remote add origin https://github.com/username/my-dotfiles-plugin.git
git push -u origin main

# Install from repository
dot plugin install https://github.com/username/my-dotfiles-plugin.git
```

## 🏆 Best Practices Checklist

- [ ] **Metadata**: Complete `plugin.yaml` with all relevant information
- [ ] **Naming**: Consistent naming conventions throughout
- [ ] **Help System**: Comprehensive help for all commands
- [ ] **Error Handling**: Clear error messages and graceful failures
- [ ] **Dependencies**: Proper dependency checking and validation
- [ ] **Configuration**: Sensible defaults and user customization options
- [ ] **Testing**: Self-tests and validation functions
- [ ] **Documentation**: Clear README and inline code comments
- [ ] **Lifecycle**: Proper init/cleanup functions
- [ ] **Cross-platform**: Support for target platforms
- [ ] **Performance**: Efficient implementation, lazy loading where appropriate

## 🤝 Contributing

This template is part of the modern dotfiles framework. Contributions to improve the template or add new features are welcome:

1. Fork the dotfiles repository
2. Create your feature branch
3. Make improvements to the template
4. Test thoroughly across platforms
5. Submit a pull request

## 📄 License

MIT License - This template can be used as the basis for any plugin, commercial or open-source.

---

*Happy plugin development! 🎉*