#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Plugin Management
# Plugin system command interface
# ============================================================================

# Load plugin system
source "$DOTFILES_DIR/lib/plugin-system.sh"

# Plugin command dispatcher
dot_plugin() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "install"|"add")
            plugin_cli "install" "$@"
            ;;
        "uninstall"|"remove"|"rm")
            plugin_cli "uninstall" "$@"
            ;;
        "enable"|"activate")
            plugin_cli "enable" "$@"
            ;;
        "disable"|"deactivate")
            plugin_cli "disable" "$@"
            ;;
        "list"|"ls")
            plugin_cli "list" "$@"
            ;;
        "search"|"find")
            plugin_cli "search" "$@"
            ;;
        "update"|"upgrade")
            plugin_cli "update" "$@"
            ;;
        "create"|"new"|"init")
            plugin_cli "create" "$@"
            ;;
        "info"|"show"|"describe")
            plugin_cli "info" "$@"
            ;;
        "status")
            show_plugin_status
            ;;
        "repos"|"repositories")
            manage_plugin_repositories "$@"
            ;;
        "validate"|"check")
            validate_plugin_system "$@"
            ;;
        "doctor")
            plugin_system_doctor
            ;;
        "-h"|"--help"|"help"|"")
            show_plugin_help
            ;;
        *)
            print_error "Unknown plugin subcommand: $subcommand"
            echo "Run 'dot plugin --help' for available commands."
            return 1
            ;;
    esac
}

# Show plugin system status
show_plugin_status() {
    echo "🔌 Plugin System Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # System information
    echo "Plugin Directory: $PLUGINS_DIR"
    echo "Config Directory: $PLUGINS_CONFIG_DIR"
    echo "Data Directory: $PLUGINS_DATA_DIR"
    echo "Cache Directory: $PLUGINS_CACHE_DIR"
    echo ""
    
    # Plugin counts
    local total_installed=0
    local total_enabled=0
    local total_available=0
    
    if [[ -d "$PLUGINS_DIR" ]]; then
        total_installed=$(find "$PLUGINS_DIR" -maxdepth 1 -type d ! -name "." ! -name "local" ! -name "core" ! -name "community" | wc -l | tr -d ' ')
    fi
    
    if [[ -f "$PLUGINS_REGISTRY_FILE" ]]; then
        total_enabled=$(get_enabled_plugins | wc -l | tr -d ' ')
    fi
    
    echo "Statistics:"
    echo "  📦 Installed: $total_installed"
    echo "  ⚡ Enabled: $total_enabled"
    echo "  🔌 Available: Updating..."
    
    # Update repository caches and count available
    update_repository_cache "core" 2>/dev/null &
    update_repository_cache "community" 2>/dev/null &
    wait
    
    local core_count=0
    local community_count=0
    
    if [[ -d "$PLUGINS_CACHE_DIR/repos/core" ]]; then
        core_count=$(find "$PLUGINS_CACHE_DIR/repos/core" -maxdepth 1 -type d ! -name "." | wc -l | tr -d ' ')
    fi
    
    if [[ -d "$PLUGINS_CACHE_DIR/repos/community" ]]; then
        community_count=$(find "$PLUGINS_CACHE_DIR/repos/community" -maxdepth 1 -type d ! -name "." | wc -l | tr -d ' ')
    fi
    
    total_available=$((core_count + community_count))
    
    echo -e "\\r  🌐 Available: $total_available"
    echo ""
    
    # Show enabled plugins
    echo "Enabled Plugins:"
    local enabled_plugins
    enabled_plugins=$(get_enabled_plugins)
    
    if [[ -n "$enabled_plugins" ]]; then
        for plugin in $enabled_plugins; do
            echo "  ✅ $plugin"
        done
    else
        echo "  No plugins enabled"
    fi
    echo ""
    
    # Repository status
    echo "Repositories:"
    if [[ -f "$PLUGINS_REGISTRY_FILE" ]]; then
        echo "  🏠 Core: $(get_repository_url "core")"
        echo "  🌍 Community: $(get_repository_url "community")"
    fi
    
    # Quick health check
    echo ""
    echo "Health Check:"
    if [[ -f "$PLUGINS_REGISTRY_FILE" ]]; then
        echo "  ✅ Plugin registry exists"
    else
        echo "  ❌ Plugin registry missing"
    fi
    
    if [[ -d "$PLUGINS_DIR" ]]; then
        echo "  ✅ Plugin directory exists"
    else
        echo "  ❌ Plugin directory missing"
    fi
    
    if command -v yq >/dev/null 2>&1; then
        echo "  ✅ YAML processor available (yq)"
    else
        echo "  ⚠️  YAML processor not found (yq) - using fallback parser"
    fi
}

# Manage plugin repositories
manage_plugin_repositories() {
    local action="${1:-list}"
    shift || true
    
    case "$action" in
        "list")
            list_plugin_repositories
            ;;
        "add")
            add_plugin_repository "$@"
            ;;
        "remove"|"rm")
            remove_plugin_repository "$@"
            ;;
        "update"|"refresh")
            update_plugin_repositories "$@"
            ;;
        *)
            echo "Usage: dot plugin repos <list|add|remove|update>"
            ;;
    esac
}

# List plugin repositories
list_plugin_repositories() {
    echo "📚 Plugin Repositories"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -f "$PLUGINS_REGISTRY_FILE" ]]; then
        echo "No repository configuration found"
        return
    fi
    
    if command -v yq >/dev/null 2>&1; then
        yq eval '.repositories | to_entries | .[] | "  " + .key + ": " + .value.url + " [" + .value.type + "]"' "$PLUGINS_REGISTRY_FILE"
    else
        # Fallback
        echo "  core: $(get_repository_url "core") [git]"
        echo "  community: $(get_repository_url "community") [git]"
    fi
}

# Add plugin repository
add_plugin_repository() {
    local name="$1"
    local url="$2"
    local type="${3:-git}"
    
    if [[ -z "$name" || -z "$url" ]]; then
        echo "Usage: dot plugin repos add <name> <url> [type]"
        return 1
    fi
    
    echo "📚 Adding repository: $name"
    
    if command -v yq >/dev/null 2>&1; then
        yq eval ".repositories.$name.url = \"$url\"" -i "$PLUGINS_REGISTRY_FILE"
        yq eval ".repositories.$name.type = \"$type\"" -i "$PLUGINS_REGISTRY_FILE"
        yq eval ".repositories.$name.enabled = true" -i "$PLUGINS_REGISTRY_FILE"
    else
        echo "⚠️  yq not found - please add repository manually to $PLUGINS_REGISTRY_FILE"
        return 1
    fi
    
    echo "✅ Repository added successfully"
    
    # Update repository cache
    if ask_yes_no "Update repository cache now?"; then
        update_repository_cache "$name"
    fi
}

# Remove plugin repository
remove_plugin_repository() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        echo "Usage: dot plugin repos remove <name>"
        return 1
    fi
    
    echo "🗑️  Removing repository: $name"
    
    if command -v yq >/dev/null 2>&1; then
        yq eval "del(.repositories.$name)" -i "$PLUGINS_REGISTRY_FILE"
    else
        echo "⚠️  yq not found - please remove repository manually from $PLUGINS_REGISTRY_FILE"
        return 1
    fi
    
    # Remove cache
    rm -rf "$PLUGINS_CACHE_DIR/repos/$name"
    
    echo "✅ Repository removed successfully"
}

# Update plugin repositories
update_plugin_repositories() {
    echo "🔄 Updating plugin repositories..."
    
    if [[ -f "$PLUGINS_REGISTRY_FILE" ]]; then
        if command -v yq >/dev/null 2>&1; then
            local repos
            repos=$(yq eval '.repositories | keys | .[]' "$PLUGINS_REGISTRY_FILE")
            
            for repo in $repos; do
                echo "  Updating: $repo"
                update_repository_cache "$repo"
            done
        else
            # Fallback: update known repositories
            echo "  Updating: core"
            update_repository_cache "core"
            echo "  Updating: community"
            update_repository_cache "community"
        fi
    fi
    
    echo "✅ Repository update completed"
}

# Validate plugin system
validate_plugin_system() {
    local plugin_name="${1:-}"
    
    if [[ -n "$plugin_name" ]]; then
        validate_single_plugin "$plugin_name"
    else
        validate_all_plugins
    fi
}

# Validate single plugin
validate_single_plugin() {
    local plugin_name="$1"
    
    echo "🔍 Validating plugin: $plugin_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ! plugin_is_installed "$plugin_name"; then
        echo "❌ Plugin not installed: $plugin_name"
        return 1
    fi
    
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    local issues=0
    
    # Check structure
    echo "Checking plugin structure..."
    if ! validate_plugin_structure "$plugin_name"; then
        ((issues++))
    fi
    
    # Check metadata
    echo "Checking plugin metadata..."
    if [[ -f "$plugin_dir/plugin.yaml" ]]; then
        if validate_plugin_yaml "$plugin_dir/plugin.yaml"; then
            echo "  ✅ plugin.yaml is valid"
        else
            echo "  ❌ plugin.yaml has issues"
            ((issues++))
        fi
    else
        echo "  ❌ plugin.yaml missing"
        ((issues++))
    fi
    
    # Check dependencies
    echo "Checking dependencies..."
    if check_plugin_dependencies "$plugin_name"; then
        echo "  ✅ All dependencies satisfied"
    else
        echo "  ❌ Missing dependencies"
        ((issues++))
    fi
    
    # Check if plugin can load
    echo "Testing plugin loading..."
    if load_plugin "$plugin_name" 2>/dev/null; then
        echo "  ✅ Plugin loads successfully"
    else
        echo "  ❌ Plugin failed to load"
        ((issues++))
    fi
    
    # Summary
    echo ""
    if [[ $issues -eq 0 ]]; then
        echo "✅ Plugin validation passed: $plugin_name"
    else
        echo "❌ Plugin validation failed: $plugin_name ($issues issues)"
        return 1
    fi
}

# Validate all plugins
validate_all_plugins() {
    echo "🔍 Validating all installed plugins..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local total_plugins=0
    local valid_plugins=0
    
    if [[ -d "$PLUGINS_DIR" ]]; then
        for plugin_dir in "$PLUGINS_DIR"/*; do
            if [[ -d "$plugin_dir" && ! "$plugin_dir" =~ /(local|core|community)$ ]]; then
                local plugin_name=$(basename "$plugin_dir")
                ((total_plugins++))
                
                echo "Checking: $plugin_name"
                if validate_single_plugin "$plugin_name" >/dev/null 2>&1; then
                    echo "  ✅ Valid"
                    ((valid_plugins++))
                else
                    echo "  ❌ Issues found"
                fi
            fi
        done
    fi
    
    echo ""
    echo "Summary: $valid_plugins/$total_plugins plugins are valid"
    
    if [[ $valid_plugins -eq $total_plugins ]]; then
        echo "✅ All plugins validated successfully"
    else
        echo "⚠️  Some plugins have issues - run validation on individual plugins for details"
    fi
}

# Plugin system doctor - comprehensive health check
plugin_system_doctor() {
    echo "🏥 Plugin System Doctor"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running comprehensive plugin system health check..."
    echo ""
    
    local issues=0
    
    # Check system requirements
    echo "🔍 Checking system requirements..."
    
    # Check bash version
    if [[ ${BASH_VERSION:0:1} -ge 4 ]]; then
        echo "  ✅ Bash version: $BASH_VERSION"
    else
        echo "  ❌ Bash version too old: $BASH_VERSION (requires 4.0+)"
        ((issues++))
    fi
    
    # Check for required commands
    local required_commands=("git" "curl" "tar" "unzip")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "  ✅ $cmd available"
        else
            echo "  ❌ $cmd not found"
            ((issues++))
        fi
    done
    
    # Check for optional commands
    echo ""
    echo "🔍 Checking optional tools..."
    local optional_commands=("yq" "jq")
    for cmd in "${optional_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "  ✅ $cmd available"
        else
            echo "  ⚠️  $cmd not found (using fallback parser)"
        fi
    done
    
    # Check directories
    echo ""
    echo "🔍 Checking directory structure..."
    local required_dirs=("$PLUGINS_DIR" "$PLUGINS_CONFIG_DIR" "$PLUGINS_DATA_DIR" "$PLUGINS_CACHE_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "  ✅ $(basename "$dir"): $dir"
        else
            echo "  ❌ Missing directory: $dir"
            ((issues++))
        fi
    done
    
    # Check registry file
    echo ""
    echo "🔍 Checking plugin registry..."
    if [[ -f "$PLUGINS_REGISTRY_FILE" ]]; then
        echo "  ✅ Registry file exists"
        
        # Validate registry format
        if command -v yq >/dev/null 2>&1; then
            if yq eval '.' "$PLUGINS_REGISTRY_FILE" >/dev/null 2>&1; then
                echo "  ✅ Registry format valid"
            else
                echo "  ❌ Registry format invalid"
                ((issues++))
            fi
        fi
    else
        echo "  ❌ Registry file missing"
        ((issues++))
    fi
    
    # Check permissions
    echo ""
    echo "🔍 Checking permissions..."
    if [[ -w "$PLUGINS_DIR" ]]; then
        echo "  ✅ Plugin directory writable"
    else
        echo "  ❌ Plugin directory not writable"
        ((issues++))
    fi
    
    if [[ -w "$PLUGINS_CONFIG_DIR" ]]; then
        echo "  ✅ Config directory writable"
    else
        echo "  ❌ Config directory not writable"
        ((issues++))
    fi
    
    # Check installed plugins
    echo ""
    echo "🔍 Checking installed plugins..."
    local installed_count=0
    local problematic_plugins=()
    
    if [[ -d "$PLUGINS_DIR" ]]; then
        for plugin_dir in "$PLUGINS_DIR"/*; do
            if [[ -d "$plugin_dir" && ! "$plugin_dir" =~ /(local|core|community)$ ]]; then
                local plugin_name=$(basename "$plugin_dir")
                ((installed_count++))
                
                if ! validate_single_plugin "$plugin_name" >/dev/null 2>&1; then
                    problematic_plugins+=("$plugin_name")
                fi
            fi
        done
    fi
    
    echo "  📦 Total installed: $installed_count"
    if [[ ${#problematic_plugins[@]} -eq 0 ]]; then
        echo "  ✅ All plugins healthy"
    else
        echo "  ⚠️  Problematic plugins: ${problematic_plugins[*]}"
    fi
    
    # Check network connectivity
    echo ""
    echo "🔍 Checking network connectivity..."
    if curl -s --max-time 5 https://github.com >/dev/null 2>&1; then
        echo "  ✅ GitHub connectivity"
    else
        echo "  ⚠️  GitHub not reachable (plugin installation may fail)"
    fi
    
    # Summary and recommendations
    echo ""
    echo "📋 Health Check Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Plugin system is healthy!"
        echo ""
        echo "🎯 Recommendations:"
        echo "  • Run 'dot plugin repos update' to refresh repositories"
        echo "  • Use 'dot plugin search <term>' to discover new plugins"
        echo "  • Create custom plugins with 'dot plugin create <name>'"
    else
        echo "❌ Found $issues issues that need attention"
        echo ""
        echo "🔧 Recommendations:"
        if [[ ! -f "$PLUGINS_REGISTRY_FILE" ]]; then
            echo "  • Initialize plugin system: dot plugin init"
        fi
        if [[ ! -d "$PLUGINS_DIR" ]]; then
            echo "  • Create plugin directories: mkdir -p $PLUGINS_DIR"
        fi
        if [[ ${#problematic_plugins[@]} -gt 0 ]]; then
            echo "  • Check specific plugins: dot plugin validate <plugin_name>"
        fi
        echo "  • Fix permission issues if any"
        echo "  • Install missing required tools"
    fi
}

# Plugin help
show_plugin_help() {
    cat << 'EOF'
🔌 Plugin Management System

USAGE:
    dot plugin <command> [options]

COMMANDS:
    install <name> [source]    Install plugin from registry or source
    uninstall <name>          Remove installed plugin
    enable <name>             Enable installed plugin
    disable <name>            Disable enabled plugin
    
    list [filter]             List plugins
      all                     All plugins (default)
      installed               Installed plugins only
      enabled                 Enabled plugins only
      available               Available plugins from repositories
    
    search <query>            Search available plugins
    update [name]             Update plugin(s)
    info <name>               Show detailed plugin information
    
    create <name> [type]      Create new plugin template
      basic                   Basic plugin template (default)
      cli                     CLI command plugin
      hook                    Git hook plugin
      theme                   Theme plugin
    
    status                    Show plugin system status
    repos <action>            Manage plugin repositories
      list                    List configured repositories
      add <name> <url>        Add new repository
      remove <name>           Remove repository
      update                  Update all repositories
    
    validate [name]           Validate plugin structure and dependencies
    doctor                    Comprehensive system health check

OPTIONS:
    --force                   Force operation (bypass checks)
    --no-deps                 Skip dependency validation
    --remove-data             Remove plugin data on uninstall
    --auto-enable             Auto-enable after installation
    -h, --help                Show this help message

EXAMPLES:
    # Install and use plugins
    dot plugin search git                    # Find git-related plugins
    dot plugin install git-flow             # Install from registry
    dot plugin install my-plugin ~/code/plugin  # Install from local path
    dot plugin enable git-flow              # Enable installed plugin
    
    # Manage plugins
    dot plugin list installed               # Show installed plugins
    dot plugin info git-flow                # Get plugin details
    dot plugin update                       # Update all plugins
    dot plugin disable git-flow             # Disable plugin
    dot plugin uninstall git-flow           # Remove plugin
    
    # Development
    dot plugin create my-tool cli           # Create CLI plugin template
    dot plugin validate my-tool             # Check plugin structure
    dot plugin repos add custom https://github.com/user/plugins.git
    
    # System maintenance
    dot plugin status                       # Check system status
    dot plugin doctor                       # Full health check
    dot plugin repos update                 # Refresh repositories

PLUGIN STRUCTURE:
    plugin-name/
    ├── plugin.yaml          # Plugin metadata (required)
    ├── install.sh           # Installation script
    ├── uninstall.sh         # Uninstallation script
    ├── lib/                 # Plugin libraries
    │   └── core.sh          # Main plugin code
    ├── config/              # Default configurations
    ├── hooks/               # Plugin lifecycle hooks
    ├── templates/           # Configuration templates
    ├── docs/                # Documentation
    └── tests/               # Plugin tests

For more information: https://docs.dotfiles.dev/plugins
EOF
}

# Export functions
export -f dot_plugin show_plugin_status manage_plugin_repositories
export -f validate_plugin_system plugin_system_doctor show_plugin_help