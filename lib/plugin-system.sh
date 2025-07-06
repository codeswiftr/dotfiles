#!/usr/bin/env bash
# =============================================================================
# Plugin and Extension System
# Extensible architecture for custom functionality and third-party integrations
# =============================================================================

# Plugin system configuration
PLUGINS_DIR="$DOTFILES_DIR/plugins"
PLUGINS_CONFIG_DIR="$HOME/.config/dotfiles/plugins"
PLUGINS_DATA_DIR="$HOME/.local/share/dotfiles/plugins"
PLUGINS_CACHE_DIR="$HOME/.cache/dotfiles/plugins"
PLUGINS_REGISTRY_FILE="$PLUGINS_CONFIG_DIR/registry.yaml"

# Plugin states
PLUGIN_STATE_AVAILABLE="available"
PLUGIN_STATE_INSTALLED="installed"
PLUGIN_STATE_ENABLED="enabled"
PLUGIN_STATE_DISABLED="disabled"
PLUGIN_STATE_ERROR="error"

# Initialize plugin system
init_plugin_system() {
    mkdir -p "$PLUGINS_DIR" "$PLUGINS_CONFIG_DIR" "$PLUGINS_DATA_DIR" "$PLUGINS_CACHE_DIR"
    
    # Create plugin registry if it doesn't exist
    if [[ ! -f "$PLUGINS_REGISTRY_FILE" ]]; then
        create_plugin_registry
    fi
    
    # Create default plugin directories
    mkdir -p "$PLUGINS_DIR"/{core,community,local}
    
    # Initialize core plugin system components
    setup_plugin_hooks
    load_enabled_plugins
}

# Create plugin registry
create_plugin_registry() {
    cat > "$PLUGINS_REGISTRY_FILE" << EOF
# Plugin Registry
# Tracks installed and enabled plugins

version: "1.0"
plugins: {}

# Plugin repositories
repositories:
  core:
    url: "https://github.com/user/dotfiles-plugins-core.git"
    type: "git"
    enabled: true
    
  community:
    url: "https://github.com/dotfiles-community/plugins.git"
    type: "git"
    enabled: true
    
# Plugin configuration
config:
  auto_update: false
  check_signatures: true
  allow_local: true
  parallel_install: true
  max_parallel: 4
EOF
}

# Plugin metadata structure
# plugins/
# ├── plugin-name/
# │   ├── plugin.yaml           # Plugin metadata
# │   ├── install.sh           # Installation script
# │   ├── uninstall.sh         # Uninstallation script
# │   ├── lib/                 # Plugin libraries
# │   │   ├── core.sh          # Core plugin functions
# │   │   └── commands.sh      # CLI commands
# │   ├── config/              # Default configurations
# │   │   └── default.yaml     # Default settings
# │   ├── hooks/               # Plugin hooks
# │   │   ├── pre-install      # Pre-installation hook
# │   │   └── post-install     # Post-installation hook
# │   ├── templates/           # Configuration templates
# │   ├── docs/                # Plugin documentation
# │   └── tests/               # Plugin tests

# Load plugin metadata
load_plugin_metadata() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    if [[ ! -f "$plugin_dir/plugin.yaml" ]]; then
        echo "Plugin metadata not found: $plugin_name" >&2
        return 1
    fi
    
    # Parse plugin.yaml and set variables
    eval "$(parse_yaml "$plugin_dir/plugin.yaml" "PLUGIN_")"
}

# Install plugin
plugin_install() {
    local plugin_name="$1"
    local plugin_source="${2:-}"
    local force="${3:-false}"
    
    echo "📦 Installing plugin: $plugin_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if plugin already installed
    if [[ "$force" != "true" ]] && plugin_is_installed "$plugin_name"; then
        echo "⚠️  Plugin already installed: $plugin_name"
        echo "Use --force to reinstall"
        return 1
    fi
    
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    # Install from source
    if [[ -n "$plugin_source" ]]; then
        install_plugin_from_source "$plugin_name" "$plugin_source"
    else
        install_plugin_from_registry "$plugin_name"
    fi
    
    # Validate plugin structure
    if ! validate_plugin_structure "$plugin_name"; then
        echo "❌ Plugin validation failed: $plugin_name"
        return 1
    fi
    
    # Load plugin metadata
    load_plugin_metadata "$plugin_name"
    
    # Check dependencies
    if ! check_plugin_dependencies "$plugin_name"; then
        echo "❌ Plugin dependency check failed: $plugin_name"
        return 1
    fi
    
    # Run pre-install hook
    run_plugin_hook "$plugin_name" "pre-install"
    
    # Execute plugin installation script
    if [[ -f "$plugin_dir/install.sh" ]]; then
        echo "🔧 Running plugin installation script..."
        cd "$plugin_dir" || return 1
        bash install.sh
        cd - >/dev/null || return 1
    fi
    
    # Run post-install hook
    run_plugin_hook "$plugin_name" "post-install"
    
    # Register plugin
    register_plugin "$plugin_name" "$PLUGIN_STATE_INSTALLED"
    
    echo "✅ Plugin installed successfully: $plugin_name"
    
    # Ask to enable plugin
    if [[ "$AUTO_ENABLE_PLUGINS" == "true" ]] || ask_yes_no "Enable plugin now?"; then
        plugin_enable "$plugin_name"
    fi
}

# Install plugin from git repository
install_plugin_from_source() {
    local plugin_name="$1"
    local source_url="$2"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    echo "📥 Installing from source: $source_url"
    
    # Remove existing directory if force install
    if [[ -d "$plugin_dir" ]]; then
        rm -rf "$plugin_dir"
    fi
    
    # Clone or download plugin
    if [[ "$source_url" =~ ^https?:// ]] || [[ "$source_url" =~ ^git@ ]]; then
        git clone "$source_url" "$plugin_dir"
    elif [[ -d "$source_url" ]]; then
        cp -r "$source_url" "$plugin_dir"
    elif [[ -f "$source_url" ]]; then
        # Extract archive
        extract_plugin_archive "$source_url" "$plugin_dir"
    else
        echo "❌ Unsupported plugin source: $source_url"
        return 1
    fi
}

# Install plugin from registry
install_plugin_from_registry() {
    local plugin_name="$1"
    
    echo "🔍 Searching plugin registry for: $plugin_name"
    
    # Check in core plugins first
    if check_plugin_in_repository "core" "$plugin_name"; then
        install_from_repository "core" "$plugin_name"
        return 0
    fi
    
    # Check in community plugins
    if check_plugin_in_repository "community" "$plugin_name"; then
        install_from_repository "community" "$plugin_name"
        return 0
    fi
    
    # Check local plugins
    if [[ -d "$PLUGINS_DIR/local/$plugin_name" ]]; then
        ln -sf "$PLUGINS_DIR/local/$plugin_name" "$PLUGINS_DIR/$plugin_name"
        return 0
    fi
    
    echo "❌ Plugin not found in registry: $plugin_name"
    return 1
}

# Check plugin in repository
check_plugin_in_repository() {
    local repo_name="$1"
    local plugin_name="$2"
    local repo_dir="$PLUGINS_CACHE_DIR/repos/$repo_name"
    
    # Update repository cache if needed
    update_repository_cache "$repo_name"
    
    [[ -d "$repo_dir/$plugin_name" ]]
}

# Install from repository
install_from_repository() {
    local repo_name="$1"
    local plugin_name="$2"
    local repo_dir="$PLUGINS_CACHE_DIR/repos/$repo_name"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    echo "📦 Installing from $repo_name repository..."
    
    cp -r "$repo_dir/$plugin_name" "$plugin_dir"
}

# Update repository cache
update_repository_cache() {
    local repo_name="$1"
    local repo_dir="$PLUGINS_CACHE_DIR/repos/$repo_name"
    local repo_url
    
    # Get repository URL from registry
    repo_url=$(get_repository_url "$repo_name")
    
    if [[ -z "$repo_url" ]]; then
        echo "❌ Repository not found: $repo_name"
        return 1
    fi
    
    # Clone or update repository
    if [[ -d "$repo_dir" ]]; then
        echo "🔄 Updating repository cache: $repo_name"
        cd "$repo_dir" || return 1
        git pull --quiet
        cd - >/dev/null || return 1
    else
        echo "📥 Cloning repository: $repo_name"
        mkdir -p "$(dirname "$repo_dir")"
        git clone --quiet "$repo_url" "$repo_dir"
    fi
}

# Get repository URL from registry
get_repository_url() {
    local repo_name="$1"
    
    # Parse YAML and extract URL
    if command -v yq >/dev/null 2>&1; then
        yq eval ".repositories.$repo_name.url" "$PLUGINS_REGISTRY_FILE"
    else
        # Fallback to grep
        grep -A 2 "^  $repo_name:" "$PLUGINS_REGISTRY_FILE" | grep "url:" | cut -d'"' -f2
    fi
}

# Validate plugin structure
validate_plugin_structure() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    echo "🔍 Validating plugin structure..."
    
    # Required files
    local required_files=(
        "plugin.yaml"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$plugin_dir/$file" ]]; then
            echo "❌ Missing required file: $file"
            return 1
        fi
    done
    
    # Validate plugin.yaml
    if ! validate_plugin_yaml "$plugin_dir/plugin.yaml"; then
        echo "❌ Invalid plugin.yaml format"
        return 1
    fi
    
    # Check for executable scripts
    if [[ -f "$plugin_dir/install.sh" ]]; then
        chmod +x "$plugin_dir/install.sh"
    fi
    
    if [[ -f "$plugin_dir/uninstall.sh" ]]; then
        chmod +x "$plugin_dir/uninstall.sh"
    fi
    
    echo "✅ Plugin structure validation passed"
    return 0
}

# Validate plugin.yaml format
validate_plugin_yaml() {
    local plugin_file="$1"
    
    # Check required fields
    local required_fields=(
        "name"
        "version"
        "description"
    )
    
    for field in "${required_fields[@]}"; do
        if ! grep -q "^$field:" "$plugin_file"; then
            echo "❌ Missing required field: $field"
            return 1
        fi
    done
    
    return 0
}

# Check plugin dependencies
check_plugin_dependencies() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    if [[ ! -f "$plugin_dir/plugin.yaml" ]]; then
        return 0
    fi
    
    echo "🔍 Checking plugin dependencies..."
    
    # Load plugin metadata
    load_plugin_metadata "$plugin_name"
    
    # Check system dependencies
    if [[ -n "${PLUGIN_dependencies:-}" ]]; then
        IFS=',' read -ra deps <<< "$PLUGIN_dependencies"
        for dep in "${deps[@]}"; do
            dep=$(echo "$dep" | xargs) # trim whitespace
            if ! command -v "$dep" >/dev/null 2>&1; then
                echo "❌ Missing system dependency: $dep"
                return 1
            fi
        done
    fi
    
    # Check plugin dependencies
    if [[ -n "${PLUGIN_plugin_dependencies:-}" ]]; then
        IFS=',' read -ra plugin_deps <<< "$PLUGIN_plugin_dependencies"
        for plugin_dep in "${plugin_deps[@]}"; do
            plugin_dep=$(echo "$plugin_dep" | xargs) # trim whitespace
            if ! plugin_is_enabled "$plugin_dep"; then
                echo "❌ Missing plugin dependency: $plugin_dep"
                echo "Install and enable required plugin: $plugin_dep"
                return 1
            fi
        done
    fi
    
    echo "✅ All dependencies satisfied"
    return 0
}

# Run plugin hook
run_plugin_hook() {
    local plugin_name="$1"
    local hook_name="$2"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    local hook_script="$plugin_dir/hooks/$hook_name"
    
    if [[ -f "$hook_script" ]]; then
        echo "🪝 Running $hook_name hook..."
        cd "$plugin_dir" || return 1
        bash "$hook_script"
        cd - >/dev/null || return 1
    fi
}

# Register plugin in registry
register_plugin() {
    local plugin_name="$1"
    local state="$2"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    # Load plugin metadata
    load_plugin_metadata "$plugin_name"
    
    # Update registry
    if command -v yq >/dev/null 2>&1; then
        yq eval ".plugins.$plugin_name.state = \"$state\"" -i "$PLUGINS_REGISTRY_FILE"
        yq eval ".plugins.$plugin_name.version = \"${PLUGIN_version:-unknown}\"" -i "$PLUGINS_REGISTRY_FILE"
        yq eval ".plugins.$plugin_name.installed_at = \"$(date -Iseconds)\"" -i "$PLUGINS_REGISTRY_FILE"
    else
        # Fallback: append to registry file
        echo "  $plugin_name:" >> "$PLUGINS_REGISTRY_FILE"
        echo "    state: $state" >> "$PLUGINS_REGISTRY_FILE"
        echo "    version: ${PLUGIN_version:-unknown}" >> "$PLUGINS_REGISTRY_FILE"
        echo "    installed_at: $(date -Iseconds)" >> "$PLUGINS_REGISTRY_FILE"
    fi
}

# Enable plugin
plugin_enable() {
    local plugin_name="$1"
    
    echo "⚡ Enabling plugin: $plugin_name"
    
    if ! plugin_is_installed "$plugin_name"; then
        echo "❌ Plugin not installed: $plugin_name"
        return 1
    fi
    
    # Load plugin
    load_plugin "$plugin_name"
    
    # Update state in registry
    register_plugin "$plugin_name" "$PLUGIN_STATE_ENABLED"
    
    echo "✅ Plugin enabled: $plugin_name"
}

# Disable plugin
plugin_disable() {
    local plugin_name="$1"
    
    echo "📴 Disabling plugin: $plugin_name"
    
    # Unload plugin if loaded
    unload_plugin "$plugin_name"
    
    # Update state in registry
    register_plugin "$plugin_name" "$PLUGIN_STATE_DISABLED"
    
    echo "✅ Plugin disabled: $plugin_name"
}

# Uninstall plugin
plugin_uninstall() {
    local plugin_name="$1"
    local remove_data="${2:-false}"
    
    echo "🗑️  Uninstalling plugin: $plugin_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ! plugin_is_installed "$plugin_name"; then
        echo "❌ Plugin not installed: $plugin_name"
        return 1
    fi
    
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    # Disable plugin first
    if plugin_is_enabled "$plugin_name"; then
        plugin_disable "$plugin_name"
    fi
    
    # Run pre-uninstall hook
    run_plugin_hook "$plugin_name" "pre-uninstall"
    
    # Execute plugin uninstallation script
    if [[ -f "$plugin_dir/uninstall.sh" ]]; then
        echo "🔧 Running plugin uninstallation script..."
        cd "$plugin_dir" || return 1
        bash uninstall.sh
        cd - >/dev/null || return 1
    fi
    
    # Run post-uninstall hook
    run_plugin_hook "$plugin_name" "post-uninstall"
    
    # Remove plugin directory
    rm -rf "$plugin_dir"
    
    # Remove plugin data if requested
    if [[ "$remove_data" == "true" ]]; then
        rm -rf "$PLUGINS_DATA_DIR/$plugin_name"
    fi
    
    # Remove from registry
    remove_plugin_from_registry "$plugin_name"
    
    echo "✅ Plugin uninstalled: $plugin_name"
}

# Load plugin
load_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    # Load plugin metadata
    load_plugin_metadata "$plugin_name"
    
    # Source plugin libraries
    if [[ -d "$plugin_dir/lib" ]]; then
        for lib_file in "$plugin_dir/lib"/*.sh; do
            if [[ -f "$lib_file" ]]; then
                source "$lib_file"
            fi
        done
    fi
    
    # Initialize plugin
    local init_function="${plugin_name//-/_}_init"
    if declare -f "$init_function" >/dev/null 2>&1; then
        "$init_function"
    fi
    
    # Register plugin commands
    register_plugin_commands "$plugin_name"
}

# Unload plugin
unload_plugin() {
    local plugin_name="$1"
    
    # Cleanup plugin
    local cleanup_function="${plugin_name//-/_}_cleanup"
    if declare -f "$cleanup_function" >/dev/null 2>&1; then
        "$cleanup_function"
    fi
    
    # Unregister plugin commands
    unregister_plugin_commands "$plugin_name"
}

# Load enabled plugins
load_enabled_plugins() {
    echo "🔌 Loading enabled plugins..."
    
    local enabled_plugins
    enabled_plugins=$(get_enabled_plugins)
    
    for plugin_name in $enabled_plugins; do
        echo "  Loading: $plugin_name"
        if ! load_plugin "$plugin_name"; then
            echo "  ⚠️  Failed to load plugin: $plugin_name"
            register_plugin "$plugin_name" "$PLUGIN_STATE_ERROR"
        fi
    done
}

# Get enabled plugins
get_enabled_plugins() {
    if [[ -f "$PLUGINS_REGISTRY_FILE" ]]; then
        if command -v yq >/dev/null 2>&1; then
            yq eval '.plugins | to_entries | .[] | select(.value.state == "enabled") | .key' "$PLUGINS_REGISTRY_FILE"
        else
            # Fallback: grep for enabled plugins
            grep -B 1 "state: enabled" "$PLUGINS_REGISTRY_FILE" | grep -E "^  [a-zA-Z]" | sed 's/://g' | sed 's/^  //'
        fi
    fi
}

# Plugin status checks
plugin_is_installed() {
    local plugin_name="$1"
    [[ -d "$PLUGINS_DIR/$plugin_name" ]]
}

plugin_is_enabled() {
    local plugin_name="$1"
    local state
    state=$(get_plugin_state "$plugin_name")
    [[ "$state" == "$PLUGIN_STATE_ENABLED" ]]
}

plugin_is_available() {
    local plugin_name="$1"
    check_plugin_in_repository "core" "$plugin_name" || \
    check_plugin_in_repository "community" "$plugin_name" || \
    [[ -d "$PLUGINS_DIR/local/$plugin_name" ]]
}

# Get plugin state
get_plugin_state() {
    local plugin_name="$1"
    
    if command -v yq >/dev/null 2>&1; then
        yq eval ".plugins.$plugin_name.state" "$PLUGINS_REGISTRY_FILE" 2>/dev/null
    else
        # Fallback: grep
        grep -A 2 "^  $plugin_name:" "$PLUGINS_REGISTRY_FILE" | grep "state:" | cut -d' ' -f4
    fi
}

# List plugins
plugin_list() {
    local filter="${1:-all}"
    
    echo "📋 Plugin List"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case "$filter" in
        "installed")
            list_installed_plugins
            ;;
        "enabled")
            list_enabled_plugins
            ;;
        "available")
            list_available_plugins
            ;;
        "all"|*)
            list_all_plugins
            ;;
    esac
}

# List installed plugins
list_installed_plugins() {
    echo "Installed Plugins:"
    
    if [[ ! -d "$PLUGINS_DIR" ]]; then
        echo "  No plugins installed"
        return
    fi
    
    for plugin_dir in "$PLUGINS_DIR"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name=$(basename "$plugin_dir")
            local state=$(get_plugin_state "$plugin_name")
            local status_icon
            
            case "$state" in
                "$PLUGIN_STATE_ENABLED") status_icon="✅" ;;
                "$PLUGIN_STATE_DISABLED") status_icon="🔘" ;;
                "$PLUGIN_STATE_ERROR") status_icon="❌" ;;
                *) status_icon="❓" ;;
            esac
            
            if [[ -f "$plugin_dir/plugin.yaml" ]]; then
                load_plugin_metadata "$plugin_name"
                echo "  $status_icon $plugin_name (v${PLUGIN_version:-unknown}) - ${PLUGIN_description:-No description}"
            else
                echo "  $status_icon $plugin_name - Invalid plugin structure"
            fi
        fi
    done
}

# List enabled plugins
list_enabled_plugins() {
    echo "Enabled Plugins:"
    
    local enabled_plugins
    enabled_plugins=$(get_enabled_plugins)
    
    if [[ -z "$enabled_plugins" ]]; then
        echo "  No plugins enabled"
        return
    fi
    
    for plugin_name in $enabled_plugins; do
        if [[ -f "$PLUGINS_DIR/$plugin_name/plugin.yaml" ]]; then
            load_plugin_metadata "$plugin_name"
            echo "  ✅ $plugin_name (v${PLUGIN_version:-unknown}) - ${PLUGIN_description:-No description}"
        fi
    done
}

# List available plugins
list_available_plugins() {
    echo "Available Plugins:"
    echo ""
    
    # Update repository caches
    echo "🔄 Updating plugin repositories..."
    update_repository_cache "core"
    update_repository_cache "community"
    
    # List core plugins
    echo "Core Plugins:"
    list_repository_plugins "core"
    
    echo ""
    
    # List community plugins
    echo "Community Plugins:"
    list_repository_plugins "community"
    
    echo ""
    
    # List local plugins
    echo "Local Plugins:"
    if [[ -d "$PLUGINS_DIR/local" ]]; then
        for plugin_dir in "$PLUGINS_DIR/local"/*; do
            if [[ -d "$plugin_dir" ]]; then
                local plugin_name=$(basename "$plugin_dir")
                if [[ -f "$plugin_dir/plugin.yaml" ]]; then
                    load_plugin_metadata "$plugin_name"
                    echo "  📁 $plugin_name (v${PLUGIN_version:-unknown}) - ${PLUGIN_description:-No description}"
                fi
            fi
        done
    else
        echo "  No local plugins"
    fi
}

# List repository plugins
list_repository_plugins() {
    local repo_name="$1"
    local repo_dir="$PLUGINS_CACHE_DIR/repos/$repo_name"
    
    if [[ ! -d "$repo_dir" ]]; then
        echo "  Repository not cached: $repo_name"
        return
    fi
    
    for plugin_dir in "$repo_dir"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name=$(basename "$plugin_dir")
            if [[ -f "$plugin_dir/plugin.yaml" ]]; then
                local old_vars=$(compgen -v | grep "^PLUGIN_")
                # Clear old plugin variables
                for var in $old_vars; do
                    unset "$var"
                done
                
                eval "$(parse_yaml "$plugin_dir/plugin.yaml" "PLUGIN_")"
                local install_status
                if plugin_is_installed "$plugin_name"; then
                    install_status="[INSTALLED]"
                else
                    install_status=""
                fi
                echo "  🌐 $plugin_name (v${PLUGIN_version:-unknown}) - ${PLUGIN_description:-No description} $install_status"
            fi
        fi
    done
}

# Search plugins
plugin_search() {
    local query="$1"
    
    echo "🔍 Searching plugins for: $query"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Update caches
    update_repository_cache "core"
    update_repository_cache "community"
    
    local found=false
    
    # Search core repository
    echo "Core Repository:"
    if search_repository_plugins "core" "$query"; then
        found=true
    fi
    
    echo ""
    
    # Search community repository
    echo "Community Repository:"
    if search_repository_plugins "community" "$query"; then
        found=true
    fi
    
    echo ""
    
    # Search local plugins
    echo "Local Plugins:"
    if search_local_plugins "$query"; then
        found=true
    fi
    
    if [[ "$found" == "false" ]]; then
        echo "No plugins found matching: $query"
    fi
}

# Search repository plugins
search_repository_plugins() {
    local repo_name="$1"
    local query="$2"
    local repo_dir="$PLUGINS_CACHE_DIR/repos/$repo_name"
    local found=false
    
    if [[ ! -d "$repo_dir" ]]; then
        echo "  Repository not available: $repo_name"
        return 1
    fi
    
    for plugin_dir in "$repo_dir"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name=$(basename "$plugin_dir")
            if [[ -f "$plugin_dir/plugin.yaml" ]]; then
                # Load metadata
                local old_vars=$(compgen -v | grep "^PLUGIN_")
                for var in $old_vars; do
                    unset "$var"
                done
                
                eval "$(parse_yaml "$plugin_dir/plugin.yaml" "PLUGIN_")"
                
                # Search in name, description, and tags
                if [[ "$plugin_name" =~ $query ]] || 
                   [[ "${PLUGIN_description:-}" =~ $query ]] || 
                   [[ "${PLUGIN_tags:-}" =~ $query ]]; then
                    
                    local install_status
                    if plugin_is_installed "$plugin_name"; then
                        install_status="[INSTALLED]"
                    else
                        install_status=""
                    fi
                    
                    echo "  🌐 $plugin_name (v${PLUGIN_version:-unknown}) - ${PLUGIN_description:-No description} $install_status"
                    found=true
                fi
            fi
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        echo "  No matches found"
    fi
    
    return 0
}

# Search local plugins
search_local_plugins() {
    local query="$1"
    local found=false
    
    if [[ -d "$PLUGINS_DIR/local" ]]; then
        for plugin_dir in "$PLUGINS_DIR/local"/*; do
            if [[ -d "$plugin_dir" ]]; then
                local plugin_name=$(basename "$plugin_dir")
                if [[ -f "$plugin_dir/plugin.yaml" ]]; then
                    load_plugin_metadata "$plugin_name"
                    
                    if [[ "$plugin_name" =~ $query ]] || 
                       [[ "${PLUGIN_description:-}" =~ $query ]] || 
                       [[ "${PLUGIN_tags:-}" =~ $query ]]; then
                        
                        echo "  📁 $plugin_name (v${PLUGIN_version:-unknown}) - ${PLUGIN_description:-No description}"
                        found=true
                    fi
                fi
            fi
        done
    fi
    
    if [[ "$found" == "false" ]]; then
        echo "  No matches found"
    fi
    
    return 0
}

# Update all plugins
plugin_update() {
    local plugin_name="${1:-all}"
    
    if [[ "$plugin_name" == "all" ]]; then
        echo "🔄 Updating all plugins..."
        update_all_plugins
    else
        echo "🔄 Updating plugin: $plugin_name"
        update_single_plugin "$plugin_name"
    fi
}

# Update all plugins
update_all_plugins() {
    local installed_plugins
    installed_plugins=$(find "$PLUGINS_DIR" -maxdepth 1 -type d -not -name ".*" -not -name "local" -not -name "core" -not -name "community" | xargs -r basename -a)
    
    for plugin_name in $installed_plugins; do
        echo "  Updating: $plugin_name"
        update_single_plugin "$plugin_name"
    done
}

# Update single plugin
update_single_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    if ! plugin_is_installed "$plugin_name"; then
        echo "❌ Plugin not installed: $plugin_name"
        return 1
    fi
    
    # Check if plugin has update script
    if [[ -f "$plugin_dir/update.sh" ]]; then
        cd "$plugin_dir" || return 1
        bash update.sh
        cd - >/dev/null || return 1
    else
        # Try to update from source if it's a git repository
        if [[ -d "$plugin_dir/.git" ]]; then
            cd "$plugin_dir" || return 1
            git pull
            cd - >/dev/null || return 1
        else
            echo "  No update method available for: $plugin_name"
        fi
    fi
}

# Create plugin template
plugin_create() {
    local plugin_name="$1"
    local plugin_type="${2:-basic}"
    
    echo "🆕 Creating new plugin: $plugin_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local plugin_dir="$PLUGINS_DIR/local/$plugin_name"
    
    if [[ -d "$plugin_dir" ]]; then
        echo "❌ Plugin already exists: $plugin_name"
        return 1
    fi
    
    mkdir -p "$plugin_dir"/{lib,config,hooks,templates,docs,tests}
    
    # Create plugin.yaml
    create_plugin_metadata "$plugin_dir" "$plugin_name" "$plugin_type"
    
    # Create basic plugin structure
    create_plugin_files "$plugin_dir" "$plugin_name" "$plugin_type"
    
    echo "✅ Plugin template created: $plugin_dir"
    echo "Edit $plugin_dir/plugin.yaml to configure your plugin"
}

# Create plugin metadata file
create_plugin_metadata() {
    local plugin_dir="$1"
    local plugin_name="$2"
    local plugin_type="$3"
    
    cat > "$plugin_dir/plugin.yaml" << EOF
# Plugin Metadata
name: $plugin_name
version: "0.1.0"
description: "A new $plugin_type plugin"
author: "$USER"
license: "MIT"
homepage: ""
repository: ""

# Plugin type and category
type: $plugin_type
category: "utility"
tags:
  - "custom"
  - "$plugin_type"

# Dependencies
dependencies: []
plugin_dependencies: []
platforms:
  - "macos"
  - "linux"

# Plugin configuration
config:
  auto_enable: false
  priority: 100

# Entry points
commands:
  - name: "$plugin_name"
    description: "Main $plugin_name command"
    function: "${plugin_name//-/_}_main"

# Hooks
hooks:
  pre-install: []
  post-install: []
  pre-uninstall: []
  post-uninstall: []
EOF
}

# Create plugin files
create_plugin_files() {
    local plugin_dir="$1"
    local plugin_name="$2"
    local plugin_type="$3"
    local func_name="${plugin_name//-/_}"
    
    # Create main library file
    cat > "$plugin_dir/lib/core.sh" << EOF
#!/usr/bin/env bash
# ${plugin_name} plugin core functionality

# Plugin initialization
${func_name}_init() {
    echo "Initializing $plugin_name plugin..."
}

# Plugin cleanup
${func_name}_cleanup() {
    echo "Cleaning up $plugin_name plugin..."
}

# Main plugin function
${func_name}_main() {
    echo "Hello from $plugin_name plugin!"
}

# Export functions
export -f ${func_name}_init ${func_name}_cleanup ${func_name}_main
EOF
    
    # Create installation script
    cat > "$plugin_dir/install.sh" << 'EOF'
#!/usr/bin/env bash
# Plugin installation script

echo "Installing plugin..."

# Add any installation logic here
# Example: create directories, copy files, install dependencies

echo "Plugin installation complete"
EOF
    
    # Create uninstallation script
    cat > "$plugin_dir/uninstall.sh" << 'EOF'
#!/usr/bin/env bash
# Plugin uninstallation script

echo "Uninstalling plugin..."

# Add any cleanup logic here
# Example: remove directories, uninstall dependencies

echo "Plugin uninstallation complete"
EOF
    
    # Create README
    cat > "$plugin_dir/README.md" << EOF
# $plugin_name Plugin

A $plugin_type plugin for the modern dotfiles framework.

## Description

${PLUGIN_description:-A new plugin}

## Installation

\`\`\`bash
dot plugin install $plugin_name
dot plugin enable $plugin_name
\`\`\`

## Usage

\`\`\`bash
dot $plugin_name
\`\`\`

## Configuration

Configuration options go here.

## License

MIT
EOF
    
    # Make scripts executable
    chmod +x "$plugin_dir/install.sh" "$plugin_dir/uninstall.sh"
}

# Setup plugin hooks
setup_plugin_hooks() {
    # Create hook directories
    mkdir -p "$PLUGINS_CONFIG_DIR/hooks"
    
    # Plugin system hooks will be integrated with main dotfiles hooks
}

# Register plugin commands
register_plugin_commands() {
    local plugin_name="$1"
    
    # This would integrate with the main CLI system
    # Commands defined in plugin.yaml would be registered
}

# Unregister plugin commands
unregister_plugin_commands() {
    local plugin_name="$1"
    
    # Remove plugin commands from CLI system
}

# Remove plugin from registry
remove_plugin_from_registry() {
    local plugin_name="$1"
    
    if command -v yq >/dev/null 2>&1; then
        yq eval "del(.plugins.$plugin_name)" -i "$PLUGINS_REGISTRY_FILE"
    else
        # Fallback: create new registry without the plugin
        grep -v -A 10 "^  $plugin_name:" "$PLUGINS_REGISTRY_FILE" > "${PLUGINS_REGISTRY_FILE}.tmp" || true
        mv "${PLUGINS_REGISTRY_FILE}.tmp" "$PLUGINS_REGISTRY_FILE"
    fi
}

# Extract plugin archive
extract_plugin_archive() {
    local archive_file="$1"
    local target_dir="$2"
    
    mkdir -p "$target_dir"
    
    case "$archive_file" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive_file" -C "$target_dir" --strip-components=1
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive_file" -C "$target_dir" --strip-components=1
            ;;
        *.zip)
            unzip -q "$archive_file" -d "$target_dir"
            # Move contents up one level if single directory
            if [[ $(ls -1 "$target_dir" | wc -l) -eq 1 ]]; then
                local single_dir="$target_dir/$(ls "$target_dir")"
                if [[ -d "$single_dir" ]]; then
                    mv "$single_dir"/* "$target_dir/"
                    rmdir "$single_dir"
                fi
            fi
            ;;
        *)
            echo "❌ Unsupported archive format: $archive_file"
            return 1
            ;;
    esac
}

# Utility function to parse YAML
parse_yaml() {
    local yaml_file="$1"
    local prefix="$2"
    
    if command -v yq >/dev/null 2>&1; then
        yq eval 'to_entries | .[] | "'"$prefix"'" + (.key | upcase) + "=\"" + (.value | tostring) + "\""' "$yaml_file"
    else
        # Simple fallback parser for basic YAML
        awk -F': ' -v prefix="$prefix" '
        /^[a-zA-Z_][a-zA-Z0-9_]*:/ {
            gsub(/[^a-zA-Z0-9_]/, "_", $1)
            print prefix toupper($1) "=\"" $2 "\""
        }' "$yaml_file" | sed 's/""$//'
    fi
}

# Utility function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        read -p "$question [Y/n]: " -r response
        [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
    else
        read -p "$question [y/N]: " -r response
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Plugin CLI interface
plugin_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "install")
            plugin_install "$@"
            ;;
        "uninstall"|"remove")
            plugin_uninstall "$@"
            ;;
        "enable")
            plugin_enable "$@"
            ;;
        "disable")
            plugin_disable "$@"
            ;;
        "list"|"ls")
            plugin_list "$@"
            ;;
        "search")
            plugin_search "$@"
            ;;
        "update")
            plugin_update "$@"
            ;;
        "create"|"new")
            plugin_create "$@"
            ;;
        "info"|"show")
            plugin_info "$@"
            ;;
        "help"|*)
            cat << 'EOF'
🔌 Plugin System

USAGE:
    plugin <command> [options]

COMMANDS:
    install <name> [source]    Install plugin from registry or source
    uninstall <name>          Uninstall plugin
    enable <name>             Enable installed plugin
    disable <name>            Disable enabled plugin
    list [filter]             List plugins (all|installed|enabled|available)
    search <query>            Search available plugins
    update [name]             Update plugin(s)
    create <name> [type]      Create new plugin template
    info <name>               Show plugin information

OPTIONS:
    --force                   Force operation
    --no-deps                 Skip dependency checks
    --remove-data             Remove plugin data on uninstall

EXAMPLES:
    plugin install git-extras            # Install from registry
    plugin install my-plugin ~/plugin   # Install from local directory
    plugin list installed               # List installed plugins
    plugin search git                   # Search for git-related plugins
    plugin create my-tool cli           # Create new CLI plugin

For more information: https://docs.dotfiles.dev/plugins
EOF
            ;;
    esac
}

# Show plugin information
plugin_info() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        echo "❌ Plugin name required"
        return 1
    fi
    
    echo "📋 Plugin Information: $plugin_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if plugin_is_installed "$plugin_name"; then
        local plugin_dir="$PLUGINS_DIR/$plugin_name"
        load_plugin_metadata "$plugin_name"
        
        echo "Name: $plugin_name"
        echo "Version: ${PLUGIN_version:-unknown}"
        echo "Description: ${PLUGIN_description:-No description}"
        echo "Author: ${PLUGIN_author:-Unknown}"
        echo "Type: ${PLUGIN_type:-unknown}"
        echo "Category: ${PLUGIN_category:-uncategorized}"
        echo "State: $(get_plugin_state "$plugin_name")"
        
        if [[ -n "${PLUGIN_homepage:-}" ]]; then
            echo "Homepage: ${PLUGIN_homepage}"
        fi
        
        if [[ -n "${PLUGIN_repository:-}" ]]; then
            echo "Repository: ${PLUGIN_repository}"
        fi
        
        if [[ -n "${PLUGIN_dependencies:-}" ]]; then
            echo "Dependencies: ${PLUGIN_dependencies}"
        fi
        
        if [[ -n "${PLUGIN_plugin_dependencies:-}" ]]; then
            echo "Plugin Dependencies: ${PLUGIN_plugin_dependencies}"
        fi
        
        if [[ -f "$plugin_dir/README.md" ]]; then
            echo ""
            echo "Documentation:"
            head -10 "$plugin_dir/README.md"
        fi
    else
        echo "❌ Plugin not installed: $plugin_name"
        
        # Check if available in repositories
        if plugin_is_available "$plugin_name"; then
            echo "✅ Plugin available for installation"
            echo "Run: dot plugin install $plugin_name"
        else
            echo "❌ Plugin not found in repositories"
        fi
    fi
}

# Initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_plugin_system
fi

# Export functions
export -f plugin_cli plugin_install plugin_uninstall plugin_enable plugin_disable
export -f plugin_list plugin_search plugin_update plugin_create plugin_info
export -f init_plugin_system load_enabled_plugins