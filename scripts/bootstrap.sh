#!/usr/bin/env bash
# =============================================================================
# Dotfiles Bootstrap Installer
# Standalone installer that clones repository and runs main installer
# =============================================================================

set -e

# Configuration
REPO_URL="https://github.com/codeswiftr/dotfiles.git"
REPO_BRANCH="master"
DOTFILES_DIR="$HOME/dotfiles"
TEMP_DIR="/tmp/dotfiles-install-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# Error handling
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

error_exit() {
    log_error "$1"
    exit 1
}

# Check if running as root
check_user() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. This may cause permission issues."
        log_warning "Consider running as a regular user instead."
        sleep 3
    fi
}

# Install prerequisites
install_prerequisites() {
    log_info "Installing prerequisites..."
    
    # Detect OS
    if command -v apt-get >/dev/null 2>&1; then
        # Ubuntu/Debian
        log_info "Detected Ubuntu/Debian system"
        apt-get update -qq || error_exit "Failed to update package list"
        apt-get install -y git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS
        log_info "Detected RHEL/CentOS system"
        yum install -y git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        log_info "Detected Fedora system"
        dnf install -y git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        log_info "Detected Arch Linux system"
        pacman -Sy --noconfirm git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v brew >/dev/null 2>&1; then
        # macOS
        log_info "Detected macOS system"
        if ! command -v git >/dev/null 2>&1; then
            xcode-select --install 2>/dev/null || true
        fi
    else
        log_warning "Unknown package manager. Please ensure git and curl are installed."
    fi
    
    log_success "Prerequisites installed"
}

# Clone repository
clone_repository() {
    log_info "Cloning dotfiles repository..."
    
    # Remove existing directory if it exists
    if [[ -d "$DOTFILES_DIR" ]]; then
        log_warning "Existing dotfiles directory found at $DOTFILES_DIR"
        read -p "Remove existing directory and continue? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$DOTFILES_DIR"
        else
            error_exit "Installation cancelled"
        fi
    fi
    
    # Clone to temporary directory first
    mkdir -p "$TEMP_DIR"
    if ! git clone --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR"; then
        error_exit "Failed to clone repository"
    fi
    
    # Move to final location
    mv "$TEMP_DIR" "$DOTFILES_DIR"
    log_success "Repository cloned to $DOTFILES_DIR"
}

# Run main installer
run_installer() {
    log_info "Running main installer..."
    
    local installer="$DOTFILES_DIR/install.sh"
    if [[ ! -f "$installer" ]]; then
        error_exit "Main installer not found at $installer"
    fi
    
    # Make installer executable
    chmod +x "$installer"
    
    # Run installer with passed arguments
    cd "$DOTFILES_DIR"
    exec "$installer" "$@"
}

# Main function
main() {
    echo "================================"
    echo "🚀 Modern Dotfiles Bootstrap"
    echo "================================"
    
    check_user
    install_prerequisites
    clone_repository
    run_installer "$@"
}

# Handle script being sourced vs executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi