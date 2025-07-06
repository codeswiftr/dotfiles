#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Backup and Restore Management
# Backup and restore system command interface
# ============================================================================

# Load backup system
source "$DOTFILES_DIR/lib/backup-restore.sh"

# Backup command dispatcher
dot_backup() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "create"|"new"|"make")
            backup_cli "create" "$@"
            ;;
        "restore"|"recover")
            backup_cli "restore" "$@"
            ;;
        "list"|"ls"|"show")
            backup_cli "list" "$@"
            ;;
        "info"|"details"|"describe")
            backup_cli "info" "$@"
            ;;
        "delete"|"remove"|"rm")
            backup_cli "delete" "$@"
            ;;
        "status"|"stat")
            show_backup_system_status
            ;;
        "config"|"configure")
            configure_backup_system "$@"
            ;;
        "schedule")
            manage_backup_schedule "$@"
            ;;
        "migrate")
            migrate_backup_data "$@"
            ;;
        "verify"|"validate"|"check")
            verify_backup_system "$@"
            ;;
        "doctor")
            backup_system_doctor
            ;;
        "export")
            export_backup_data "$@"
            ;;
        "import")
            import_backup_data "$@"
            ;;
        "init"|"initialize")
            backup_cli "init"
            ;;
        "-h"|"--help"|"help"|"")
            show_backup_help
            ;;
        *)
            print_error "Unknown backup subcommand: $subcommand"
            echo "Run 'dot backup --help' for available commands."
            return 1
            ;;
    esac
}

# Show backup system status
show_backup_system_status() {
    echo "💾 Backup System Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # System information
    echo "Backup Directory: $BACKUP_DIR"
    echo "Config Directory: $BACKUP_CONFIG_DIR"
    echo "Metadata File: $BACKUP_METADATA_FILE"
    echo ""
    
    # Check if system is initialized
    if [[ -f "$BACKUP_METADATA_FILE" ]]; then
        echo "Status: ✅ Initialized"
    else
        echo "Status: ❌ Not initialized"
        echo "Run 'dot backup init' to initialize the backup system"
        return 1
    fi
    
    # Backup statistics
    if command -v jq >/dev/null 2>&1 && [[ -f "$BACKUP_METADATA_FILE" ]]; then
        local total_backups=$(jq '.backups | length' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 0)
        local full_backups=$(jq '[.backups[] | select(.type == "full")] | length' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 0)
        local incremental_backups=$(jq '[.backups[] | select(.type == "incremental")] | length' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 0)
        local config_backups=$(jq '[.backups[] | select(.type == "config-only")] | length' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 0)
        
        echo "Backup Statistics:"
        echo "  📦 Total backups: $total_backups"
        echo "  🔄 Full backups: $full_backups"
        echo "  📈 Incremental: $incremental_backups"
        echo "  ⚙️  Config-only: $config_backups"
        echo ""
        
        # Latest backup info
        local latest_backup=$(jq -r '.backups[0].name // "none"' "$BACKUP_METADATA_FILE" 2>/dev/null)
        local latest_type=$(jq -r '.backups[0].type // "none"' "$BACKUP_METADATA_FILE" 2>/dev/null)
        local latest_date=$(jq -r '.backups[0].created // "none"' "$BACKUP_METADATA_FILE" 2>/dev/null)
        
        echo "Latest Backup:"
        echo "  Name: $latest_backup"
        echo "  Type: $latest_type"
        echo "  Date: $latest_date"
        echo ""
        
        # Configuration
        local compression=$(jq -r '.config.compression // "gzip"' "$BACKUP_METADATA_FILE" 2>/dev/null)
        local auto_backup=$(jq -r '.config.auto_backup.enabled // false' "$BACKUP_METADATA_FILE" 2>/dev/null)
        local retention_daily=$(jq -r '.config.retention.daily // 7' "$BACKUP_METADATA_FILE" 2>/dev/null)
        
        echo "Configuration:"
        echo "  Compression: $compression"
        echo "  Auto-backup: $auto_backup"
        echo "  Retention (daily): $retention_daily"
    fi
    
    # Disk usage
    if [[ -d "$BACKUP_DIR" ]]; then
        local total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "unknown")
        echo ""
        echo "Storage Usage:"
        echo "  Total backup size: $total_size"
        
        # Available space
        local available_space=$(df -h "$BACKUP_DIR" 2>/dev/null | tail -1 | awk '{print $4}' || echo "unknown")
        echo "  Available space: $available_space"
    fi
    
    # Health check
    echo ""
    echo "Health Check:"
    
    # Check required directories
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "  ✅ Backup directory exists"
    else
        echo "  ❌ Backup directory missing"
    fi
    
    if [[ -d "$BACKUP_CONFIG_DIR" ]]; then
        echo "  ✅ Config directory exists"
    else
        echo "  ❌ Config directory missing"
    fi
    
    # Check permissions
    if [[ -w "$BACKUP_DIR" ]]; then
        echo "  ✅ Backup directory writable"
    else
        echo "  ❌ Backup directory not writable"
    fi
    
    # Check for required tools
    local required_tools=("tar" "gzip")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ❌ $tool not found"
        fi
    done
    
    # Check optional tools
    local optional_tools=("jq" "rsync" "bzip2" "xz" "zip")
    local missing_optional=()
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_optional+=("$tool")
        fi
    done
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        echo "  ⚠️  Optional tools missing: ${missing_optional[*]}"
    else
        echo "  ✅ All optional tools available"
    fi
}

# Configure backup system
configure_backup_system() {
    local setting="${1:-}"
    local value="${2:-}"
    
    if [[ -z "$setting" ]]; then
        show_backup_config
        return
    fi
    
    echo "⚙️  Configuring backup system: $setting"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq required for configuration management"
        return 1
    fi
    
    case "$setting" in
        "compression")
            if [[ -z "$value" ]]; then
                echo "Current compression: $(jq -r '.config.compression' "$BACKUP_METADATA_FILE")"
                echo "Available options: gzip, bzip2, xz, zip, none"
                return
            fi
            
            if [[ "$value" =~ ^(gzip|bzip2|xz|zip|none)$ ]]; then
                jq ".config.compression = \"$value\"" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
                mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
                echo "✅ Compression set to: $value"
            else
                echo "❌ Invalid compression type: $value"
                echo "Valid options: gzip, bzip2, xz, zip, none"
            fi
            ;;
        "auto-backup")
            if [[ -z "$value" ]]; then
                local enabled=$(jq -r '.config.auto_backup.enabled' "$BACKUP_METADATA_FILE")
                echo "Auto-backup enabled: $enabled"
                return
            fi
            
            if [[ "$value" =~ ^(true|false|on|off|yes|no)$ ]]; then
                local bool_value
                case "$value" in
                    true|on|yes) bool_value="true" ;;
                    false|off|no) bool_value="false" ;;
                esac
                
                jq ".config.auto_backup.enabled = $bool_value" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
                mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
                echo "✅ Auto-backup set to: $bool_value"
            else
                echo "❌ Invalid value: $value"
                echo "Valid options: true, false, on, off, yes, no"
            fi
            ;;
        "retention")
            configure_retention_policy "$value" "$3"
            ;;
        *)
            echo "❌ Unknown setting: $setting"
            echo "Available settings: compression, auto-backup, retention"
            ;;
    esac
}

# Show backup configuration
show_backup_config() {
    echo "⚙️  Backup System Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq required to display configuration"
        return 1
    fi
    
    if [[ ! -f "$BACKUP_METADATA_FILE" ]]; then
        echo "❌ Backup system not initialized"
        return 1
    fi
    
    echo "Compression Settings:"
    local compression=$(jq -r '.config.compression' "$BACKUP_METADATA_FILE")
    local compression_level=$(jq -r '.config.compression_level' "$BACKUP_METADATA_FILE")
    echo "  Type: $compression"
    echo "  Level: $compression_level"
    echo ""
    
    echo "Retention Policy:"
    local daily=$(jq -r '.config.retention.daily' "$BACKUP_METADATA_FILE")
    local weekly=$(jq -r '.config.retention.weekly' "$BACKUP_METADATA_FILE")
    local monthly=$(jq -r '.config.retention.monthly' "$BACKUP_METADATA_FILE")
    local yearly=$(jq -r '.config.retention.yearly' "$BACKUP_METADATA_FILE")
    echo "  Daily: $daily backups"
    echo "  Weekly: $weekly backups"
    echo "  Monthly: $monthly backups"
    echo "  Yearly: $yearly backups"
    echo ""
    
    echo "Auto-backup Settings:"
    local auto_enabled=$(jq -r '.config.auto_backup.enabled' "$BACKUP_METADATA_FILE")
    local auto_frequency=$(jq -r '.config.auto_backup.frequency' "$BACKUP_METADATA_FILE")
    local auto_time=$(jq -r '.config.auto_backup.time' "$BACKUP_METADATA_FILE")
    echo "  Enabled: $auto_enabled"
    echo "  Frequency: $auto_frequency"
    echo "  Time: $auto_time"
    echo ""
    
    echo "Exclude Patterns:"
    jq -r '.config.exclude_patterns[]' "$BACKUP_METADATA_FILE" | while read -r pattern; do
        echo "  - $pattern"
    done
}

# Configure retention policy
configure_retention_policy() {
    local period="$1"
    local count="$2"
    
    if [[ -z "$period" ]]; then
        echo "Retention policy settings:"
        jq -r '.config.retention | to_entries[] | "  \(.key): \(.value)"' "$BACKUP_METADATA_FILE"
        return
    fi
    
    if [[ -z "$count" ]]; then
        echo "Current $period retention: $(jq -r ".config.retention.$period" "$BACKUP_METADATA_FILE")"
        return
    fi
    
    if [[ ! "$count" =~ ^[0-9]+$ ]]; then
        echo "❌ Count must be a number"
        return 1
    fi
    
    case "$period" in
        "daily"|"weekly"|"monthly"|"yearly")
            jq ".config.retention.$period = $count" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
            mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
            echo "✅ $period retention set to: $count"
            ;;
        *)
            echo "❌ Invalid period: $period"
            echo "Valid periods: daily, weekly, monthly, yearly"
            ;;
    esac
}

# Manage backup schedule
manage_backup_schedule() {
    local action="${1:-status}"
    shift || true
    
    case "$action" in
        "status")
            show_backup_schedule_status
            ;;
        "enable")
            enable_backup_schedule "$@"
            ;;
        "disable")
            disable_backup_schedule
            ;;
        "set")
            set_backup_schedule "$@"
            ;;
        *)
            echo "Usage: dot backup schedule <status|enable|disable|set>"
            ;;
    esac
}

# Show backup schedule status
show_backup_schedule_status() {
    echo "📅 Backup Schedule Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v crontab >/dev/null 2>&1; then
        local cron_entry=$(crontab -l 2>/dev/null | grep "dot backup" || echo "")
        if [[ -n "$cron_entry" ]]; then
            echo "Status: ✅ Scheduled"
            echo "Cron entry: $cron_entry"
        else
            echo "Status: ❌ Not scheduled"
        fi
    else
        echo "Status: ❌ cron not available"
    fi
    
    # Check system timer (systemd)
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user is-enabled dotfiles-backup.timer >/dev/null 2>&1; then
            echo "Systemd timer: ✅ Enabled"
            systemctl --user status dotfiles-backup.timer --no-pager
        else
            echo "Systemd timer: ❌ Not configured"
        fi
    fi
}

# Enable backup schedule
enable_backup_schedule() {
    local frequency="${1:-daily}"
    local time="${2:-02:00}"
    
    echo "📅 Enabling backup schedule: $frequency at $time"
    
    # Create cron entry
    if command -v crontab >/dev/null 2>&1; then
        local cron_schedule
        case "$frequency" in
            "daily")
                local hour="${time%%:*}"
                local minute="${time##*:}"
                cron_schedule="$minute $hour * * *"
                ;;
            "weekly")
                local hour="${time%%:*}"
                local minute="${time##*:}"
                cron_schedule="$minute $hour * * 0"  # Sunday
                ;;
            "monthly")
                local hour="${time%%:*}"
                local minute="${time##*:}"
                cron_schedule="$minute $hour 1 * *"  # 1st of month
                ;;
            *)
                echo "❌ Invalid frequency: $frequency"
                echo "Valid options: daily, weekly, monthly"
                return 1
                ;;
        esac
        
        # Add to crontab
        (crontab -l 2>/dev/null | grep -v "dot backup create"; echo "$cron_schedule cd $DOTFILES_DIR && ./bin/dot backup create incremental") | crontab -
        echo "✅ Cron job added: $cron_schedule"
    fi
    
    # Update configuration
    if command -v jq >/dev/null 2>&1; then
        jq ".config.auto_backup.enabled = true | .config.auto_backup.frequency = \"$frequency\" | .config.auto_backup.time = \"$time\"" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
        mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
    fi
}

# Disable backup schedule
disable_backup_schedule() {
    echo "📅 Disabling backup schedule"
    
    # Remove from crontab
    if command -v crontab >/dev/null 2>&1; then
        crontab -l 2>/dev/null | grep -v "dot backup create" | crontab -
        echo "✅ Cron job removed"
    fi
    
    # Update configuration
    if command -v jq >/dev/null 2>&1; then
        jq ".config.auto_backup.enabled = false" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
        mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
    fi
}

# Migrate backup data
migrate_backup_data() {
    local source_dir="${1:-}"
    local target_dir="${2:-$BACKUP_DIR}"
    
    if [[ -z "$source_dir" ]]; then
        echo "Usage: dot backup migrate <source_dir> [target_dir]"
        return 1
    fi
    
    echo "🚚 Migrating backup data"
    echo "Source: $source_dir"
    echo "Target: $target_dir"
    
    if [[ ! -d "$source_dir" ]]; then
        echo "❌ Source directory not found: $source_dir"
        return 1
    fi
    
    mkdir -p "$target_dir"
    
    # Copy backup files
    echo "📦 Copying backup files..."
    rsync -av --progress "$source_dir/" "$target_dir/"
    
    # Update metadata paths if needed
    if [[ -f "$target_dir/metadata.json" ]] && command -v jq >/dev/null 2>&1; then
        echo "🔄 Updating metadata paths..."
        jq --arg new_path "$target_dir" '.backups[] |= (.path = (.path | gsub("^[^/]+"; $new_path)))' "$target_dir/metadata.json" > "$target_dir/metadata.json.tmp"
        mv "$target_dir/metadata.json.tmp" "$target_dir/metadata.json"
    fi
    
    echo "✅ Migration completed"
}

# Verify backup system
verify_backup_system() {
    local backup_name="${1:-all}"
    
    echo "🔍 Verifying backup system"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ "$backup_name" == "all" ]]; then
        verify_all_backups
    else
        verify_single_backup "$backup_name"
    fi
}

# Verify all backups
verify_all_backups() {
    echo "Verifying all backups..."
    
    local total_backups=0
    local valid_backups=0
    local invalid_backups=()
    
    if [[ -d "$BACKUP_DIR" ]]; then
        for backup_path in "$BACKUP_DIR"/*; do
            if [[ -e "$backup_path" ]]; then
                local backup_name=$(basename "$backup_path")
                ((total_backups++))
                
                echo "  Checking: $backup_name"
                if validate_backup "$backup_path" >/dev/null 2>&1; then
                    echo "    ✅ Valid"
                    ((valid_backups++))
                else
                    echo "    ❌ Invalid"
                    invalid_backups+=("$backup_name")
                fi
            fi
        done
    fi
    
    echo ""
    echo "Verification Summary:"
    echo "  Total backups: $total_backups"
    echo "  Valid backups: $valid_backups"
    echo "  Invalid backups: $((total_backups - valid_backups))"
    
    if [[ ${#invalid_backups[@]} -gt 0 ]]; then
        echo ""
        echo "Invalid backups:"
        for backup in "${invalid_backups[@]}"; do
            echo "  ❌ $backup"
        done
    fi
}

# Verify single backup
verify_single_backup() {
    local backup_name="$1"
    
    echo "Verifying backup: $backup_name"
    
    local backup_path
    backup_path=$(find_backup "$backup_name")
    
    if [[ -z "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_name"
        return 1
    fi
    
    if validate_backup "$backup_path"; then
        echo "✅ Backup is valid: $backup_name"
        
        # Additional checks
        if [[ -f "$backup_path/MANIFEST.json" ]] && command -v jq >/dev/null 2>&1; then
            local total_files=$(jq -r '.metadata.total_files' "$backup_path/MANIFEST.json")
            local actual_files=$(find "$backup_path/data" -type f | wc -l | tr -d ' ')
            
            echo "  📊 Manifest files: $total_files"
            echo "  📊 Actual files: $actual_files"
            
            if [[ "$total_files" == "$actual_files" ]]; then
                echo "  ✅ File count matches"
            else
                echo "  ⚠️  File count mismatch"
            fi
        fi
    else
        echo "❌ Backup validation failed: $backup_name"
        return 1
    fi
}

# Backup system doctor
backup_system_doctor() {
    echo "🏥 Backup System Doctor"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running comprehensive backup system health check..."
    echo ""
    
    local issues=0
    
    # Check system requirements
    echo "🔍 Checking system requirements..."
    
    # Check required tools
    local required_tools=("tar" "gzip" "rsync")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ❌ $tool not found"
            ((issues++))
        fi
    done
    
    # Check optional tools
    echo ""
    echo "🔍 Checking optional tools..."
    local optional_tools=("jq" "bzip2" "xz" "zip" "unzip")
    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ⚠️  $tool not found (functionality limited)"
        fi
    done
    
    # Check directory structure
    echo ""
    echo "🔍 Checking directory structure..."
    local required_dirs=("$BACKUP_DIR" "$BACKUP_CONFIG_DIR")
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
    if [[ -w "$BACKUP_DIR" ]]; then
        echo "  ✅ Backup directory writable"
    else
        echo "  ❌ Backup directory not writable"
        ((issues++))
    fi
    
    if [[ -w "$BACKUP_CONFIG_DIR" ]]; then
        echo "  ✅ Config directory writable"
    else
        echo "  ❌ Config directory not writable"
        ((issues++))
    fi
    
    # Check metadata file
    echo ""
    echo "🔍 Checking metadata..."
    if [[ -f "$BACKUP_METADATA_FILE" ]]; then
        echo "  ✅ Metadata file exists"
        
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$BACKUP_METADATA_FILE" >/dev/null 2>&1; then
                echo "  ✅ Metadata format valid"
            else
                echo "  ❌ Metadata format invalid"
                ((issues++))
            fi
        fi
    else
        echo "  ❌ Metadata file missing"
        ((issues++))
    fi
    
    # Check disk space
    echo ""
    echo "🔍 Checking disk space..."
    if [[ -d "$BACKUP_DIR" ]]; then
        local available_space=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
        local available_gb=$((available_space / 1024 / 1024))
        
        if [[ $available_gb -gt 1 ]]; then
            echo "  ✅ Sufficient disk space: ${available_gb}GB available"
        else
            echo "  ⚠️  Low disk space: ${available_gb}GB available"
        fi
    fi
    
    # Verify existing backups
    echo ""
    echo "🔍 Verifying existing backups..."
    if [[ -d "$BACKUP_DIR" ]]; then
        local backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d ! -name "." | wc -l | tr -d ' ')
        echo "  📦 Found $backup_count backups"
        
        if [[ $backup_count -gt 0 ]]; then
            verify_all_backups >/dev/null 2>&1
            echo "  ✅ Backup verification completed"
        fi
    fi
    
    # Summary
    echo ""
    echo "📋 Health Check Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Backup system is healthy!"
        echo ""
        echo "🎯 Recommendations:"
        echo "  • Create your first backup: dot backup create"
        echo "  • Set up automatic backups: dot backup schedule enable"
        echo "  • Configure retention policy: dot backup config retention"
    else
        echo "❌ Found $issues issues that need attention"
        echo ""
        echo "🔧 Recommendations:"
        if [[ ! -f "$BACKUP_METADATA_FILE" ]]; then
            echo "  • Initialize backup system: dot backup init"
        fi
        if [[ ! -d "$BACKUP_DIR" ]]; then
            echo "  • Create backup directory: mkdir -p $BACKUP_DIR"
        fi
        echo "  • Install missing required tools"
        echo "  • Fix permission issues if any"
        echo "  • Check available disk space"
    fi
}

# Export backup data
export_backup_data() {
    local target_file="${1:-backup-export-$(date +%Y%m%d).tar.gz}"
    
    echo "📤 Exporting backup data to: $target_file"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo "❌ Backup directory not found"
        return 1
    fi
    
    # Create export archive
    cd "$(dirname "$BACKUP_DIR")" || return 1
    tar -czf "$target_file" "$(basename "$BACKUP_DIR")"
    
    echo "✅ Backup data exported to: $target_file"
    echo "📊 Export size: $(ls -lh "$target_file" | awk '{print $5}')"
}

# Import backup data
import_backup_data() {
    local source_file="$1"
    local target_dir="${2:-$BACKUP_DIR}"
    
    if [[ -z "$source_file" ]]; then
        echo "Usage: dot backup import <source_file> [target_dir]"
        return 1
    fi
    
    echo "📥 Importing backup data from: $source_file"
    
    if [[ ! -f "$source_file" ]]; then
        echo "❌ Source file not found: $source_file"
        return 1
    fi
    
    # Create target directory
    mkdir -p "$(dirname "$target_dir")"
    
    # Extract archive
    case "$source_file" in
        *.tar.gz|*.tgz)
            tar -xzf "$source_file" -C "$(dirname "$target_dir")"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$source_file" -C "$(dirname "$target_dir")"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$source_file" -C "$(dirname "$target_dir")"
            ;;
        *.zip)
            unzip -q "$source_file" -d "$(dirname "$target_dir")"
            ;;
        *)
            echo "❌ Unsupported file format: $source_file"
            return 1
            ;;
    esac
    
    echo "✅ Backup data imported successfully"
    echo "📋 Run 'dot backup list' to see imported backups"
}

# Backup help
show_backup_help() {
    cat << 'EOF'
💾 Backup and Restore System

USAGE:
    dot backup <command> [options]

COMMANDS:
    create [type] [name] [description]  Create backup
      full                              Full backup (default)
      incremental                       Incremental backup since last backup
      differential                      Differential backup since last full
      config-only                       Configuration files only
      
    restore <name> [target] [type]      Restore from backup
      full                              Complete restore (default)
      selective                         Interactive file selection
      config-only                       Configuration files only
      
    list [filter]                       List backups
      all                               All backups (default)
      full                              Full backups only
      incremental                       Incremental backups only
      
    info <name>                         Show backup details
    delete <name>                       Delete backup
    
    status                              Show system status
    config [setting] [value]            Configure backup system
      compression <type>                Set compression (gzip|bzip2|xz|zip|none)
      auto-backup <enabled>             Enable/disable auto-backup
      retention <period> <count>        Set retention policy
      
    schedule <action>                   Manage backup schedule
      status                            Show schedule status
      enable [freq] [time]             Enable scheduled backups
      disable                          Disable scheduled backups
      
    verify [name]                       Verify backup integrity
    doctor                             System health check
    migrate <source> [target]          Migrate backup data
    export [file]                      Export backup data
    import <file> [target]             Import backup data
    init                               Initialize backup system

OPTIONS:
    --force                            Skip confirmations
    --no-backup                        Skip creating restore point
    --overwrite                        Overwrite existing files
    --compress <type>                  Override compression setting

BACKUP TYPES:
    full          Complete backup of all configured paths
    incremental   Only files changed since last backup
    differential  Only files changed since last full backup
    config-only   Configuration files and settings only

EXAMPLES:
    # Basic backup operations
    dot backup create                          # Create full backup
    dot backup create incremental my-work      # Create incremental backup
    dot backup list                           # List all backups
    dot backup info backup-20231201           # Show backup details
    
    # Restore operations
    dot backup restore backup-20231201        # Full restore
    dot backup restore backup-20231201 /tmp   # Restore to specific location
    dot backup restore backup-20231201 ~ selective  # Interactive restore
    
    # System configuration
    dot backup config compression xz           # Use XZ compression
    dot backup config retention daily 14      # Keep 14 daily backups
    dot backup schedule enable daily 03:00    # Daily backup at 3 AM
    
    # Maintenance
    dot backup verify                          # Verify all backups
    dot backup doctor                          # Health check
    dot backup delete old-backup --force       # Delete backup

RETENTION POLICY:
    Daily backups are kept for the configured number of days
    Weekly backups are promoted from daily backups
    Monthly backups are promoted from weekly backups
    Yearly backups are promoted from monthly backups

For more information: https://docs.dotfiles.dev/backup
EOF
}

# Export functions
export -f dot_backup show_backup_system_status configure_backup_system
export -f manage_backup_schedule verify_backup_system backup_system_doctor
export -f show_backup_help