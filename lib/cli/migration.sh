#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Migration and Upgrade Management
# Migration and upgrade system command interface
# ============================================================================

# Load migration system
source "$DOTFILES_DIR/lib/migration.sh"

# Migration command dispatcher
dot_migration() {
    local subcommand="${1:-status}"
    shift || true
    
    case "$subcommand" in
        "init"|"initialize"|"setup")
            migration_cli "init" "$@"
            ;;
        "status"|"check"|"info")
            migration_cli "status" "$@"
            ;;
        "migrate"|"upgrade"|"update")
            migration_cli "migrate" "$@"
            ;;
        "rollback"|"revert"|"undo")
            migration_cli "rollback" "$@"
            ;;
        "backup"|"save")
            migration_cli "backup" "$@"
            ;;
        "version"|"versions")
            show_migration_versions "$@"
            ;;
        "history"|"log")
            show_migration_history "$@"
            ;;
        "doctor"|"health")
            migration_system_doctor
            ;;
        "force")
            force_migration "$@"
            ;;
        "dry-run"|"preview")
            preview_migration "$@"
            ;;
        "-h"|"--help"|"help"|"")
            show_migration_help
            ;;
        *)
            print_error "Unknown migration subcommand: $subcommand"
            echo "Run 'dot migrate --help' for available commands."
            return 1
            ;;
    esac
}

# Show migration versions
show_migration_versions() {
    echo "📋 Version Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local current_version=$(detect_current_version)
    local target_version="$CURRENT_VERSION"
    
    echo "Current Version: $current_version"
    echo "Target Version: $target_version"
    echo "Minimum Supported: $MIN_SUPPORTED_VERSION"
    echo ""
    
    # Show version compatibility
    echo "Version Compatibility:"
    if version_compare "$current_version" ">=" "$MIN_SUPPORTED_VERSION"; then
        echo "  ✅ Current version is supported"
    else
        echo "  ❌ Current version is below minimum supported version"
    fi
    
    if needs_migration; then
        echo "  ⚠️  Migration required to reach target version"
    else
        echo "  ✅ Current version matches target version"
    fi
    
    # Show available upgrade paths
    echo ""
    echo "Available Upgrade Paths:"
    echo "  • 1.0.0 → 1.1.0: Configuration structure modernization"
    echo "  • 1.1.0 → 1.2.0: Shell integration improvements"
    echo "  • 1.2.0 → 2.0.0: Full feature modernization"
    echo "  • 1.x.x → 2.0.0: Direct modernization upgrade"
    
    # Show deprecation warnings
    echo ""
    echo "Deprecation Status:"
    check_deprecation_warnings "$current_version"
}

# Check deprecation warnings
check_deprecation_warnings() {
    local version="$1"
    
    case "$version" in
        "1.0.0")
            echo "  ⚠️  Legacy configuration structure (deprecated)"
            echo "  ⚠️  Old shell integration method (deprecated)"
            echo "  ⚠️  Manual symlink management (deprecated)"
            ;;
        "1.1.0")
            echo "  ⚠️  Old shell integration method (deprecated)"
            echo "  ⚠️  Manual symlink management (deprecated)"
            ;;
        "1.2.0")
            echo "  ⚠️  Missing modern plugin system"
            echo "  ⚠️  Missing backup system"
            echo "  ⚠️  Missing metrics collection"
            ;;
        "2.0.0")
            echo "  ✅ No deprecation warnings"
            ;;
        *)
            echo "  ❓ Unknown version - please check compatibility"
            ;;
    esac
}

# Show migration history
show_migration_history() {
    echo "📜 Migration History"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -f "$MIGRATION_STATE_FILE" ]]; then
        echo "❌ No migration history found"
        echo "Run 'dot migrate init' to initialize the migration system"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq required to display migration history"
        return 1
    fi
    
    local migration_count=$(jq '.migration_history | length' "$MIGRATION_STATE_FILE" 2>/dev/null || echo "0")
    
    if [[ $migration_count -eq 0 ]]; then
        echo "📭 No migrations have been performed yet"
        return
    fi
    
    echo "Total Migrations: $migration_count"
    echo ""
    
    # Show migration history
    echo "Migration Timeline:"
    jq -r '.migration_history[] | "  \(.timestamp): \(.from) → \(.to) (\(.type))"' "$MIGRATION_STATE_FILE" 2>/dev/null || echo "  Unable to read migration history"
    
    # Show migration log if available
    if [[ -f "$MIGRATION_LOG_FILE" ]]; then
        echo ""
        echo "Recent Log Entries:"
        tail -5 "$MIGRATION_LOG_FILE" | while read -r line; do
            echo "  $line"
        done
    fi
    
    # Show backup information
    echo ""
    echo "Migration Backups:"
    if [[ -d "$MIGRATION_BACKUP_DIR" ]]; then
        local backup_count=$(find "$MIGRATION_BACKUP_DIR" -maxdepth 1 -type d -name "pre-migration-*" | wc -l | tr -d ' ')
        echo "  Available backups: $backup_count"
        
        if [[ $backup_count -gt 0 ]]; then
            echo "  Backups:"
            find "$MIGRATION_BACKUP_DIR" -maxdepth 1 -type d -name "pre-migration-*" | sort -r | head -5 | while read -r backup; do
                local backup_name=$(basename "$backup")
                local backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "unknown")
                echo "    $backup_name ($backup_size)"
            done
        fi
    else
        echo "  No migration backups found"
    fi
}

# Migration system doctor
migration_system_doctor() {
    echo "🏥 Migration System Doctor"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running comprehensive migration system health check..."
    echo ""
    
    local issues=0
    
    # Check system requirements
    echo "🔍 Checking system requirements..."
    
    # Check required tools
    local required_tools=("jq" "find" "cp" "mv" "mkdir")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ❌ $tool not found"
            ((issues++))
        fi
    done
    
    # Check directory structure
    echo ""
    echo "🔍 Checking directory structure..."
    local required_dirs=("$MIGRATION_DIR" "$MIGRATION_CONFIG_DIR" "$MIGRATION_BACKUP_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "  ✅ $(basename "$dir"): $dir"
        else
            echo "  ❌ Missing directory: $dir"
            ((issues++))
        fi
    done
    
    # Check permissions
    echo ""
    echo "🔍 Checking permissions..."
    if [[ -w "$MIGRATION_DIR" ]]; then
        echo "  ✅ Migration directory writable"
    else
        echo "  ❌ Migration directory not writable"
        ((issues++))
    fi
    
    # Check configuration files
    echo ""
    echo "🔍 Checking configuration files..."
    if [[ -f "$MIGRATION_STATE_FILE" ]]; then
        echo "  ✅ Migration state file exists"
        
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$MIGRATION_STATE_FILE" >/dev/null 2>&1; then
                echo "  ✅ Migration state format valid"
            else
                echo "  ❌ Migration state format invalid"
                ((issues++))
            fi
        fi
    else
        echo "  ❌ Migration state file missing"
        ((issues++))
    fi
    
    # Check version detection
    echo ""
    echo "🔍 Checking version detection..."
    local current_version=$(detect_current_version)
    if [[ -n "$current_version" ]]; then
        echo "  ✅ Version detection works: $current_version"
    else
        echo "  ❌ Version detection failed"
        ((issues++))
    fi
    
    # Check migration requirements
    echo ""
    echo "🔍 Checking migration requirements..."
    if needs_migration; then
        echo "  ⚠️  Migration needed: $current_version → $CURRENT_VERSION"
    else
        echo "  ✅ System up to date: $current_version"
    fi
    
    # Check backup space
    echo ""
    echo "🔍 Checking backup space..."
    if [[ -d "$MIGRATION_BACKUP_DIR" ]]; then
        local available_space=$(df "$MIGRATION_BACKUP_DIR" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
        local available_mb=$((available_space / 1024))
        
        if [[ $available_mb -gt 500 ]]; then
            echo "  ✅ Sufficient backup space: ${available_mb}MB available"
        else
            echo "  ⚠️  Low backup space: ${available_mb}MB available"
        fi
    fi
    
    # Check dotfiles integrity
    echo ""
    echo "🔍 Checking dotfiles integrity..."
    if [[ -d "$DOTFILES_DIR" ]]; then
        echo "  ✅ Dotfiles directory exists: $DOTFILES_DIR"
        
        if [[ -f "$DOTFILES_DIR/bin/dot" ]]; then
            echo "  ✅ DOT CLI available"
        else
            echo "  ❌ DOT CLI not found"
            ((issues++))
        fi
        
        if [[ -d "$DOTFILES_DIR/lib" ]]; then
            echo "  ✅ Library directory exists"
        else
            echo "  ❌ Library directory missing"
            ((issues++))
        fi
    else
        echo "  ❌ Dotfiles directory not found: $DOTFILES_DIR"
        ((issues++))
    fi
    
    # Summary
    echo ""
    echo "📋 Health Check Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Migration system is healthy!"
        echo ""
        echo "🎯 Recommendations:"
        if needs_migration; then
            echo "  • Run migration: dot migrate"
            echo "  • Create backup: dot migrate backup"
        else
            echo "  • System is up to date"
            echo "  • Consider creating a backup: dot migrate backup"
        fi
    else
        echo "❌ Found $issues issues that need attention"
        echo ""
        echo "🔧 Recommendations:"
        if [[ ! -f "$MIGRATION_STATE_FILE" ]]; then
            echo "  • Initialize migration system: dot migrate init"
        fi
        if [[ ! -d "$MIGRATION_DIR" ]]; then
            echo "  • Create migration directory: mkdir -p $MIGRATION_DIR"
        fi
        echo "  • Install missing required tools"
        echo "  • Fix permission issues if any"
        echo "  • Check available disk space"
    fi
}

# Force migration (bypass safety checks)
force_migration() {
    local target_version="${1:-$CURRENT_VERSION}"
    local current_version=$(detect_current_version)
    
    echo "⚠️  Force migration mode enabled"
    echo "🚨 This will bypass safety checks and run migration directly"
    echo ""
    echo "From: $current_version"
    echo "To: $target_version"
    echo ""
    
    read -p "Are you sure you want to proceed? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "🚀 Starting force migration..."
        run_migration "$current_version" "$target_version" "force"
    else
        echo "❌ Force migration cancelled"
    fi
}

# Preview migration (dry run)
preview_migration() {
    local target_version="${1:-$CURRENT_VERSION}"
    local current_version=$(detect_current_version)
    
    echo "👁️  Migration Preview (Dry Run)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "From: $current_version"
    echo "To: $target_version"
    echo ""
    
    if ! needs_migration; then
        echo "✅ No migration needed - system is already up to date"
        return
    fi
    
    echo "📋 Migration Plan:"
    
    case "$current_version->$target_version" in
        "1.0.0->2.0.0"|"1.*->2.0.0")
            echo "  🔄 Full modernization migration"
            echo "    1. Update directory structure"
            echo "    2. Migrate configuration files"
            echo "    3. Update shell integration"
            echo "    4. Initialize new systems (plugins, backup, metrics)"
            echo "    5. Update symlinks and paths"
            echo "    6. Clean up deprecated files"
            ;;
        "1.0.0->1.1.0")
            echo "  🔄 Configuration structure migration"
            echo "    1. Move configuration files to new structure"
            echo "    2. Update configuration paths"
            ;;
        "1.1.0->1.2.0")
            echo "  🔄 Shell integration migration"
            echo "    1. Update shell integration scripts"
            echo "    2. Modernize initialization process"
            ;;
        "1.2.0->2.0.0")
            echo "  🔄 Modernization migration"
            echo "    1. Initialize plugin system"
            echo "    2. Initialize backup system"
            echo "    3. Initialize metrics system"
            ;;
        *)
            echo "  🔄 Generic migration"
            echo "    1. Update directory structure"
            echo "    2. Update shell integration"
            ;;
    esac
    
    echo ""
    echo "📦 Backup Information:"
    echo "  • Backup will be created automatically"
    echo "  • Backup location: $MIGRATION_BACKUP_DIR"
    echo "  • Backup name: pre-migration-${current_version}-$(date +%Y%m%d%H%M%S)"
    
    echo ""
    echo "⚠️  Potential Risks:"
    echo "  • Configuration files will be modified"
    echo "  • Shell integration may change"
    echo "  • Some manual adjustments may be needed"
    
    echo ""
    echo "🔄 Rollback Information:"
    echo "  • Rollback available: dot migrate rollback"
    echo "  • Automatic backup will be created"
    echo "  • Manual backup recommended before migration"
    
    echo ""
    echo "To proceed with the migration:"
    echo "  dot migrate $target_version"
}

# Version comparison helper
version_compare() {
    local version1="$1"
    local operator="$2"
    local version2="$3"
    
    # Simple version comparison (works for semantic versioning)
    case "$operator" in
        ">=")
            [[ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" == "$version2" ]]
            ;;
        ">")
            [[ "$version1" != "$version2" ]] && [[ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" == "$version2" ]]
            ;;
        "<=")
            [[ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" == "$version1" ]]
            ;;
        "<")
            [[ "$version1" != "$version2" ]] && [[ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" == "$version1" ]]
            ;;
        "=="|"=")
            [[ "$version1" == "$version2" ]]
            ;;
        "!=")
            [[ "$version1" != "$version2" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Export functions
export -f dot_migration show_migration_versions show_migration_history
export -f migration_system_doctor force_migration preview_migration version_compare