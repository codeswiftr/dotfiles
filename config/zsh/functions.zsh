# ============================================================================
# Custom Functions
# Project management, development workflows, and utility functions
# ============================================================================

# ----------------------------------------------------------------------------
# Terminal / SSH Helpers
# ----------------------------------------------------------------------------

# Install Ghostty terminfo on a remote server
# Usage: ghostty-terminfo-install user@host
function ghostty-terminfo-install() {
    local host="$1"
    if [[ -z "$host" ]]; then
        echo "Usage: ghostty-terminfo-install user@host"
        echo "Copies Ghostty's terminfo to remote server for full terminal support"
        return 1
    fi

    if ! command -v infocmp &>/dev/null; then
        echo "Error: infocmp not found (install ncurses-bin)"
        return 1
    fi

    echo "Installing Ghostty terminfo on $host..."
    infocmp -x xterm-ghostty 2>/dev/null | command ssh "$host" 'tic -x -' && \
        echo "✓ Ghostty terminfo installed on $host" || \
        echo "✗ Failed to install terminfo (try: TERM=xterm-256color ssh $host)"
}

# Turn off terminal modes a remote program may have left enabled (mouse
# tracking, alt screen, bracketed paste, focus events, kitty keyboard, ...)
# without clearing the screen. Cheaper than `reset`, keeps scrollback.
_term_reset_modes() {
    [[ -t 1 ]] || return 0
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l\e[?1015l'  # mouse
    printf '\e[?1004l\e[?2004l\e[?2026l'                              # focus, paste, sync
    printf '\e[?1049l\e[?47l\e[?25h\e[?7h\e[?1l\e>'                   # alt screen, cursor, keypad
    printf '\e[<u\e[0m\e(B'                                            # kitty kbd pop, SGR, charset
    stty sane 2>/dev/null
}

# Fix a broken terminal after an SSH drop / crashed TUI. Ghostty: cmd+shift+r.
function fix-term() {
    _term_reset_modes
    if [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
        export TERM="xterm-256color"
        echo "TERM set to xterm-256color (no xterm-ghostty terminfo here)"
    fi
    echo "terminal modes reset"
}

# Human shells: reset local terminal modes when ssh exits, however it exits.
# A broken pipe leaves Ghostty in mouse-tracking/alt-screen mode otherwise.
# scp/rsync/git call the ssh binary directly and are unaffected.
if [[ -z "$DOTFILES_AGENT_SAFE" ]]; then
    ssh() {
        command ssh "$@"
        local rc=$?
        _term_reset_modes
        return $rc
    }
fi

# ----------------------------------------------------------------------------
# Project Management
# ----------------------------------------------------------------------------

# Project switching with language detection
function proj() {
    local project=$(fd -t d -d 2 . ~/work ~/projects 2>/dev/null | fzf --preview "eza --tree --level=2 {}")
    if [[ -n "$project" ]]; then
        cd "$project"
        echo "📁 Switched to: $(basename $project)"
        
        # Auto-detect project type and setup environment
        if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
            echo "🐍 Python project detected"
            if command -v mise &> /dev/null; then
                mise use python@latest
            fi
        elif [[ -f "package.json" ]]; then
            echo "📦 JavaScript project detected"
            if command -v mise &> /dev/null; then
                mise use node@latest
            fi
        elif [[ -f "Package.swift" ]]; then
            echo "🍎 Swift project detected"
        elif [[ -f "Cargo.toml" ]]; then
            echo "🦀 Rust project detected"
        fi
    fi
}

# dot reload wrapper: reload all configs in the current interactive shell
# Unset any existing alias to allow function redefinition on reload
unalias dot-reload 2>/dev/null || true

dot-reload() {
    # 1) herdr: reload server-side config
    if command -v herdr >/dev/null 2>&1; then
        herdr server reload-config >/dev/null 2>&1 || true
    fi
    # 2) mise: refresh shims
    if command -v mise >/dev/null 2>&1; then
        mise reshim >/dev/null 2>&1 || true
    fi
    # 3) zsh: re-source configs in-place to avoid spawning a subshell
    if [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc"
        echo "✅ Reloaded shell configuration (zsh)"
    fi
}

# Quick Python environment setup with uv
function py-env() {
    local env_name=${1:-$(basename $(pwd))}
    if [[ ! -d ".venv" ]]; then
        echo "🐍 Creating virtual environment: $env_name"
        uv venv --python 3.12
        echo "✅ Virtual environment created. Activating..."
        source .venv/bin/activate
        if [[ -f "pyproject.toml" ]]; then
            echo "📦 Installing dependencies from pyproject.toml..."
            uv sync
        fi
    else
        echo "🔄 Virtual environment already exists. Activating..."
        source .venv/bin/activate
    fi
}

# ============================================================================
# Utility Functions (inspired by Omarchy)
# ============================================================================

# Compression helpers
compress() { 
    tar -czf "${1%/}.tar.gz" "${1%/}"
    echo "✅ Created: ${1%/}.tar.gz"
}
alias decompress="tar -xzf"

# Cross-platform open command
open() {
    if [[ "$OSTYPE" == darwin* ]]; then
        command open "$@"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$@" >/dev/null 2>&1 &
    else
        echo "No open command available"
        return 1
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    echo "🌐 Serving current directory on http://localhost:$port"
    if command -v python3 &>/dev/null; then
        python3 -m http.server "$port"
    elif command -v bun &>/dev/null; then
        bunx serve -p "$port"
    else
        echo "No server available (need python3 or bun)"
    fi
}

# Quick JSON formatting
json() {
    if [[ -p /dev/stdin ]]; then
        cat | python3 -m json.tool
    elif [[ -f "$1" ]]; then
        python3 -m json.tool "$1"
    else
        echo "Usage: json <file> or cat file.json | json"
    fi
}

# Weather (requires curl)
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?format=3"
}

# Quick note taking
note() {
    local notes_dir="${NOTES_DIR:-$HOME/notes}"
    mkdir -p "$notes_dir"
    local note_file="$notes_dir/$(date +%Y-%m-%d).md"
    
    if [[ $# -eq 0 ]]; then
        ${EDITOR:-nvim} "$note_file"
    else
        echo "## $(date +%H:%M)" >> "$note_file"
        echo "$*" >> "$note_file"
        echo "" >> "$note_file"
        echo "📝 Added to $note_file"
    fi
}

# Port finder - what's running on a port
port() {
    if [[ -z "$1" ]]; then
        echo "Usage: port <number>"
        return 1
    fi
    lsof -i :"$1"
}

# Kill process on port
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port>"
        return 1
    fi
    local pid=$(lsof -t -i:"$1")
    if [[ -n "$pid" ]]; then
        kill -9 "$pid"
        echo "✅ Killed process $pid on port $1"
    else
        echo "No process found on port $1"
    fi
}

# Quick backup
backup() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$file" "${file}.bak.$(date +%Y%m%d-%H%M%S)"
    echo "✅ Backed up: $file"
}

# Extract any archive
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <file>"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)           echo "Cannot extract: $1" ;;
    esac
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}
