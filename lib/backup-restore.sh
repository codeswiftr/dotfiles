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

# Backup compression (respect environment overrides)
BACKUP_COMPRESSION="${BACKUP_COMPRESSION:-gzip}"
BACKUP_COMPRESSION_LEVEL="${BACKUP_COMPRESSION_LEVEL:-6}"

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
    local include_paths=()
    if [[ $# -ge 4 ]]; then
        include_paths=("${@:4}")
    fi
    
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
            if [[ ${#include_paths[@]} -gt 0 ]]; then
                create_full_backup "$backup_path" "${include_paths[@]}"
            else
                create_full_backup "$backup_path"
            fi
            ;;
        "$BACKUP_TYPE_INCREMENTAL")
            if [[ ${#include_paths[@]} -gt 0 ]]; then
                create_incremental_backup "$backup_path" "${include_paths[@]}"
            else
                create_incremental_backup "$backup_path"
            fi
            ;;
        "$BACKUP_TYPE_DIFFERENTIAL")
            if [[ ${#include_paths[@]} -gt 0 ]]; then
                backup_differential "$backup_path" "${include_paths[@]}"
            else
                backup_differential "$backup_path"
            fi
            ;;
        "$BACKUP_TYPE_CONFIG_ONLY")
            if [[ ${#include_paths[@]} -gt 0 ]]; then
                create_config_backup "$backup_path" "${include_paths[@]}"
            else
                create_config_backup "$backup_path"
            fi
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
        backup_compression "$backup_path" "$BACKUP_COMPRESSION" "$BACKUP_COMPRESSION_LEVEL"
    fi
    
    # Update backup metadata
    update_backup_metadata "$backup_name" "$backup_type" "$description" "$backup_path"
    
    # Clean up old backups based on retention policy
    cleanup_old_backups || true
    
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

# Create full backup - Epic 4.1 Core Implementation
create_full_backup() {
    local backup_path="$1"
    shift || true
    local include_paths=()
    if [[ $# -gt 0 ]]; then
        include_paths=("$@")
    fi
    
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
    local checksum_file="$backup_path/checksums.sha256"
    
    # Create backup structure
    mkdir -p "$backup_path/data"
    
    # Generate checksums for integrity verification
    echo "🔍 Generating checksums for integrity verification..."
    > "$checksum_file"  # Clear checksum file
    
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
            
            # Copy with exclusions and verify integrity
            if [[ -d "$path" ]]; then
                # Use rsync for directory synchronization with checksum verification
                rsync -a \
                    --exclude-from="$BACKUP_EXCLUDE_FILE" \
                    --stats \
                    --checksum \
                    "$path/" "$backup_target/" 2>&1 | \
                    tee "$backup_path/rsync-${rel_path//[^a-zA-Z0-9]/_}.log"
                
                # Generate checksums for all files in the directory
                if command -v find >/dev/null 2>&1 && command -v shasum >/dev/null 2>&1; then
                    find "$backup_target" -type f -exec shasum -a 256 {} \; | \
                        sed "s|$backup_path/data/||" >> "$checksum_file"
                fi
            else
                # Copy individual file and create checksum
                cp "$path" "$backup_target"
                if command -v shasum >/dev/null 2>&1; then
                    shasum -a 256 "$backup_target" | sed "s|$backup_path/data/||" >> "$checksum_file"
                fi
            fi
            
            # Count files and calculate size
            local path_files=$(find "$backup_target" -type f 2>/dev/null | wc -l | tr -d ' ')
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
    
    # Create backup index for fast incremental operations
    create_backup_index "$backup_path"
    
    # Update manifest with complete metadata
    update_manifest_stats "$backup_path" "$files_backed_up" "$total_size" "$duration"
    update_manifest_contents "$backup_path" "${include_paths[@]}"
    
    echo "  📊 Total files: $files_backed_up"
    echo "  📊 Total size: $(format_size "$total_size")"
    echo "  ⏱️  Duration: ${duration}s"
    echo "  🔍 Integrity checksums: $(wc -l < "$checksum_file" | tr -d ' ') files verified"
}

# Full backup (backward compatibility wrapper)
backup_full() {
    create_full_backup "$@"
}

# Create incremental backup - Epic 4.1 Core Implementation
create_incremental_backup() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    
    echo "📦 Creating incremental backup..."
    
    # Find the most recent full or incremental backup
    local base_backup
    base_backup=$(find_latest_backup "$BACKUP_TYPE_FULL" "$BACKUP_TYPE_INCREMENTAL")
    
    if [[ -z "$base_backup" ]]; then
        echo "⚠️  No base backup found, creating full backup instead"
        if [[ ${#include_paths[@]} -gt 0 ]]; then
            create_full_backup "$backup_path" "${include_paths[@]}"
        else
            create_full_backup "$backup_path"
        fi
        return
    fi
    
    echo "  📚 Base backup: $base_backup"
    
    # Load base backup index for efficient comparison
    local base_backup_path
    base_backup_path=$(find_backup "$base_backup")
    local base_index_file="$base_backup_path/backup-index.txt"
    
    if [[ ! -f "$base_index_file" ]]; then
        echo "  ⚠️  Base backup index not found, using timestamp comparison"
        # Use the base index file as a stable reference for -newer
        if [[ ${#include_paths[@]} -gt 0 ]]; then
            backup_changes_since "$backup_path" "$base_index_file" "${include_paths[@]}"
        else
            backup_changes_since "$backup_path" "$base_index_file"
        fi
        return
    fi
    
    # Perform efficient incremental backup using file index comparison
    if [[ ${#include_paths[@]} -gt 0 ]]; then
        perform_incremental_backup "$backup_path" "$base_index_file" "${include_paths[@]}"
    else
        perform_incremental_backup "$backup_path" "$base_index_file"
    fi
}

# Incremental backup (backward compatibility wrapper) 
backup_incremental() {
    create_incremental_backup "$@"
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

# Create config-only backup - Epic 4.1 Core Implementation
create_config_backup() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    
    echo "📦 Creating configuration-only backup..."
    
    # Enhanced config paths if none specified - comprehensive coverage
    if [[ ${#include_paths[@]} -eq 0 ]]; then
        include_paths=(
            # Core dotfiles configuration
            "$DOTFILES_DIR/config"
            "$HOME/.config/dotfiles"
            
            # Shell configurations
            "$HOME/.zshrc"
            "$HOME/.bashrc"
            "$HOME/.profile"
            "$HOME/.bash_profile"
            
            # Git configuration
            "$HOME/.gitconfig"
            "$HOME/.gitignore_global"
            
            # SSH configuration
            "$HOME/.ssh/config"
            "$HOME/.ssh/known_hosts"
            
            # Development tool configs
            "$HOME/.config/nvim"
            "$HOME/.tmux.conf"
            "$HOME/.vimrc"
            
            # Package manager configs
            "$HOME/.npmrc"
            "$HOME/.pip/pip.conf"
            "$HOME/.cargo/config.toml"
            
            # Application configs (if they exist)
            "$HOME/.config/git"
            "$HOME/.config/gh"
            "$HOME/.config/code-server"
        )
    fi
    
    # Filter to only existing paths to avoid errors
    local existing_paths=()
    for path in "${include_paths[@]}"; do
        if [[ -e "$path" ]]; then
            existing_paths+=("$path")
        fi
    done
    
    echo "  📝 Backing up ${#existing_paths[@]} configuration items..."
    
    # Use full backup implementation with config-specific optimizations
    create_full_backup "$backup_path" "${existing_paths[@]}"
}

# Config-only backup (backward compatibility wrapper)
backup_config_only() {
    create_config_backup "$@"
}

# Backup changes since timestamp
backup_changes_since() {
    local backup_path="$1"
    local since_ref="$2"   # file path (preferred) or timestamp
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
            
            # Find files newer than reference (file preferred)
            local changed_count=0
            if [[ -f "$since_ref" ]]; then
                while IFS= read -r file; do
                    # Exclusion check using helper (ignores comments/blank lines)
                    if is_path_excluded "$file"; then
                        continue
                    fi
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
                    changed_count=$((changed_count + 1))
                done < <(find "$path" -type f -newer "$since_ref" 2>/dev/null)
            fi
            
            if [[ $changed_count -eq 0 ]]; then
                echo "    No changes found"
            else
                echo "    Found $changed_count changed files"
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
            restore_full_system "$backup_path" "$target_path" "$options"
            ;;
        "selective")
            restore_selective "$backup_path" "$target_path" "$options"
            ;;
        "config-only")
            restore_selective_config "$backup_path" "$target_path" "$options"
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

# Restore full system - Epic 4.2 Core Implementation
restore_full_system() {
    local backup_path="$1"
    local target_path="${2:-$HOME}"
    local options="$3"
    
    echo "🔄 Performing full system restore..."
    
    local data_dir="$backup_path/data"
    
    if [[ ! -d "$data_dir" ]]; then
        echo "❌ Backup data directory not found"
        return 1
    fi
    
    # Validate backup before restoration
    if ! backup_validation "$backup_path" "quick"; then
        echo "❌ Backup validation failed, aborting restore"
        return 1
    fi
    
    local files_restored=0
    local total_size=0
    local start_time=$(date +%s)
    
    # Restore each path with enhanced error handling and validation
    for backup_item in "$data_dir"/*; do
        if [[ -e "$backup_item" ]]; then
            local item_name=$(basename "$backup_item")
            
            # Determine target path with cross-platform support
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
            
            # Create parent directory with proper permissions
            mkdir -p "$(dirname "$restore_target")"
            
            # Backup existing files if they exist (unless --no-backup specified)
            if [[ "$options" != *"--no-backup"* ]] && [[ -e "$restore_target" ]]; then
                local backup_existing="$restore_target.pre-restore-$(date +%Y%m%d-%H%M%S)"
                echo "    💾 Backing up existing: $backup_existing"
                cp -r "$restore_target" "$backup_existing" 2>/dev/null || true
            fi
            
            # Restore with appropriate options and verification
            local restore_success=false
            
            if [[ "$options" == *"--overwrite"* ]]; then
                if [[ -d "$backup_item" ]]; then
                    rsync -av --progress "$backup_item/" "$restore_target/"
                else
                    cp "$backup_item" "$restore_target"
                fi
                restore_success=true
            else
                if [[ -d "$backup_item" ]]; then
                    rsync -av --ignore-existing --progress "$backup_item/" "$restore_target/"
                else
                    if [[ ! -e "$restore_target" ]]; then
                        cp "$backup_item" "$restore_target"
                    else
                        echo "    ⚠️  Skipping existing file: $restore_target"
                    fi
                fi
                restore_success=true
            fi
            
            if [[ "$restore_success" == "true" ]]; then
                # Count restored files and calculate size
                local item_files=$(find "$restore_target" -type f 2>/dev/null | wc -l | tr -d ' ')
                local item_size=$(du -sb "$restore_target" 2>/dev/null | cut -f1 || echo 0)
                
                files_restored=$((files_restored + item_files))
                total_size=$((total_size + item_size))
                
                echo "    ✅ Restored: $item_files files, $(format_size "$item_size")"
            else
                echo "    ❌ Failed to restore: $item_name"
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "📊 Restore summary:"
    echo "  Files restored: $files_restored"
    echo "  Total size: $(format_size "$total_size")"
    echo "  Duration: ${duration}s"
    
    # Set appropriate permissions for common config files
    fix_restored_permissions "$target_path"
    
    echo "✅ Full system restore completed successfully"
}

# Full restore (backward compatibility wrapper)
restore_full() {
    restore_full_system "$@"
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

# Restore selective configuration - Epic 4.2 Core Implementation
restore_selective_config() {
    local backup_path="$1"
    local target_path="${2:-$HOME}"
    local options="$3"
    local config_filter="${4:-all}"
    
    echo "🔄 Performing selective configuration restore..."
    
    local data_dir="$backup_path/data"
    
    if [[ ! -d "$data_dir" ]]; then
        echo "❌ Backup data directory not found"
        return 1
    fi
    
    # Enhanced configuration file detection and categorization
    local shell_configs=("*zshrc*" "*bashrc*" "*profile*" "*bash_profile*")
    local git_configs=("*gitconfig*" "*gitignore*")
    local ssh_configs=("*ssh*")
    local editor_configs=("*nvim*" "*vim*" "*tmux*")
    local app_configs=("*config*" "*dotfiles*")
    
    local config_categories=()
    case "$config_filter" in
        "shell")
            config_categories=("${shell_configs[@]}")
            ;;
        "git")
            config_categories=("${git_configs[@]}")
            ;;
        "ssh")
            config_categories=("${ssh_configs[@]}")
            ;;
        "editor")
            config_categories=("${editor_configs[@]}")
            ;;
        "app")
            config_categories=("${app_configs[@]}")
            ;;
        "all")
            config_categories=("${shell_configs[@]}" "${git_configs[@]}" "${ssh_configs[@]}" "${editor_configs[@]}" "${app_configs[@]}")
            ;;
        *)
            echo "❌ Invalid config filter: $config_filter"
            echo "Valid filters: shell, git, ssh, editor, app, all"
            return 1
            ;;
    esac
    
    local files_restored=0
    
    for pattern in "${config_categories[@]}"; do
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
                
                echo "  📝 Restoring config: $item_name -> $restore_target"
                
                # Backup existing config if it exists
                if [[ "$options" != *"--no-backup"* ]] && [[ -e "$restore_target" ]]; then
                    local backup_existing="$restore_target.backup-$(date +%Y%m%d-%H%M%S)"
                    cp -r "$restore_target" "$backup_existing" 2>/dev/null
                    echo "    💾 Existing config backed up to: $backup_existing"
                fi
                
                mkdir -p "$(dirname "$restore_target")"
                
                if [[ -d "$backup_item" ]]; then
                    rsync -av "$backup_item/" "$restore_target/"
                else
                    cp "$backup_item" "$restore_target"
                fi
                
                ((files_restored++))
                echo "    ✅ Configuration restored successfully"
            fi
        done
    done
    
    echo "📊 Selective configuration restore completed: $files_restored items restored"
    
    # Fix permissions for sensitive config files
    fix_config_permissions "$target_path"
}

# Config-only restore (backward compatibility wrapper)
restore_config_only() {
    restore_selective_config "$@"
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

# Determine if a given path should be excluded based on exclude list
# - Ignores blank lines and comment lines (starting with '#') to mirror rsync behavior
# - Uses fixed-string matching for simple, fast checks
is_path_excluded() {
    local path_to_check="$1"
    if [[ -z "$path_to_check" ]]; then
        return 1
    fi
    if [[ -f "$BACKUP_EXCLUDE_FILE" ]]; then
        # Filter exclude patterns: drop comments and empty lines, normalize line endings
        if grep -F -q -f <(sed -e 's/\r$//' -e '/^\s*#/d' -e '/^\s*$/d' "$BACKUP_EXCLUDE_FILE") -- <<< "$path_to_check" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
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
        tmpfile=$(mktemp)
        jq ".metadata.total_files = $files_count | .metadata.total_size = $total_size | .metadata.duration = $duration" "$manifest_file" > "$tmpfile" || true
        [[ -s "$tmpfile" ]] && mv "$tmpfile" "$manifest_file" || rm -f "$tmpfile"
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

# Create backup index for efficient incremental operations
create_backup_index() {
    local backup_path="$1"
    local index_file="$backup_path/backup-index.txt"
    
    echo "📝 Creating backup index for incremental operations..."
    
    # Generate file index with metadata (path, size, mtime, checksum)
    > "$index_file"  # Clear index file
    
    if [[ -d "$backup_path/data" ]]; then
        find "$backup_path/data" -type f -exec stat -c "%n|%s|%Y" {} \; 2>/dev/null | \
            while IFS='|' read -r filepath filesize mtime; do
                # Calculate relative path from backup root
                local rel_path="${filepath#$backup_path/data/}"
                
                # Get file checksum for integrity
                local checksum=""
                if command -v shasum >/dev/null 2>&1; then
                    checksum=$(shasum -a 256 "$filepath" 2>/dev/null | cut -d' ' -f1)
                fi
                
                echo "$rel_path|$filesize|$mtime|$checksum" >> "$index_file"
            done
        
        # Fallback for systems without stat -c (like macOS)
        if [[ ! -s "$index_file" ]] && [[ -d "$backup_path/data" ]]; then
            find "$backup_path/data" -type f -exec ls -la {} \; | \
                while read -r perms links owner group size month day time filepath; do
                    local rel_path="${filepath#$backup_path/data/}"
                    local mtime=$(date -r "$filepath" "+%s" 2>/dev/null || echo "0")
                    local checksum=""
                    if command -v shasum >/dev/null 2>&1; then
                        checksum=$(shasum -a 256 "$filepath" 2>/dev/null | cut -d' ' -f1)
                    fi
                    echo "$rel_path|$size|$mtime|$checksum" >> "$index_file"
                done
        fi
        
        local index_count=$(wc -l < "$index_file" | tr -d ' ')
        echo "  📋 Indexed $index_count files for future incremental backups"
    fi
}

# Perform efficient incremental backup using file index comparison
perform_incremental_backup() {
    local backup_path="$1"
    local base_index_file="$2"
    shift 2
    local include_paths=("$@")
    
    echo "  🔍 Comparing files against base backup index..."
    
    # Default paths if none specified
        if [[ ${#include_paths[@]} -eq 0 ]]; then
        include_paths=(
            "$DOTFILES_DIR"
            "$HOME/.config"
            "$HOME/.local/share/dotfiles"
        )
    fi
    
    local files_backed_up=0
    local total_size=0
    local start_time=$(date +%s)
    local checksum_file="$backup_path/checksums.sha256"
    
    mkdir -p "$backup_path/data"
    > "$checksum_file"  # Clear checksum file
    
    # Create temporary current index
    local current_index=$(mktemp)
    trap "rm -f '$current_index'" EXIT
    
    # Build current state index
    for path in "${include_paths[@]}"; do
        if [[ -e "$path" ]]; then
            find "$path" -type f ! -path "*/\.git/objects/*" 2>/dev/null | \
                while read -r filepath; do
                    if is_path_excluded "$filepath"; then
                        continue
                    fi
                    local filesize=$(stat -c"%s" "$filepath" 2>/dev/null || stat -f"%z" "$filepath" 2>/dev/null || echo "0")
                    local mtime=$(stat -c"%Y" "$filepath" 2>/dev/null || date -r "$filepath" "+%s" 2>/dev/null || echo "0")
                    local checksum=""
                    if command -v shasum >/dev/null 2>&1; then
                        checksum=$(shasum -a 256 "$filepath" 2>/dev/null | cut -d' ' -f1)
                    fi
                    echo "$filepath|$filesize|$mtime|$checksum" >> "$current_index"
                done
        fi
    done
    
    # Compare against base index and copy changed files
    while IFS='|' read -r current_file current_size current_mtime current_checksum; do
        local needs_backup=true
        
        # Check if file exists in base backup
        # Compute relative path key same as create_backup_index
        local rel_key
        if [[ "$current_file" == "$HOME"* ]]; then
            rel_key="home${current_file#$HOME}"
        elif [[ "$current_file" == "$DOTFILES_DIR"* ]]; then
            rel_key="dotfiles${current_file#$DOTFILES_DIR}"
        else
            rel_key=$(echo "$current_file" | sed 's|^/||' | tr '/' '_')
        fi
        if grep -Fq "^$rel_key|" "$base_index_file" 2>/dev/null; then
            # File exists in base backup, check if it's changed
            local base_entry
            base_entry=$(grep -F "^$rel_key|" "$base_index_file" | head -1)
            
            if [[ -n "$base_entry" ]]; then
                local base_size=$(echo "$base_entry" | cut -d'|' -f2)
                local base_mtime=$(echo "$base_entry" | cut -d'|' -f3)
                local base_checksum=$(echo "$base_entry" | cut -d'|' -f4)
                
                # Skip if file hasn't changed (same size, mtime, and checksum)
                if [[ "$current_size" == "$base_size" ]] && \
                   [[ "$current_mtime" == "$base_mtime" ]] && \
                   [[ -n "$current_checksum" && "$current_checksum" == "$base_checksum" ]]; then
                    needs_backup=false
                fi
            fi
        fi
        
        if [[ "$needs_backup" == "true" ]]; then
            echo "  📄 Changed: $(basename "$current_file")"
            
            # Determine backup path structure
            local rel_path
            if [[ "$current_file" == "$HOME"* ]]; then
                rel_path="home${current_file#$HOME}"
            elif [[ "$current_file" == "$DOTFILES_DIR"* ]]; then
                rel_path="dotfiles${current_file#$DOTFILES_DIR}"
            else
                rel_path="$(echo "$current_file" | sed 's|^/||' | tr '/' '_')"
            fi
            
            local backup_target="$backup_path/data/$rel_path"
            mkdir -p "$(dirname "$backup_target")"
            
            # Copy file and record checksum
            cp "$current_file" "$backup_target"
            echo "$rel_path|$current_checksum" >> "$checksum_file"
            
            files_backed_up=$((files_backed_up + 1))
            total_size=$((total_size + current_size))
        fi
        
    done < "$current_index"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Create new backup index
    create_backup_index "$backup_path"
    
    # Update manifest
    update_manifest_stats "$backup_path" "$files_backed_up" "$total_size" "$duration"
    update_manifest_contents "$backup_path" "${include_paths[@]}"
    
    echo "  📊 Changed files: $files_backed_up"
    echo "  📊 Total size: $(format_size "$total_size")"
    echo "  ⏱️  Duration: ${duration}s"
}

# Update manifest contents
update_manifest_contents() {
    local backup_path="$1"
    shift
    local include_paths=("$@")
    local manifest_file="$backup_path/MANIFEST.json"
    
    if command -v jq >/dev/null 2>&1 && [[ -f "$manifest_file" ]]; then
        local tmpfile
        tmpfile=$(mktemp)
        local contents_json
        if [[ ${#include_paths[@]} -gt 0 ]]; then
            # Safely build JSON array of include paths
            contents_json=$(printf '%s\n' "${include_paths[@]}" | jq -R . | jq -s .)
        else
            contents_json='[]'
        fi
        # Only attempt jq write if we built valid JSON
        if [[ -n "$contents_json" ]]; then
            jq ".contents = $contents_json" "$manifest_file" > "$tmpfile" 2>/dev/null || true
        fi
        if [[ -s "$tmpfile" ]]; then
            mv "$tmpfile" "$manifest_file"
        else
            rm -f "$tmpfile"
        fi
    fi
}

# Backup validation - Epic 4.1 Core Implementation
backup_validation() {
    local backup_path="$1"
    local validation_type="${2:-full}"  # full, quick, checksum
    
    echo "🔍 Validating backup: $(basename "$backup_path")"
    
    case "$validation_type" in
        "quick")
            validate_backup_quick "$backup_path"
            ;;
        "checksum")
            validate_backup_checksums "$backup_path"
            ;;
        "full")
            validate_backup_full "$backup_path"
            ;;
        *)
            echo "❌ Invalid validation type: $validation_type"
            return 1
            ;;
    esac
}

# Quick backup validation
validate_backup_quick() {
    local backup_path="$1"
    
    # Check basic structure
    if [[ ! -d "$backup_path" ]]; then
        echo "❌ Backup directory not found"
        return 1
    fi
    
    if [[ ! -f "$backup_path/MANIFEST.json" ]]; then
        echo "❌ Backup manifest missing"
        return 1
    fi
    
    if [[ ! -d "$backup_path/data" ]]; then
        echo "❌ Backup data directory missing"
        return 1
    fi
    
    echo "✅ Basic backup structure valid"
    return 0
}

# Checksum-based backup validation
validate_backup_checksums() {
    local backup_path="$1"
    local checksum_file="$backup_path/checksums.sha256"
    
    if ! validate_backup_quick "$backup_path"; then
        return 1
    fi
    
    if [[ ! -f "$checksum_file" ]]; then
        echo "⚠️  No checksum file found, skipping integrity verification"
        return 0
    fi
    
    echo "  🔍 Verifying file checksums..."
    
    local total_files=0
    local verified_files=0
    local failed_files=()
    
    while IFS='|' read -r rel_path expected_checksum || [[ -n "$rel_path" ]]; do
        [[ -z "$rel_path" ]] && continue
        
        local full_path="$backup_path/data/$rel_path"
        ((total_files++))
        
        if [[ -f "$full_path" ]]; then
            if command -v shasum >/dev/null 2>&1; then
                local actual_checksum
                actual_checksum=$(shasum -a 256 "$full_path" 2>/dev/null | cut -d' ' -f1)
                
                if [[ "$actual_checksum" == "$expected_checksum" ]]; then
                    ((verified_files++))
                else
                    failed_files+=("$rel_path")
                fi
            else
                echo "  ⚠️  shasum not available, skipping checksum verification"
                ((verified_files++))
            fi
        else
            failed_files+=("$rel_path (missing)")
        fi
    done < "$checksum_file"
    
    if [[ ${#failed_files[@]} -eq 0 ]]; then
        echo "  ✅ All $verified_files/$total_files files verified successfully"
        return 0
    else
        echo "  ❌ $((total_files - verified_files))/$total_files files failed verification:"
        printf '    - %s\n' "${failed_files[@]}"
        return 1
    fi
}

# Full backup validation
validate_backup_full() {
    local backup_path="$1"
    
    echo "  🔍 Performing full backup validation..."
    
    # Run quick validation first
    if ! validate_backup_quick "$backup_path"; then
        return 1
    fi
    
    # Validate manifest JSON
    local manifest_file="$backup_path/MANIFEST.json"
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$manifest_file" >/dev/null 2>&1; then
            echo "❌ Invalid manifest JSON format"
            return 1
        fi
        echo "  ✅ Manifest JSON format valid"
    fi
    
    # Validate checksums if available
    validate_backup_checksums "$backup_path"
    local checksum_result=$?
    
    # Validate file count consistency
    if [[ -f "$manifest_file" ]] && command -v jq >/dev/null 2>&1; then
        local manifest_file_count=$(jq -r '.metadata.total_files // 0' "$manifest_file")
        local actual_file_count=$(find "$backup_path/data" -type f 2>/dev/null | wc -l | tr -d ' ')
        
        if [[ "$manifest_file_count" == "$actual_file_count" ]]; then
            echo "  ✅ File count matches manifest ($actual_file_count files)"
        else
            echo "  ⚠️  File count mismatch: manifest=$manifest_file_count, actual=$actual_file_count"
        fi
    fi
    
    if [[ $checksum_result -eq 0 ]]; then
        echo "✅ Full backup validation passed"
        return 0
    else
        echo "⚠️  Backup validation completed with warnings"
        return 1
    fi
}

# Backup compression - Epic 4.1 Core Implementation  
backup_compression() {
    local backup_path="$1"
    local compression_type="${2:-$BACKUP_COMPRESSION}"
    local compression_level="${3:-$BACKUP_COMPRESSION_LEVEL}"
    
    if [[ "$compression_type" == "none" ]]; then
        echo "  ℹ️  Compression disabled"
        return 0
    fi
    
    echo "🗜️  Compressing backup with $compression_type (level $compression_level)..."
    
    local start_time=$(date +%s)
    local original_size=$(du -sb "$backup_path" 2>/dev/null | cut -f1 || echo 0)
    
    case "$compression_type" in
        "gzip")
            cd "$(dirname "$backup_path")" || return 1
            tar --use-compress-program="gzip -$compression_level" -cf "${backup_path}.tar.gz" "$(basename "$backup_path")"
            local compressed_file="${backup_path}.tar.gz"
            ;;
        "bzip2")
            cd "$(dirname "$backup_path")" || return 1
            tar --use-compress-program="bzip2 -$compression_level" -cf "${backup_path}.tar.bz2" "$(basename "$backup_path")"
            local compressed_file="${backup_path}.tar.bz2"
            ;;
        "xz")
            cd "$(dirname "$backup_path")" || return 1
            tar --use-compress-program="xz -$compression_level" -cf "${backup_path}.tar.xz" "$(basename "$backup_path")"
            local compressed_file="${backup_path}.tar.xz"
            ;;
        "zip")
            cd "$(dirname "$backup_path")" || return 1
            zip -r$compression_level "${backup_path}.zip" "$(basename "$backup_path")" >/dev/null
            local compressed_file="${backup_path}.zip"
            ;;
        *)
            echo "❌ Unsupported compression type: $compression_type"
            return 1
            ;;
    esac
    
    if [[ -f "$compressed_file" ]]; then
        local compressed_size=$(du -sb "$compressed_file" 2>/dev/null | cut -f1 || echo 0)
        local compression_ratio=0
        
        if [[ $original_size -gt 0 ]]; then
            compression_ratio=$(( (original_size - compressed_size) * 100 / original_size ))
        fi
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo "  ✅ Compression completed:"
        echo "    Original size: $(format_size "$original_size")"
        echo "    Compressed size: $(format_size "$compressed_size")"
        echo "    Compression ratio: ${compression_ratio}%"
        echo "    Duration: ${duration}s"
        
        # Remove original directory after successful compression
        rm -rf "$backup_path"
        
        return 0
    else
        echo "❌ Compression failed"
        return 1
    fi
}

# Export functions
export -f backup_cli backup_create backup_restore backup_list backup_delete
export -f show_backup_info init_backup_system ask_yes_no
# Restore cross-platform - Epic 4.2 Core Implementation
restore_cross_platform() {
    local backup_path="$1"
    local source_platform="$2"  # linux, darwin, windows
    local target_platform="${3:-$(uname -s | tr '[:upper:]' '[:lower:]')}" 
    local target_path="${4:-$HOME}"
    local options="$5"
    
    echo "🔄 Performing cross-platform restore: $source_platform -> $target_platform"
    
    if [[ "$source_platform" == "$target_platform" ]]; then
        echo "  ℹ️  Same platform detected, performing standard restore"
        restore_full_system "$backup_path" "$target_path" "$options"
        return
    fi
    
    # Platform-specific path mappings and adaptations
    case "$target_platform" in
        "darwin")
            adapt_backup_for_macos "$backup_path" "$target_path" "$options"
            ;;
        "linux")
            adapt_backup_for_linux "$backup_path" "$target_path" "$options"
            ;;
        *)
            echo "⚠️  Unknown target platform: $target_platform, attempting generic restore"
            restore_full_system "$backup_path" "$target_path" "$options"
            ;;
    esac
    
    echo "✅ Cross-platform restore completed"
}

# Adapt backup for macOS
adapt_backup_for_macos() {
    local backup_path="$1"
    local target_path="$2"
    local options="$3"
    
    echo "  🍎 Adapting restore for macOS..."
    
    # Perform standard restore first
    restore_full_system "$backup_path" "$target_path" "$options"
    
    # macOS-specific adaptations
    # Fix Homebrew paths if needed
    if [[ -d "$target_path/.local/share/dotfiles" ]]; then
        echo "  🍺 Updating Homebrew configuration for macOS"
        # Update package manager references from Linux to Homebrew
        find "$target_path/.local/share/dotfiles" -name "*.sh" -exec sed -i '' 's|apt-get|brew|g' {} \; 2>/dev/null || true
        find "$target_path/.local/share/dotfiles" -name "*.sh" -exec sed -i '' 's|yum|brew|g' {} \; 2>/dev/null || true
    fi
    
    # Set macOS-specific permissions
    fix_macos_permissions "$target_path"
}

# Adapt backup for Linux
adapt_backup_for_linux() {
    local backup_path="$1"
    local target_path="$2"
    local options="$3"
    
    echo "  🐧 Adapting restore for Linux..."
    
    # Perform standard restore first
    restore_full_system "$backup_path" "$target_path" "$options"
    
    # Linux-specific adaptations
    # Fix package manager references if restoring from macOS
    if [[ -d "$target_path/.local/share/dotfiles" ]]; then
        echo "  📦 Updating package manager configuration for Linux"
        # Detect Linux distribution and adapt accordingly
        if command -v apt-get >/dev/null 2>&1; then
            find "$target_path/.local/share/dotfiles" -name "*.sh" -exec sed -i 's|brew install|apt-get install|g' {} \; 2>/dev/null || true
        elif command -v yum >/dev/null 2>&1; then
            find "$target_path/.local/share/dotfiles" -name "*.sh" -exec sed -i 's|brew install|yum install|g' {} \; 2>/dev/null || true
        elif command -v pacman >/dev/null 2>&1; then
            find "$target_path/.local/share/dotfiles" -name "*.sh" -exec sed -i 's|brew install|pacman -S|g' {} \; 2>/dev/null || true
        fi
    fi
    
    # Set Linux-specific permissions
    fix_linux_permissions "$target_path"
}

# Rollback to backup - Epic 4.2 Core Implementation
rollback_to_backup() {
    local backup_name="$1"
    local rollback_scope="${2:-selective}"  # full, selective, config-only
    local options="$3"
    
    if [[ -z "$backup_name" ]]; then
        echo "❌ Backup name required for rollback"
        echo "Available backups:"
        backup_list | head -10
        return 1
    fi
    
    echo "⏪ Rolling back to backup: $backup_name"
    
    # Find and validate backup
    local backup_path
    backup_path=$(find_backup "$backup_name")
    
    if [[ -z "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_name"
        return 1
    fi
    
    # Decompress if needed
    if [[ ! -d "$backup_path" ]]; then
        echo "📦 Decompressing backup for rollback..."
        backup_path=$(decompress_backup "$backup_path")
        if [[ -z "$backup_path" ]]; then
            echo "❌ Failed to decompress backup"
            return 1
        fi
    fi
    
    # Validate backup integrity before rollback
    if ! backup_validation "$backup_path" "full"; then
        echo "❌ Backup validation failed, rollback aborted for safety"
        return 1
    fi
    
    # Show rollback information
    echo "Rollback Details:"
    show_backup_info "$backup_name" | grep -E "(Type|Created|Platform|Files|Size)"
    echo ""
    
    # Confirm rollback unless forced
    if [[ "$options" != *"--force"* ]]; then
        if ! ask_yes_no "Proceed with rollback? This will modify your current configuration"; then
            echo "❌ Rollback cancelled"
            return 1
        fi
    fi
    
    # Create pre-rollback backup unless disabled
    if [[ "$options" != *"--no-backup"* ]]; then
        echo "💾 Creating pre-rollback backup..."
        local pre_rollback_name="pre-rollback-$(date +%Y%m%d-%H%M%S)"
        backup_create "config-only" "$pre_rollback_name" "Pre-rollback safety backup"
        echo "✅ Pre-rollback backup created: $pre_rollback_name"
    fi
    
    # Perform rollback based on scope
    case "$rollback_scope" in
        "full")
            restore_full_system "$backup_path" "$HOME" "$options --overwrite"
            ;;
        "selective")
            restore_selective "$backup_path" "$HOME" "$options --overwrite"
            ;;
        "config-only")
            restore_selective_config "$backup_path" "$HOME" "$options --overwrite"
            ;;
        *)
            echo "❌ Invalid rollback scope: $rollback_scope"
            echo "Valid scopes: full, selective, config-only"
            return 1
            ;;
    esac
    
    echo "✅ Rollback to $backup_name completed successfully"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Restart your shell: dot reload"
    echo "  2. Run health check: dot check"
    echo "  3. Verify configurations are working correctly"
}

# Restore validation - Epic 4.2 Core Implementation
restore_validation() {
    local target_path="${1:-$HOME}"
    local validation_scope="${2:-basic}"  # basic, full, config
    
    echo "🔍 Validating restore operation..."
    
    local validation_passed=true
    local issues=()
    
    case "$validation_scope" in
        "basic")
            validate_basic_restore "$target_path"
            ;;
        "full")
            validate_full_restore "$target_path"
            ;;
        "config")
            validate_config_restore "$target_path"
            ;;
        *)
            echo "❌ Invalid validation scope: $validation_scope"
            return 1
            ;;
    esac
}

# Validate basic restore
validate_basic_restore() {
    local target_path="$1"
    
    echo "  🔍 Basic restore validation..."
    
    # Check for essential dotfiles
    local essential_files=(
        ".zshrc"
        ".gitconfig"
        ".local/share/dotfiles"
    )
    
    local missing_files=()
    for file in "${essential_files[@]}"; do
        if [[ ! -e "$target_path/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        echo "    ✅ Essential files present"
        return 0
    else
        echo "    ⚠️  Missing essential files: ${missing_files[*]}"
        return 1
    fi
}

# Validate full restore
validate_full_restore() {
    local target_path="$1"
    
    echo "  🔍 Full restore validation..."
    
    # Run basic validation first
    validate_basic_restore "$target_path"
    local basic_result=$?
    
    # Check permissions on sensitive files
    echo "  🔒 Checking file permissions..."
    validate_file_permissions "$target_path"
    local perm_result=$?
    
    # Check for broken symlinks
    echo "  🔗 Checking for broken symlinks..."
    validate_symlinks "$target_path"
    local symlink_result=$?
    
    if [[ $basic_result -eq 0 && $perm_result -eq 0 && $symlink_result -eq 0 ]]; then
        echo "  ✅ Full restore validation passed"
        return 0
    else
        echo "  ⚠️  Full restore validation found issues"
        return 1
    fi
}

# Validate configuration restore
validate_config_restore() {
    local target_path="$1"
    
    echo "  🔍 Configuration restore validation..."
    
    # Check shell configuration
    if [[ -f "$target_path/.zshrc" ]]; then
        if zsh -n "$target_path/.zshrc" 2>/dev/null; then
            echo "    ✅ Zsh configuration syntax valid"
        else
            echo "    ⚠️  Zsh configuration syntax errors detected"
        fi
    fi
    
    # Check git configuration
    if [[ -f "$target_path/.gitconfig" ]]; then
        if git config --file "$target_path/.gitconfig" --list >/dev/null 2>&1; then
            echo "    ✅ Git configuration valid"
        else
            echo "    ⚠️  Git configuration issues detected"
        fi
    fi
    
    return 0
}

# Fix permissions for restored files
fix_restored_permissions() {
    local target_path="$1"
    
    echo "  🔒 Setting appropriate permissions..."
    
    # SSH configuration permissions
    if [[ -d "$target_path/.ssh" ]]; then
        chmod 700 "$target_path/.ssh" 2>/dev/null || true
        chmod 600 "$target_path/.ssh"/* 2>/dev/null || true
        chmod 644 "$target_path/.ssh"/*.pub 2>/dev/null || true
        chmod 644 "$target_path/.ssh/config" 2>/dev/null || true
        chmod 644 "$target_path/.ssh/known_hosts" 2>/dev/null || true
    fi
    
    # GPG permissions
    if [[ -d "$target_path/.gnupg" ]]; then
        chmod 700 "$target_path/.gnupg" 2>/dev/null || true
        chmod 600 "$target_path/.gnupg"/* 2>/dev/null || true
    fi
    
    # Shell configuration files
    chmod 644 "$target_path"/.{zshrc,bashrc,profile,bash_profile} 2>/dev/null || true
    
    # Git configuration
    chmod 644 "$target_path/.gitconfig" 2>/dev/null || true
}

# Fix permissions for configuration files
fix_config_permissions() {
    fix_restored_permissions "$@"
}

# Fix macOS-specific permissions
fix_macos_permissions() {
    local target_path="$1"
    
    fix_restored_permissions "$target_path"
    
    # macOS-specific permission fixes
    if [[ -d "$target_path/Library" ]]; then
        chmod 755 "$target_path/Library" 2>/dev/null || true
    fi
}

# Fix Linux-specific permissions
fix_linux_permissions() {
    local target_path="$1"
    
    fix_restored_permissions "$target_path"
    
    # Linux-specific permission fixes
    # (Add any Linux-specific permission requirements here)
}

# Validate file permissions
validate_file_permissions() {
    local target_path="$1"
    
    local permission_issues=()
    
    # Check SSH directory permissions
    if [[ -d "$target_path/.ssh" ]]; then
        local ssh_perms=$(stat -c "%a" "$target_path/.ssh" 2>/dev/null || stat -f "%Lp" "$target_path/.ssh" 2>/dev/null)
        if [[ "$ssh_perms" != "700" ]]; then
            permission_issues+=("SSH directory permissions: $ssh_perms (should be 700)")
        fi
    fi
    
    if [[ ${#permission_issues[@]} -eq 0 ]]; then
        echo "    ✅ File permissions correct"
        return 0
    else
        echo "    ⚠️  Permission issues found:"
        printf '      - %s\n' "${permission_issues[@]}"
        return 1
    fi
}

# Validate symlinks
validate_symlinks() {
    local target_path="$1"
    
    local broken_links=()
    
    # Find broken symlinks
    while IFS= read -r -d '' symlink; do
        if [[ ! -e "$symlink" ]]; then
            broken_links+=("$symlink")
        fi
    done < <(find "$target_path" -type l -print0 2>/dev/null)
    
    if [[ ${#broken_links[@]} -eq 0 ]]; then
        echo "    ✅ No broken symlinks found"
        return 0
    else
        echo "    ⚠️  Broken symlinks found:"
        printf '      - %s\n' "${broken_links[@]}"
        return 1
    fi
}

export -f create_full_backup create_incremental_backup create_config_backup
export -f backup_validation backup_compression
export -f restore_full_system restore_selective_config restore_cross_platform
export -f rollback_to_backup restore_validation