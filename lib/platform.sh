#!/usr/bin/env bash
# =============================================================================
# Cross-Platform Compatibility
# Platform detection and path helpers
# =============================================================================

PLATFORM_OS=""
PLATFORM_DISTRO=""
PLATFORM_ARCH=""
PLATFORM_SHELL=""
PLATFORM_PACKAGE_MANAGER=""

detect_platform() {
    case "$OSTYPE" in
        linux-gnu*)
            PLATFORM_OS="linux"
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                PLATFORM_DISTRO="$ID"
            elif [[ -f /etc/debian_version ]]; then PLATFORM_DISTRO="debian"
            elif [[ -f /etc/arch-release ]]; then PLATFORM_DISTRO="arch"
            elif [[ -f /etc/alpine-release ]]; then PLATFORM_DISTRO="alpine"
            else PLATFORM_DISTRO="unknown"
            fi
            # Normalize distro families
            case "$PLATFORM_DISTRO" in
                ubuntu|debian) PLATFORM_DISTRO="debian" ;;
                centos|rhel|fedora) PLATFORM_DISTRO="rhel" ;;
                manjaro|endeavouros) PLATFORM_DISTRO="arch" ;;
            esac
            ;;
        darwin*)   PLATFORM_OS="macos"; PLATFORM_DISTRO="macos" ;;
        cygwin*)   PLATFORM_OS="windows"; PLATFORM_DISTRO="cygwin" ;;
        msys*)     PLATFORM_OS="windows"; PLATFORM_DISTRO="msys" ;;
        freebsd*)  PLATFORM_OS="freebsd"; PLATFORM_DISTRO="freebsd" ;;
        *)         PLATFORM_OS="unknown"; PLATFORM_DISTRO="unknown" ;;
    esac

    PLATFORM_ARCH=$(uname -m 2>/dev/null || echo "unknown")
    case "$PLATFORM_ARCH" in
        x86_64|amd64) PLATFORM_ARCH="x64" ;;
        arm64|aarch64) PLATFORM_ARCH="arm64" ;;
        armv7*) PLATFORM_ARCH="arm" ;;
    esac

    PLATFORM_SHELL=$(basename "$SHELL" 2>/dev/null || echo "unknown")

    # Detect package manager
    case "$PLATFORM_OS" in
        macos) command -v brew &>/dev/null && PLATFORM_PACKAGE_MANAGER="brew" || PLATFORM_PACKAGE_MANAGER="none" ;;
        linux)
            case "$PLATFORM_DISTRO" in
                debian) PLATFORM_PACKAGE_MANAGER="apt" ;;
                rhel)   command -v dnf &>/dev/null && PLATFORM_PACKAGE_MANAGER="dnf" || PLATFORM_PACKAGE_MANAGER="yum" ;;
                arch)   PLATFORM_PACKAGE_MANAGER="pacman" ;;
                alpine) PLATFORM_PACKAGE_MANAGER="apk" ;;
                *)      PLATFORM_PACKAGE_MANAGER="unknown" ;;
            esac ;;
        *) PLATFORM_PACKAGE_MANAGER="unknown" ;;
    esac
}

# Platform-specific path helpers (used by templating.sh)
get_config_dir() {
    case "$PLATFORM_OS" in
        macos)   echo "$HOME/Library/Application Support" ;;
        linux)   echo "${XDG_CONFIG_HOME:-$HOME/.config}" ;;
        windows) echo "${APPDATA:-$HOME/AppData/Roaming}" ;;
        *)       echo "$HOME/.config" ;;
    esac
}

get_cache_dir() {
    case "$PLATFORM_OS" in
        macos)   echo "$HOME/Library/Caches" ;;
        linux)   echo "${XDG_CACHE_HOME:-$HOME/.cache}" ;;
        windows) echo "${LOCALAPPDATA:-$HOME/AppData/Local}" ;;
        *)       echo "$HOME/.cache" ;;
    esac
}

get_data_dir() {
    case "$PLATFORM_OS" in
        macos)   echo "$HOME/Library/Application Support" ;;
        linux)   echo "${XDG_DATA_HOME:-$HOME/.local/share}" ;;
        windows) echo "${APPDATA:-$HOME/AppData/Roaming}" ;;
        *)       echo "$HOME/.local/share" ;;
    esac
}

get_bin_dir() {
    case "$PLATFORM_OS" in
        macos)
            [[ "$PLATFORM_ARCH" == "arm64" ]] && echo "/opt/homebrew/bin" || echo "/usr/local/bin" ;;
        linux)   echo "$HOME/.local/bin" ;;
        windows) echo "$HOME/bin" ;;
        *)       echo "$HOME/.local/bin" ;;
    esac
}
