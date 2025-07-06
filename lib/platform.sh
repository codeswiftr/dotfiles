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

# Export functions
export -f detect_platform install_package xopen xcopy xpaste
export -f install_modern_tools check_platform_compatibility
export -f get_config_dir get_cache_dir get_data_dir get_bin_dir
export -f setup_platform_paths setup_shell_config