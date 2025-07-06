#!/usr/bin/env bash
# =============================================================================
# Declarative Dotfiles Installer - 2025 Edition
# Uses tools.yaml configuration for declarative, reproducible installations
# =============================================================================

set -e

# Script configuration - handle both direct execution and piped execution
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Fallback for piped execution
    SCRIPT_DIR="$(pwd)"
fi

# Load platform compatibility framework
if [[ -f "$SCRIPT_DIR/lib/platform.sh" ]]; then
    source "$SCRIPT_DIR/lib/platform.sh"
else
    # Basic platform detection fallback
    detect_os() {
        case "$(uname -s)" in
            Darwin*) echo "macos" ;;
            Linux*) echo "linux" ;;
            CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
            *) echo "unknown" ;;
        esac
    }
    
    detect_distro() {
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            echo "${ID:-unknown}"
        elif [[ "$(uname -s)" == "Darwin" ]]; then
            echo "macos"
        else
            echo "unknown"
        fi
    }
    
    OS=$(detect_os)
    DISTRO=$(detect_distro)
fi
DOTFILES_DIR="${SCRIPT_DIR}"
CONFIG_FILE="${SCRIPT_DIR}/config/tools.yaml"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$HOME/dotfiles-install.log"

# Default values
PROFILE="standard"
DRY_RUN=false
VERBOSE=false
FORCE=false
SKIP_EXISTING=true

# Colors and emojis
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SUCCESS="✅"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"

# =============================================================================
# Utility Functions
# =============================================================================

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[LOG]${NC} $1" >&2
    fi
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "${CYAN}${GEAR} $1${NC}"
    log "STEP: $1"
}

print_success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log "WARNING: $1"
}

print_info() {
    echo -e "${CYAN}${INFO} $1${NC}"
    log "INFO: $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/arch-release ]]; then
            echo "arch"
        elif [[ -f /etc/debian_version ]]; then
            echo "ubuntu"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Parse YAML (simplified parser for our specific format)
parse_yaml() {
    local file="$1"
    local prefix="$2"
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$file" |
    awk -F"$fs" '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
        }
    }'
}

# Get tool information from config
get_tool_info() {
    local tool="$1"
    local field="$2"
    local os="${3:-$(detect_os)}"
    
    # Read the YAML config and extract tool information
    # This is a simplified implementation - in a real system you'd use yq
    grep -A 20 "^  $tool:" "$CONFIG_FILE" | grep "    $field:" | head -1 | cut -d'"' -f2
}

# Get installation command for a tool
get_install_command() {
    local tool="$1"
    local os="${2:-$(detect_os)}"
    
    # Extract install command for specific OS
    sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
    sed -n "/    install:/,/^    [a-zA-Z]/p" | \
    grep "      $os:" | cut -d'"' -f2
}

# Verify tool installation
verify_tool() {
    local tool="$1"
    local verify_cmd
    
    verify_cmd=$(sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
                 grep "    verify:" | cut -d'"' -f2)
    
    if [[ -n "$verify_cmd" ]]; then
        eval "$verify_cmd" >/dev/null 2>&1
    else
        command_exists "$tool"
    fi
}

# Install a single tool
install_tool() {
    local tool="$1"
    local os="${2:-$(detect_os)}"
    
    print_step "Installing $tool..."
    
    # Check if tool is already installed
    if verify_tool "$tool" && [[ "$SKIP_EXISTING" == "true" ]]; then
        print_info "$tool is already installed, skipping"
        return 0
    fi
    
    # Get installation command
    local install_cmd
    install_cmd=$(get_install_command "$tool" "$os")
    
    if [[ -z "$install_cmd" ]]; then
        print_warning "No installation command found for $tool on $os"
        return 1
    fi
    
    # Execute installation
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN: Would execute: $install_cmd"
    else
        print_info "Executing: $install_cmd"
        if eval "$install_cmd"; then
            print_success "Successfully installed $tool"
            
            # Run post-install commands if they exist
            local post_install
            post_install=$(sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
                          sed -n "/    post_install:/,/^    [a-zA-Z]/p" | \
                          grep "      -" | sed 's/      - "//' | sed 's/"//')
            
            if [[ -n "$post_install" ]]; then
                print_step "Running post-install commands for $tool..."
                while IFS= read -r cmd; do
                    if [[ -n "$cmd" ]]; then
                        print_info "Executing: $cmd"
                        eval "$cmd" || print_warning "Post-install command failed: $cmd"
                    fi
                done <<< "$post_install"
            fi
        else
            print_error "Failed to install $tool"
            return 1
        fi
    fi
}

# Install tools from a group
install_group() {
    local group="$1"
    local tools
    
    print_header "Installing group: $group"
    
    # Extract tools from group
    tools=$(sed -n "/^  $group:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
           sed -n "/    tools:/,/^    [a-zA-Z]/p" | \
           grep "      -" | sed 's/      - //')
    
    if [[ -z "$tools" ]]; then
        print_warning "No tools found in group: $group"
        return 1
    fi
    
    local failed_tools=()
    
    while IFS= read -r tool; do
        if [[ -n "$tool" ]]; then
            if ! install_tool "$tool"; then
                failed_tools+=("$tool")
            fi
        fi
    done <<< "$tools"
    
    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        print_warning "Failed to install some tools in group $group: ${failed_tools[*]}"
        return 1
    else
        print_success "Successfully installed all tools in group: $group"
        return 0
    fi
}

# Install based on profile
install_profile() {
    local profile="$1"
    local groups
    
    print_header "Installing profile: $profile"
    
    # Extract groups from profile
    groups=$(sed -n "/^  $profile:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
            sed -n "/    groups:/,/^    [a-zA-Z]/p" | \
            grep -o '"\w*"' | tr -d '"')
    
    if [[ -z "$groups" ]]; then
        print_error "Profile not found or has no groups: $profile"
        return 1
    fi
    
    print_info "Profile $profile includes groups: $(echo $groups | tr '\n' ' ')"
    
    local failed_groups=()
    
    while IFS= read -r group; do
        if [[ -n "$group" ]]; then
            if ! install_group "$group"; then
                failed_groups+=("$group")
            fi
        fi
    done <<< "$groups"
    
    if [[ ${#failed_groups[@]} -gt 0 ]]; then
        print_error "Failed to install some groups: ${failed_groups[*]}"
        return 1
    else
        print_success "Successfully installed profile: $profile"
        return 0
    fi
}

# Setup package manager
setup_package_manager() {
    local os="${1:-$(detect_os)}"
    
    print_step "Setting up package manager for $os..."
    
    case "$os" in
        "macos")
            if ! command_exists brew; then
                print_step "Installing Homebrew..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install Homebrew"
                else
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    print_success "Homebrew installed"
                fi
            else
                print_info "Homebrew already installed"
            fi
            ;;
        "ubuntu")
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "DRY RUN: Would update apt packages"
            else
                print_step "Updating apt packages..."
                sudo apt update && sudo apt upgrade -y
                print_success "Package manager updated"
            fi
            ;;
        "arch")
            if ! command_exists yay; then
                print_step "Installing yay AUR helper..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install yay"
                else
                    git clone https://aur.archlinux.org/yay.git /tmp/yay
                    cd /tmp/yay && makepkg -si --noconfirm
                    print_success "yay installed"
                fi
            else
                print_info "yay already installed"
            fi
            ;;
        *)
            print_warning "Unknown OS: $os, skipping package manager setup"
            ;;
    esac
}

# Show available profiles
show_profiles() {
    print_header "Available Installation Profiles"
    
    echo "Profiles defined in config/tools.yaml:"
    echo ""
    
    # Extract profile information
    grep -A 3 "^  [a-zA-Z]*:$" "$CONFIG_FILE" | grep -A 2 "profiles:" -A 100 | while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_]+):$ ]]; then
            profile_name=$(echo "$line" | sed 's/[[:space:]]*\([a-zA-Z_]*\):.*/\1/')
            if [[ "$profile_name" != "profiles" ]]; then
                echo -e "${BLUE}$profile_name${NC}"
            fi
        elif [[ "$line" =~ description: ]]; then
            description=$(echo "$line" | sed 's/.*description:[[:space:]]*"\(.*\)"/\1/')
            echo -e "  ${CYAN}$description${NC}"
            echo ""
        fi
    done
}

# Show help
show_help() {
    cat << EOF
Declarative Dotfiles Installer

USAGE:
    $0 [OPTIONS] [COMMAND]

COMMANDS:
    install [PROFILE]     Install using specified profile (default: standard)
    profiles              Show available installation profiles
    tools                 List all available tools
    verify                Verify current installation status
    
OPTIONS:
    -p, --profile PROFILE Installation profile (minimal|standard|full|ai_focused)
    -d, --dry-run         Show what would be done without executing
    -v, --verbose         Enable verbose output
    -f, --force           Force installation even if tools exist
    -s, --skip-existing   Skip tools that are already installed (default)
    -h, --help            Show this help message

EXAMPLES:
    $0 install standard                    # Install standard profile
    $0 --dry-run install full             # Preview full installation
    $0 --verbose --force install minimal  # Force install minimal with verbose output
    $0 profiles                           # Show available profiles
    $0 verify                            # Check current installation status

CONFIG:
    Configuration file: config/tools.yaml
    Log file: ~/dotfiles-install.log
    Backup directory: ~/dotfiles-backup-[timestamp]

For more information, see: docs/installation.md
EOF
}

# Verify current installation
verify_installation() {
    print_header "Verifying Current Installation"
    
    local os
    os=$(detect_os)
    print_info "Detected OS: $os"
    
    # Check essential tools
    local tools=("zsh" "git" "curl" "nvim" "tmux" "starship" "zoxide" "eza" "bat" "ripgrep" "fd" "fzf")
    local installed=0
    local total=${#tools[@]}
    
    echo ""
    echo "Tool Status:"
    echo "============"
    
    for tool in "${tools[@]}"; do
        if verify_tool "$tool"; then
            echo -e "${GREEN}${SUCCESS} $tool${NC}"
            ((installed++))
        else
            echo -e "${RED}${ERROR} $tool${NC}"
        fi
    done
    
    echo ""
    echo "Summary: $installed/$total tools installed"
    
    if [[ $installed -eq $total ]]; then
        print_success "All essential tools are installed!"
    else
        print_warning "Some tools are missing. Run installation to complete setup."
    fi
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--force)
                FORCE=true
                SKIP_EXISTING=false
                shift
                ;;
            -s|--skip-existing)
                SKIP_EXISTING=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            install)
                COMMAND="install"
                if [[ -n "${2:-}" ]] && [[ ! "$2" =~ ^- ]]; then
                    PROFILE="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            profiles)
                COMMAND="profiles"
                shift
                ;;
            verify)
                COMMAND="verify"
                shift
                ;;
            tools)
                COMMAND="tools"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Set default command
    COMMAND="${COMMAND:-install}"
    
    # Check if config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Create log file
    touch "$LOG_FILE"
    log "=== Dotfiles Installation Started ==="
    log "Profile: $PROFILE"
    log "Dry run: $DRY_RUN"
    log "Verbose: $VERBOSE"
    log "Force: $FORCE"
    
    # Execute command
    case "$COMMAND" in
        "install")
            print_header "Modern Dotfiles Installation - 2025 Edition"
            print_info "Profile: $PROFILE"
            print_info "OS: $(detect_os)"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "DRY RUN MODE - No changes will be made"
            fi
            
            setup_package_manager
            install_profile "$PROFILE"
            
            print_success "Installation completed!"
            print_info "Log file: $LOG_FILE"
            ;;
        "profiles")
            show_profiles
            ;;
        "verify")
            verify_installation
            ;;
        "tools")
            print_header "Available Tools"
            grep "^  [a-zA-Z].*:$" "$CONFIG_FILE" | grep -A 1000 "^tools:" | head -50 | sed 's/^  \([^:]*\):.*/\1/' | sort
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"