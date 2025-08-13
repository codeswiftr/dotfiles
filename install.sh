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
HEADLESS=false

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

# YAML helpers (prefer Python PyYAML; fallback to legacy parsing)
has_pyyaml() {
    python3 -c 'import yaml' >/dev/null 2>&1
}

yaml_query_install_cmd() {
    local tool="$1" os="$2"
    if has_pyyaml; then
        python3 - "$CONFIG_FILE" "$tool" "$os" <<'PY'
import sys, yaml
cfg_path, tool, os_name = sys.argv[1:4]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
# Prefer OS-specific command; fall back to 'all'
install_map = (data.get('tools', {}).get(tool, {}).get('install', {}) or {})
cmd = install_map.get(os_name) or install_map.get('all')
print(cmd or "")
PY
    else
        # Try OS-specific first
        local cmd
        cmd=$(sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        sed -n "/    install:/,/^    [a-zA-Z]/p" | \
        grep "      $os:" | cut -d'\"' -f2)
        if [[ -z "$cmd" ]]; then
            # Fallback to 'all:'
            cmd=$(sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
            sed -n "/    install:/,/^    [a-zA-Z]/p" | \
            grep "      all:" | cut -d'\"' -f2)
        fi
        echo "$cmd"
    fi
}

yaml_query_verify_cmd() {
    local tool="$1"
    if has_pyyaml; then
        python3 - "$CONFIG_FILE" "$tool" <<'PY'
import sys, yaml
cfg_path, tool = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
print((data.get('tools', {}).get(tool, {}) or {}).get('verify', '') or '')
PY
    else
        sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        grep "    verify:" | cut -d'\"' -f2
    fi
}

yaml_query_post_install() {
    local tool="$1"
    if has_pyyaml; then
        python3 - "$CONFIG_FILE" "$tool" <<'PY'
import sys, yaml
cfg_path, tool = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
pi = (data.get('tools', {}).get(tool, {}) or {}).get('post_install', []) or []
for line in pi:
    print(line)
PY
    else
        sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        sed -n "/    post_install:/,/^    [a-zA-Z]/p" | \
        grep "      -" | sed 's/      - \"//' | sed 's/\"//'
    fi
}

yaml_query_group_tools() {
    local group="$1"
    if has_pyyaml; then
        python3 - "$CONFIG_FILE" "$group" <<'PY'
import sys, yaml
cfg_path, group = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
tools = (data.get('groups', {}).get(group, {}) or {}).get('tools', []) or []
for t in tools:
    print(t)
PY
    else
        sed -n "/^  $group:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        sed -n "/    tools:/,/^    [a-zA-Z]/p" | \
        grep "      -" | sed 's/      - //'
    fi
}

yaml_query_profile_groups() {
    local profile="$1"
    if has_pyyaml; then
        python3 - "$CONFIG_FILE" "$profile" <<'PY'
import sys, yaml
cfg_path, profile = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
groups = (data.get('profiles', {}).get(profile, {}) or {}).get('groups', []) or []
for g in groups:
    print(g)
PY
    else
        sed -n "/^  $profile:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        sed -n "/    groups:/,/^    [a-zA-Z]/p" | \
        grep -o '"\w*"' | tr -d '"'
    fi
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
    yaml_query_install_cmd "$tool" "$os"
}

# Verify tool installation
verify_tool() {
    local tool="$1"
    local verify_cmd
    
    verify_cmd=$(yaml_query_verify_cmd "$tool")
    
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
            post_install=$(yaml_query_post_install "$tool")
            
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
    tools=$(yaml_query_group_tools "$group")
    
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
    groups=$(yaml_query_profile_groups "$profile")
    
    if [[ -z "$groups" ]]; then
        print_error "Profile not found or has no groups: $profile"
        return 1
    fi
    
    print_info "Profile $profile includes groups: $(echo "$groups" | tr '\n' ' ')"
    
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

# =============================================================================
# Dotfiles Linking Functions
# =============================================================================

# Link dotfiles configuration
link_dotfiles() {
    print_header "Linking Dotfiles Configuration"
    
    local linked_count=0
    local failed_links=()
    
    # Create necessary directories
    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/zsh/completions" "$HOME/.config/git"

    # Desired logical sources and resolved targets
    local desired_sources=(
        ".zshrc"
        ".tmux.conf"
        ".gitconfig"
        "config/nvim"
        "bin"
        "completions/_dot"
        "hooks"
    )

    local targets=(
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
        "$HOME/.local/bin"
        "$HOME/.local/share/zsh/completions/_dot"
        "$HOME/.config/git/hooks"
    )

    # Resolve actual sources with fallbacks and auto-generation
    local sources=()
    for src in "${desired_sources[@]}"; do
        case "$src" in
            ".tmux.conf")
                if [[ -f "$DOTFILES_DIR/.tmux.conf" ]]; then
                    sources+=(".tmux.conf")
                elif [[ -f "$DOTFILES_DIR/config/tmux/tmux.conf" ]]; then
                    sources+=("config/tmux/tmux.conf")
                else
                    print_warning "Tmux config not found in repo"
                    sources+=(".tmux.conf")
                fi
                ;;
            ".gitconfig")
                if [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
                    sources+=(".gitconfig")
                elif [[ -f "$DOTFILES_DIR/config/gitconfig" ]]; then
                    sources+=("config/gitconfig")
                else
                    print_warning "Git config not found in repo"
                    sources+=(".gitconfig")
                fi
                ;;
            ".zshrc")
                if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
                    sources+=(".zshrc")
                else
                    local gen_file="$DOTFILES_DIR/.zshrc"
                    if [[ "$DRY_RUN" == "true" ]]; then
                        print_info "DRY RUN: Would generate $gen_file"
                    else
                        print_step "Generating minimal .zshrc in repository"
                        cat > "$gen_file" <<'RC'
# Generated by install.sh - minimal loader
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[[ -f "$DOTFILES_DIR/config/zsh/paths.zsh" ]] && source "$DOTFILES_DIR/config/zsh/paths.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/core.zsh" ]] && source "$DOTFILES_DIR/config/zsh/core.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/environment.zsh" ]] && source "$DOTFILES_DIR/config/zsh/environment.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/optimization.zsh" ]] && source "$DOTFILES_DIR/config/zsh/optimization.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/performance.zsh" ]] && source "$DOTFILES_DIR/config/zsh/performance.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/tools.zsh" ]] && source "$DOTFILES_DIR/config/zsh/tools.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/aliases.zsh" ]] && source "$DOTFILES_DIR/config/zsh/aliases.zsh"
[[ -f "$DOTFILES_DIR/config/zsh/completions.zsh" ]] && source "$DOTFILES_DIR/config/zsh/completions.zsh"
if [[ "$(uname -s)" == "Darwin" ]] && [[ -f "$DOTFILES_DIR/config/platform/macos.zsh" ]]; then
  source "$DOTFILES_DIR/config/platform/macos.zsh"
elif [[ -f "$DOTFILES_DIR/config/platform/linux.zsh" ]]; then
  source "$DOTFILES_DIR/config/platform/linux.zsh"
fi
[[ -f "$DOTFILES_DIR/config/zsh/ai-enhanced.zsh" ]] && source "$DOTFILES_DIR/config/zsh/ai-enhanced.zsh"
RC
                    fi
                    sources+=(".zshrc")
                fi
                ;;
            *)
                sources+=("$src")
                ;;
        esac
    done
    
    # Link each dotfile
    for i in "${!sources[@]}"; do
        local source_path="${sources[$i]}"
        local target_path="${targets[$i]}"
        local source_full="$DOTFILES_DIR/$source_path"
        
        if [[ ! -e "$source_full" ]]; then
            print_warning "Source not found: $source_full"
            # In dry-run mode, treat missing sources as warnings only
            if [[ "$DRY_RUN" != "true" ]]; then
                failed_links+=("$source_path (source missing)")
            fi
            continue
        fi
        
        if link_dotfile "$source_full" "$target_path"; then
            ((linked_count++))
        else
            failed_links+=("$source_path")
        fi
    done
    
    # Summary
    print_success "Successfully linked $linked_count dotfiles"
    
    if [[ ${#failed_links[@]} -gt 0 ]]; then
        print_warning "Failed to link: ${failed_links[*]}"
        # Do not fail the overall process in dry-run mode
        if [[ "$DRY_RUN" != "true" ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Link individual dotfile with backup
link_dotfile() {
    local source="$1"
    local target="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN: Would link $source -> $target"
        return 0
    fi
    
    # Check if target already exists
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            print_info "Already linked: $(basename "$target")"
            return 0
        fi
        
        # Backup existing file/link
        local backup_path="$BACKUP_DIR/$(basename "$target")"
        if [[ "$FORCE" == "true" ]] || [[ "$SKIP_EXISTING" == "false" ]]; then
            print_step "Backing up existing $(basename "$target") to $backup_path"
            mkdir -p "$BACKUP_DIR"
            if ! mv "$target" "$backup_path" 2>/dev/null; then
                print_error "Failed to backup $target"
                return 1
            fi
        else
            print_info "Skipping existing: $(basename "$target")"
            return 0
        fi
    fi
    
    # Create the symlink
    if ln -sf "$source" "$target"; then
        print_success "Linked: $(basename "$target") -> $source"
        return 0
    else
        print_error "Failed to link: $target -> $source"
        return 1
    fi
}

# Show available profiles
show_profiles() {
    print_header "Available Installation Profiles"
    
    echo "Profiles defined in config/tools.yaml:"
    echo ""
    
    # Extract profile information using python (only if PyYAML is available), otherwise fallback
    if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
        python3 -c "
import yaml
import sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        data = yaml.safe_load(f)
    
    if 'profiles' in data:
        for profile, config in data['profiles'].items():
            print(f'\033[0;34m{profile}\033[0m')
            if 'description' in config:
                print(f'  \033[0;36m{config[\"description\"]}\033[0m')
            print()
except Exception as e:
    print(f'Error reading profiles: {e}')
    sys.exit(1)
" 2>/dev/null
    else
        # Fallback to simple grep approach
        echo -e "${BLUE}minimal${NC}"
        echo -e "  ${CYAN}Minimal installation for basic functionality${NC}"
        echo ""
        echo -e "${BLUE}standard${NC}"
        echo -e "  ${CYAN}Standard development environment${NC}"
        echo ""
        echo -e "${BLUE}full${NC}"
        echo -e "  ${CYAN}Complete installation with all tools${NC}"
        echo ""
    fi
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
    link                  Link dotfiles configuration only (skip tool installation)
    
OPTIONS:
    -p, --profile PROFILE Installation profile (minimal|standard|full|ai_focused)
    -d, --dry-run         Show what would be done without executing
    -v, --verbose         Enable verbose output
    -f, --force           Force installation even if tools exist
    -s, --skip-existing   Skip tools that are already installed (default)
    --headless, --yes     Non-interactive mode; auto-accept safe actions
    -h, --help            Show this help message

EXAMPLES:
    $0 install standard                    # Install standard profile
    $0 --dry-run install full             # Preview full installation
    $0 --verbose --force install minimal  # Force install minimal with verbose output
    $0 profiles                           # Show available profiles
    $0 verify                            # Check current installation status
    $0 link                              # Link dotfiles configuration only
    $0 --dry-run link                    # Preview dotfiles linking

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
    # Agent mode implies headless defaults
    if [[ "${DOTFILES_MODE:-}" == "agent" ]]; then
        HEADLESS=true
        export DOTFILES_NONINTERACTIVE=1
        PROFILE="${PROFILE:-standard}"
    fi

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
            --headless|--yes)
                HEADLESS=true
                export DOTFILES_NONINTERACTIVE=1
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
            link)
                COMMAND="link"
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
            link_dotfiles
            
            # Final verification step
            if [[ "$DRY_RUN" == "false" ]]; then
                print_header "Final Verification"
                if "$DOTFILES_DIR/bin/dot" check; then
                    print_success "Setup completed and verified successfully!"
                    print_info "Please restart your shell or run 'source ~/.zshrc' to apply changes."
                    print_info "For a full reload, it's recommended to restart your terminal."
                    echo -e "${ROCKET} Enjoy your new streamlined environment! ${ROCKET}"
                else
                    print_error "Setup completed but verification failed."
                    print_warning "Run 'dot check' to see the issues."
                    return 1
                fi
            else
                print_success "Installation completed!"
            fi
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
        "link")
            print_header "Linking Dotfiles Only"
            link_dotfiles
            print_success "Linking completed!"
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