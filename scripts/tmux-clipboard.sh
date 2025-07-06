#!/usr/bin/env bash
# =============================================================================
# Tmux Cross-Platform Clipboard Helper
# Provides unified clipboard operations across different platforms
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[CLIPBOARD]${NC} $1" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
            echo "wayland"
        elif command -v xclip >/dev/null 2>&1; then
            echo "x11"
        else
            echo "linux_fallback"
        fi
    else
        echo "unknown"
    fi
}

# Copy to system clipboard
copy_to_clipboard() {
    local content="$1"
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            echo -n "$content" | pbcopy
            success "Copied to macOS clipboard"
            ;;
        "x11")
            echo -n "$content" | xclip -in -selection clipboard
            success "Copied to X11 clipboard"
            ;;
        "wayland")
            echo -n "$content" | wl-copy
            success "Copied to Wayland clipboard"
            ;;
        "wsl")
            echo -n "$content" | clip.exe
            success "Copied to Windows clipboard (WSL)"
            ;;
        "linux_fallback")
            # Try different clipboard tools
            if command -v xsel >/dev/null 2>&1; then
                echo -n "$content" | xsel --clipboard --input
                success "Copied using xsel"
            elif command -v copyq >/dev/null 2>&1; then
                echo -n "$content" | copyq copy -
                success "Copied using copyq"
            else
                warn "No clipboard tool available - content copied to tmux buffer only"
                tmux set-buffer "$content"
                return 1
            fi
            ;;
        *)
            error "Unsupported platform: $platform"
            return 1
            ;;
    esac
}

# Paste from system clipboard
paste_from_clipboard() {
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            pbpaste
            ;;
        "x11")
            xclip -o -selection clipboard
            ;;
        "wayland")
            wl-paste
            ;;
        "wsl")
            # Clean Windows line endings
            powershell.exe Get-Clipboard | tr -d '\r'
            ;;
        "linux_fallback")
            if command -v xsel >/dev/null 2>&1; then
                xsel --clipboard --output
            elif command -v copyq >/dev/null 2>&1; then
                copyq clipboard
            else
                error "No clipboard tool available"
                return 1
            fi
            ;;
        *)
            error "Unsupported platform: $platform"
            return 1
            ;;
    esac
}

# Check clipboard availability
check_clipboard() {
    local platform=$(detect_platform)
    
    log "Platform detected: $platform"
    
    case "$platform" in
        "macos")
            if command -v pbcopy >/dev/null 2>&1 && command -v pbpaste >/dev/null 2>&1; then
                success "macOS clipboard tools available"
                return 0
            else
                error "macOS clipboard tools not found"
                return 1
            fi
            ;;
        "x11")
            if command -v xclip >/dev/null 2>&1; then
                success "xclip available for X11"
                return 0
            else
                error "xclip not found - install with: sudo apt install xclip"
                return 1
            fi
            ;;
        "wayland")
            if command -v wl-copy >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
                success "Wayland clipboard tools available"
                return 0
            else
                error "Wayland clipboard tools not found - install with: sudo apt install wl-clipboard"
                return 1
            fi
            ;;
        "wsl")
            if command -v clip.exe >/dev/null 2>&1 && command -v powershell.exe >/dev/null 2>&1; then
                success "WSL clipboard integration available"
                return 0
            else
                error "WSL clipboard tools not found"
                return 1
            fi
            ;;
        "linux_fallback")
            local found=false
            if command -v xsel >/dev/null 2>&1; then
                log "xsel found"
                found=true
            fi
            if command -v copyq >/dev/null 2>&1; then
                log "copyq found"
                found=true
            fi
            if [[ "$found" == "true" ]]; then
                success "Fallback clipboard tools available"
                return 0
            else
                error "No clipboard tools found - install xclip, xsel, or copyq"
                return 1
            fi
            ;;
        *)
            error "Unsupported platform"
            return 1
            ;;
    esac
}

# Show clipboard status
show_status() {
    local platform=$(detect_platform)
    
    echo "=== Tmux Clipboard Status ==="
    echo "Platform: $platform"
    echo "OS Type: $OSTYPE"
    
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "Wayland Display: $WAYLAND_DISPLAY"
    fi
    
    if [[ -n "${DISPLAY:-}" ]]; then
        echo "X11 Display: $DISPLAY"
    fi
    
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        echo "WSL Distribution: $WSL_DISTRO_NAME"
    fi
    
    echo ""
    echo "Available tools:"
    
    for tool in pbcopy pbpaste xclip xsel wl-copy wl-paste clip.exe powershell.exe copyq; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool"
        else
            echo "  ❌ $tool"
        fi
    done
    
    echo ""
    
    if check_clipboard; then
        echo "✅ Clipboard functionality is working"
    else
        echo "❌ Clipboard functionality has issues"
    fi
}

# Main function
main() {
    case "${1:-}" in
        "copy")
            if [[ -z "${2:-}" ]]; then
                # Read from stdin
                content=$(cat)
            else
                content="$2"
            fi
            copy_to_clipboard "$content"
            ;;
        "paste")
            paste_from_clipboard
            ;;
        "check")
            check_clipboard
            ;;
        "status")
            show_status
            ;;
        "test")
            log "Testing clipboard functionality..."
            test_content="tmux clipboard test $(date)"
            if copy_to_clipboard "$test_content"; then
                sleep 0.5
                pasted_content=$(paste_from_clipboard)
                if [[ "$pasted_content" == "$test_content" ]]; then
                    success "Clipboard test passed!"
                else
                    error "Clipboard test failed - content mismatch"
                    echo "Expected: $test_content"
                    echo "Got: $pasted_content"
                    return 1
                fi
            else
                error "Clipboard test failed - could not copy"
                return 1
            fi
            ;;
        "help"|"-h"|"--help"|"")
            echo "Tmux Cross-Platform Clipboard Helper"
            echo ""
            echo "Usage: $0 <command> [arguments]"
            echo ""
            echo "Commands:"
            echo "  copy [text]    Copy text to system clipboard (or from stdin)"
            echo "  paste          Paste from system clipboard"
            echo "  check          Check if clipboard functionality is available"
            echo "  status         Show detailed platform and tool status"
            echo "  test           Test clipboard functionality"
            echo "  help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 copy 'Hello World'"
            echo "  echo 'Hello World' | $0 copy"
            echo "  $0 paste"
            echo "  $0 test"
            ;;
        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            return 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"