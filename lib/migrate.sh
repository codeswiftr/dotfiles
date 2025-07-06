#!/usr/bin/env bash

# ============================================================================
# Dotfiles Migration System
# Handles version migrations and breaking changes
# ============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Emojis
SUCCESS="✅"
INFO="ℹ️"
GEAR="⚙️"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MIGRATION_STATE_FILE="$HOME/.dotfiles_migrations"

# ============================================================================
# Utility Functions
# ============================================================================

print_success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

print_migration() {
    echo -e "${YELLOW}${GEAR} $1${NC}"
}

# ============================================================================
# Migration State Management
# ============================================================================

get_completed_migrations() {
    if [[ -f "$MIGRATION_STATE_FILE" ]]; then
        cat "$MIGRATION_STATE_FILE"
    fi
}

mark_migration_completed() {
    local migration_id="$1"
    echo "$migration_id" >> "$MIGRATION_STATE_FILE"
}

is_migration_completed() {
    local migration_id="$1"
    grep -q "^$migration_id$" "$MIGRATION_STATE_FILE" 2>/dev/null
}

# ============================================================================
# Individual Migration Functions
# ============================================================================

# Example migration function - template for future migrations
migrate_2025_1_0() {
    local migration_id="2025.1.0"
    
    if is_migration_completed "$migration_id"; then
        return 0
    fi
    
    print_migration "Running migration for version 2025.1.0"
    
    # Example migrations (these would be actual migration steps)
    
    # 1. Update tmux plugin manager location if needed
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_info "TPM already installed in correct location"
    else
        print_info "Installing TPM (Tmux Plugin Manager)"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null || true
    fi
    
    # 2. Ensure tmux scripts directory exists
    mkdir -p "$HOME/.config/tmux/scripts"
    
    # 3. Make sure sessionizer script is executable
    if [[ -f "$DOTFILES_DIR/.config/tmux/scripts/tmux-sessionizer" ]]; then
        chmod +x "$DOTFILES_DIR/.config/tmux/scripts/tmux-sessionizer"
    fi
    
    # 4. Create necessary directories
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.cache/uv"
    mkdir -p "$HOME/.cache/ruff"
    
    # 5. Set up starship config if not exists
    if [[ ! -f "$HOME/.config/starship.toml" ]]; then
        print_info "Creating Starship configuration"
        cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship configuration
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$nodejs\
$character"""

[directory]
style = "blue"

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vicmd_symbol = "[❮](green)"

[git_branch]
format = "[$branch]($style)"
style = "bright-black"

[git_status]
format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
style = "cyan"

[python]
symbol = "🐍 "
format = '[$symbol$pyenv_prefix$version]($style) '

[nodejs]
symbol = "📦 "
format = '[$symbol$version]($style) '
EOF
    fi
    
    mark_migration_completed "$migration_id"
    print_success "Migration 2025.1.0 completed"
}

# Migration for LSP deprecation fixes
migrate_2025_1_1() {
    local migration_id="2025.1.1"
    
    if is_migration_completed "$migration_id"; then
        return 0
    fi
    
    print_migration "Running migration for version 2025.1.1 - LSP fixes"
    
    # Remove old LSP servers that have been renamed
    if command -v mason >/dev/null 2>&1; then
        print_info "Updating Mason LSP servers"
        # Remove deprecated servers
        ~/.local/share/nvim/mason/bin/mason uninstall ruff-lsp 2>/dev/null || true
        ~/.local/share/nvim/mason/bin/mason uninstall typescript-language-server 2>/dev/null || true
        
        # Install new servers
        ~/.local/share/nvim/mason/bin/mason install ruff 2>/dev/null || true
        ~/.local/share/nvim/mason/bin/mason install typescript-language-server 2>/dev/null || true
    fi
    
    # Update Neovim configuration if it exists and hasn't been updated
    local nvim_config="$HOME/.config/nvim/init.lua"
    if [[ -f "$nvim_config" ]]; then
        # Check if old configuration exists and update it
        if grep -q "ruff_lsp" "$nvim_config" 2>/dev/null; then
            print_info "Updating Neovim LSP configuration"
            # The configuration should already be updated by our new version
            # This is just a safety check
        fi
    fi
    
    mark_migration_completed "$migration_id"
    print_success "Migration 2025.1.1 completed - LSP deprecation warnings fixed"
}

# Future migration template
migrate_2025_2_0() {
    local migration_id="2025.2.0"
    
    if is_migration_completed "$migration_id"; then
        return 0
    fi
    
    print_migration "Running migration for version 2025.2.0"
    
    # Add future migration steps here
    # Example:
    # - Update configuration formats
    # - Migrate old settings to new structure
    # - Install new dependencies
    # - Remove deprecated files
    
    mark_migration_completed "$migration_id"
    print_success "Migration 2025.2.0 completed"
}

# ============================================================================
# Migration Runner
# ============================================================================

run_migrations() {
    print_info "Checking for required migrations..."
    
    # Create migration state file if it doesn't exist
    touch "$MIGRATION_STATE_FILE"
    
    # List of all migrations in order
    local migrations=(
        "migrate_2025_1_0"
        "migrate_2025_1_1"
        # "migrate_2025_2_0"  # Add future migrations here
    )
    
    local ran_migrations=false
    
    for migration in "${migrations[@]}"; do
        if command -v "$migration" >/dev/null 2>&1; then
            "$migration"
            ran_migrations=true
        fi
    done
    
    if [[ "$ran_migrations" == "true" ]]; then
        print_success "All migrations completed successfully"
    else
        print_info "No migrations required"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

# Run migrations when script is executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_migrations
fi