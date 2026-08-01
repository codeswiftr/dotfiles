#!/usr/bin/env bash
# =============================================================================
# Declarative Dotfiles Installer - 2025 Edition
# Uses tools.yaml configuration for declarative, reproducible installations
# =============================================================================

set -eo pipefail

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
PROFILE_EXPLICIT=false
DRY_RUN=false
VERBOSE=false
FORCE=false
SKIP_EXISTING=true
HEADLESS=false
NO_SUDO=false

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
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux-musl"* ]]; then
        if [[ -f /etc/alpine-release ]]; then
            echo "alpine"
        elif [[ -f /etc/arch-release ]]; then
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

# Returns Ubuntu version like "22", "24" or empty string
detect_ubuntu_version() {
    if [[ -f /etc/os-release ]]; then
        local ver
        ver=$(. /etc/os-release && echo "${VERSION_ID:-}" | cut -d. -f1)
        echo "$ver"
    fi
}

# YAML helpers (prefer Python PyYAML; fallback to legacy parsing)
# Resolve the first python3 that can actually import yaml. Probes absolute
# system paths before $PATH so a broken user shim (pyenv leftover, alias) can't
# silently force the regex fallback, which can't parse YAML block scalars.
PYYAML_PYTHON=""
has_pyyaml() {
    [[ -n "$PYYAML_PYTHON" ]] && return 0
    local candidate
    for candidate in /usr/bin/python3 /usr/local/bin/python3 /opt/homebrew/bin/python3 python3; do
        command -v "$candidate" >/dev/null 2>&1 || continue
        if "$candidate" -c 'import yaml' >/dev/null 2>&1; then
            PYYAML_PYTHON="$candidate"
            return 0
        fi
    done
    return 1
}

yaml_query_install_cmd() {
    local tool="$1" os="$2"
    if has_pyyaml; then
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$tool" "$os" <<'PY'
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
        # Try OS-specific first using more robust parsing
        local cmd
        cmd=$(sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        sed -n "/    install:/,/^    [a-zA-Z]/p" | \
        grep "      $os:" | sed 's/.*: *"\([^"]*\)".*/\1/')
        if [[ -z "$cmd" ]]; then
            # Fallback to 'all:'
            cmd=$(sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
            sed -n "/    install:/,/^    [a-zA-Z]/p" | \
            grep "      all:" | sed 's/.*: *"\([^"]*\)".*/\1/')
        fi
        echo "$cmd"
    fi
}

yaml_query_verify_cmd() {
    local tool="$1"
    if has_pyyaml; then
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$tool" <<'PY'
import sys, yaml
cfg_path, tool = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
print((data.get('tools', {}).get(tool, {}) or {}).get('verify', '') or '')
PY
    else
        sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        grep "    verify:" | sed 's/.*: *"\([^"]*\)".*/\1/'
    fi
}

# Returns provider name (e.g. "mise") when tools.yaml should not package-install the tool
yaml_query_provided_by() {
    local tool="$1"
    if has_pyyaml; then
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$tool" <<'PY'
import sys, yaml
cfg_path, tool = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
print((data.get('tools', {}).get(tool, {}) or {}).get('provided_by', '') or '')
PY
    else
        sed -n "/^  $tool:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
        grep "    provided_by:" | head -1 | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/' | tr -d ' '
    fi
}

yaml_query_post_install() {
    local tool="$1"
    if has_pyyaml; then
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$tool" <<'PY'
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

yaml_query_node_profile() {
    local hostname="$1"
    if has_pyyaml; then
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$hostname" <<'PY'
import sys, yaml
cfg_path, hostname = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
node = (data.get('nodes', {}) or {}).get(hostname, {}) or {}
print(node.get('profile', '') or '')
PY
    else
        sed -n "/^  ${hostname}:/,/^  [a-zA-Z]/p" "$CONFIG_FILE" | \
            grep "^    profile:" | head -1 | \
            sed 's/^    profile:[[:space:]]*//;s/[[:space:]]*$//'
    fi
}

yaml_query_group_tools() {
    local group="$1"
    if has_pyyaml; then
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$group" <<'PY'
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
        "$PYYAML_PYTHON" - "$CONFIG_FILE" "$profile" <<'PY'
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

    # mise-owned tools: version pins live in mise.toml (bootstrapped earlier)
    local provided_by
    provided_by=$(yaml_query_provided_by "$tool" 2>/dev/null || true)
    if [[ "$provided_by" == "mise" ]]; then
        if verify_tool "$tool"; then
            print_info "$tool provided by mise (already available)"
            return 0
        fi
        print_info "$tool is mise-managed — run: mise install  (see mise.toml)"
        # Not a hard failure: install may continue offline or with partial mise
        return 0
    fi

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

    # Skip sudo commands in --no-sudo mode (return 2 = skipped, not success)
    if [[ "$NO_SUDO" == "true" ]] && [[ "$install_cmd" == *"sudo "* ]]; then
        print_info "Skipping $tool (requires sudo)"
        return 2
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
                        # Skip sudo commands in post-install too
                        if [[ "$NO_SUDO" == "true" ]] && [[ "$cmd" == *"sudo "* ]]; then
                            print_info "Skipping post-install (requires sudo): $cmd"
                            continue
                        fi
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
    local skipped_tools=()

    while IFS= read -r tool; do
        if [[ -n "$tool" ]]; then
            install_tool "$tool"
            local rc=$?
            if [[ $rc -eq 1 ]]; then
                failed_tools+=("$tool")
            elif [[ $rc -eq 2 ]]; then
                skipped_tools+=("$tool")
            fi
        fi
    done <<< "$tools"

    if [[ ${#skipped_tools[@]} -gt 0 ]]; then
        print_warning "Skipped tools in $group (require sudo): ${skipped_tools[*]}"
    fi

    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        print_warning "Failed to install some tools in group $group: ${failed_tools[*]}"
        return 1
    elif [[ ${#skipped_tools[@]} -gt 0 ]]; then
        print_warning "Group $group: ${#skipped_tools[@]} tool(s) skipped (require sudo)"
        return 1
    else
        print_success "Successfully installed all tools in group: $group"
        return 0
    fi
}

# Install mise and activate it so mise-managed tools work during install
install_mise_bootstrap() {
    print_step "Bootstrapping mise (universal version manager)..."

    # Set musl flag for Alpine
    [[ -f /etc/alpine-release ]] && export MISE_LIBC=musl

    if ! command -v mise >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "DRY RUN: Would install mise v2025.4.0"
            return 0
        fi
        if [[ "$NO_SUDO" == "true" ]] || [[ "$(detect_os)" != "macos" ]]; then
            curl -fsSL https://mise.run | MISE_VERSION=v2025.4.0 sh
            export PATH="$HOME/.local/bin:$PATH"
        else
            brew install mise 2>/dev/null || curl -fsSL https://mise.run | MISE_VERSION=v2025.4.0 sh
        fi
    else
        print_info "mise already installed: $(mise --version 2>/dev/null)"
    fi

    # Activate mise in this shell so subsequent installs see the shims
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate bash 2>/dev/null)" 2>/dev/null || \
            export PATH="$HOME/.local/share/mise/shims:$PATH"

        # Sync global mise config from dotfiles and install pinned tools
        local mise_config_src="$DOTFILES_DIR/mise.toml"
        local mise_config_dst="$HOME/.config/mise/config.toml"
        if [[ -f "$mise_config_src" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "DRY RUN: Would copy mise.toml → $mise_config_dst and run mise install"
            else
                mkdir -p "$(dirname "$mise_config_dst")"
                # Trust the source config so mise doesn't block on untrusted files
                mise trust "$mise_config_src" >/dev/null 2>&1 || true
                if ! diff -q "$mise_config_src" "$mise_config_dst" >/dev/null 2>&1; then
                    cp "$mise_config_src" "$mise_config_dst"
                    mise trust "$mise_config_dst" >/dev/null 2>&1 || true
                    print_step "Installing mise-managed tools (pinned versions)..."
                    mise install --quiet 2>/dev/null && \
                        print_success "mise tools installed" || \
                        print_warning "Some mise tools failed — run 'mise install' manually"
                else
                    print_info "mise config unchanged, skipping install"
                fi
            fi
        fi
    else
        print_warning "mise install failed — user-level tools may be unavailable"
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
            # Check for Xcode CLI tools first (required for git, compilers, etc.)
            if ! xcode-select -p &>/dev/null; then
                print_step "Installing Xcode Command Line Tools..."
                print_info "This may take a few minutes..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install Xcode Command Line Tools"
                else
                    xcode-select --install 2>/dev/null || true
                    # Wait for Xcode CLI tools installation
                    local timeout=300  # 5 minutes
                    local elapsed=0
                    echo -e "${YELLOW}Waiting for Xcode Command Line Tools installation...${NC}"
                    echo -e "${CYAN}If a dialog appeared, please click 'Install' and wait for completion.${NC}"
                    while ! xcode-select -p &>/dev/null && [[ $elapsed -lt $timeout ]]; do
                        sleep 5
                        ((elapsed+=5))
                        echo -n "."
                    done
                    echo ""
                    if xcode-select -p &>/dev/null; then
                        print_success "Xcode Command Line Tools installed"
                    else
                        print_error "Xcode Command Line Tools installation timed out"
                        print_info "Please run 'xcode-select --install' manually and try again"
                        return 1
                    fi
                fi
            else
                print_info "Xcode Command Line Tools already installed"
            fi

            if ! command_exists brew; then
                print_step "Installing Homebrew..."
                print_info "This is the macOS package manager - required for installing development tools"
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install Homebrew"
                else
                    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                        print_error "Failed to install Homebrew"
                        print_info "Please visit https://brew.sh for manual installation instructions"
                        return 1
                    fi

                    # Setup Homebrew PATH for Apple Silicon
                    if [[ "$(uname -m)" == "arm64" ]]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                        print_info "Apple Silicon detected - Homebrew installed at /opt/homebrew"
                    else
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                    print_success "Homebrew installed successfully"
                fi
            else
                print_info "Homebrew already installed"
            fi
            
            # Ensure PyYAML is available for better YAML parsing
            if ! has_pyyaml; then
                print_step "Installing PyYAML for better configuration parsing..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install PyYAML"
                else
                    python3 -m pip install --user PyYAML || pip3 install PyYAML || true
                fi
            fi
            ;;
        "ubuntu")
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "DRY RUN: Would update apt packages"
            elif [[ "$NO_SUDO" == "true" ]]; then
                print_info "Skipping apt setup (--no-sudo mode)"
            else
                print_step "Updating apt package lists..."
                # Only update, skip upgrade for faster installs (upgrade is optional)
                $SUDO_CMD apt update -qq
                print_success "Package lists updated"

                # Install essential build tools for external installers
                print_step "Installing essential dependencies..."
                $SUDO_CMD apt install -y build-essential curl wget git ca-certificates || true
            fi

            # Ensure PyYAML is available for better YAML parsing
            if ! has_pyyaml; then
                print_step "Installing PyYAML for better configuration parsing..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install PyYAML"
                elif [[ "$NO_SUDO" == "true" ]]; then
                    # Try user install without sudo
                    python3 -m pip install --user PyYAML 2>/dev/null || pip3 install --user PyYAML 2>/dev/null || true
                else
                    $SUDO_CMD apt install -y python3-pip python3-yaml || python3 -m pip install --user PyYAML || pip3 install PyYAML || true
                fi
            fi
            ;;
        "alpine")
            print_step "Setting up Alpine package manager..."
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "DRY RUN: Would run apk update"
            else
                apk update && print_success "apk updated"
            fi
            export MISE_LIBC=musl
            ;;
        "arch")
            if ! command_exists yay; then
                print_step "Installing yay AUR helper..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install yay"
                else
                    local _yay_tmp
                    _yay_tmp=$(mktemp -d)
                    git clone https://aur.archlinux.org/yay.git "$_yay_tmp/yay" || { print_warning "Failed to clone yay"; rm -rf "$_yay_tmp"; return 1; }
                    (cd "$_yay_tmp/yay" && makepkg -si --noconfirm)
                    rm -rf "$_yay_tmp"
                    print_success "yay installed"
                fi
            else
                print_info "yay already installed"
            fi

            # Ensure PyYAML is available for better YAML parsing
            if ! has_pyyaml; then
                print_step "Installing PyYAML for better configuration parsing..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    print_info "DRY RUN: Would install PyYAML"
                else
                    sudo pacman -S --noconfirm python-pip python-yaml || python3 -m pip install --user PyYAML || pip3 install PyYAML || true
                fi
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

# Link dotfiles configuration (chezmoi preferred, fallback to manual)
link_dotfiles() {
    # Use chezmoi if available (manages templates, symlinks, and run_onchange)
    if command -v chezmoi >/dev/null 2>&1; then
        print_header "Applying Dotfiles via chezmoi"
        # home/ is the chezmoi source tree (templates use sourceDir/.. for repo roots).
        local chezmoi_src="$DOTFILES_DIR/home"
        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "DRY RUN: Would apply dotfiles via chezmoi"
            chezmoi --source "$chezmoi_src" managed 2>/dev/null | while read -r f; do
                print_info "  Would manage: ~/$f"
            done
            return 0
        fi
        if chezmoi --source "$chezmoi_src" apply --force; then
            print_success "Dotfiles applied via chezmoi"
            return 0
        fi
        print_warning "chezmoi apply failed — falling back to manual linking"
        # fall through to manual linker below
    fi

    # Fallback: manual symlink-based linking (no chezmoi, or chezmoi failed)
    print_header "Linking Dotfiles Configuration"
    
    local linked_count=0
    local failed_links=()
    
    # Create necessary directories
    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/zsh/completions" "$HOME/.config/git"

    # Desired logical sources and resolved targets
    # Managed file manifest (see ARCHITECTURE.md)
    # Note: bin/ is NOT linked -- it's on $PATH via defaults.zsh
    local desired_sources=(
        ".zshrc"
        "config/zsh/.zshenv"
        "config/zsh/.zprofile"
        ".tmux.conf"
        ".gitconfig"
        "config/nvim"
        "config/starship.toml"
        "completions/_dot"
        "hooks"
    )

    local targets=(
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.zprofile"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
        "$HOME/.config/starship.toml"
        "$HOME/.local/share/zsh/completions/_dot"
        "$HOME/.config/git/hooks"
    )

    # Resolve actual sources (canonical paths, no fallbacks)
    local sources=()
    for src in "${desired_sources[@]}"; do
        case "$src" in
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
# Generated by install.sh - minimal loader matching active module chain
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export ZSH_CONFIG_DIR="$DOTFILES_DIR/config/zsh"

# SSH session detection
[[ -n "$SSH_CONNECTION" ]] && export DOTFILES_SSH=1

# Core configuration
[[ -f "$ZSH_CONFIG_DIR/defaults.zsh" ]] && source "$ZSH_CONFIG_DIR/defaults.zsh"
[[ -f "$ZSH_CONFIG_DIR/core.zsh" ]] && source "$ZSH_CONFIG_DIR/core.zsh"
[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"
[[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"

# Tool initialization (SSH-aware)
if [[ -z "$DOTFILES_SSH" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/tools-optimized.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-optimized.zsh"
else
    [[ -f "$ZSH_CONFIG_DIR/tools-minimal.zsh" ]] && source "$ZSH_CONFIG_DIR/tools-minimal.zsh"
fi

# User experience
[[ -f "$ZSH_CONFIG_DIR/history-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/history-enhanced.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"

# Optional features
[[ -f "$ZSH_CONFIG_DIR/ai-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/ai-enhanced.zsh"

# Local customizations
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
[[ -f "$HOME/.env.local" ]] && source "$HOME/.env.local"
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
            ((++linked_count))
        else
            failed_links+=("$source_path")
        fi
    done
    
    # Configure git to use our hooks directory
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN: Would set git core.hooksPath"
    else
        git config --global core.hooksPath "$HOME/.config/git/hooks" 2>/dev/null \
            && print_success "Git hooks path configured" \
            || print_warning "Could not configure git hooks path"
    fi

    # Summary
    print_success "Successfully linked $linked_count dotfiles"

    if [[ ${#failed_links[@]} -gt 0 ]]; then
        print_warning "Failed to link: ${failed_links[*]}"
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

# =============================================================================
# Claude Code Configuration Linking
# =============================================================================

# Link Claude Code configuration files
link_claude_config() {
    print_header "Linking Claude Code Configuration"

    local claude_source="$DOTFILES_DIR/config/claude"
    local claude_target="$HOME/.claude"
    local linked_count=0
    local failed_links=()

    # Check if Claude config exists in dotfiles
    if [[ ! -d "$claude_source" ]]; then
        print_info "Claude Code config not found in dotfiles, skipping"
        return 0
    fi

    # Create ~/.claude if it doesn't exist
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN: Would create $claude_target"
    else
        mkdir -p "$claude_target"
    fi

    # Link directories (commands, agents, skills, output-styles)
    local dirs=("commands" "agents" "skills" "output-styles")
    for dir in "${dirs[@]}"; do
        if [[ -d "$claude_source/$dir" ]]; then
            if link_dotfile "$claude_source/$dir" "$claude_target/$dir"; then
                ((++linked_count))
            else
                failed_links+=("$dir")
            fi
        fi
    done

    # Link individual files
    local files=("CLAUDE.md" "WORKFLOW_GUIDE.md" "starship-statusline.sh")
    for file in "${files[@]}"; do
        if [[ -f "$claude_source/$file" ]]; then
            if link_dotfile "$claude_source/$file" "$claude_target/$file"; then
                ((++linked_count))
            else
                failed_links+=("$file")
            fi
        fi
    done

    # Handle settings.json template
    if [[ -f "$claude_source/settings.json.template" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "DRY RUN: Would generate $claude_target/settings.json from template"
        elif [[ ! -f "$claude_target/settings.json" ]]; then
            print_step "Generating settings.json from template..."
            # Expand $HOME in the template
            sed "s|\$HOME|$HOME|g" "$claude_source/settings.json.template" > "$claude_target/settings.json"
            print_success "Generated settings.json"
            ((++linked_count))
        else
            print_info "settings.json already exists, skipping (won't overwrite)"
        fi
    fi

    # Summary
    print_success "Successfully linked $linked_count Claude Code configs"

    if [[ ${#failed_links[@]} -gt 0 ]]; then
        print_warning "Failed to link: ${failed_links[*]}"
    fi

    return 0
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
    --no-sudo             Install user-space tools only (no root required)
    -h, --help            Show this help message

EXAMPLES:
    $0 install standard                    # Install standard profile
    $0 --dry-run install full             # Preview full installation
    $0 --verbose --force install minimal  # Force install minimal with verbose output
    $0 --no-sudo install standard         # Install without sudo (user tools only)
    $0 profiles                           # Show available profiles
    $0 verify                            # Check current installation status
    $0 link                              # Link dotfiles configuration only

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

# =============================================================================
# Plugin Validation Functions
# =============================================================================

# Validate Neovim plugins are installed
validate_nvim_plugins() {
    print_step "Validating Neovim plugin setup..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN: Would validate Neovim plugins"
        return 0
    fi

    if ! command_exists nvim; then
        print_warning "Neovim not installed, skipping plugin validation"
        return 0
    fi

    local nvim_config="$HOME/.config/nvim"
    local lazy_dir="$HOME/.local/share/nvim/lazy"

    # Check if config is linked
    if [[ ! -d "$nvim_config" ]]; then
        print_warning "Neovim config not found at $nvim_config"
        return 1
    fi

    # Check for lazy.nvim bootstrap (verify lua/ exists to detect partial clones)
    if [[ -d "$lazy_dir/lazy.nvim/lua" ]]; then
        print_success "lazy.nvim plugin manager installed"
    else
        print_info "Bootstrapping lazy.nvim (first-time setup)..."
        # Run nvim headlessly to bootstrap plugins
        if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
            print_success "Neovim plugins installed successfully"
        else
            print_warning "Plugin installation may need manual intervention"
            print_info "Run 'nvim' and wait for plugins to install, or run ':Lazy sync'"
        fi
    fi

    # Count installed plugins
    if [[ -d "$lazy_dir" ]]; then
        local plugin_count
        plugin_count=$(find "$lazy_dir" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        ((plugin_count--)) # Subtract 1 for the lazy_dir itself
        print_info "Neovim plugins installed: $plugin_count"
    fi

    return 0
}

# Validate Tmux plugins are installed
validate_tmux_plugins() {
    print_step "Validating Tmux plugin setup..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN: Would validate Tmux plugins"
        return 0
    fi

    if ! command_exists tmux; then
        print_warning "Tmux not installed, skipping plugin validation"
        return 0
    fi

    local tpm_dir="$HOME/.tmux/plugins/tpm"

    # Check for TPM (verify bin/ exists to detect partial clones)
    if [[ -d "$tpm_dir" ]] && [[ -f "$tpm_dir/bin/install_plugins" ]]; then
        print_success "TPM (Tmux Plugin Manager) installed"
    else
        print_info "Installing TPM (Tmux Plugin Manager)..."
        if git clone https://github.com/tmux-plugins/tpm "$tpm_dir" 2>/dev/null; then
            print_success "TPM installed successfully"
        else
            print_warning "Failed to install TPM"
            print_info "TPM will auto-install on first tmux session"
        fi
    fi

    # Install plugins via TPM if it exists
    if [[ -d "$tpm_dir" ]] && [[ -f "$tpm_dir/bin/install_plugins" ]]; then
        print_info "Installing Tmux plugins via TPM..."
        if "$tpm_dir/bin/install_plugins" >/dev/null 2>&1; then
            print_success "Tmux plugins installed"
        else
            print_info "Plugins will install on first tmux session"
        fi
    fi

    # Count installed plugins
    local plugins_dir="$HOME/.tmux/plugins"
    if [[ -d "$plugins_dir" ]]; then
        local plugin_count
        plugin_count=$(find "$plugins_dir" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        ((plugin_count--)) # Subtract 1 for the plugins_dir itself
        print_info "Tmux plugins installed: $plugin_count"
    fi

    return 0
}

# Run all post-installation validations
run_post_install_validations() {
    print_header "Post-Installation Validation"

    validate_nvim_plugins
    validate_tmux_plugins

    print_success "Post-installation validation complete"
}

# Ensure PATH includes common tool locations
setup_paths() {
    # Add common binary directories to PATH for this session
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.atuin/bin:$PATH"

    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"
}

# Setup sudo for non-interactive use
# Sets SUDO_CMD variable to use throughout the script
setup_sudo_cmd() {
    local os="${1:-$(detect_os)}"

    # Skip for macOS (uses different privilege model)
    if [[ "$os" == "macos" ]]; then
        SUDO_CMD="sudo"
        return 0
    fi

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        SUDO_CMD=""
        return 0
    fi

    # Check if sudo exists
    if ! command_exists sudo; then
        print_warning "sudo not found - some tools may fail to install"
        SUDO_CMD=""
        return 0
    fi

    # Check if we have a TTY
    if [[ -t 0 ]]; then
        # Interactive mode - can prompt for password
        SUDO_CMD="sudo"
        if [[ "$DRY_RUN" != "true" ]]; then
            print_info "Some operations require administrator privileges."
            # Pre-authenticate to cache credentials
            sudo -v || {
                print_warning "sudo authentication failed. Some tools may not install."
                return 1
            }
            # Keep sudo alive in background
            (while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null) &
        fi
    else
        # Non-interactive mode - check for passwordless sudo
        if sudo -n true 2>/dev/null; then
            SUDO_CMD="sudo"
            print_info "Using passwordless sudo"
        else
            print_error "No TTY for sudo password prompt."
            print_info "Run with: bash -c \"\$(curl -fsSL URL)\""
            print_info "Or pre-authenticate: sudo -v && ./install.sh"
            return 1
        fi
    fi

    return 0
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
                PROFILE_EXPLICIT=true
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
            --no-sudo)
                NO_SUDO=true
                SUDO_CMD=""
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
                    PROFILE_EXPLICIT=true
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
            # Auto-detect profile from nodes map if not explicitly provided
            if [[ "$PROFILE_EXPLICIT" == "false" ]]; then
                local _node_hostname _node_profile
                _node_hostname=$(hostname -s 2>/dev/null || hostname)
                _node_profile=$(yaml_query_node_profile "$_node_hostname")
                if [[ -n "$_node_profile" ]]; then
                    PROFILE="$_node_profile"
                    print_info "Auto-detected profile '$PROFILE' for node '$_node_hostname'"
                fi
            fi

            print_header "Modern Dotfiles Installation - 2025 Edition"
            print_info "Profile: $PROFILE"
            print_info "OS: $(detect_os)"

            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "DRY RUN MODE - No changes will be made"
            fi

            # Validate profile name early — reject unknown profiles before doing any work
            local _valid_profiles
            _valid_profiles=$(yaml_query_profile_groups "$PROFILE" 2>/dev/null)
            if [[ -z "$_valid_profiles" ]]; then
                print_error "Unknown profile: '$PROFILE'"
                print_info "Valid profiles: minimal, standard, full, ai_focused"
                print_info "Run './install.sh profiles' to see details"
                exit 1
            fi

            # Setup paths early
            setup_paths

            # Setup sudo (skip in dry-run mode or --no-sudo mode)
            if [[ "$DRY_RUN" != "true" ]] && [[ "$NO_SUDO" != "true" ]]; then
                setup_sudo_cmd "$(detect_os)" || {
                    print_error "Cannot proceed without sudo access"
                    print_info "Use --no-sudo to install user-space tools only"
                    exit 1
                }
            elif [[ "$NO_SUDO" == "true" ]]; then
                SUDO_CMD=""
                print_warning "Running without sudo - only user-space tools will be installed"
                print_info "Tools requiring apt/sudo will be skipped"
            else
                SUDO_CMD="sudo"  # Placeholder for dry-run display
            fi

            # Track whether any step had failures
            local _install_warnings=false

            # Package manager is required — abort if it fails
            if ! setup_package_manager; then
                print_error "Package manager setup failed — cannot continue"
                print_info "Fix the package manager issue above and re-run the installer"
                exit 1
            fi

            # mise is nice-to-have; warn but continue on failure
            if ! install_mise_bootstrap; then
                print_warning "mise bootstrap failed — version-managed tools may be unavailable"
                _install_warnings=true
            fi

            # Profile install: partial success is acceptable
            if ! install_profile "$PROFILE"; then
                print_warning "Some tools in profile '$PROFILE' failed to install"
                _install_warnings=true
            fi

            # Dotfile linking: warn but continue
            if ! link_dotfiles; then
                print_warning "Some dotfiles failed to link — run './install.sh link' to retry"
                _install_warnings=true
            fi

            # Link Claude config (only needed if chezmoi wasn't used above)
            if ! command -v chezmoi >/dev/null 2>&1; then
                link_claude_config
            fi

            # Run plugin validations and setup
            run_post_install_validations

            # Final verification step
            if [[ "$DRY_RUN" == "false" ]]; then
                print_header "Final Verification"
                if "$DOTFILES_DIR/bin/dot" check 2>/dev/null; then
                    print_success "Setup completed and verified successfully!"
                else
                    print_warning "Some checks may need attention. Run 'dot check' for details."
                fi
                echo ""
                if [[ "$_install_warnings" == "true" ]]; then
                    print_warning "Installation completed with warnings. Some tools failed to install."
                    print_info "Review the log and re-run to retry failed steps."
                else
                    print_success "Installation complete!"
                fi
                print_info "Please restart your shell or run 'source ~/.zshrc' to apply changes."
                print_info "For a full reload, it's recommended to restart your terminal."
                echo ""
                echo -e "${ROCKET} Enjoy your new streamlined environment! ${ROCKET}"
            else
                print_success "Dry run completed - no changes made!"
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
            # Link Claude config (only needed if chezmoi wasn't used)
            if ! command -v chezmoi >/dev/null 2>&1; then
                link_claude_config
            fi
            print_success "Linking completed!"
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments (only when executed directly, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi