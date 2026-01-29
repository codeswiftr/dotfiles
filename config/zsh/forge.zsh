# ============================================================================
# FORGE Portfolio Functions
# Project navigation and environment management for multi-MVP portfolio
# ============================================================================

_forge_require() {
    local tool="$1"
    local hint="$2"

    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "❌ Missing dependency: $tool"
        [[ -n "$hint" ]] && echo "   Install: $hint"
        return 1
    fi
}

_forge_list_projects() {
    local root="$1"

    if command -v fd >/dev/null 2>&1; then
        fd -t d -d 3 . "$root" \
            --exclude node_modules --exclude .git --exclude __pycache__ --exclude .venv --exclude dist --exclude build
    else
        find "$root" -maxdepth 3 -type d \
            -name node_modules -o -name .git -o -name __pycache__ -o -name .venv -o -name dist -o -name build \
            -prune -o -type d -print
    fi
}

# FORGE project switcher with fzf
function forge() {
    local forge_root="${FORGE_ROOT:-$HOME/work/FORGE}"
    local project

    if [[ ! -d "$forge_root" ]]; then
        echo "❌ FORGE_ROOT not found: $forge_root"
        return 1
    fi

    if [[ -n "$1" ]]; then
        if command -v fd >/dev/null 2>&1; then
            project=$(fd -t d -d 3 "$1" "$forge_root" --exclude node_modules --exclude .git --exclude __pycache__ --exclude .venv | head -1)
        else
            project=$(find "$forge_root" -maxdepth 3 -type d -name "*$1*" \
                -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" -not -path "*/.venv/*" \
                | head -1)
        fi
        if [[ -z "$project" ]]; then
            echo "❌ Project not found: $1"
            return 1
        fi
    else
        if ! command -v fzf >/dev/null 2>&1; then
            echo "❌ Missing dependency: fzf"
            echo "   Tip: run 'forge <project-name>' or install fzf"
            return 1
        fi

        local preview_cmd="ls -la {}"
        if command -v eza >/dev/null 2>&1; then
            preview_cmd="eza --tree --level=2 --icons {}"
        fi

        project=$(_forge_list_projects "$forge_root" | fzf --prompt="forge> " --height 40% --reverse \
            --preview "$preview_cmd" --preview-window=right:50%)
    fi

    if [[ -n "$project" ]]; then
        cd "$project" || return 1
        echo "→ $(basename "$project")"

        if [[ -f "pyproject.toml" ]]; then
            echo "  🐍 Python (uv)"
        fi
        if [[ -f "package.json" ]]; then
            echo "  📦 JavaScript/TypeScript"
        fi
        if [[ -f "CLAUDE.md" ]]; then
            echo "  🤖 Has CLAUDE.md"
        fi
    fi
}

# Quick domain jump
function fdom() {
    local forge_root="${FORGE_ROOT:-$HOME/work/FORGE}"
    local domain="$1"

    if [[ ! -d "$forge_root" ]]; then
        echo "❌ FORGE_ROOT not found: $forge_root"
        return 1
    fi

    if [[ -z "$domain" ]]; then
        echo "Available domains:"
        ls -1 "$forge_root" | grep -E '\-com$|\-io$|\-dev$|\-es$' | while read d; do
            echo "  $d"
        done
        return 0
    fi

    if [[ -d "$forge_root/$domain" ]]; then
        cd "$forge_root/$domain" || return 1
        echo "→ $domain"
        ls
    else
        local match=$(ls -1 "$forge_root" | grep -i "$domain" | head -1)
        if [[ -n "$match" ]]; then
            cd "$forge_root/$match" || return 1
            echo "→ $match"
            ls
        else
            echo "❌ Domain not found: $domain"
        fi
    fi
}

# Load project-specific .env into shell
function forge-env() {
    local env_file="${1:-.env}"

    if [[ -f "$env_file" ]]; then
        echo "Loading: $env_file"
        set -a
        source "$env_file"
        set +a
        echo "✅ Environment loaded"

        echo ""
        echo "Key variables set:"
        grep -E '^[A-Z_]+=' "$env_file" | cut -d= -f1 | while read var; do
            if [[ -n "${(P)var}" ]]; then
                echo "  ✓ $var"
            fi
        done
    else
        echo "❌ No $env_file found in $(pwd)"
        echo ""
        echo "Available .env files:"
        find . -maxdepth 2 -name ".env*" -type f 2>/dev/null | head -10
    fi
}

# Quick env check for FORGE projects
function forge-check-env() {
    echo "═══════════════════════════════════════"
    echo "  FORGE Environment Check"
    echo "═══════════════════════════════════════"
    echo ""
    echo "API Keys:"
    echo "  ANTHROPIC_API_KEY:      ${ANTHROPIC_API_KEY:+✅ set}${ANTHROPIC_API_KEY:-❌ missing}"
    echo "  OPENAI_API_KEY:         ${OPENAI_API_KEY:+✅ set}${OPENAI_API_KEY:-⚠️  optional}"
    echo "  GEMINI_API_KEY:         ${GEMINI_API_KEY:+✅ set}${GEMINI_API_KEY:-⚠️  optional}"
    echo ""
    echo "Deployment:"
    echo "  RAILWAY_TOKEN:          ${RAILWAY_TOKEN:+✅ set}${RAILWAY_TOKEN:-❌ missing}"
    echo "  CLOUDFLARE_API_TOKEN:   ${CLOUDFLARE_API_TOKEN:+✅ set}${CLOUDFLARE_API_TOKEN:-❌ missing}"
    echo "  CLOUDFLARE_ACCOUNT_ID:  ${CLOUDFLARE_ACCOUNT_ID:+✅ set}${CLOUDFLARE_ACCOUNT_ID:-⚠️  optional}"
    echo ""
    echo "Analytics:"
    echo "  POSTHOG_API_KEY:        ${POSTHOG_API_KEY:+✅ set}${POSTHOG_API_KEY:-⚠️  optional}"
    echo "  POSTHOG_HOST:           ${POSTHOG_HOST:+✅ set}${POSTHOG_HOST:-⚠️  optional}"
    echo ""
    echo "Database:"
    echo "  DATABASE_URL:           ${DATABASE_URL:+✅ set}${DATABASE_URL:-⚠️  project-specific}"
    echo ""
    echo "FORGE:"
    echo "  FORGE_ROOT:             ${FORGE_ROOT:-$HOME/work/FORGE}"
    echo "═══════════════════════════════════════"
}

# FORGE backend dev server (FastAPI)
function forge-api() {
    local port="${1:-8000}"

    if [[ ! -f "pyproject.toml" ]]; then
        echo "❌ No pyproject.toml found. Are you in a backend directory?"
        return 1
    fi

    _forge_require uv "https://docs.astral.sh/uv/" || return 1

    echo "🚀 Starting FastAPI server on port $port..."
    uv run fastapi dev --port "$port"
}

# FORGE frontend dev server (Vite)
function forge-web() {
    local port="${1:-5173}"

    if [[ ! -f "package.json" ]]; then
        echo "❌ No package.json found. Are you in a frontend directory?"
        return 1
    fi

    _forge_require bun "https://bun.sh" || return 1

    echo "🚀 Starting Vite dev server on port $port..."
    bun run dev -- --port "$port"
}

# Quick FORGE status
function forge-status() {
    local forge_root="${FORGE_ROOT:-$HOME/work/FORGE}"

    if [[ ! -d "$forge_root" ]]; then
        echo "❌ FORGE_ROOT not found: $forge_root"
        return 1
    fi

    echo "═══════════════════════════════════════"
    echo "  FORGE Portfolio Status"
    echo "═══════════════════════════════════════"
    echo ""

    for domain in $(ls -1 "$forge_root" | grep -E '\-com$|\-io$|\-dev$|\-es$'); do
        local count=$(ls -1 "$forge_root/$domain" 2>/dev/null | wc -l | tr -d ' ')
        printf "  %-25s %s projects\n" "$domain" "$count"
    done

    echo ""
    echo "Current: $(pwd)"
    echo "═══════════════════════════════════════"
}

alias forge-tmux="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/tmux/forge-layout.sh"
alias ft="forge-tmux"
