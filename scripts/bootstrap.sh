#!/usr/bin/env bash
# =============================================================================
# Dotfiles Bootstrap Installer
# Standalone installer that clones repository and runs main installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/.../bootstrap.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/.../bootstrap.sh | bash -s -- install full
#   ./bootstrap.sh install full
# =============================================================================

set -eo pipefail

# Configuration
REPO_URL="https://github.com/codeswiftr/dotfiles.git"
REPO_BRANCH="main"
DOTFILES_DIR="$HOME/dotfiles"
TEMP_DIR="/tmp/dotfiles-install-$$"

# Detect if running via pipe (curl | bash)
PIPED_EXECUTION=false
if [[ ! -t 0 ]]; then
    PIPED_EXECUTION=true
fi

# Colors (force colors even in pipe mode for better UX)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions - output to stderr to ensure visibility in pipe mode
log_info() { echo -e "${BLUE}ℹ️  $1${NC}" >&2; }
log_success() { echo -e "${GREEN}✅ $1${NC}" >&2; }
log_error() { echo -e "${RED}❌ $1${NC}" >&2; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}" >&2; }
log_step() { echo -e "${CYAN}▶  $1${NC}" >&2; }

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

# Ensure sudo works in non-interactive mode
setup_sudo() {
    # Check if we need sudo at all
    if [[ $EUID -eq 0 ]]; then
        # Running as root, no sudo needed
        SUDO_CMD=""
        return 0
    fi

    # Check if sudo is available
    if ! command -v sudo >/dev/null 2>&1; then
        log_error "sudo is required but not installed"
        return 1
    fi

    # Check if we have a TTY for password prompt
    if [[ -t 0 ]]; then
        # Interactive mode - can prompt for password
        SUDO_CMD="sudo"
        log_info "Interactive mode: sudo will prompt for password if needed"
        # Pre-authenticate sudo to cache credentials
        sudo -v || {
            log_error "sudo authentication failed"
            return 1
        }
    else
        # Non-interactive (piped) mode
        # Check if sudo works without password (NOPASSWD configured)
        if sudo -n true 2>/dev/null; then
            SUDO_CMD="sudo"
            log_info "Passwordless sudo available"
        else
            log_error "No TTY available for sudo password prompt"
            echo "" >&2
            echo -e "${YELLOW}To install in non-interactive mode, either:${NC}" >&2
            echo "  1. Run with TTY: bash -c \"\$(curl -fsSL URL)\"" >&2
            echo "  2. Pre-authenticate: sudo -v && curl -fsSL URL | bash" >&2
            echo "  3. Configure NOPASSWD in /etc/sudoers for apt commands" >&2
            echo "" >&2
            return 1
        fi
    fi

    return 0
}

# Install prerequisites
install_prerequisites() {
    log_step "Checking prerequisites..."

    # Detect OS
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS
        log_info "Detected macOS system"

        # Check for Xcode Command Line Tools (required for git)
        if ! xcode-select -p &>/dev/null; then
            log_info "Installing Xcode Command Line Tools..."
            log_info "A dialog may appear - please click 'Install' and wait for completion."
            xcode-select --install 2>/dev/null || true

            # Wait for installation with user-friendly feedback
            local timeout=300  # 5 minutes
            local elapsed=0
            echo -e "${YELLOW}Waiting for Xcode Command Line Tools installation...${NC}" >&2
            echo -e "${BLUE}This is required for git and developer tools.${NC}" >&2
            while ! xcode-select -p &>/dev/null && [[ $elapsed -lt $timeout ]]; do
                sleep 5
                ((elapsed+=5))
                echo -n "." >&2
            done
            echo "" >&2

            if xcode-select -p &>/dev/null; then
                log_success "Xcode Command Line Tools installed"
            else
                log_error "Xcode Command Line Tools installation timed out or was cancelled"
                echo "" >&2
                echo -e "${YELLOW}To install manually:${NC}" >&2
                echo "  1. Run: xcode-select --install" >&2
                echo "  2. Click 'Install' in the dialog" >&2
                echo "  3. Wait for completion" >&2
                echo "  4. Re-run this script" >&2
                echo "" >&2
                error_exit "Xcode CLI tools required for installation"
            fi
        else
            log_info "Xcode Command Line Tools already installed"
        fi

    elif command -v apt-get >/dev/null 2>&1; then
        # Ubuntu/Debian
        log_info "Detected Ubuntu/Debian system"
        setup_sudo || error_exit "sudo setup failed"
        $SUDO_CMD apt-get update -qq || error_exit "Failed to update package list"
        $SUDO_CMD apt-get install -y git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS
        log_info "Detected RHEL/CentOS system"
        setup_sudo || error_exit "sudo setup failed"
        $SUDO_CMD yum install -y git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        log_info "Detected Fedora system"
        setup_sudo || error_exit "sudo setup failed"
        $SUDO_CMD dnf install -y git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        log_info "Detected Arch Linux system"
        setup_sudo || error_exit "sudo setup failed"
        $SUDO_CMD pacman -Sy --noconfirm git curl wget ca-certificates || error_exit "Failed to install prerequisites"
    else
        log_warning "Unknown package manager."
        echo "" >&2
        echo -e "${YELLOW}Please ensure these tools are installed:${NC}" >&2
        echo "  - git" >&2
        echo "  - curl" >&2
        echo "" >&2
        echo "Then re-run this script." >&2
        error_exit "Required tools not found"
    fi

    log_success "Prerequisites installed"
}

# Clone repository
clone_repository() {
    log_step "Cloning dotfiles repository..."

    # Remove existing directory if it exists
    if [[ -d "$DOTFILES_DIR" ]]; then
        log_warning "Existing dotfiles directory found at $DOTFILES_DIR"

        if [[ "$PIPED_EXECUTION" == "true" ]]; then
            # In pipe mode, auto-backup and continue
            local backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
            log_info "Pipe mode: backing up existing directory to $backup_dir"
            mv "$DOTFILES_DIR" "$backup_dir"
            log_success "Existing dotfiles backed up"
        else
            # Interactive mode: ask user
            read -p "Remove existing directory and continue? (y/N): " -r </dev/tty
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$DOTFILES_DIR"
            else
                error_exit "Installation cancelled"
            fi
        fi
    fi

    # Clone to temporary directory first
    log_info "Downloading from $REPO_URL..."
    mkdir -p "$TEMP_DIR"
    if ! git clone --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" 2>&1; then
        error_exit "Failed to clone repository. Check your internet connection."
    fi

    # Move to final location
    mv "$TEMP_DIR" "$DOTFILES_DIR"
    log_success "Repository cloned to $DOTFILES_DIR"
}

# Run main installer
run_installer() {
    log_step "Running main installer..."

    local installer="$DOTFILES_DIR/install.sh"
    if [[ ! -f "$installer" ]]; then
        error_exit "Main installer not found at $installer"
    fi

    # Make installer executable
    chmod +x "$installer"

    # Check if config file exists
    local config_file="$DOTFILES_DIR/config/tools.yaml"
    if [[ ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        log_info "Available files in config directory:"
        ls -la "$DOTFILES_DIR/config/" >&2 || true
        error_exit "Missing configuration file"
    fi

    # Run installer with passed arguments, default to 'install standard' if no args
    cd "$DOTFILES_DIR"

    # Add headless flag for pipe mode
    local extra_args=""
    if [[ "$PIPED_EXECUTION" == "true" ]]; then
        extra_args="--headless"
    fi

    if [[ $# -eq 0 ]]; then
        log_info "Using default profile 'standard'"
        "$installer" $extra_args install standard
    else
        log_info "Running with profile: $*"
        "$installer" $extra_args "$@"
    fi
}

# Main function
main() {
    # Immediate feedback - output to stderr for pipe visibility
    echo "" >&2
    echo "================================" >&2
    echo "🚀 Modern Dotfiles Bootstrap" >&2
    echo "================================" >&2
    echo "" >&2

    if [[ "$PIPED_EXECUTION" == "true" ]]; then
        log_info "Running in pipe mode (curl | bash)"
    fi

    check_user
    install_prerequisites
    clone_repository
    run_installer "$@"

    echo "" >&2
    log_success "Bootstrap complete!"
    echo "" >&2
}

# Always run main when this script executes
# Works correctly for both: ./bootstrap.sh AND curl | bash
main "$@"