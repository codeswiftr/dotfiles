#!/bin/bash

# Git Hooks Setup Script
# Installs and configures Git hooks for dotfiles repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/hooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in a git repository
check_git_repo() {
    if [[ ! -d "$REPO_ROOT/.git" ]]; then
        log_error "Not in a Git repository"
        exit 1
    fi
}

# Create hooks directory if it doesn't exist
setup_hooks_directory() {
    if [[ ! -d "$HOOKS_DIR" ]]; then
        log_error "Hooks directory not found: $HOOKS_DIR"
        exit 1
    fi
    
    log_info "Found hooks directory: $HOOKS_DIR"
}

# Install individual hook
install_hook() {
    local hook_name="$1"
    local hook_source="$HOOKS_DIR/$hook_name"
    local hook_target="$GIT_HOOKS_DIR/$hook_name"
    
    if [[ ! -f "$hook_source" ]]; then
        log_warning "Hook not found: $hook_source"
        return 1
    fi
    
    # Backup existing hook
    if [[ -f "$hook_target" ]]; then
        log_info "Backing up existing $hook_name hook"
        mv "$hook_target" "$hook_target.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create symlink to hook
    ln -sf "$hook_source" "$hook_target"
    
    # Make sure hook is executable
    chmod +x "$hook_target"
    
    log_success "Installed $hook_name hook"
}

# Install all hooks
install_all_hooks() {
    log_info "Installing Git hooks..."
    
    # List of hooks to install
    local hooks=(
        "pre-commit"
        "commit-msg"
        "pre-push"
    )
    
    for hook in "${hooks[@]}"; do
        install_hook "$hook"
    done
}

# Test hooks
test_hooks() {
    log_info "Testing Git hooks..."
    
    # Test pre-commit hook
    if [[ -f "$GIT_HOOKS_DIR/pre-commit" ]]; then
        log_info "Testing pre-commit hook..."
        if "$GIT_HOOKS_DIR/pre-commit" >/dev/null 2>&1; then
            log_success "Pre-commit hook test passed"
        else
            log_warning "Pre-commit hook test failed (this may be expected)"
        fi
    fi
    
    # Test commit-msg hook with a dummy message
    if [[ -f "$GIT_HOOKS_DIR/commit-msg" ]]; then
        log_info "Testing commit-msg hook..."
        local temp_msg_file
        temp_msg_file=$(mktemp)
        echo "feat: test commit message" > "$temp_msg_file"
        
        if "$GIT_HOOKS_DIR/commit-msg" "$temp_msg_file" >/dev/null 2>&1; then
            log_success "Commit-msg hook test passed"
        else
            log_warning "Commit-msg hook test failed"
        fi
        
        rm -f "$temp_msg_file"
    fi
}

# Configure Git hooks directory
configure_git_hooks() {
    log_info "Configuring Git hooks directory..."
    
    # Set Git hooks directory (Git 2.9+)
    if git config core.hooksPath >/dev/null 2>&1; then
        git config core.hooksPath "$HOOKS_DIR"
        log_success "Set Git hooks directory to: $HOOKS_DIR"
    else
        log_info "Using traditional .git/hooks directory"
    fi
}

# Display hook information
show_hook_info() {
    log_info "Git Hooks Configuration:"
    echo
    
    # Show installed hooks
    if [[ -d "$GIT_HOOKS_DIR" ]]; then
        echo "Installed hooks:"
        for hook in "$GIT_HOOKS_DIR"/*; do
            if [[ -f "$hook" ]] && [[ -x "$hook" ]]; then
                local hook_name
                hook_name=$(basename "$hook")
                echo "  ✓ $hook_name"
            fi
        done
    fi
    
    echo
    echo "Hook descriptions:"
    echo "  pre-commit    - Runs quality gates before commit"
    echo "  commit-msg    - Validates commit message format"
    echo "  pre-push      - Comprehensive validation before push"
    echo
    echo "To manually run hooks:"
    echo "  ./hooks/pre-commit"
    echo "  ./hooks/commit-msg <message-file>"
    echo "  ./hooks/pre-push <remote> <url>"
    echo
    echo "To disable hooks temporarily:"
    echo "  git commit --no-verify"
    echo "  git push --no-verify"
}

# Uninstall hooks
uninstall_hooks() {
    log_info "Uninstalling Git hooks..."
    
    local hooks=(
        "pre-commit"
        "commit-msg"
        "pre-push"
    )
    
    for hook in "${hooks[@]}"; do
        local hook_target="$GIT_HOOKS_DIR/$hook"
        
        if [[ -f "$hook_target" ]]; then
            rm -f "$hook_target"
            log_success "Removed $hook hook"
        fi
        
        # Restore backup if it exists
        if [[ -f "$hook_target.backup."* ]]; then
            local backup_file
            backup_file=$(ls -t "$hook_target.backup."* | head -1)
            mv "$backup_file" "$hook_target"
            log_info "Restored backup for $hook hook"
        fi
    done
    
    # Reset Git hooks directory
    git config --unset core.hooksPath 2>/dev/null || true
    
    log_success "Hooks uninstalled"
}

# Main execution
main() {
    local action="${1:-install}"
    
    case "$action" in
        install)
            log_info "Installing Git hooks for dotfiles repository"
            check_git_repo
            setup_hooks_directory
            install_all_hooks
            test_hooks
            configure_git_hooks
            show_hook_info
            ;;
        uninstall)
            log_info "Uninstalling Git hooks"
            check_git_repo
            uninstall_hooks
            ;;
        test)
            log_info "Testing Git hooks"
            check_git_repo
            test_hooks
            ;;
        info)
            log_info "Showing Git hooks information"
            show_hook_info
            ;;
        *)
            echo "Usage: $0 {install|uninstall|test|info}"
            echo
            echo "Commands:"
            echo "  install    - Install all Git hooks (default)"
            echo "  uninstall  - Remove all Git hooks"
            echo "  test       - Test installed hooks"
            echo "  info       - Show hook information"
            exit 1
            ;;
    esac
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi