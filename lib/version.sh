#!/usr/bin/env bash

# ============================================================================
# Dotfiles Version Management System
# Similar to Oh My Zsh's update mechanism
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
SUCCESS="✅"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"
UPDATE="🔄"
NEW="🆕"
WARNING="⚠️"

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
VERSION_FILE="$DOTFILES_DIR/VERSION"
LAST_UPDATE_FILE="$HOME/.dotfiles_last_update_check"
UPDATE_INTERVAL=$((7 * 24 * 60 * 60)) # 7 days in seconds
REMOTE_VERSION_URL="https://raw.githubusercontent.com/codeswiftr/dotfiles/master/VERSION"
REPO_URL="https://github.com/codeswiftr/dotfiles"

# ============================================================================
# Utility Functions
# ============================================================================

print_success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
}

print_info() {
    echo -e "${CYAN}${INFO} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_update() {
    echo -e "${BLUE}${UPDATE} $1${NC}"
}

print_new() {
    echo -e "${PURPLE}${NEW} $1${NC}"
}

# ============================================================================
# Version Functions
# ============================================================================

get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "unknown"
    fi
}

get_remote_version() {
    if command -v curl >/dev/null 2>&1; then
        curl -s "$REMOTE_VERSION_URL" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

get_last_update_check() {
    if [[ -f "$LAST_UPDATE_FILE" ]]; then
        cat "$LAST_UPDATE_FILE"
    else
        echo "0"
    fi
}

set_last_update_check() {
    echo "$(date +%s)" > "$LAST_UPDATE_FILE"
}

version_compare() {
    # Compare version strings
    # Returns: 0 if equal, 1 if first > second, 2 if first < second
    local version1="$1"
    local version2="$2"
    
    if [[ "$version1" == "$version2" ]]; then
        return 0
    fi
    
    # Simple string comparison for now (can be enhanced for semantic versioning)
    if [[ "$version1" > "$version2" ]]; then
        return 1
    else
        return 2
    fi
}

# ============================================================================
# Update Check Functions
# ============================================================================

should_check_for_updates() {
    local last_check=$(get_last_update_check)
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_check))
    
    if [[ $time_diff -gt $UPDATE_INTERVAL ]]; then
        return 0
    else
        return 1
    fi
}

check_for_updates() {
    local current_version=$(get_current_version)
    local remote_version=$(get_remote_version)
    
    if [[ "$remote_version" == "unknown" ]]; then
        print_warning "Unable to check for updates (network issue)"
        return 1
    fi
    
    version_compare "$remote_version" "$current_version"
    local result=$?
    
    case $result in
        0)
            print_success "You have the latest version ($current_version)"
            return 0
            ;;
        1)
            print_new "Update available: $current_version → $remote_version"
            return 2
            ;;
        2)
            print_info "You have a newer version than remote ($current_version > $remote_version)"
            return 0
            ;;
    esac
}

# ============================================================================
# Update Functions
# ============================================================================

show_update_prompt() {
    local current_version=$(get_current_version)
    local remote_version=$(get_remote_version)
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                     ${ROCKET} ${YELLOW}Dotfiles Update Available${NC} ${ROCKET}                     ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  Current version: ${RED}$current_version${NC}                                        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Latest version:  ${GREEN}$remote_version${NC}                                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Run 'dotfiles-update' to update your configuration         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Or use 'dotfiles-update --auto' for automatic updates     ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

perform_update() {
    local backup_dir="$HOME/dotfiles-backup-update-$(date +%Y%m%d-%H%M%S)"
    
    print_update "Starting dotfiles update..."
    
    # Check if we're in a git repository
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        print_error "Dotfiles directory is not a git repository"
        print_info "Please reinstall using the installation script"
        return 1
    fi
    
    # Create backup
    print_update "Creating backup at $backup_dir"
    mkdir -p "$backup_dir"
    cp -r "$HOME/.zshrc" "$HOME/.vimrc" "$HOME/.tmux.conf" "$HOME/.gitconfig" "$HOME/.config/nvim" "$backup_dir/" 2>/dev/null || true
    
    # Save current directory
    local original_dir=$(pwd)
    
    # Navigate to dotfiles directory
    cd "$DOTFILES_DIR" || {
        print_error "Cannot access dotfiles directory: $DOTFILES_DIR"
        return 1
    }
    
    # Fetch latest changes
    print_update "Fetching latest changes..."
    if ! git fetch origin; then
        print_error "Failed to fetch updates from remote repository"
        cd "$original_dir"
        return 1
    fi
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "You have uncommitted changes in your dotfiles"
        print_info "Stashing changes..."
        git stash push -m "Auto-stash before update $(date)"
    fi
    
    # Get current branch
    local current_branch=$(git branch --show-current)
    
    # Pull latest changes
    print_update "Updating to latest version..."
    if ! git pull origin "$current_branch"; then
        print_error "Failed to pull updates"
        cd "$original_dir"
        return 1
    fi
    
    # Check if there are new changes
    local new_version=$(get_current_version)
    
    # Run any migration scripts if they exist
    if [[ -f "$DOTFILES_DIR/lib/migrate.sh" ]]; then
        print_update "Running migration scripts..."
        bash "$DOTFILES_DIR/lib/migrate.sh" || {
            print_warning "Migration script failed, but continuing..."
        }
    fi
    
    # Re-link configurations (in case new files were added)
    print_update "Updating configurations..."
    
    # Link main configs
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    
    # Update Neovim config
    mkdir -p "$HOME/.config/nvim"
    ln -sf "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    
    # Update tmux scripts
    mkdir -p "$HOME/.config/tmux/scripts"
    ln -sf "$DOTFILES_DIR/.config/tmux/scripts/tmux-sessionizer" "$HOME/.config/tmux/scripts/tmux-sessionizer"
    chmod +x "$HOME/.config/tmux/scripts/tmux-sessionizer"
    
    # Update timestamp
    set_last_update_check
    
    # Return to original directory
    cd "$original_dir"
    
    print_success "Update completed successfully!"
    print_info "Updated from version $(get_current_version) to $new_version"
    print_info "Backup saved to: $backup_dir"
    print_info "Please restart your terminal or run 'source ~/.zshrc'"
    
    # Show changelog if available
    show_changelog_since_version "$current_version"
}

show_changelog_since_version() {
    local since_version="$1"
    local changelog_file="$DOTFILES_DIR/CHANGELOG.md"
    
    if [[ -f "$changelog_file" ]]; then
        print_info "Recent changes:"
        echo -e "${YELLOW}$(head -30 "$changelog_file")${NC}"
    fi
}

# ============================================================================
# Auto Update Functions
# ============================================================================

auto_update_check() {
    # Only check if enough time has passed
    if ! should_check_for_updates; then
        return 0
    fi
    
    # Update the last check timestamp
    set_last_update_check
    
    # Check for updates silently
    check_for_updates >/dev/null 2>&1
    local result=$?
    
    if [[ $result -eq 2 ]]; then
        # Update available
        show_update_prompt
    fi
}

# ============================================================================
# Main Commands
# ============================================================================

dotfiles_version() {
    local current_version=$(get_current_version)
    local remote_version=$(get_remote_version)
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                   ${ROCKET} ${YELLOW}Dotfiles Version Info${NC} ${ROCKET}                      ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  Current version: ${GREEN}$current_version${NC}                                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Remote version:  ${CYAN}$remote_version${NC}                                          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Repository:      ${PURPLE}$REPO_URL${NC}     ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  Last check:      $(date -r $(get_last_update_check) 2>/dev/null || echo 'Never')                                        ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    check_for_updates
}

dotfiles_update() {
    local auto_mode=false
    
    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --auto)
                auto_mode=true
                ;;
            --help|-h)
                echo "Usage: dotfiles-update [--auto] [--help]"
                echo ""
                echo "Options:"
                echo "  --auto    Perform update without prompting"
                echo "  --help    Show this help message"
                return 0
                ;;
        esac
    done
    
    # Check for updates first
    check_for_updates
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        print_success "Already up to date!"
        return 0
    elif [[ $result -eq 1 ]]; then
        print_error "Cannot check for updates"
        return 1
    fi
    
    # Update available
    if [[ "$auto_mode" == "true" ]]; then
        perform_update
    else
        echo -e "${YELLOW}Update available. Do you want to update now? (y/N): ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            perform_update
        else
            print_info "Update cancelled. Run 'dotfiles-update' anytime to update."
        fi
    fi
}

dotfiles_changelog() {
    local changelog_file="$DOTFILES_DIR/CHANGELOG.md"
    
    if [[ -f "$changelog_file" ]]; then
        if command -v bat >/dev/null 2>&1; then
            bat "$changelog_file"
        elif command -v less >/dev/null 2>&1; then
            less "$changelog_file"
        else
            cat "$changelog_file"
        fi
    else
        print_error "Changelog not found"
    fi
}

# ============================================================================
# Export Functions for Use in Shell
# ============================================================================

# Make functions available when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, export functions
    export -f dotfiles_version
    export -f dotfiles_update
    export -f dotfiles_changelog
    export -f auto_update_check
fi