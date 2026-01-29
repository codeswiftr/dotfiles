#!/bin/bash
# ============================================================================
# Cross-Platform Clipboard Utilities
# Supports: macOS (Tahoe, Ventura), Linux (Wayland, X11)
# ============================================================================

# Detect clipboard backend
_clipboard_backend() {
    if [[ "$OSTYPE" == darwin* ]]; then
        echo "pbcopy"
    elif [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy &>/dev/null; then
        echo "wl-copy"
    elif [[ -n "$DISPLAY" ]] && command -v xclip &>/dev/null; then
        echo "xclip"
    elif [[ -n "$DISPLAY" ]] && command -v xsel &>/dev/null; then
        echo "xsel"
    else
        echo "none"
    fi
}

# Copy to system clipboard
# Usage: echo "text" | clip_copy
#        clip_copy < file.txt
clip_copy() {
    local backend=$(_clipboard_backend)
    case "$backend" in
        pbcopy)
            pbcopy
            ;;
        wl-copy)
            wl-copy
            ;;
        xclip)
            xclip -selection clipboard
            ;;
        xsel)
            xsel --clipboard --input
            ;;
        none)
            echo "Error: No clipboard tool available" >&2
            echo "Install: wl-copy (Wayland) or xclip (X11)" >&2
            return 1
            ;;
    esac
}

# Paste from system clipboard
# Usage: clip_paste
#        clip_paste > file.txt
clip_paste() {
    local backend=$(_clipboard_backend)
    case "$backend" in
        pbcopy)
            pbpaste
            ;;
        wl-copy)
            wl-paste
            ;;
        xclip)
            xclip -selection clipboard -o
            ;;
        xsel)
            xsel --clipboard --output
            ;;
        none)
            echo "Error: No clipboard tool available" >&2
            return 1
            ;;
    esac
}

# Get tmux copy command for current platform
# Usage: bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "$(clip_cmd)"
clip_cmd() {
    local backend=$(_clipboard_backend)
    case "$backend" in
        pbcopy)   echo "pbcopy" ;;
        wl-copy)  echo "wl-copy" ;;
        xclip)    echo "xclip -selection clipboard" ;;
        xsel)     echo "xsel --clipboard --input" ;;
        none)     echo "cat > /dev/null" ;;
    esac
}

# Check clipboard availability
clip_check() {
    local backend=$(_clipboard_backend)
    if [[ "$backend" == "none" ]]; then
        echo "❌ No clipboard tool available"
        echo ""
        echo "Install one of:"
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
            echo "  • wl-clipboard (Wayland): sudo pacman -S wl-clipboard"
        fi
        if [[ -n "$DISPLAY" ]] || [[ -z "$WAYLAND_DISPLAY" ]]; then
            echo "  • xclip (X11): sudo apt install xclip"
            echo "  • xsel (X11): sudo apt install xsel"
        fi
        return 1
    else
        echo "✅ Clipboard backend: $backend"
        return 0
    fi
}

# Export functions for subshells
export -f _clipboard_backend clip_copy clip_paste clip_cmd clip_check 2>/dev/null || true
