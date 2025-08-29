#!/usr/bin/env bash
# =============================================================================
# CLI Plugin Template - Example implementation demonstrating plugin structure
# =============================================================================

# Plugin configuration and constants
CLI_TEMPLATE_VERSION="1.0.0"
CLI_TEMPLATE_CONFIG_DIR="${HOME}/.config/dotfiles/plugins/cli-template"
CLI_TEMPLATE_DATA_DIR="${HOME}/.local/share/dotfiles/plugins/cli-template"

# Plugin initialization
cli_template_init() {
    echo "🔌 CLI Plugin Template initialized (v${CLI_TEMPLATE_VERSION})"
    
    # Create plugin directories
    mkdir -p "$CLI_TEMPLATE_CONFIG_DIR" "$CLI_TEMPLATE_DATA_DIR"
    
    # Initialize plugin state
    setup_cli_template_config
}

# Plugin cleanup
cli_template_cleanup() {
    echo "🔌 CLI Plugin Template cleaned up"
    
    # Cleanup resources if needed
    # This is called when plugin is disabled
}

# Main example command function
cli_template_example() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        "hello"|"hi")
            cli_template_hello "$@"
            ;;
        "config")
            cli_template_show_config "$@"
            ;;
        "status"|"st")
            cli_template_status
            ;;
        "test")
            cli_template_test "$@"
            ;;
        "version"|"-v"|"--version")
            echo "CLI Plugin Template v${CLI_TEMPLATE_VERSION}"
            ;;
        "help"|"-h"|"--help"|"")
            cli_template_help
            ;;
        *)
            echo "❌ Unknown example command: $subcommand"
            echo "Run 'dot example help' for available commands"
            return 1
            ;;
    esac
}

# Demo command showcasing plugin capabilities
cli_template_demo() {
    echo "🎯 CLI Plugin Template Demonstration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "This template demonstrates:"
    echo "  ✅ Plugin metadata structure (plugin.yaml)"
    echo "  ✅ Command registration and routing"
    echo "  ✅ Configuration management"
    echo "  ✅ Help system integration"
    echo "  ✅ Error handling patterns"
    echo "  ✅ Plugin lifecycle management"
    echo "  ✅ DOT CLI integration"
    echo ""
    
    echo "📋 Available Commands:"
    echo "  dot example hello [name]    # Greeting command"
    echo "  dot example config          # Show configuration"
    echo "  dot example status          # Show plugin status"
    echo "  dot example test            # Run self-tests"
    echo "  dot example version         # Show version"
    echo "  dot example help            # Show help"
    echo ""
    
    echo "  dot template-demo           # This demonstration"
    echo ""
    
    echo "🔧 Plugin Structure:"
    echo "  plugin.yaml                 # Plugin metadata"
    echo "  lib/core.sh                 # Main plugin code"
    echo "  config/                     # Default configurations"
    echo "  docs/                       # Documentation"
    echo "  tests/                      # Plugin tests"
    echo "  install.sh                  # Installation script"
    echo "  uninstall.sh               # Uninstallation script"
    echo ""
    
    echo "💡 Use this as a reference when creating your own plugins!"
}

# Example hello command with argument handling
cli_template_hello() {
    local name="${1:-World}"
    local greeting="${2:-Hello}"
    
    echo "$greeting, $name! 👋"
    echo ""
    echo "This demonstrates:"
    echo "  • Argument parsing and defaults"
    echo "  • String interpolation"
    echo "  • User-friendly output formatting"
    echo ""
    echo "Try: dot example hello Alice Howdy"
}

# Configuration display
cli_template_show_config() {
    echo "⚙️  CLI Template Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Version: $CLI_TEMPLATE_VERSION"
    echo "Config Directory: $CLI_TEMPLATE_CONFIG_DIR"
    echo "Data Directory: $CLI_TEMPLATE_DATA_DIR"
    echo "Plugin Location: $(dirname "$(dirname "${BASH_SOURCE[0]}")")"
    
    if [[ -f "$CLI_TEMPLATE_CONFIG_DIR/settings.yaml" ]]; then
        echo ""
        echo "Custom Settings:"
        cat "$CLI_TEMPLATE_CONFIG_DIR/settings.yaml"
    else
        echo ""
        echo "No custom settings configured"
    fi
}

# Status check
cli_template_status() {
    echo "📊 CLI Template Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check plugin health
    local health_score=0
    local total_checks=4
    
    # Check 1: Plugin directories exist
    if [[ -d "$CLI_TEMPLATE_CONFIG_DIR" && -d "$CLI_TEMPLATE_DATA_DIR" ]]; then
        echo "  ✅ Plugin directories: OK"
        ((health_score++))
    else
        echo "  ❌ Plugin directories: Missing"
    fi
    
    # Check 2: Plugin is properly loaded
    if declare -f cli_template_init >/dev/null 2>&1; then
        echo "  ✅ Plugin functions: Loaded"
        ((health_score++))
    else
        echo "  ❌ Plugin functions: Not loaded"
    fi
    
    # Check 3: DOT CLI integration
    if [[ -n "${DOTFILES_DIR:-}" ]]; then
        echo "  ✅ DOT CLI integration: Active"
        ((health_score++))
    else
        echo "  ❌ DOT CLI integration: Not active"
    fi
    
    # Check 4: Plugin commands registered
    if command -v dot >/dev/null 2>&1 && dot example version >/dev/null 2>&1; then
        echo "  ✅ Command registration: Working"
        ((health_score++))
    else
        echo "  ❌ Command registration: Failed"
    fi
    
    # Summary
    echo ""
    local health_percentage=$((health_score * 100 / total_checks))
    echo "Overall Health: $health_score/$total_checks ($health_percentage%)"
    
    if [[ $health_score -eq $total_checks ]]; then
        echo "🎉 Plugin is fully operational!"
    elif [[ $health_score -gt $((total_checks / 2)) ]]; then
        echo "⚠️  Plugin has some issues but is functional"
    else
        echo "❌ Plugin has significant issues"
    fi
}

# Self-test functionality
cli_template_test() {
    echo "🧪 Running CLI Template Self-Tests"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local tests_passed=0
    local total_tests=5
    
    # Test 1: Basic function execution
    echo -n "Testing basic function execution... "
    if cli_template_hello "Test" "Hi" | grep -q "Hi, Test"; then
        echo "✅ PASS"
        ((tests_passed++))
    else
        echo "❌ FAIL"
    fi
    
    # Test 2: Configuration access
    echo -n "Testing configuration access... "
    if [[ -n "$CLI_TEMPLATE_CONFIG_DIR" ]]; then
        echo "✅ PASS"
        ((tests_passed++))
    else
        echo "❌ FAIL"
    fi
    
    # Test 3: Error handling
    echo -n "Testing error handling... "
    if cli_template_example "nonexistent" 2>&1 | grep -q "Unknown example command"; then
        echo "✅ PASS"
        ((tests_passed++))
    else
        echo "❌ FAIL"
    fi
    
    # Test 4: Help system
    echo -n "Testing help system... "
    if cli_template_help | grep -q "CLI Template Plugin"; then
        echo "✅ PASS"
        ((tests_passed++))
    else
        echo "❌ FAIL"
    fi
    
    # Test 5: Plugin metadata
    echo -n "Testing plugin metadata... "
    local plugin_dir
    plugin_dir="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
    if [[ -f "$plugin_dir/plugin.yaml" ]] && grep -q "cli-plugin-template" "$plugin_dir/plugin.yaml"; then
        echo "✅ PASS"
        ((tests_passed++))
    else
        echo "❌ FAIL"
    fi
    
    # Summary
    echo ""
    echo "Test Results: $tests_passed/$total_tests passed"
    
    if [[ $tests_passed -eq $total_tests ]]; then
        echo "🎉 All tests passed!"
        return 0
    else
        echo "❌ Some tests failed"
        return 1
    fi
}

# Setup plugin configuration
setup_cli_template_config() {
    # Create default configuration if it doesn't exist
    if [[ ! -f "$CLI_TEMPLATE_CONFIG_DIR/settings.yaml" ]]; then
        cat > "$CLI_TEMPLATE_CONFIG_DIR/settings.yaml" << 'EOF'
# CLI Template Plugin Configuration
cli_template:
  # Default greeting
  default_greeting: "Hello"
  
  # Enable debug mode
  debug: false
  
  # Custom settings
  feature_flags:
    - "demo_mode"
    - "self_test"
EOF
    fi
}

# Help system
cli_template_help() {
    cat << 'EOF'
🔌 CLI Template Plugin - Example Implementation

DESCRIPTION:
    This plugin serves as a comprehensive template and example for creating
    CLI plugins within the dotfiles framework. It demonstrates best practices
    for plugin structure, command handling, and integration patterns.

USAGE:
    dot example <command> [options]
    dot template-demo

COMMANDS:
    hello [name] [greeting]    Demonstrate argument handling (default: World, Hello)
    config                     Show plugin configuration and directories
    status                     Check plugin health and integration status
    test                       Run comprehensive self-tests
    version                    Display plugin version information
    help                       Show this help message

    template-demo              Show complete plugin demonstration

EXAMPLES:
    # Basic usage
    dot example hello
    dot example hello Alice
    dot example hello Bob Howdy
    
    # Plugin management
    dot example config
    dot example status
    dot example test
    
    # Information
    dot example version
    dot template-demo

PLUGIN STRUCTURE DEMONSTRATED:
    ✅ Metadata definition (plugin.yaml)
    ✅ Command registration and routing
    ✅ Argument parsing and validation
    ✅ Configuration management
    ✅ Error handling and user feedback
    ✅ Help system integration
    ✅ Self-testing capabilities
    ✅ Plugin lifecycle management
    ✅ DOT CLI integration patterns

DEVELOPMENT PATTERNS:
    • Namespace all functions with plugin prefix
    • Use consistent error handling and user feedback
    • Implement help for all commands and subcommands
    • Provide configuration options where appropriate
    • Include self-testing for reliability
    • Follow plugin lifecycle (init/cleanup)
    • Export functions for plugin system

CONFIGURATION:
    Plugin config: ~/.config/dotfiles/plugins/cli-template/
    Plugin data:   ~/.local/share/dotfiles/plugins/cli-template/

For more information about plugin development:
    https://docs.dotfiles.dev/plugins/development
EOF
}

# Export functions for plugin system
export -f cli_template_init cli_template_cleanup cli_template_example cli_template_demo