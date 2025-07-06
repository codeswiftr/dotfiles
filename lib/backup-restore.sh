#!/usr/bin/env bash
# =============================================================================
# Backup and Restore System
# Comprehensive backup, restore, and migration functionality for dotfiles
# =============================================================================

# Backup system configuration
BACKUP_DIR="$HOME/.local/share/dotfiles/backups"
BACKUP_CONFIG_DIR="$HOME/.config/dotfiles/backup"
BACKUP_METADATA_FILE="$BACKUP_CONFIG_DIR/metadata.json"
BACKUP_EXCLUDE_FILE="$BACKUP_CONFIG_DIR/exclude.list"

# Backup types
BACKUP_TYPE_FULL="full"
BACKUP_TYPE_INCREMENTAL="incremental"
BACKUP_TYPE_DIFFERENTIAL="differential"
BACKUP_TYPE_CONFIG_ONLY="config-only"

# Backup compression
BACKUP_COMPRESSION="gzip"
BACKUP_COMPRESSION_LEVEL="6"

# Initialize backup system
init_backup_system() {
    mkdir -p "$BACKUP_DIR" "$BACKUP_CONFIG_DIR"
    
    # Create backup metadata file if it doesn't exist
    if [[ ! -f "$BACKUP_METADATA_FILE" ]]; then
        create_backup_metadata
    fi
    
    # Create default exclude list
    if [[ ! -f "$BACKUP_EXCLUDE_FILE" ]]; then
        create_default_exclude_list
    fi
    
    # Set up backup hooks
    setup_backup_hooks
}

# Create backup metadata file
create_backup_metadata() {
    cat > "$BACKUP_METADATA_FILE" << EOF
{
  "version": "1.0",
  "created": "$(date -Iseconds)",
  "backups": [],
  "config": {
    "compression": "$BACKUP_COMPRESSION",
    "compression_level": "$BACKUP_COMPRESSION_LEVEL",
    "retention": {
      "daily": 7,
      "weekly": 4,
      "monthly": 12,
      "yearly": 2
    },
    "auto_backup": {
      "enabled": false,
      "frequency": "daily",
      "time": "02:00"
    },
    "exclude_patterns": [
      "*.log",
      "*.tmp",
      "*~",
      ".DS_Store",
      "node_modules/",
      ".git/objects/",
      "*.cache"
    ]
  }
}
EOF
}

# Create default exclude list
create_default_exclude_list() {
    cat > "$BACKUP_EXCLUDE_FILE" << EOF
# Backup Exclude List
# Files and directories to exclude from backups

# Temporary files
*.tmp
*~
*.bak
*.swp
*.swo

# System files
.DS_Store
Thumbs.db
desktop.ini

# Logs and caches
*.log
*.cache
.cache/
logs/

# Development artifacts
node_modules/
.npm/
.cargo/registry/
.cargo/git/
__pycache__/
*.pyc
.pytest_cache/
.coverage

# Git objects (keep refs and config)
.git/objects/
.git/logs/
.git/refs/remotes/

# Large files that change frequently
*.iso
*.dmg
*.img
*.qcow2
*.vdi
*.vmdk

# Database files
*.db
*.sqlite
*.sqlite3

# Sensitive files (should use secret management instead)
*.key
*.pem
*.p12
*.pfx
id_rsa
id_dsa
id_ecdsa
id_ed25519

# IDE and editor files
.vscode/settings.json
.idea/
*.sublime-*
EOF
}

# Setup backup hooks
setup_backup_hooks() {
    # Create backup hook directories
    mkdir -p "$BACKUP_CONFIG_DIR/hooks"/{pre-backup,post-backup,pre-restore,post-restore}
    
    # These hooks integrate with the main dotfiles hook system
}

# Create backup
backup_create() {
    local backup_type="${1:-$BACKUP_TYPE_FULL}"
    local backup_name="${2:-}"
    local description="${3:-}"
    local include_paths=("${@:4}")
    
    # Generate backup name if not provided
    if [[ -z "$backup_name" ]]; then
        backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    echo "💾 Creating backup: $backup_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Type: $backup_type"
    echo "Description: ${description:-Automated backup}"
    echo ""
    
    local backup_path="$BACKUP_DIR/$backup_name"
    mkdir -p "$backup_path"
    
    # Create backup manifest
    create_backup_manifest "$backup_path" "$backup_type" "$description"
    
    # Run pre-backup hooks
    run_backup_hooks "pre-backup" "$backup_path"
    
    # Perform backup based on type
    case "$backup_type" in
        "$BACKUP_TYPE_FULL")
            backup_full "$backup_path" "${include_paths[@]}"
            ;;
        "$BACKUP_TYPE_INCREMENTAL")
            backup_incremental "$backup_path" "${include_paths[@]}"
            ;;
        "$BACKUP_TYPE_DIFFERENTIAL")
            backup_differential "$backup_path" "${include_paths[@]}"
            ;;
        "$BACKUP_TYPE_CONFIG_ONLY")
            backup_config_only "$backup_path" "${include_paths[@]}"
            ;;
        *)
            echo "❌ Unknown backup type: $backup_type"
            return 1
            ;;
    esac
    
    # Run post-backup hooks
    run_backup_hooks "post-backup" "$backup_path"
    
    # Compress backup if configured
    if [[ "$BACKUP_COMPRESSION" != "none" ]]; then
        compress_backup "$backup_path"
    fi
    
    # Update backup metadata
    update_backup_metadata "$backup_name" "$backup_type" "$description" "$backup_path"
    
    # Clean up old backups based on retention policy
    cleanup_old_backups
    
    echo "✅ Backup created successfully: $backup_path"
    echo "📊 Backup size: $(get_backup_size "$backup_path")"
}

# Create backup manifest
create_backup_manifest() {
    local backup_path="$1"
    local backup_type="$2"
    local description="$3"
    
    cat > "$backup_path/MANIFEST.json" << EOF
{
  "backup": {
    "name": "$(basename "$backup_path")",
    "type": "$backup_type",
    "description": "$description",
    "created": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "user": "$USER",
    "platform": {
      "os": "$(uname -s)",
      "arch": "$(uname -m)",
      "version": "$(uname -r)"
    },
    "dotfiles": {
      "version": "$(cat "$DOTFILES_DIR/VERSION" 2>/dev/null || echo "unknown")",
      "commit": "$(cd "$DOTFILES_DIR" && git rev-parse HEAD 2>/dev/null || echo "unknown")",
      "branch": "$(cd "$DOTFILES_DIR" && git branch --show-current 2>/dev/null || echo "unknown")"
    }
  },
  "contents": [],
  "metadata": {
    "compression": "$BACKUP_COMPRESSION",
    "compression_level": "$BACKUP_COMPRESSION_LEVEL",
    "total_files": 0,
    "total_size": 0,
    "duration": 0
  }
}
EOF
}

# Full backup
backup_full() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    
    echo "📦 Creating full backup..."
    
    # Default paths if none specified
    if [[ ${#include_paths[@]} -eq 0 ]]; then
        include_paths=(
            "$DOTFILES_DIR"
            "$HOME/.config"
            "$HOME/.local/share/dotfiles"
            "$HOME/.ssh/config"
            "$HOME/.gitconfig"
            "$HOME/.zshrc"
            "$HOME/.bashrc"
            "$HOME/.profile"
        )
    fi
    
    local files_backed_up=0
    local total_size=0
    local start_time=$(date +%s)
    
    # Create backup structure
    mkdir -p "$backup_path/data"
    
    for path in "${include_paths[@]}"; do
        if [[ -e "$path" ]]; then
            echo "  📁 Backing up: $path"
            
            # Determine relative path for backup
            local rel_path
            if [[ "$path" == "$HOME"* ]]; then
                rel_path="home${path#$HOME}"
            elif [[ "$path" == "$DOTFILES_DIR"* ]]; then
                rel_path="dotfiles${path#$DOTFILES_DIR}"
            else
                rel_path="$(echo "$path" | sed 's|^/||' | tr '/' '_')"
            fi
            
            local backup_target="$backup_path/data/$rel_path"
            mkdir -p "$(dirname "$backup_target")"
            
            # Copy with exclusions
            if [[ -d "$path" ]]; then
                rsync -a \
                    --exclude-from="$BACKUP_EXCLUDE_FILE" \
                    --stats \
                    "$path/" "$backup_target/" | \
                    tee "$backup_path/rsync-$rel_path.log"
            else
                cp "$path" "$backup_target"
            fi
            
            # Count files and calculate size
            local path_files=$(find "$backup_target" -type f | wc -l | tr -d ' ')
            local path_size=$(du -sb "$backup_target" 2>/dev/null | cut -f1 || echo 0)
            
            files_backed_up=$((files_backed_up + path_files))
            total_size=$((total_size + path_size))
            
            echo "    Files: $path_files, Size: $(format_size "$path_size")"
        else
            echo "  ⚠️  Path not found: $path"
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Update manifest
    update_manifest_stats "$backup_path" "$files_backed_up" "$total_size" "$duration"
    
    echo "  📊 Total files: $files_backed_up"
    echo "  📊 Total size: $(format_size "$total_size")"
    echo "  ⏱️  Duration: ${duration}s"
}

# Incremental backup
backup_incremental() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    
    echo "📦 Creating incremental backup..."
    
    # Find the most recent full or incremental backup
    local base_backup
    base_backup=$(find_latest_backup "$BACKUP_TYPE_FULL" "$BACKUP_TYPE_INCREMENTAL")
    
    if [[ -z "$base_backup" ]]; then
        echo "⚠️  No base backup found, creating full backup instead"
        backup_full "$backup_path" "${include_paths[@]}"
        return
    fi
    
    echo "  📚 Base backup: $base_backup"
    
    # Create incremental backup using timestamps
    local base_timestamp
    base_timestamp=$(get_backup_timestamp "$base_backup")
    
    backup_changes_since "$backup_path" "$base_timestamp" "${include_paths[@]}"
}

# Differential backup
backup_differential() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    
    echo "📦 Creating differential backup..."
    
    # Find the most recent full backup
    local base_backup
    base_backup=$(find_latest_backup "$BACKUP_TYPE_FULL")
    
    if [[ -z "$base_backup" ]]; then
        echo "⚠️  No full backup found, creating full backup instead"
        backup_full "$backup_path" "${include_paths[@]}"
        return
    fi
    
    echo "  📚 Base backup: $base_backup"
    
    # Create differential backup
    local base_timestamp
    base_timestamp=$(get_backup_timestamp "$base_backup")
    
    backup_changes_since "$backup_path" "$base_timestamp" "${include_paths[@]}"
}

# Config-only backup
backup_config_only() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    
    echo "📦 Creating configuration-only backup..."
    
    # Default config paths if none specified
    if [[ ${#include_paths[@]} -eq 0 ]]; then
        include_paths=(
            "$DOTFILES_DIR/config"
            "$HOME/.config/dotfiles"
            "$HOME/.gitconfig"
            "$HOME/.ssh/config"
        )
    fi
    
    backup_full "$backup_path" "${include_paths[@]}"
}

# Backup changes since timestamp
backup_changes_since() {
    local backup_path="$1"
    local since_timestamp="$2"
    shift 2
    local include_paths=("$@")
    
    # Default paths if none specified
    if [[ ${#include_paths[@]} -eq 0 ]]; then
        include_paths=(
            "$DOTFILES_DIR"
            "$HOME/.config"
        )
    fi
    
    local files_backed_up=0
    local total_size=0
    local start_time=$(date +%s)
    
    mkdir -p "$backup_path/data"
    
    for path in "${include_paths[@]}"; do
        if [[ -e "$path" ]]; then
            echo "  📁 Checking changes in: $path"
            
            # Find files newer than timestamp
            local changed_files
            mapfile -t changed_files < <(find "$path" -type f -newer "$since_timestamp" 2>/dev/null | grep -v -f "$BACKUP_EXCLUDE_FILE" || true)
            
            if [[ ${#changed_files[@]} -gt 0 ]]; then
                echo "    Found ${#changed_files[@]} changed files"
                
                for file in "${changed_files[@]}"; do
                    # Calculate relative path
                    local rel_path
                    if [[ "$file" == "$HOME"* ]]; then
                        rel_path="home${file#$HOME}"
                    elif [[ "$file" == "$DOTFILES_DIR"* ]]; then
                        rel_path="dotfiles${file#$DOTFILES_DIR}"
                    else
                        rel_path="$(echo "$file" | sed 's|^/||' | tr '/' '_')"
                    fi
                    
                    local backup_target="$backup_path/data/$rel_path"
                    mkdir -p "$(dirname "$backup_target")"
                    
                    cp "$file" "$backup_target"
                    
                    local file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
                    files_backed_up=$((files_backed_up + 1))
                    total_size=$((total_size + file_size))
                done
            else
                echo "    No changes found"
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Update manifest
    update_manifest_stats "$backup_path" "$files_backed_up" "$total_size" "$duration"
    
    echo "  📊 Changed files: $files_backed_up"
    echo "  📊 Total size: $(format_size "$total_size")"
    echo "  ⏱️  Duration: ${duration}s"
}

# Compress backup
compress_backup() {
    local backup_path="$1"
    
    echo "🗜️  Compressing backup..."
    
    case "$BACKUP_COMPRESSION" in
        "gzip")
            cd "$(dirname "$backup_path")" || return 1
            tar -czf "${backup_path}.tar.gz" "$(basename "$backup_path")"
            rm -rf "$backup_path"
            echo "  ✅ Compressed to: ${backup_path}.tar.gz"
            ;;
        "bzip2")
            cd "$(dirname "$backup_path")" || return 1
            tar -cjf "${backup_path}.tar.bz2" "$(basename "$backup_path")"
            rm -rf "$backup_path"
            echo "  ✅ Compressed to: ${backup_path}.tar.bz2"
            ;;
        "xz")
            cd "$(dirname "$backup_path")" || return 1
            tar -cJf "${backup_path}.tar.xz" "$(basename "$backup_path")"
            rm -rf "$backup_path"
            echo "  ✅ Compressed to: ${backup_path}.tar.xz"
            ;;
        "zip")
            cd "$(dirname "$backup_path")" || return 1
            zip -r "${backup_path}.zip" "$(basename "$backup_path")" >/dev/null
            rm -rf "$backup_path"
            echo "  ✅ Compressed to: ${backup_path}.zip"
            ;;
        *)
            echo "  ℹ️  No compression applied"
            ;;
    esac
}

# Restore backup
backup_restore() {
    local backup_name="${1:-}"
    local target_path="${2:-$HOME}"
    local restore_type="${3:-full}"
    local options="${4:-}"
    
    if [[ -z "$backup_name" ]]; then
        echo "❌ Backup name required"
        echo "Available backups:"
        backup_list
        return 1
    fi
    
    echo "🔄 Restoring backup: $backup_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Find backup
    local backup_path
    backup_path=$(find_backup "$backup_name")
    
    if [[ -z "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_name"
        return 1
    fi
    
    # Check if backup is compressed
    if [[ ! -d "$backup_path" ]]; then
        backup_path=$(decompress_backup "$backup_path")
    fi
    
    # Validate backup
    if ! validate_backup "$backup_path"; then
        echo "❌ Backup validation failed: $backup_name"
        return 1
    fi
    
    # Load backup manifest
    local manifest_file="$backup_path/MANIFEST.json"
    if [[ ! -f "$manifest_file" ]]; then
        echo "❌ Backup manifest not found"
        return 1
    fi
    
    # Show backup information
    show_backup_info "$manifest_file"
    
    # Confirm restore
    if [[ "$options" != *"--force"* ]]; then
        echo ""
        if ! ask_yes_no "Continue with restore?"; then
            echo "❌ Restore cancelled"
            return 1
        fi
    fi
    
    # Create restore point
    if [[ "$options" != *"--no-backup"* ]]; then
        echo "💾 Creating restore point..."
        backup_create "full" "restore-point-$(date +%Y%m%d-%H%M%S)" "Pre-restore backup"
    fi
    
    # Run pre-restore hooks
    run_backup_hooks "pre-restore" "$backup_path"
    
    # Perform restore
    case "$restore_type" in
        "full")
            restore_full "$backup_path" "$target_path" "$options"
            ;;
        "selective")
            restore_selective "$backup_path" "$target_path" "$options"
            ;;
        "config-only")
            restore_config_only "$backup_path" "$target_path" "$options"
            ;;
        *)
            echo "❌ Unknown restore type: $restore_type"
            return 1
            ;;
    esac
    
    # Run post-restore hooks
    run_backup_hooks "post-restore" "$backup_path"
    
    echo "✅ Restore completed successfully"
    
    # Recommend follow-up actions
    echo ""
    echo "📋 Recommended next steps:"
    echo "  1. Restart your shell: dot reload"
    echo "  2. Run health check: dot check"
    echo "  3. Update configurations if needed"
}

# Full restore
restore_full() {
    local backup_path="$1"
    local target_path="$2"
    local options="$3"
    
    echo "🔄 Performing full restore..."
    
    local data_dir="$backup_path/data"
    
    if [[ ! -d "$data_dir" ]]; then
        echo "❌ Backup data directory not found"
        return 1
    fi
    
    # Restore each path
    for backup_item in "$data_dir"/*; do
        if [[ -e "$backup_item" ]]; then
            local item_name=$(basename "$backup_item")
            
            # Determine target path
            local restore_target
            case "$item_name" in
                "home"*)
                    restore_target="$HOME${item_name#home}"
                    ;;
                "dotfiles"*)
                    restore_target="$DOTFILES_DIR${item_name#dotfiles}"
                    ;;
                *)
                    restore_target="$target_path/$item_name"
                    ;;
            esac
            
            echo "  📁 Restoring: $item_name -> $restore_target"
            
            # Create parent directory
            mkdir -p "$(dirname "$restore_target")"
            
            # Restore with options
            if [[ "$options" == *"--overwrite"* ]]; then
                rsync -a "$backup_item/" "$restore_target/"
            else
                rsync -a --ignore-existing "$backup_item/" "$restore_target/"
            fi
        fi
    done
}

# Selective restore
restore_selective() {
    local backup_path="$1"
    local target_path="$2"
    local options="$3"
    
    echo "🔄 Performing selective restore..."
    
    local data_dir="$backup_path/data"
    
    # List available items
    echo "Available items for restore:"
    local items=()
    local index=1
    
    for backup_item in "$data_dir"/*; do
        if [[ -e "$backup_item" ]]; then
            local item_name=$(basename "$backup_item")
            items+=("$item_name")
            echo "  $index) $item_name"
            ((index++))
        fi
    done
    
    echo ""
    echo "Enter item numbers to restore (comma-separated, or 'all'):"
    read -r selection
    
    if [[ "$selection" == "all" ]]; then
        restore_full "$backup_path" "$target_path" "$options"
    else
        IFS=',' read -ra selected_indices <<< "$selection"
        for idx in "${selected_indices[@]}"; do
            idx=$(echo "$idx" | xargs) # trim whitespace
            if [[ "$idx" =~ ^[0-9]+$ ]] && [[ $idx -le ${#items[@]} ]]; then
                local item_name="${items[$((idx-1))]}"
                local backup_item="$data_dir/$item_name"
                
                # Determine target path
                local restore_target
                case "$item_name" in
                    "home"*)
                        restore_target="$HOME${item_name#home}"
                        ;;
                    "dotfiles"*)
                        restore_target="$DOTFILES_DIR${item_name#dotfiles}"
                        ;;
                    *)
                        restore_target="$target_path/$item_name"
                        ;;
                esac
                
                echo "  📁 Restoring: $item_name -> $restore_target"
                mkdir -p "$(dirname "$restore_target")"
                rsync -a "$backup_item/" "$restore_target/"
            fi
        done
    fi
}

# Config-only restore
restore_config_only() {
    local backup_path="$1"
    local target_path="$2"
    local options="$3"
    
    echo "🔄 Performing configuration-only restore..."
    
    local data_dir="$backup_path/data"
    
    # Restore only configuration directories and files
    local config_patterns=("*config*" "*dotfiles*" "*gitconfig*" "*ssh*")
    
    for pattern in "${config_patterns[@]}"; do
        for backup_item in "$data_dir"/$pattern; do
            if [[ -e "$backup_item" ]]; then
                local item_name=$(basename "$backup_item")
                
                # Determine target path
                local restore_target
                case "$item_name" in
                    "home"*)
                        restore_target="$HOME${item_name#home}"
                        ;;
                    "dotfiles"*)
                        restore_target="$DOTFILES_DIR${item_name#dotfiles}"
                        ;;
                    *)
                        restore_target="$target_path/$item_name"
                        ;;
                esac
                
                echo "  📁 Restoring config: $item_name -> $restore_target"
                mkdir -p "$(dirname "$restore_target")"
                rsync -a "$backup_item/" "$restore_target/"
            fi
        done
    done
}

# List backups
backup_list() {
    local filter="${1:-all}"
    
    echo "💾 Backup List"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo "No backups found"
        return
    fi
    
    local backups=()
    
    # Find all backups (both directories and compressed files)
    while IFS= read -r -d '' backup; do
        backups+=("$backup")
    done < <(find "$BACKUP_DIR" -maxdepth 1 \( -type d -o -name "*.tar.gz" -o -name "*.tar.bz2" -o -name "*.tar.xz" -o -name "*.zip" \) -print0 2>/dev/null)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo "No backups found"
        return
    fi
    
    # Sort backups by date (newest first)
    IFS=$'\n' backups=($(printf '%s\n' "${backups[@]}" | sort -r))
    
    echo "Name                 Type         Size       Date                Description"
    echo "─────────────────────────────────────────────────────────────────────────────"
    
    for backup in "${backups[@]}"; do
        local backup_name=$(basename "$backup" | sed 's/\.\(tar\.\(gz\|bz2\|xz\)\|zip\)$//')
        local backup_type="unknown"
        local backup_size
        local backup_date
        local backup_desc="No description"
        
        # Get backup size
        if [[ -d "$backup" ]]; then
            backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "unknown")
        else
            backup_size=$(ls -lh "$backup" 2>/dev/null | awk '{print $5}' || echo "unknown")
        fi
        
        # Get backup date from filename or file stats
        if [[ "$backup_name" =~ [0-9]{8}-[0-9]{6} ]]; then
            local date_part="${backup_name##*-}"
            date_part="${date_part%%-*}"
            if [[ ${#date_part} -eq 15 ]]; then
                local year="${date_part:0:4}"
                local month="${date_part:4:2}"
                local day="${date_part:6:2}"
                local hour="${date_part:9:2}"
                local minute="${date_part:11:2}"
                local second="${date_part:13:2}"
                backup_date="$year-$month-$day $hour:$minute:$second"
            else
                backup_date=$(date -r "$backup" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
            fi
        else
            backup_date=$(date -r "$backup" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
        fi
        
        # Try to get backup type and description from manifest
        local manifest_file
        if [[ -d "$backup" ]]; then
            manifest_file="$backup/MANIFEST.json"
        else
            # For compressed backups, we'd need to extract manifest
            manifest_file=""
        fi
        
        if [[ -f "$manifest_file" ]] && command -v jq >/dev/null 2>&1; then
            backup_type=$(jq -r '.backup.type // "unknown"' "$manifest_file" 2>/dev/null)
            backup_desc=$(jq -r '.backup.description // "No description"' "$manifest_file" 2>/dev/null)
        fi
        
        # Apply filter
        case "$filter" in
            "full")
                [[ "$backup_type" == "full" ]] || continue
                ;;
            "incremental")
                [[ "$backup_type" == "incremental" ]] || continue
                ;;
            "differential")
                [[ "$backup_type" == "differential" ]] || continue
                ;;
            "config-only")
                [[ "$backup_type" == "config-only" ]] || continue
                ;;
        esac
        
        # Truncate long descriptions
        if [[ ${#backup_desc} -gt 20 ]]; then
            backup_desc="${backup_desc:0:17}..."
        fi
        
        printf "%-20s %-12s %-10s %-19s %s\n" \
            "$backup_name" "$backup_type" "$backup_size" "$backup_date" "$backup_desc"
    done
}

# Show backup information
show_backup_info() {
    local backup_name="$1"
    
    echo "📋 Backup Information: $backup_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Find backup
    local backup_path
    backup_path=$(find_backup "$backup_name")
    
    if [[ -z "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_name"
        return 1
    fi
    
    # Check if backup is compressed
    local is_compressed=false
    if [[ ! -d "$backup_path" ]]; then
        is_compressed=true
        echo "Status: Compressed"
        echo "Size: $(ls -lh "$backup_path" | awk '{print $5}')"
        echo ""
        
        # Try to extract manifest for info
        local temp_dir=$(mktemp -d)
        case "$backup_path" in
            *.tar.gz) tar -xzf "$backup_path" -C "$temp_dir" --wildcards "*/MANIFEST.json" 2>/dev/null || true ;;
            *.tar.bz2) tar -xjf "$backup_path" -C "$temp_dir" --wildcards "*/MANIFEST.json" 2>/dev/null || true ;;
            *.tar.xz) tar -xJf "$backup_path" -C "$temp_dir" --wildcards "*/MANIFEST.json" 2>/dev/null || true ;;
            *.zip) unzip -q "$backup_path" "*/MANIFEST.json" -d "$temp_dir" 2>/dev/null || true ;;
        esac
        
        local manifest_file=$(find "$temp_dir" -name "MANIFEST.json" | head -1)
        if [[ -f "$manifest_file" ]]; then
            backup_path=$(dirname "$manifest_file")
        else
            echo "⚠️  Cannot read compressed backup manifest"
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    local manifest_file="$backup_path/MANIFEST.json"
    if [[ ! -f "$manifest_file" ]]; then
        echo "❌ Backup manifest not found"
        return 1
    fi
    
    # Display backup information
    if command -v jq >/dev/null 2>&1; then
        local name=$(jq -r '.backup.name' "$manifest_file")
        local type=$(jq -r '.backup.type' "$manifest_file")
        local description=$(jq -r '.backup.description' "$manifest_file")
        local created=$(jq -r '.backup.created' "$manifest_file")
        local hostname=$(jq -r '.backup.hostname' "$manifest_file")
        local user=$(jq -r '.backup.user' "$manifest_file")
        local os=$(jq -r '.backup.platform.os' "$manifest_file")
        local arch=$(jq -r '.backup.platform.arch' "$manifest_file")
        local dotfiles_version=$(jq -r '.backup.dotfiles.version' "$manifest_file")
        local dotfiles_commit=$(jq -r '.backup.dotfiles.commit' "$manifest_file")
        local total_files=$(jq -r '.metadata.total_files' "$manifest_file")
        local total_size=$(jq -r '.metadata.total_size' "$manifest_file")
        local duration=$(jq -r '.metadata.duration' "$manifest_file")
        
        echo "Name: $name"
        echo "Type: $type"
        echo "Description: $description"
        echo "Created: $created"
        echo "Source Host: $hostname"
        echo "Source User: $user"
        echo "Platform: $os $arch"
        echo "Dotfiles Version: $dotfiles_version"
        echo "Dotfiles Commit: $dotfiles_commit"
        echo ""
        echo "Statistics:"
        echo "  Files: $total_files"
        echo "  Size: $(format_size "$total_size")"
        echo "  Duration: ${duration}s"
        
        # List contents
        echo ""
        echo "Contents:"
        jq -r '.contents[]? // empty' "$manifest_file" | while read -r item; do
            echo "  📁 $item"
        done
    else
        echo "⚠️  jq not available - showing raw manifest"
        cat "$manifest_file"
    fi
    
    # Clean up temp directory if created
    if [[ "$is_compressed" == "true" ]] && [[ -n "${temp_dir:-}" ]]; then
        rm -rf "$temp_dir"
    fi
}

# Delete backup
backup_delete() {
    local backup_name="$1"
    local force="${2:-false}"
    
    if [[ -z "$backup_name" ]]; then
        echo "❌ Backup name required"
        return 1
    fi
    
    echo "🗑️  Deleting backup: $backup_name"
    
    # Find backup
    local backup_path
    backup_path=$(find_backup "$backup_name")
    
    if [[ -z "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_name"
        return 1
    fi
    
    # Show backup info
    show_backup_info "$backup_name"
    
    # Confirm deletion
    if [[ "$force" != "true" ]]; then
        echo ""
        if ! ask_yes_no "Are you sure you want to delete this backup?"; then
            echo "❌ Deletion cancelled"
            return 1
        fi
    fi
    
    # Delete backup
    rm -rf "$backup_path"
    
    # Remove from metadata
    remove_backup_from_metadata "$backup_name"
    
    echo "✅ Backup deleted: $backup_name"
}

# Utility functions

# Find backup by name
find_backup() {
    local backup_name="$1"
    
    # Check for exact directory match
    if [[ -d "$BACKUP_DIR/$backup_name" ]]; then
        echo "$BACKUP_DIR/$backup_name"
        return
    fi
    
    # Check for compressed files
    for ext in tar.gz tar.bz2 tar.xz zip; do
        if [[ -f "$BACKUP_DIR/$backup_name.$ext" ]]; then
            echo "$BACKUP_DIR/$backup_name.$ext"
            return
        fi
    done
    
    # Check for partial matches
    local matches=($(ls -1 "$BACKUP_DIR" 2>/dev/null | grep "$backup_name" || true))
    if [[ ${#matches[@]} -eq 1 ]]; then
        echo "$BACKUP_DIR/${matches[0]}"
    fi
}

# Find latest backup of specific type(s)
find_latest_backup() {
    local types=("$@")
    
    if [[ ! -f "$BACKUP_METADATA_FILE" ]] || ! command -v jq >/dev/null 2>&1; then
        return 1
    fi
    
    for type in "${types[@]}"; do
        local latest
        latest=$(jq -r ".backups[] | select(.type == \"$type\") | .name" "$BACKUP_METADATA_FILE" | head -1)
        if [[ -n "$latest" ]]; then
            echo "$latest"
            return
        fi
    done
}

# Get backup timestamp
get_backup_timestamp() {
    local backup_name="$1"
    
    if [[ ! -f "$BACKUP_METADATA_FILE" ]] || ! command -v jq >/dev/null 2>&1; then
        return 1
    fi
    
    jq -r ".backups[] | select(.name == \"$backup_name\") | .created" "$BACKUP_METADATA_FILE"
}

# Validate backup
validate_backup() {
    local backup_path="$1"
    
    # Check if backup directory exists
    if [[ ! -d "$backup_path" ]]; then
        echo "❌ Backup directory not found: $backup_path"
        return 1
    fi
    
    # Check for manifest file
    if [[ ! -f "$backup_path/MANIFEST.json" ]]; then
        echo "❌ Backup manifest missing"
        return 1
    fi
    
    # Validate manifest JSON
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$backup_path/MANIFEST.json" 2>/dev/null; then
            echo "❌ Invalid backup manifest format"
            return 1
        fi
    fi
    
    # Check for data directory
    if [[ ! -d "$backup_path/data" ]]; then
        echo "❌ Backup data directory missing"
        return 1
    fi
    
    echo "✅ Backup validation passed"
    return 0
}

# Decompress backup
decompress_backup() {
    local backup_file="$1"
    
    local temp_dir=$(mktemp -d)
    local backup_name=$(basename "$backup_file" | sed 's/\.\(tar\.\(gz\|bz2\|xz\)\|zip\)$//')
    
    echo "📦 Decompressing backup: $backup_name"
    
    case "$backup_file" in
        *.tar.gz)
            tar -xzf "$backup_file" -C "$temp_dir"
            ;;
        *.tar.bz2)
            tar -xjf "$backup_file" -C "$temp_dir"
            ;;
        *.tar.xz)
            tar -xJf "$backup_file" -C "$temp_dir"
            ;;
        *.zip)
            unzip -q "$backup_file" -d "$temp_dir"
            ;;
        *)
            echo "❌ Unsupported compression format"
            rm -rf "$temp_dir"
            return 1
            ;;
    esac
    
    # Find the extracted backup directory
    local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d ! -name "." | head -1)
    if [[ -n "$extracted_dir" ]]; then
        echo "$extracted_dir"
    else
        echo "❌ Failed to extract backup"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Run backup hooks
run_backup_hooks() {
    local hook_type="$1"
    local backup_path="$2"
    
    local hook_dir="$BACKUP_CONFIG_DIR/hooks/$hook_type"
    
    if [[ -d "$hook_dir" ]]; then
        for hook_script in "$hook_dir"/*; do
            if [[ -x "$hook_script" ]]; then
                echo "🪝 Running $hook_type hook: $(basename "$hook_script")"
                "$hook_script" "$backup_path"
            fi
        done
    fi
}

# Update backup metadata
update_backup_metadata() {
    local backup_name="$1"
    local backup_type="$2"
    local description="$3"
    local backup_path="$4"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  jq not available - skipping metadata update"
        return
    fi
    
    local backup_entry=$(cat << EOF
{
  "name": "$backup_name",
  "type": "$backup_type",
  "description": "$description",
  "path": "$backup_path",
  "created": "$(date -Iseconds)",
  "size": $(get_backup_size "$backup_path" | sed 's/[^0-9]//g')
}
EOF
)
    
    # Add backup to metadata
    jq ".backups = [${backup_entry}] + .backups" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
    mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
}

# Remove backup from metadata
remove_backup_from_metadata() {
    local backup_name="$1"
    
    if ! command -v jq >/dev/null 2>&1; then
        return
    fi
    
    jq ".backups = (.backups | map(select(.name != \"$backup_name\")))" "$BACKUP_METADATA_FILE" > "${BACKUP_METADATA_FILE}.tmp"
    mv "${BACKUP_METADATA_FILE}.tmp" "$BACKUP_METADATA_FILE"
}

# Update manifest stats
update_manifest_stats() {
    local backup_path="$1"
    local files_count="$2"
    local total_size="$3"
    local duration="$4"
    
    local manifest_file="$backup_path/MANIFEST.json"
    
    if command -v jq >/dev/null 2>&1; then
        jq ".metadata.total_files = $files_count | .metadata.total_size = $total_size | .metadata.duration = $duration" "$manifest_file" > "${manifest_file}.tmp"
        mv "${manifest_file}.tmp" "$manifest_file"
    fi
}

# Get backup size
get_backup_size() {
    local backup_path="$1"
    
    if [[ -d "$backup_path" ]]; then
        du -sh "$backup_path" 2>/dev/null | cut -f1 || echo "unknown"
    else
        ls -lh "$backup_path" 2>/dev/null | awk '{print $5}' || echo "unknown"
    fi
}

# Format size in human readable format
format_size() {
    local size="$1"
    
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec --suffix=B "$size"
    else
        # Fallback
        if [[ $size -lt 1024 ]]; then
            echo "${size}B"
        elif [[ $size -lt 1048576 ]]; then
            echo "$((size / 1024))KB"
        elif [[ $size -lt 1073741824 ]]; then
            echo "$((size / 1048576))MB"
        else
            echo "$((size / 1073741824))GB"
        fi
    fi
}

# Clean up old backups based on retention policy
cleanup_old_backups() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  jq not available - skipping automatic cleanup"
        return
    fi
    
    local daily_retention=$(jq -r '.config.retention.daily' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 7)
    local weekly_retention=$(jq -r '.config.retention.weekly' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 4)
    local monthly_retention=$(jq -r '.config.retention.monthly' "$BACKUP_METADATA_FILE" 2>/dev/null || echo 12)
    
    echo "🧹 Cleaning up old backups (retention: ${daily_retention}d/${weekly_retention}w/${monthly_retention}m)"
    
    # Implementation of retention policy cleanup would go here
    # This is a complex algorithm that categorizes backups by age and keeps
    # appropriate numbers based on the retention policy
}

# Ask yes/no question
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

# Backup CLI interface
backup_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "create"|"backup")
            backup_create "$@"
            ;;
        "restore")
            backup_restore "$@"
            ;;
        "list"|"ls")
            backup_list "$@"
            ;;
        "info"|"show")
            show_backup_info "$@"
            ;;
        "delete"|"remove"|"rm")
            backup_delete "$@"
            ;;
        "init")
            init_backup_system
            echo "✅ Backup system initialized"
            ;;
        "help"|*)
            cat << 'EOF'
💾 Backup and Restore System

USAGE:
    backup <command> [options]

COMMANDS:
    create [type] [name] [description]  Create new backup
      full                              Full backup (default)
      incremental                       Incremental backup
      differential                      Differential backup
      config-only                       Configuration files only
      
    restore <name> [target] [type]      Restore from backup
      full                              Full restore (default)
      selective                         Interactive selection
      config-only                       Configuration only
      
    list [filter]                       List backups
      all                               All backups (default)
      full                              Full backups only
      incremental                       Incremental backups only
      differential                      Differential backups only
      
    info <name>                         Show backup information
    delete <name>                       Delete backup
    init                                Initialize backup system

OPTIONS:
    --force                             Skip confirmations
    --no-backup                         Skip creating restore point
    --overwrite                         Overwrite existing files
    --compress <type>                   Compression (gzip|bzip2|xz|zip|none)

EXAMPLES:
    backup create full                  # Create full backup
    backup create incremental my-inc    # Create incremental backup
    backup restore backup-20231201     # Restore backup
    backup list                         # List all backups
    backup info backup-20231201         # Show backup details
    backup delete old-backup --force    # Delete backup

For more information: https://docs.dotfiles.dev/backup
EOF
            ;;
    esac
}

# Initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_backup_system
fi

# Export functions
export -f backup_cli backup_create backup_restore backup_list backup_delete
export -f show_backup_info init_backup_system ask_yes_no