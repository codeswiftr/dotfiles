#!/usr/bin/env bash
# =============================================================================
# Cross-Platform Compatibility Framework
# Unified platform detection and compatibility layer
# =============================================================================

# Platform detection variables
PLATFORM_OS=""
PLATFORM_DISTRO=""
PLATFORM_ARCH=""
PLATFORM_SHELL=""
PLATFORM_PACKAGE_MANAGER=""

# Initialize platform detection
detect_platform() {
    # Detect operating system
    case "$OSTYPE" in
        linux-gnu*)
            PLATFORM_OS="linux"
            detect_linux_distro
            ;;
        darwin*)
            PLATFORM_OS="macos"
            PLATFORM_DISTRO="macos"
            ;;
        cygwin*)
            PLATFORM_OS="windows"
            PLATFORM_DISTRO="cygwin"
            ;;
        msys*)
            PLATFORM_OS="windows"
            PLATFORM_DISTRO="msys"
            ;;
        win32*)
            PLATFORM_OS="windows"
            PLATFORM_DISTRO="native"
            ;;
        freebsd*)
            PLATFORM_OS="freebsd"
            PLATFORM_DISTRO="freebsd"
            ;;
        *)
            PLATFORM_OS="unknown"
            PLATFORM_DISTRO="unknown"
            ;;
    esac
    
    # Detect architecture
    PLATFORM_ARCH=$(uname -m 2>/dev/null || echo "unknown")
    case "$PLATFORM_ARCH" in
        x86_64|amd64)
            PLATFORM_ARCH="x64"
            ;;
        i386|i686)
            PLATFORM_ARCH="x86"
            ;;
        arm64|aarch64)
            PLATFORM_ARCH="arm64"
            ;;
        armv7*)
            PLATFORM_ARCH="arm"
            ;;
    esac
    
    # Detect shell
    PLATFORM_SHELL=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    
    # Detect package manager
    detect_package_manager
}

# Detect Linux distribution
detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        PLATFORM_DISTRO="$ID"
    elif [[ -f /etc/debian_version ]]; then
        PLATFORM_DISTRO="debian"
    elif [[ -f /etc/redhat-release ]]; then
        PLATFORM_DISTRO="rhel"
    elif [[ -f /etc/arch-release ]]; then
        PLATFORM_DISTRO="arch"
    elif [[ -f /etc/alpine-release ]]; then
        PLATFORM_DISTRO="alpine"
    else
        PLATFORM_DISTRO="unknown"
    fi
    
    # Handle special cases
    case "$PLATFORM_DISTRO" in
        ubuntu|debian)
            PLATFORM_DISTRO="debian"
            ;;
        centos|rhel|fedora)
            PLATFORM_DISTRO="rhel"
            ;;
        manjaro|endeavouros)
            PLATFORM_DISTRO="arch"
            ;;
    esac
}

# Detect package manager
detect_package_manager() {
    case "$PLATFORM_OS" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                PLATFORM_PACKAGE_MANAGER="brew"
            elif command -v port >/dev/null 2>&1; then
                PLATFORM_PACKAGE_MANAGER="macports"
            else
                PLATFORM_PACKAGE_MANAGER="none"
            fi
            ;;
        linux)
            case "$PLATFORM_DISTRO" in
                debian)
                    PLATFORM_PACKAGE_MANAGER="apt"
                    ;;
                rhel)
                    if command -v dnf >/dev/null 2>&1; then
                        PLATFORM_PACKAGE_MANAGER="dnf"
                    elif command -v yum >/dev/null 2>&1; then
                        PLATFORM_PACKAGE_MANAGER="yum"
                    fi
                    ;;
                arch)
                    PLATFORM_PACKAGE_MANAGER="pacman"
                    ;;
                alpine)
                    PLATFORM_PACKAGE_MANAGER="apk"
                    ;;
                *)
                    PLATFORM_PACKAGE_MANAGER="unknown"
                    ;;
            esac
            ;;
        windows)
            if command -v choco >/dev/null 2>&1; then
                PLATFORM_PACKAGE_MANAGER="chocolatey"
            elif command -v winget >/dev/null 2>&1; then
                PLATFORM_PACKAGE_MANAGER="winget"
            elif command -v scoop >/dev/null 2>&1; then
                PLATFORM_PACKAGE_MANAGER="scoop"
            else
                PLATFORM_PACKAGE_MANAGER="none"
            fi
            ;;
        *)
            PLATFORM_PACKAGE_MANAGER="unknown"
            ;;
    esac
}

# Platform-specific path helpers
get_config_dir() {
    case "$PLATFORM_OS" in
        macos)
            echo "$HOME/Library/Application Support"
            ;;
        linux)
            echo "${XDG_CONFIG_HOME:-$HOME/.config}"
            ;;
        windows)
            echo "${APPDATA:-$HOME/AppData/Roaming}"
            ;;
        *)
            echo "$HOME/.config"
            ;;
    esac
}

get_cache_dir() {
    case "$PLATFORM_OS" in
        macos)
            echo "$HOME/Library/Caches"
            ;;
        linux)
            echo "${XDG_CACHE_HOME:-$HOME/.cache}"
            ;;
        windows)
            echo "${LOCALAPPDATA:-$HOME/AppData/Local}"
            ;;
        *)
            echo "$HOME/.cache"
            ;;
    esac
}

get_data_dir() {
    case "$PLATFORM_OS" in
        macos)
            echo "$HOME/Library/Application Support"
            ;;
        linux)
            echo "${XDG_DATA_HOME:-$HOME/.local/share}"
            ;;
        windows)
            echo "${APPDATA:-$HOME/AppData/Roaming}"
            ;;
        *)
            echo "$HOME/.local/share"
            ;;
    esac
}

get_bin_dir() {
    case "$PLATFORM_OS" in
        macos)
            if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
                echo "/opt/homebrew/bin"
            else
                echo "/usr/local/bin"
            fi
            ;;
        linux)
            echo "$HOME/.local/bin"
            ;;
        windows)
            echo "$HOME/bin"
            ;;
        *)
            echo "$HOME/.local/bin"
            ;;
    esac
}

# Package installation wrapper
install_package() {
    local package="$1"
    local package_manager_override="$2"
    
    local pm="${package_manager_override:-$PLATFORM_PACKAGE_MANAGER}"
    
    case "$pm" in
        apt)
            sudo apt update && sudo apt install -y "$package"
            ;;
        brew)
            brew install "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        yum)
            sudo yum install -y "$package"
            ;;
        apk)
            sudo apk add "$package"
            ;;
        chocolatey)
            choco install "$package" -y
            ;;
        winget)
            winget install "$package"
            ;;
        scoop)
            scoop install "$package"
            ;;
        *)
            echo "Unsupported package manager: $pm"
            return 1
            ;;
    esac
}

# Cross-platform command wrappers
xopen() {
    local target="$1"
    
    case "$PLATFORM_OS" in
        macos)
            open "$target"
            ;;
        linux)
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$target"
            elif command -v gnome-open >/dev/null 2>&1; then
                gnome-open "$target"
            else
                echo "No suitable open command found"
                return 1
            fi
            ;;
        windows)
            if command -v start >/dev/null 2>&1; then
                start "$target"
            else
                cmd /c start "$target"
            fi
            ;;
        *)
            echo "Unsupported platform for open command"
            return 1
            ;;
    esac
}

xcopy() {
    local source="$1"
    local dest="$2"
    
    case "$PLATFORM_OS" in
        macos)
            if command -v pbcopy >/dev/null 2>&1; then
                echo "$source" | pbcopy
            else
                cp "$source" "$dest"
            fi
            ;;
        linux)
            if command -v xclip >/dev/null 2>&1; then
                echo "$source" | xclip -selection clipboard
            elif command -v xsel >/dev/null 2>&1; then
                echo "$source" | xsel --clipboard --input
            else
                cp "$source" "$dest"
            fi
            ;;
        windows)
            if command -v clip >/dev/null 2>&1; then
                echo "$source" | clip
            else
                copy "$source" "$dest"
            fi
            ;;
        *)
            cp "$source" "$dest"
            ;;
    esac
}

xpaste() {
    case "$PLATFORM_OS" in
        macos)
            pbpaste
            ;;
        linux)
            if command -v xclip >/dev/null 2>&1; then
                xclip -selection clipboard -o
            elif command -v xsel >/dev/null 2>&1; then
                xsel --clipboard --output
            else
                echo "No clipboard utility found"
                return 1
            fi
            ;;
        windows)
            powershell -command "Get-Clipboard"
            ;;
        *)
            echo "Unsupported platform for paste command"
            return 1
            ;;
    esac
}

# Platform-specific tool installation
install_modern_tools() {
    echo "🔧 Installing modern development tools for $PLATFORM_OS..."
    
    case "$PLATFORM_OS" in
        macos)
            install_macos_tools
            ;;
        linux)
            install_linux_tools
            ;;
        windows)
            install_windows_tools
            ;;
        *)
            echo "Unsupported platform: $PLATFORM_OS"
            return 1
            ;;
    esac
}

install_macos_tools() {
    # Install Homebrew if not present
    if ! command -v brew >/dev/null 2>&1; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon
        if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    # Essential tools
    local tools=(
        "git"
        "zsh"
        "starship"
        "eza"
        "bat"
        "ripgrep"
        "fd"
        "fzf"
        "zoxide"
        "tmux"
        "neovim"
    )
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "📦 Installing $tool..."
            brew install "$tool"
        fi
    done
    
    # Development tools
    local dev_tools=(
        "mise"
        "uv"
        "bun"
        "docker"
    )
    
    for tool in "${dev_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "📦 Installing $tool..."
            if [[ "$tool" == "docker" ]]; then
                brew install --cask docker
            else
                brew install "$tool"
            fi
        fi
    done
}

install_linux_tools() {
    # Update package manager
    case "$PLATFORM_PACKAGE_MANAGER" in
        apt)
            sudo apt update
            ;;
        dnf)
            sudo dnf check-update || true
            ;;
        pacman)
            sudo pacman -Sy
            ;;
    esac
    
    # Essential tools with platform-specific names
    local tools=()
    case "$PLATFORM_PACKAGE_MANAGER" in
        apt)
            tools=(
                "git"
                "zsh"
                "curl"
                "wget"
                "tmux"
                "ripgrep"
                "fd-find"
                "fzf"
                "bat"
            )
            ;;
        pacman)
            tools=(
                "git"
                "zsh"
                "curl"
                "wget"
                "tmux"
                "ripgrep"
                "fd"
                "fzf"
                "bat"
                "eza"
            )
            ;;
        dnf)
            tools=(
                "git"
                "zsh"
                "curl"
                "wget"
                "tmux"
                "ripgrep"
                "fd-find"
                "fzf"
                "bat"
            )
            ;;
    esac
    
    for tool in "${tools[@]}"; do
        echo "📦 Installing $tool..."
        install_package "$tool"
    done
    
    # Install tools from external sources
    install_linux_external_tools
}

install_linux_external_tools() {
    local bin_dir=$(get_bin_dir)
    mkdir -p "$bin_dir"
    
    # Starship
    if ! command -v starship >/dev/null 2>&1; then
        echo "📦 Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$bin_dir"
    fi
    
    # Zoxide
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "📦 Installing Zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    # mise
    if ! command -v mise >/dev/null 2>&1; then
        echo "📦 Installing mise..."
        curl https://mise.run | sh
    fi
    
    # uv
    if ! command -v uv >/dev/null 2>&1; then
        echo "📦 Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    
    # Bun
    if ! command -v bun >/dev/null 2>&1; then
        echo "📦 Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
}

install_windows_tools() {
    # Install package manager if not present
    if ! command -v choco >/dev/null 2>&1 && ! command -v winget >/dev/null 2>&1; then
        echo "📦 Installing Chocolatey..."
        powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    fi
    
    local tools=(
        "git"
        "starship"
        "ripgrep"
        "fd"
        "fzf"
        "bat"
        "eza"
        "neovim"
    )
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "📦 Installing $tool..."
            if command -v choco >/dev/null 2>&1; then
                choco install "$tool" -y
            elif command -v winget >/dev/null 2>&1; then
                winget install "$tool"
            fi
        fi
    done
}

# Environment variable helpers
set_platform_vars() {
    export PLATFORM_OS
    export PLATFORM_DISTRO
    export PLATFORM_ARCH
    export PLATFORM_SHELL
    export PLATFORM_PACKAGE_MANAGER
    
    # Set platform-specific variables
    export DOTFILES_CONFIG_DIR=$(get_config_dir)
    export DOTFILES_CACHE_DIR=$(get_cache_dir)
    export DOTFILES_DATA_DIR=$(get_data_dir)
    export DOTFILES_BIN_DIR=$(get_bin_dir)
}

# Platform-specific PATH management
setup_platform_paths() {
    local bin_dir=$(get_bin_dir)
    
    # Add platform-specific paths
    case "$PLATFORM_OS" in
        macos)
            # Homebrew paths
            if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
                export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
            else
                export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
            fi
            ;;
        linux)
            export PATH="$HOME/.local/bin:$PATH"
            export PATH="$HOME/.cargo/bin:$PATH"
            ;;
        windows)
            export PATH="$HOME/bin:$PATH"
            ;;
    esac
    
    # Add user bin directory
    if [[ -d "$bin_dir" ]]; then
        export PATH="$bin_dir:$PATH"
    fi
}

# Shell-specific configuration
setup_shell_config() {
    case "$PLATFORM_SHELL" in
        zsh)
            setup_zsh_config
            ;;
        bash)
            setup_bash_config
            ;;
        fish)
            setup_fish_config
            ;;
    esac
}

setup_zsh_config() {
    # Create zsh config directory if needed
    local zsh_dir="${ZDOTDIR:-$HOME}/.zsh"
    mkdir -p "$zsh_dir"
    
    # Platform-specific zsh configuration
    case "$PLATFORM_OS" in
        macos)
            # Add Homebrew completions
            if [[ -d "/opt/homebrew/share/zsh/site-functions" ]]; then
                fpath=("/opt/homebrew/share/zsh/site-functions" $fpath)
            elif [[ -d "/usr/local/share/zsh/site-functions" ]]; then
                fpath=("/usr/local/share/zsh/site-functions" $fpath)
            fi
            ;;
        linux)
            # Add local completions
            if [[ -d "$HOME/.local/share/zsh/site-functions" ]]; then
                fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
            fi
            ;;
    esac
}

setup_bash_config() {
    # Platform-specific bash configuration
    case "$PLATFORM_OS" in
        macos)
            # Use newer bash if available
            if [[ -f "/opt/homebrew/bin/bash" ]]; then
                export SHELL="/opt/homebrew/bin/bash"
            elif [[ -f "/usr/local/bin/bash" ]]; then
                export SHELL="/usr/local/bin/bash"
            fi
            ;;
    esac
}

setup_fish_config() {
    # Platform-specific fish configuration
    local fish_config_dir=$(get_config_dir)/fish
    mkdir -p "$fish_config_dir"
}

# Platform compatibility checks
check_platform_compatibility() {
    echo "🔍 Platform Compatibility Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "OS: $PLATFORM_OS"
    echo "Distribution: $PLATFORM_DISTRO"
    echo "Architecture: $PLATFORM_ARCH"
    echo "Shell: $PLATFORM_SHELL"
    echo "Package Manager: $PLATFORM_PACKAGE_MANAGER"
    echo ""
    
    # Check for potential issues
    local issues=()
    
    # Check shell compatibility
    if [[ "$PLATFORM_SHELL" != "zsh" ]] && [[ "$PLATFORM_SHELL" != "bash" ]]; then
        issues+=("Unsupported shell: $PLATFORM_SHELL")
    fi
    
    # Check package manager
    if [[ "$PLATFORM_PACKAGE_MANAGER" == "none" ]] || [[ "$PLATFORM_PACKAGE_MANAGER" == "unknown" ]]; then
        issues+=("No package manager detected")
    fi
    
    # Check architecture support
    if [[ "$PLATFORM_ARCH" == "unknown" ]]; then
        issues+=("Unknown architecture")
    fi
    
    # Report issues
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "⚠️ Compatibility Issues:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        echo ""
    else
        echo "✅ Platform fully supported"
    fi
    
    # Show recommendations
    echo "📋 Recommendations:"
    case "$PLATFORM_OS" in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "  - Install Homebrew for package management"
            fi
            if [[ "$PLATFORM_SHELL" != "zsh" ]]; then
                echo "  - Switch to zsh (default on modern macOS)"
            fi
            ;;
        linux)
            if [[ "$PLATFORM_DISTRO" == "unknown" ]]; then
                echo "  - Verify Linux distribution compatibility"
            fi
            ;;
        windows)
            echo "  - Consider using WSL for better compatibility"
            echo "  - Install a package manager (Chocolatey/Winget/Scoop)"
            ;;
    esac
}

# Initialize platform detection when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    detect_platform
    set_platform_vars
fi

# ============================================================================
# Epic 7.1: Cross-Platform Configuration Features
# Advanced platform-specific optimizations and management
# ============================================================================

# Platform configuration optimization
platform_config_optimization() {
    local optimization_level="${1:-auto}"
    local target_platform="${2:-$PLATFORM_OS}"
    
    print_info "🔧 Optimizing configuration for $target_platform (level: $optimization_level)..."
    
    case "$target_platform" in
        "macos")
            optimize_macos_config "$optimization_level"
            ;;
        "linux")
            optimize_linux_config "$optimization_level"
            ;;
        "windows")
            optimize_windows_config "$optimization_level"
            ;;
        *)
            print_error "Unsupported platform: $target_platform"
            return 1
            ;;
    esac
    
    # Apply universal optimizations
    apply_universal_optimizations "$optimization_level"
    
    print_success "Platform configuration optimized!"
}

# macOS-specific optimizations
optimize_macos_config() {
    local level="$1"
    
    print_info "🍎 Applying macOS optimizations (level: $level)..."
    
    # Performance optimizations
    case "$level" in
        "max"|"performance")
            # Disable visual effects for performance
            defaults write com.apple.dock expose-animation-duration -float 0.1
            defaults write com.apple.dock launchanim -bool false
            defaults write com.apple.finder DisableAllAnimations -bool true
            defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
            ;;
        "balanced"|"auto")
            # Moderate optimizations
            defaults write com.apple.dock autohide-time-modifier -float 0.5
            defaults write com.apple.dock autohide-delay -float 0.2
            ;;
    esac
    
    # Development-specific optimizations
    if [[ "$level" != "minimal" ]]; then
        # Show hidden files in Finder
        defaults write com.apple.finder AppleShowAllFiles -bool true
        
        # Show file extensions
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true
        
        # Disable creation of .DS_Store files on network volumes
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
        
        # Enable developer tools
        sudo DevToolsSecurity -enable 2>/dev/null || true
    fi
    
    # Hardware-specific optimizations
    if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
        # Apple Silicon specific optimizations
        export HOMEBREW_PREFIX="/opt/homebrew"
        export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
        
        # Optimize for Rosetta compatibility if needed
        if [[ -n "$ROSETTA_ACTIVE" ]]; then
            export HOMEBREW_PREFIX="/usr/local"
        fi
    else
        # Intel Mac optimizations
        export HOMEBREW_PREFIX="/usr/local"
        export HOMEBREW_CELLAR="/usr/local/Cellar"
    fi
    
    # Apply changes
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
}

# Linux-specific optimizations
optimize_linux_config() {
    local level="$1"
    
    print_info "🐧 Applying Linux optimizations (level: $level)..."
    
    # Distribution-specific optimizations
    case "$PLATFORM_DISTRO" in
        "debian")
            optimize_debian_config "$level"
            ;;
        "arch")
            optimize_arch_config "$level"
            ;;
        "rhel")
            optimize_rhel_config "$level"
            ;;
    esac
    
    # General Linux optimizations
    if [[ "$level" != "minimal" ]]; then
        # Optimize swappiness for development workloads
        if [[ -w "/proc/sys/vm/swappiness" ]]; then
            echo "10" | sudo tee /proc/sys/vm/swappiness >/dev/null 2>&1 || true
        fi
        
        # Increase file watch limits for development tools
        if [[ -w "/proc/sys/fs/inotify/max_user_watches" ]]; then
            echo "524288" | sudo tee /proc/sys/fs/inotify/max_user_watches >/dev/null 2>&1 || true
        fi
    fi
    
    # Performance tuning based on hardware
    optimize_linux_hardware "$level"
}

# Windows-specific optimizations
optimize_windows_config() {
    local level="$1"
    
    print_info "🪟 Applying Windows optimizations (level: $level)..."
    
    # WSL-specific optimizations
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        optimize_wsl_config "$level"
        return
    fi
    
    # Native Windows optimizations
    case "$level" in
        "max"|"performance")
            # Disable visual effects for performance
            powershell -Command "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 2" 2>/dev/null || true
            ;;
        "balanced"|"auto")
            # Moderate optimizations
            powershell -Command "Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value 100" 2>/dev/null || true
            ;;
    esac
    
    # Development environment setup
    if [[ "$level" != "minimal" ]]; then
        # Enable developer mode
        powershell -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1" 2>/dev/null || true
        
        # Set execution policy for PowerShell scripts
        powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" 2>/dev/null || true
    fi
}

# Distribution-specific optimizations
optimize_debian_config() {
    local level="$1"
    
    if [[ "$level" != "minimal" ]]; then
        # Update package lists more efficiently
        sudo sed -i 's/^deb-src/#deb-src/' /etc/apt/sources.list 2>/dev/null || true
        
        # Configure APT for faster downloads
        echo 'APT::Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80retries >/dev/null 2>&1 || true
        echo 'Acquire::http::Pipeline-Depth "5";' | sudo tee /etc/apt/apt.conf.d/80pipeline >/dev/null 2>&1 || true
    fi
}

optimize_arch_config() {
    local level="$1"
    
    if [[ "$level" != "minimal" ]]; then
        # Enable parallel downloads in pacman
        sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf 2>/dev/null || true
        
        # Use faster mirrors if reflector is available
        if command -v reflector >/dev/null 2>&1; then
            sudo reflector --country US --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist 2>/dev/null || true
        fi
    fi
}

optimize_rhel_config() {
    local level="$1"
    
    if [[ "$level" != "minimal" ]]; then
        # Configure DNF for faster operation
        if [[ -f "/etc/dnf/dnf.conf" ]]; then
            sudo sed -i 's/#max_parallel_downloads=3/max_parallel_downloads=10/' /etc/dnf/dnf.conf 2>/dev/null || true
            sudo sed -i 's/#fastestmirror=True/fastestmirror=True/' /etc/dnf/dnf.conf 2>/dev/null || true
        fi
    fi
}

# WSL-specific optimizations
optimize_wsl_config() {
    local level="$1"
    
    print_info "🐧🪟 Applying WSL-specific optimizations..."
    
    # Create or update .wslconfig
    local wslconfig="$HOME/../.wslconfig"
    if [[ "$level" != "minimal" ]]; then
        cat > "$wslconfig" << EOF
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
EOF
    fi
    
    # Optimize for development workflows
    if [[ "$level" == "max" ]] || [[ "$level" == "performance" ]]; then
        # Disable Windows Defender real-time protection for WSL paths
        powershell.exe -Command "Add-MpPreference -ExclusionProcess '%LOCALAPPDATA%\\Packages\\*\\LocalState\\rootfs\\*'" 2>/dev/null || true
    fi
}

# Hardware-specific Linux optimizations
optimize_linux_hardware() {
    local level="$1"
    
    # CPU-specific optimizations
    local cpu_info=$(cat /proc/cpuinfo 2>/dev/null || echo "")
    if echo "$cpu_info" | grep -qi "intel"; then
        # Intel-specific optimizations
        export CFLAGS="-march=native -O2"
    elif echo "$cpu_info" | grep -qi "amd"; then
        # AMD-specific optimizations
        export CFLAGS="-march=native -O2"
    fi
    
    # Memory-based optimizations
    local total_memory=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo "0")
    if [[ $total_memory -gt 16777216 ]]; then  # >16GB
        export DOTFILES_HIGH_MEMORY=1
        # Enable more aggressive caching
        export ZSH_CACHE_SIZE=1000
    elif [[ $total_memory -gt 8388608 ]]; then  # >8GB
        export DOTFILES_MEDIUM_MEMORY=1
        export ZSH_CACHE_SIZE=500
    else
        export DOTFILES_LOW_MEMORY=1
        export ZSH_CACHE_SIZE=100
    fi
}

# Universal optimizations across all platforms
apply_universal_optimizations() {
    local level="$1"
    
    print_info "🌐 Applying universal optimizations..."
    
    # Shell optimizations
    case "$PLATFORM_SHELL" in
        "zsh")
            optimize_zsh_universal "$level"
            ;;
        "bash")
            optimize_bash_universal "$level"
            ;;
    esac
    
    # Development tool optimizations
    if [[ "$level" != "minimal" ]]; then
        # Git optimizations
        git config --global core.preloadindex true 2>/dev/null || true
        git config --global core.fscache true 2>/dev/null || true
        git config --global gc.auto 256 2>/dev/null || true
        
        # Node.js optimizations
        if command -v node >/dev/null 2>&1; then
            export NODE_OPTIONS="--max-old-space-size=8192"
        fi
        
        # Python optimizations
        export PYTHONOPTIMIZE=1
        export PYTHONDONTWRITEBYTECODE=1
    fi
}

# Shell-specific universal optimizations
optimize_zsh_universal() {
    local level="$1"
    
    # Optimize completion system
    export ZSH_COMPDUMP="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
    
    case "$level" in
        "max"|"performance")
            export DOTFILES_FAST_MODE=1
            export ZSH_DISABLE_COMPFIX=true
            ;;
        "balanced"|"auto")
            export DOTFILES_BALANCED_MODE=1
            ;;
    esac
}

optimize_bash_universal() {
    local level="$1"
    
    # Optimize bash completion
    export BASH_COMPLETION_USER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion"
    
    case "$level" in
        "max"|"performance")
            export DOTFILES_FAST_MODE=1
            ;;
        "balanced"|"auto")
            export DOTFILES_BALANCED_MODE=1
            ;;
    esac
}

# Platform-specific tool management
platform_tool_management() {
    local action="${1:-status}"
    local tool_name="${2:-}"
    
    case "$action" in
        "install")
            platform_install_tool "$tool_name" "${3:-}"
            ;;
        "update")
            platform_update_tools "$tool_name"
            ;;
        "remove")
            platform_remove_tool "$tool_name"
            ;;
        "list")
            platform_list_tools
            ;;
        "status")
            platform_tool_status "$tool_name"
            ;;
        "sync")
            platform_sync_tools
            ;;
        *)
            print_error "Unknown action: $action"
            echo "Available actions: install, update, remove, list, status, sync"
            return 1
            ;;
    esac
}

# Install platform-specific tool
platform_install_tool() {
    local tool="$1"
    local version="${2:-latest}"
    
    print_info "📦 Installing $tool ($version) on $PLATFORM_OS..."
    
    case "$tool" in
        "docker")
            install_docker_platform_specific
            ;;
        "nodejs"|"node")
            install_nodejs_platform_specific "$version"
            ;;
        "python")
            install_python_platform_specific "$version"
            ;;
        "rust")
            install_rust_platform_specific
            ;;
        "go"|"golang")
            install_go_platform_specific "$version"
            ;;
        "java")
            install_java_platform_specific "$version"
            ;;
        *)
            # Fallback to generic package installation
            install_package "$tool"
            ;;
    esac
}

# Docker installation across platforms
install_docker_platform_specific() {
    case "$PLATFORM_OS" in
        "macos")
            if ! command -v docker >/dev/null 2>&1; then
                brew install --cask docker
                print_info "Docker Desktop installed. Please start it from Applications."
            fi
            ;;
        "linux")
            case "$PLATFORM_DISTRO" in
                "debian")
                    curl -fsSL https://get.docker.com | sh
                    sudo usermod -aG docker "$USER"
                    ;;
                "arch")
                    sudo pacman -S docker docker-compose
                    sudo systemctl enable docker
                    sudo usermod -aG docker "$USER"
                    ;;
                *)
                    curl -fsSL https://get.docker.com | sh
                    ;;
            esac
            ;;
        "windows")
            if command -v choco >/dev/null 2>&1; then
                choco install docker-desktop -y
            else
                print_info "Please install Docker Desktop from https://docker.com/products/docker-desktop"
            fi
            ;;
    esac
}

# Node.js installation with version management
install_nodejs_platform_specific() {
    local version="${1:-lts}"
    
    # Use mise/rtx for version management if available
    if command -v mise >/dev/null 2>&1; then
        mise install node@"$version"
        mise use node@"$version"
    elif command -v fnm >/dev/null 2>&1; then
        fnm install "$version"
        fnm use "$version"
    elif command -v nvm >/dev/null 2>&1; then
        nvm install "$version"
        nvm use "$version"
    else
        # Fallback to package manager
        case "$PLATFORM_OS" in
            "macos")
                brew install node
                ;;
            "linux")
                # Install Node.js via NodeSource repository for latest version
                case "$PLATFORM_DISTRO" in
                    "debian")
                        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                        ;;
                    "arch")
                        sudo pacman -S nodejs npm
                        ;;
                    "rhel")
                        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                        sudo dnf install -y nodejs
                        ;;
                esac
                ;;
        esac
    fi
}

# Python installation with version management
install_python_platform_specific() {
    local version="${1:-3.11}"
    
    # Use mise/rtx for version management if available
    if command -v mise >/dev/null 2>&1; then
        mise install python@"$version"
        mise use python@"$version"
    elif command -v pyenv >/dev/null 2>&1; then
        pyenv install "$version"
        pyenv global "$version"
    else
        # Fallback to package manager
        case "$PLATFORM_OS" in
            "macos")
                brew install python@"${version%.*}"
                ;;
            "linux")
                case "$PLATFORM_DISTRO" in
                    "debian")
                        sudo apt-get install -y "python$version" "python$version-venv" "python$version-pip"
                        ;;
                    "arch")
                        sudo pacman -S python python-pip
                        ;;
                    "rhel")
                        sudo dnf install -y "python$version" "python$version-pip"
                        ;;
                esac
                ;;
        esac
    fi
    
    # Install uv for fast Python package management
    if ! command -v uv >/dev/null 2>&1; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

# Platform performance tuning
platform_performance_tuning() {
    local performance_profile="${1:-auto}"
    local apply_immediately="${2:-false}"
    
    print_info "⚡ Tuning platform performance (profile: $performance_profile)..."
    
    # Detect optimal performance profile if auto
    if [[ "$performance_profile" == "auto" ]]; then
        performance_profile=$(detect_optimal_performance_profile)
        print_info "Detected optimal profile: $performance_profile"
    fi
    
    # Apply performance tuning
    case "$performance_profile" in
        "high")
            apply_high_performance_tuning
            ;;
        "balanced")
            apply_balanced_performance_tuning
            ;;
        "battery")
            apply_battery_optimized_tuning
            ;;
        "development")
            apply_development_optimized_tuning
            ;;
        *)
            print_error "Unknown performance profile: $performance_profile"
            return 1
            ;;
    esac
    
    # Apply changes immediately if requested
    if [[ "$apply_immediately" == "true" ]]; then
        apply_performance_changes_immediately
    fi
    
    print_success "Performance tuning applied! (profile: $performance_profile)"
}

# Detect optimal performance profile based on system capabilities
detect_optimal_performance_profile() {
    local cpu_cores=$(nproc 2>/dev/null || echo "1")
    local total_memory=$(free -m 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "1024")
    local power_source="unknown"
    
    # Detect power source on different platforms
    case "$PLATFORM_OS" in
        "macos")
            if pmset -g ps | grep -q "AC Power"; then
                power_source="ac"
            else
                power_source="battery"
            fi
            ;;
        "linux")
            if [[ -f "/sys/class/power_supply/AC/online" ]] && [[ "$(cat /sys/class/power_supply/AC/online)" == "1" ]]; then
                power_source="ac"
            elif [[ -f "/sys/class/power_supply/ADP1/online" ]] && [[ "$(cat /sys/class/power_supply/ADP1/online)" == "1" ]]; then
                power_source="ac"
            else
                power_source="battery"
            fi
            ;;
    esac
    
    # Determine optimal profile
    if [[ $cpu_cores -ge 8 ]] && [[ $total_memory -ge 16384 ]] && [[ "$power_source" == "ac" ]]; then
        echo "high"
    elif [[ $cpu_cores -ge 4 ]] && [[ $total_memory -ge 8192 ]]; then
        echo "development"
    elif [[ "$power_source" == "battery" ]]; then
        echo "battery"
    else
        echo "balanced"
    fi
}

# Apply high performance tuning
apply_high_performance_tuning() {
    print_info "🚀 Applying high performance tuning..."
    
    # Shell optimizations
    export DOTFILES_FAST_MODE=1
    export DOTFILES_HIGH_PERFORMANCE=1
    export ZSH_DISABLE_COMPFIX=true
    
    # System-specific tuning
    case "$PLATFORM_OS" in
        "macos")
            # Disable animations
            defaults write com.apple.dock expose-animation-duration -float 0.1
            defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
            # Increase file handle limits
            sudo launchctl limit maxfiles 65536 200000 2>/dev/null || true
            ;;
        "linux")
            # Optimize I/O scheduler for SSDs
            if [[ -f "/sys/block/sda/queue/scheduler" ]]; then
                echo "noop" | sudo tee /sys/block/sda/queue/scheduler >/dev/null 2>&1 || true
            fi
            # Increase file watch limits
            echo "524288" | sudo tee /proc/sys/fs/inotify/max_user_watches >/dev/null 2>&1 || true
            ;;
    esac
    
    # Development tool optimizations
    export NODE_OPTIONS="--max-old-space-size=8192"
    export PYTHONOPTIMIZE=1
    export CARGO_BUILD_JOBS=$(nproc)
    export MAKEFLAGS="-j$(nproc)"
}

# Apply development-optimized tuning
apply_development_optimized_tuning() {
    print_info "💻 Applying development-optimized tuning..."
    
    # Development-focused optimizations
    export DOTFILES_DEV_MODE=1
    export DOTFILES_FAST_COMPLETION=1
    
    # Tool-specific optimizations
    export NODE_OPTIONS="--max-old-space-size=4096"
    export PYTHONOPTIMIZE=0  # Disable for better debugging
    export CARGO_BUILD_JOBS=$(($(nproc) / 2))
    
    # Git optimizations for large repositories
    git config --global core.preloadindex true 2>/dev/null || true
    git config --global core.untrackedCache true 2>/dev/null || true
    git config --global feature.manyFiles true 2>/dev/null || true
}

# Apply performance changes immediately
apply_performance_changes_immediately() {
    print_info "🔄 Applying performance changes immediately..."
    
    case "$PLATFORM_OS" in
        "macos")
            # Restart affected services
            killall Dock 2>/dev/null || true
            killall SystemUIServer 2>/dev/null || true
            ;;
        "linux")
            # Reload sysctl settings
            sudo sysctl -p 2>/dev/null || true
            ;;
    esac
    
    # Reload shell configuration
    if [[ -n "$ZSH_VERSION" ]]; then
        autoload -U compinit && compinit
    elif [[ -n "$BASH_VERSION" ]]; then
        hash -r
    fi
}

# Platform migration tools
platform_migration_tools() {
    local action="${1:-status}"
    local source_platform="${2:-}"
    local target_platform="${3:-$PLATFORM_OS}"
    
    case "$action" in
        "export")
            export_platform_config "$source_platform"
            ;;
        "import")
            import_platform_config "$source_platform" "$target_platform"
            ;;
        "migrate")
            migrate_between_platforms "$source_platform" "$target_platform"
            ;;
        "compare")
            compare_platform_configs "$source_platform" "$target_platform"
            ;;
        "status")
            show_migration_status
            ;;
        *)
            print_error "Unknown migration action: $action"
            echo "Available actions: export, import, migrate, compare, status"
            return 1
            ;;
    esac
}

# Export platform configuration
export_platform_config() {
    local platform="${1:-$PLATFORM_OS}"
    local export_file="${DOTFILES_DATA_DIR:-$HOME/.local/share}/dotfiles/platform-export-$platform-$(date +%Y%m%d).tar.gz"
    
    print_info "📤 Exporting $platform configuration..."
    
    mkdir -p "$(dirname "$export_file")"
    
    # Create temporary directory for export
    local temp_dir=$(mktemp -d)
    local export_dir="$temp_dir/platform-config"
    mkdir -p "$export_dir"
    
    # Export platform-specific configurations
    case "$platform" in
        "macos")
            # Export system preferences
            defaults read > "$export_dir/macos-defaults.plist" 2>/dev/null || true
            
            # Export Homebrew packages
            if command -v brew >/dev/null 2>&1; then
                brew bundle dump --file="$export_dir/Brewfile" --force
            fi
            
            # Export system information
            system_profiler SPSoftwareDataType > "$export_dir/system-info.txt" 2>/dev/null || true
            ;;
        "linux")
            # Export installed packages
            case "$PLATFORM_PACKAGE_MANAGER" in
                "apt")
                    dpkg --get-selections > "$export_dir/packages-apt.txt" 2>/dev/null || true
                    ;;
                "pacman")
                    pacman -Qqe > "$export_dir/packages-pacman.txt" 2>/dev/null || true
                    ;;
                "dnf")
                    dnf list installed > "$export_dir/packages-dnf.txt" 2>/dev/null || true
                    ;;
            esac
            
            # Export system information
            uname -a > "$export_dir/system-info.txt"
            cat /etc/os-release >> "$export_dir/system-info.txt" 2>/dev/null || true
            ;;
        "windows")
            # Export installed programs
            if command -v powershell.exe >/dev/null 2>&1; then
                powershell.exe -Command "Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Export-Csv -Path '$export_dir/windows-programs.csv'" 2>/dev/null || true
            fi
            ;;
    esac
    
    # Export common configurations
    cp -r "$DOTFILES_DIR/config" "$export_dir/" 2>/dev/null || true
    cp "$HOME/.zshrc" "$export_dir/" 2>/dev/null || true
    cp "$HOME/.bashrc" "$export_dir/" 2>/dev/null || true
    cp "$HOME/.gitconfig" "$export_dir/" 2>/dev/null || true
    
    # Create metadata
    cat > "$export_dir/metadata.json" << EOF
{
    "platform": "$platform",
    "distro": "$PLATFORM_DISTRO",
    "architecture": "$PLATFORM_ARCH",
    "export_date": "$(date -Iseconds)",
    "dotfiles_version": "$(git -C "$DOTFILES_DIR" rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
EOF
    
    # Create archive
    tar -czf "$export_file" -C "$temp_dir" "platform-config"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    print_success "Platform configuration exported to: $export_file"
    echo "Archive size: $(du -h "$export_file" | cut -f1)"
}

# Import platform configuration
import_platform_config() {
    local source_platform="$1"
    local target_platform="${2:-$PLATFORM_OS}"
    local import_file="${3:-}"
    
    print_info "📥 Importing configuration from $source_platform to $target_platform..."
    
    # Find import file if not specified
    if [[ -z "$import_file" ]]; then
        local data_dir="${DOTFILES_DATA_DIR:-$HOME/.local/share}/dotfiles"
        import_file=$(find "$data_dir" -name "platform-export-$source_platform-*.tar.gz" -type f | sort -r | head -1)
        
        if [[ -z "$import_file" ]]; then
            print_error "No export file found for $source_platform"
            return 1
        fi
        
        print_info "Using export file: $(basename "$import_file")"
    fi
    
    # Extract and import configuration
    local temp_dir=$(mktemp -d)
    tar -xzf "$import_file" -C "$temp_dir"
    local import_dir="$temp_dir/platform-config"
    
    # Platform-specific import logic
    case "$target_platform" in
        "macos")
            if [[ "$source_platform" == "linux" ]]; then
                import_linux_to_macos "$import_dir"
            fi
            ;;
        "linux")
            if [[ "$source_platform" == "macos" ]]; then
                import_macos_to_linux "$import_dir"
            fi
            ;;
    esac
    
    # Import common configurations
    if [[ -f "$import_dir/.zshrc" ]]; then
        cp "$import_dir/.zshrc" "$HOME/.zshrc.imported"
        print_info "ZSH configuration imported as ~/.zshrc.imported"
    fi
    
    if [[ -f "$import_dir/.gitconfig" ]]; then
        cp "$import_dir/.gitconfig" "$HOME/.gitconfig.imported"
        print_info "Git configuration imported as ~/.gitconfig.imported"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    print_success "Configuration import completed!"
    print_info "Review imported configurations before replacing your current setup."
}

# Cross-platform migration helpers
import_linux_to_macos() {
    local import_dir="$1"
    
    print_info "🐧➡️🍎 Migrating Linux configuration to macOS..."
    
    # Convert package lists to Homebrew
    if [[ -f "$import_dir/packages-apt.txt" ]]; then
        convert_apt_to_brew "$import_dir/packages-apt.txt"
    elif [[ -f "$import_dir/packages-pacman.txt" ]]; then
        convert_pacman_to_brew "$import_dir/packages-pacman.txt"
    fi
}

import_macos_to_linux() {
    local import_dir="$1"
    
    print_info "🍎➡️🐧 Migrating macOS configuration to Linux..."
    
    # Convert Homebrew packages to Linux equivalents
    if [[ -f "$import_dir/Brewfile" ]]; then
        convert_brew_to_linux "$import_dir/Brewfile"
    fi
}

# Package conversion utilities
convert_apt_to_brew() {
    local apt_packages="$1"
    local brewfile="$HOME/Brewfile.migrated"
    
    print_info "Converting APT packages to Homebrew..."
    
    # Package mapping (simplified)
    declare -A package_map=(
        ["nodejs"]="node"
        ["python3"]="python"
        ["vim"]="neovim"
        ["git"]="git"
        ["curl"]="curl"
        ["wget"]="wget"
        ["tmux"]="tmux"
        ["zsh"]="zsh"
    )
    
    echo "# Generated Brewfile from APT packages" > "$brewfile"
    
    while read -r line; do
        local package=$(echo "$line" | cut -f1)
        local brew_package="${package_map[$package]:-$package}"
        
        # Skip if package is likely not available in Homebrew
        case "$package" in
            *"-dev"|*"-devel"|"lib"*)
                echo "# Skipped development package: $package" >> "$brewfile"
                ;;
            *)
                echo "brew \"$brew_package\"" >> "$brewfile"
                ;;
        esac
    done < "$apt_packages"
    
    print_info "Brewfile created at: $brewfile"
    print_info "Review and run: brew bundle --file=$brewfile"
}

# Show migration status
show_migration_status() {
    echo "🔄 Platform Migration Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Current Platform: $PLATFORM_OS ($PLATFORM_DISTRO)"
    echo "Architecture: $PLATFORM_ARCH"
    echo "Package Manager: $PLATFORM_PACKAGE_MANAGER"
    echo ""
    
    # Show available exports
    local data_dir="${DOTFILES_DATA_DIR:-$HOME/.local/share}/dotfiles"
    if [[ -d "$data_dir" ]]; then
        echo "Available Exports:"
        find "$data_dir" -name "platform-export-*.tar.gz" -type f -exec basename {} \; 2>/dev/null | sort || echo "  No exports found"
    fi
    
    echo ""
    echo "Migration Commands:"
    echo "  Export current: dot platform migrate export"
    echo "  Import from other: dot platform migrate import <source-platform>"
    echo "  Full migration: dot platform migrate migrate <source> <target>"
}

# Export functions
export -f detect_platform install_package xopen xcopy xpaste
export -f install_modern_tools check_platform_compatibility
export -f get_config_dir get_cache_dir get_data_dir get_bin_dir
export -f setup_platform_paths setup_shell_config
export -f platform_config_optimization platform_tool_management
export -f platform_performance_tuning platform_migration_tools