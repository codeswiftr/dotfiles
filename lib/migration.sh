#!/usr/bin/env bash
# =============================================================================
# Migration and Upgrade System
# Handles version migrations, configuration upgrades, and system transitions
# =============================================================================

# Migration system configuration
MIGRATION_DIR="$HOME/.local/share/dotfiles/migrations"
MIGRATION_CONFIG_DIR="$HOME/.config/dotfiles/migration"
MIGRATION_LOG_FILE="$MIGRATION_DIR/migration.log"
MIGRATION_STATE_FILE="$MIGRATION_DIR/state.json"
MIGRATION_BACKUP_DIR="$MIGRATION_DIR/backups"

# Version information
CURRENT_VERSION="2.0.0"
MIN_SUPPORTED_VERSION="1.0.0"

# Initialize migration system
init_migration_system() {
    mkdir -p "$MIGRATION_DIR" "$MIGRATION_CONFIG_DIR" "$MIGRATION_BACKUP_DIR"
    
    # Create migration state file if it doesn't exist
    if [[ ! -f "$MIGRATION_STATE_FILE" ]]; then
        create_migration_state
    fi
    
    # Create migration log
    if [[ ! -f "$MIGRATION_LOG_FILE" ]]; then
        touch "$MIGRATION_LOG_FILE"
        echo "$(date -Iseconds) Migration system initialized" >> "$MIGRATION_LOG_FILE"
    fi
}

# Create migration state file
create_migration_state() {
    cat > "$MIGRATION_STATE_FILE" << EOF
{
  "current_version": "$CURRENT_VERSION",
  "last_migration": null,
  "migration_history": [],
  "pending_migrations": [],
  "system_info": {
    "hostname": "$(hostname)",
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "dotfiles_path": "$DOTFILES_DIR",
    "initialized": "$(date -Iseconds)"
  },
  "compatibility": {
    "min_supported_version": "$MIN_SUPPORTED_VERSION",
    "deprecation_warnings": [],
    "breaking_changes": []
  }
}
EOF
}

# Detect current system version
detect_current_version() {
    local version_file="$DOTFILES_DIR/VERSION"
    local git_version=""
    local config_version=""
    
    # Check VERSION file
    if [[ -f "$version_file" ]]; then
        version_file_content=$(cat "$version_file" | tr -d '\n')
    fi
    
    # Check git tags
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        git_version=$(cd "$DOTFILES_DIR" && git describe --tags --abbrev=0 2>/dev/null || echo "")
    fi
    
    # Check migration state
    if [[ -f "$MIGRATION_STATE_FILE" ]] && command -v jq >/dev/null 2>&1; then
        config_version=$(jq -r '.current_version // empty' "$MIGRATION_STATE_FILE" 2>/dev/null || echo "")
    fi
    
    # Determine version priority: git tags > VERSION file > config > default
    if [[ -n "$git_version" ]]; then
        echo "$git_version"
    elif [[ -n "$version_file_content" ]]; then
        echo "$version_file_content"
    elif [[ -n "$config_version" ]]; then
        echo "$config_version"
    else
        echo "1.0.0"  # Default for legacy systems
    fi
}

# Check if migration is needed
needs_migration() {
    local current_version=$(detect_current_version)
    local target_version="$CURRENT_VERSION"
    
    if [[ "$current_version" != "$target_version" ]]; then
        return 0  # Migration needed
    else
        return 1  # No migration needed
    fi
}

# Get available migrations
get_available_migrations() {
    local from_version="$1"
    local to_version="$2"
    
    # Define migration paths
    local migration_key="${from_version}->${to_version}"
    
    case "$migration_key" in
        "1.0.0->1.1.0")
            echo "config_structure_update"
            ;;
        "1.1.0->1.2.0")
            echo "shell_integration_update"
            ;;
        "1.2.0->2.0.0")
            echo "modernization_upgrade"
            ;;
        "1.0.0->2.0.0"|"1.*->2.0.0")
            echo "full_modernization"
            ;;
        *)
            # For any version to 2.0.0, use full modernization
            if [[ "$to_version" == "2.0.0" ]]; then
                echo "full_modernization"
            else
                echo "generic_migration"
            fi
            ;;
    esac
}

# Run migration
run_migration() {
    local from_version="$1"
    local to_version="$2"
    local migration_type="${3:-auto}"
    
    echo "🚀 Starting migration from $from_version to $to_version"
    echo "$(date -Iseconds) Starting migration $from_version -> $to_version" >> "$MIGRATION_LOG_FILE"
    
    # Create backup before migration
    create_migration_backup "$from_version"
    
    # Run specific migration based on version jump
    case "$from_version->$to_version" in
        "1.0.0->2.0.0"|"1.*->2.0.0")
            run_full_modernization_migration
            ;;
        "1.0.0->1.1.0")
            run_config_structure_migration
            ;;
        "1.1.0->1.2.0")
            run_shell_integration_migration
            ;;
        "1.2.0->2.0.0")
            run_modernization_migration
            ;;
        *)
            run_generic_migration "$from_version" "$to_version"
            ;;
    esac
    
    # Update migration state
    update_migration_state "$from_version" "$to_version"
    
    echo "✅ Migration completed successfully"
    echo "$(date -Iseconds) Migration $from_version -> $to_version completed" >> "$MIGRATION_LOG_FILE"
}

# Create migration backup
create_migration_backup() {
    local version="$1"
    local backup_name="pre-migration-${version}-$(date +%Y%m%d%H%M%S)"
    local backup_path="$MIGRATION_BACKUP_DIR/$backup_name"
    
    echo "📦 Creating migration backup: $backup_name"
    
    mkdir -p "$backup_path"
    
    # Backup configuration files
    if [[ -d "$HOME/.config/dotfiles" ]]; then
        cp -r "$HOME/.config/dotfiles" "$backup_path/config"
    fi
    
    # Backup local data
    if [[ -d "$HOME/.local/share/dotfiles" ]]; then
        cp -r "$HOME/.local/share/dotfiles" "$backup_path/data"
    fi
    
    # Backup key dotfiles
    local important_files=(
        ".zshrc"
        ".bashrc"
        ".gitconfig"
        ".vimrc"
        ".tmux.conf"
    )
    
    mkdir -p "$backup_path/dotfiles"
    for file in "${important_files[@]}"; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$backup_path/dotfiles/"
        fi
    done
    
    # Create backup manifest
    cat > "$backup_path/MANIFEST.json" << EOF
{
  "backup_name": "$backup_name",
  "version": "$version",
  "created": "$(date -Iseconds)",
  "files_backed_up": $(find "$backup_path" -type f | wc -l | tr -d ' '),
  "backup_size": "$(du -sh "$backup_path" | cut -f1)"
}
EOF
    
    echo "✅ Backup created: $backup_path"
}

# Run full modernization migration (1.x -> 2.0)
run_full_modernization_migration() {
    echo "🔄 Running full modernization migration..."
    
    # 1. Update directory structure
    update_directory_structure
    
    # 2. Migrate configuration files
    migrate_configuration_files
    
    # 3. Update shell integration
    update_shell_integration
    
    # 4. Initialize new systems
    initialize_new_systems
    
    # 5. Update symlinks and paths
    update_symlinks_and_paths
    
    # 6. Clean up deprecated files
    cleanup_deprecated_files
}

# Update directory structure
update_directory_structure() {
    echo "📁 Updating directory structure..."
    
    # Create new directories
    local new_dirs=(
        "$HOME/.config/dotfiles"
        "$HOME/.local/share/dotfiles"
        "$HOME/.local/share/dotfiles/plugins"
        "$HOME/.local/share/dotfiles/backups"
        "$HOME/.local/share/dotfiles/metrics"
    )
    
    for dir in "${new_dirs[@]}"; do
        mkdir -p "$dir"
        echo "  ✅ Created: $dir"
    done
    
    # Move old configuration if it exists
    if [[ -d "$HOME/.dotfiles/config" ]] && [[ ! -d "$HOME/.config/dotfiles" ]]; then
        mv "$HOME/.dotfiles/config" "$HOME/.config/dotfiles"
        echo "  🔄 Moved old config to new location"
    fi
}

# Migrate configuration files
migrate_configuration_files() {
    echo "⚙️  Migrating configuration files..."
    
    # Update zshrc to use new structure
    if [[ -f "$HOME/.zshrc" ]]; then
        # Backup original
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
        
        # Update source paths
        sed -i.bak 's|source.*dotfiles/setup.sh|source '"$DOTFILES_DIR"'/setup.sh|g' "$HOME/.zshrc"
        sed -i.bak 's|export DOTFILES_DIR=.*|export DOTFILES_DIR="'"$DOTFILES_DIR"'"|g' "$HOME/.zshrc"
        
        echo "  ✅ Updated .zshrc"
    fi
    
    # Migrate git configuration
    migrate_git_configuration
    
    # Migrate tool configurations
    migrate_tool_configurations
}

# Migrate git configuration
migrate_git_configuration() {
    echo "🔧 Migrating git configuration..."
    
    # Update git hooks if they exist
    local git_hooks_dir="$DOTFILES_DIR/git/hooks"
    if [[ -d "$git_hooks_dir" ]]; then
        # Update hook paths
        for hook in "$git_hooks_dir"/*; do
            if [[ -f "$hook" ]]; then
                sed -i.bak 's|#!/bin/bash|#!/usr/bin/env bash|g' "$hook"
                echo "  ✅ Updated hook: $(basename "$hook")"
            fi
        done
    fi
}

# Migrate tool configurations
migrate_tool_configurations() {
    echo "🛠️  Migrating tool configurations..."
    
    # Update tmux configuration
    if [[ -f "$HOME/.tmux.conf" ]]; then
        # Update tmux plugin paths
        sed -i.bak 's|set-environment -g.*dotfiles|set-environment -g DOTFILES_DIR "'"$DOTFILES_DIR"'"|g' "$HOME/.tmux.conf"
        echo "  ✅ Updated tmux configuration"
    fi
    
    # Update vim configuration
    if [[ -f "$HOME/.vimrc" ]]; then
        # Update vim source paths
        sed -i.bak 's|source.*dotfiles/vim|source '"$DOTFILES_DIR"'/config/vim|g' "$HOME/.vimrc"
        echo "  ✅ Updated vim configuration"
    fi
}

# Update shell integration
update_shell_integration() {
    echo "🐚 Updating shell integration..."
    
    # Update shell initialization
    if [[ -f "$DOTFILES_DIR/setup.sh" ]]; then
        # Ensure setup.sh uses new library structure
        if ! grep -q "lib/core.sh" "$DOTFILES_DIR/setup.sh"; then
            cat >> "$DOTFILES_DIR/setup.sh" << 'EOF'

# Load modern dotfiles core
if [[ -f "$DOTFILES_DIR/lib/core.sh" ]]; then
    source "$DOTFILES_DIR/lib/core.sh"
fi
EOF
            echo "  ✅ Updated setup.sh for modern structure"
        fi
    fi
}

# Initialize new systems
initialize_new_systems() {
    echo "🚀 Initializing new systems..."
    
    # Initialize plugin system
    if command -v "$DOTFILES_DIR/bin/dot" >/dev/null 2>&1; then
        "$DOTFILES_DIR/bin/dot" plugin init >/dev/null 2>&1 || true
        echo "  ✅ Initialized plugin system"
    fi
    
    # Initialize backup system
    if command -v "$DOTFILES_DIR/bin/dot" >/dev/null 2>&1; then
        "$DOTFILES_DIR/bin/dot" backup init >/dev/null 2>&1 || true
        echo "  ✅ Initialized backup system"
    fi
    
    # Initialize metrics system
    if command -v "$DOTFILES_DIR/bin/dot" >/dev/null 2>&1; then
        "$DOTFILES_DIR/bin/dot" metrics init >/dev/null 2>&1 || true
        echo "  ✅ Initialized metrics system"
    fi
}

# Update symlinks and paths
update_symlinks_and_paths() {
    echo "🔗 Updating symlinks and paths..."
    
    # Update PATH in shell configuration
    local shell_files=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
    )
    
    for file in "${shell_files[@]}"; do
        if [[ -f "$file" ]]; then
            # Add new bin directory to PATH if not already present
            if ! grep -q "$DOTFILES_DIR/bin" "$file"; then
                echo "" >> "$file"
                echo "# Dotfiles modern CLI" >> "$file"
                echo "export PATH=\"$DOTFILES_DIR/bin:\$PATH\"" >> "$file"
                echo "  ✅ Updated PATH in $(basename "$file")"
            fi
        fi
    done
    
    # Update existing symlinks
    if [[ -L "$HOME/.gitconfig" ]]; then
        local target=$(readlink "$HOME/.gitconfig")
        if [[ "$target" == *"dotfiles/git"* ]]; then
            ln -sf "$DOTFILES_DIR/config/git/gitconfig" "$HOME/.gitconfig"
            echo "  ✅ Updated .gitconfig symlink"
        fi
    fi
}

# Cleanup deprecated files
cleanup_deprecated_files() {
    echo "🧹 Cleaning up deprecated files..."
    
    # Remove deprecated directories
    local deprecated_dirs=(
        "$HOME/.dotfiles/legacy"
        "$HOME/.dotfiles/old"
        "$DOTFILES_DIR/deprecated"
    )
    
    for dir in "${deprecated_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo "  🗑️  Removed deprecated directory: $dir"
        fi
    done
    
    # Remove deprecated files
    local deprecated_files=(
        "$HOME/.zshrc.bak"
        "$HOME/.bashrc.bak"
        "$HOME/.tmux.conf.bak"
        "$HOME/.vimrc.bak"
    )
    
    for file in "${deprecated_files[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
            echo "  🗑️  Removed backup file: $(basename "$file")"
        fi
    done
}

# Update migration state
update_migration_state() {
    local from_version="$1"
    local to_version="$2"
    local timestamp=$(date -Iseconds)
    
    if [[ ! -f "$MIGRATION_STATE_FILE" ]] || ! command -v jq >/dev/null 2>&1; then
        return
    fi
    
    local temp_file=$(mktemp)
    
    # Update migration state
    jq --arg from "$from_version" --arg to "$to_version" --arg ts "$timestamp" '
      .current_version = $to |
      .last_migration = $ts |
      .migration_history += [{
        "from": $from,
        "to": $to,
        "timestamp": $ts,
        "type": "automatic"
      }]
    ' "$MIGRATION_STATE_FILE" > "$temp_file"
    
    mv "$temp_file" "$MIGRATION_STATE_FILE"
}

# Run config structure migration (1.0 -> 1.1)
run_config_structure_migration() {
    echo "🔄 Running configuration structure migration..."
    
    # Move configuration files to new structure
    if [[ -d "$HOME/.dotfiles" ]]; then
        mkdir -p "$HOME/.config/dotfiles"
        
        # Move specific config files
        if [[ -f "$HOME/.dotfiles/config.sh" ]]; then
            mv "$HOME/.dotfiles/config.sh" "$HOME/.config/dotfiles/config.sh"
        fi
    fi
    
    echo "✅ Configuration structure migration completed"
}

# Run shell integration migration (1.1 -> 1.2)
run_shell_integration_migration() {
    echo "🔄 Running shell integration migration..."
    
    # Update shell integration scripts
    update_shell_integration
    
    echo "✅ Shell integration migration completed"
}

# Run modernization migration (1.2 -> 2.0)
run_modernization_migration() {
    echo "🔄 Running modernization migration..."
    
    # Initialize new systems only
    initialize_new_systems
    
    echo "✅ Modernization migration completed"
}

# Run generic migration
run_generic_migration() {
    local from_version="$1"
    local to_version="$2"
    
    echo "🔄 Running generic migration from $from_version to $to_version..."
    
    # Basic migration steps
    update_directory_structure
    update_shell_integration
    
    echo "✅ Generic migration completed"
}

# Check migration status
check_migration_status() {
    echo "📊 Migration System Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local current_version=$(detect_current_version)
    local target_version="$CURRENT_VERSION"
    
    echo "Current Version: $current_version"
    echo "Target Version: $target_version"
    
    if needs_migration; then
        echo "Status: ⚠️  Migration needed"
        echo "Migration Type: $(get_available_migrations "$current_version" "$target_version")"
    else
        echo "Status: ✅ Up to date"
    fi
    
    echo ""
    
    # Show migration history
    if [[ -f "$MIGRATION_STATE_FILE" ]] && command -v jq >/dev/null 2>&1; then
        local migration_count=$(jq '.migration_history | length' "$MIGRATION_STATE_FILE" 2>/dev/null || echo "0")
        local last_migration=$(jq -r '.last_migration // "never"' "$MIGRATION_STATE_FILE" 2>/dev/null || echo "never")
        
        echo "Migration History:"
        echo "  Total migrations: $migration_count"
        echo "  Last migration: $last_migration"
        
        if [[ $migration_count -gt 0 ]]; then
            echo ""
            echo "Recent migrations:"
            jq -r '.migration_history[-3:] | .[] | "  \(.from) → \(.to) (\(.timestamp))"' "$MIGRATION_STATE_FILE" 2>/dev/null || echo "  No recent migrations"
        fi
    fi
    
    # Show backup information
    echo ""
    echo "Migration Backups:"
    if [[ -d "$MIGRATION_BACKUP_DIR" ]]; then
        local backup_count=$(find "$MIGRATION_BACKUP_DIR" -maxdepth 1 -type d | wc -l | tr -d ' ')
        local backup_size=$(du -sh "$MIGRATION_BACKUP_DIR" 2>/dev/null | cut -f1 || echo "unknown")
        
        echo "  Backup count: $((backup_count - 1))"  # Subtract 1 for the directory itself
        echo "  Total size: $backup_size"
        
        # Show recent backups
        if [[ $backup_count -gt 1 ]]; then
            echo "  Recent backups:"
            find "$MIGRATION_BACKUP_DIR" -maxdepth 1 -type d -name "pre-migration-*" | sort -r | head -3 | while read -r backup; do
                echo "    $(basename "$backup")"
            done
        fi
    else
        echo "  No migration backups found"
    fi
}

# Rollback migration
rollback_migration() {
    local backup_name="${1:-latest}"
    
    echo "🔄 Rolling back migration..."
    
    if [[ "$backup_name" == "latest" ]]; then
        # Find latest backup
        backup_name=$(find "$MIGRATION_BACKUP_DIR" -maxdepth 1 -type d -name "pre-migration-*" | sort -r | head -1 | xargs basename)
    fi
    
    if [[ -z "$backup_name" ]]; then
        echo "❌ No backup found for rollback"
        return 1
    fi
    
    local backup_path="$MIGRATION_BACKUP_DIR/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_name"
        return 1
    fi
    
    echo "📦 Rolling back to: $backup_name"
    
    # Restore configuration
    if [[ -d "$backup_path/config" ]]; then
        rm -rf "$HOME/.config/dotfiles"
        cp -r "$backup_path/config" "$HOME/.config/dotfiles"
        echo "  ✅ Restored configuration"
    fi
    
    # Restore data
    if [[ -d "$backup_path/data" ]]; then
        rm -rf "$HOME/.local/share/dotfiles"
        cp -r "$backup_path/data" "$HOME/.local/share/dotfiles"
        echo "  ✅ Restored data"
    fi
    
    # Restore dotfiles
    if [[ -d "$backup_path/dotfiles" ]]; then
        for file in "$backup_path/dotfiles"/*; do
            if [[ -f "$file" ]]; then
                cp "$file" "$HOME/$(basename "$file")"
                echo "  ✅ Restored $(basename "$file")"
            fi
        done
    fi
    
    echo "✅ Rollback completed"
    echo "$(date -Iseconds) Rollback to $backup_name completed" >> "$MIGRATION_LOG_FILE"
}

# Migration CLI interface
migration_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "init"|"initialize")
            init_migration_system
            echo "✅ Migration system initialized"
            ;;
        "status"|"check")
            check_migration_status
            ;;
        "migrate"|"upgrade")
            local target_version="${1:-$CURRENT_VERSION}"
            local current_version=$(detect_current_version)
            
            if needs_migration; then
                echo "🚀 Starting migration from $current_version to $target_version"
                run_migration "$current_version" "$target_version"
            else
                echo "✅ System is already up to date ($current_version)"
            fi
            ;;
        "rollback"|"revert")
            rollback_migration "$@"
            ;;
        "backup")
            local version="${1:-$(detect_current_version)}"
            create_migration_backup "$version"
            ;;
        "version")
            echo "Current version: $(detect_current_version)"
            echo "Target version: $CURRENT_VERSION"
            ;;
        "help"|"")
            show_migration_help
            ;;
        *)
            echo "❌ Unknown migration command: $command"
            echo "Run 'dot migrate help' for available commands"
            return 1
            ;;
    esac
}

# Show migration help
show_migration_help() {
    cat << 'EOF'
🔄 Migration and Upgrade System

USAGE:
    dot migrate <command> [options]

COMMANDS:
    init                Initialize migration system
    status              Show migration status
    migrate [version]   Run migration to target version
    rollback [backup]   Rollback to previous state
    backup [version]    Create manual backup
    version             Show version information
    help                Show this help message

MIGRATION COMMANDS:
    # Check if migration is needed
    dot migrate status
    
    # Run automatic migration
    dot migrate
    
    # Migrate to specific version
    dot migrate 2.0.0
    
    # Create backup before making changes
    dot migrate backup
    
    # Rollback to previous state
    dot migrate rollback
    
    # Rollback to specific backup
    dot migrate rollback pre-migration-1.0.0-20231201120000

EXAMPLES:
    # Check current migration status
    dot migrate status
    
    # Run full modernization upgrade
    dot migrate 2.0.0
    
    # Create a backup before manual changes
    dot migrate backup 1.5.0-custom
    
    # Rollback if something went wrong
    dot migrate rollback

AUTOMATIC MIGRATIONS:
    The system automatically detects your current version and
    determines the best migration path. Supported migrations:
    
    • 1.0.0 → 2.0.0: Full modernization upgrade
    • 1.0.0 → 1.1.0: Configuration structure update
    • 1.1.0 → 1.2.0: Shell integration update
    • 1.2.0 → 2.0.0: Modern features upgrade

SAFETY FEATURES:
    • Automatic backups before migration
    • Rollback capability
    • Migration state tracking
    • Compatibility checking
    • Step-by-step migration logs

For more information: https://docs.dotfiles.dev/migration
EOF
}

# Export functions
export -f init_migration_system detect_current_version needs_migration
export -f run_migration check_migration_status rollback_migration
export -f migration_cli