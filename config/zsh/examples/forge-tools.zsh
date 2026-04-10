# =============================================================================
# FORGE-specific Tools Integration
# Critical tooling for FORGE portfolio development and fleet operations
# =============================================================================

# Skip in SSH sessions — FORGE is a local dev tool, not needed on remote nodes
[[ -n "$DOTFILES_SSH" ]] && return 0

# -----------------------------------------------------------------------------
# FORGE Configuration (~/.forgerc)
# -----------------------------------------------------------------------------

# Load user config if exists, otherwise use defaults
if [[ -f "$HOME/.forgerc" ]]; then
    source "$HOME/.forgerc"
elif [[ -f "${DOTFILES_DIR:-$HOME/dotfiles}/config/forge/.forgerc" ]]; then
    source "${DOTFILES_DIR:-$HOME/dotfiles}/config/forge/.forgerc"
fi

# Ensure FORGE_ROOT is set (default: ~/work/FORGE)
export FORGE_ROOT="${FORGE_ROOT:-$HOME/work/FORGE}"

# -----------------------------------------------------------------------------
# PATH Additions for FORGE Tools
# -----------------------------------------------------------------------------

# QMD - FORGE documentation search (BM25 + vector search for .md files)
# Critical for agents to understand architecture/workflows quickly
# Add npm-global to PATH if qmd is available (via npm, bun, or direct install)
if command -v qmd >/dev/null 2>&1; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Forge CLI - FORGE fleet management and orchestration
if [[ -f "$HOME/.local/bin/forge" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
elif [[ -f "$FORGE_ROOT/.local/bin/forge" ]]; then
    # Check FORGE installation if in local bin
    export PATH="$FORGE_ROOT/.local/bin:$PATH"
fi

# -----------------------------------------------------------------------------
# QMD Quick References
# -----------------------------------------------------------------------------
# QMD provides semantic search across all FORGE markdown documentation
# See: https://github.com/forge-portfolio/qmd

# Quick search - fast BM25 search (use this first)
alias qs='qmd search'

# File list mode - find docs by filename patterns
alias qf='qmd search --files'

# Get specific document by ID
alias qg='qmd get'

# Update QMD index
alias qu='qmd update'

# Vector search - slower but more accurate (use when BM25 misses)
alias qv='qmd query'

# QMD helper with context hints
qmd-help() {
    cat << 'EOF'
📚 QMD - FORGE Documentation Search

Quick Commands:
  qs "topic"        - Fast BM25 search (default: use this first)
  qf "pattern"      - Find files by name pattern
  qg qmd://...      - Get specific document
  qv "complex query" - Vector search (slower, more accurate)
  qu                - Update index

Search Strategy:
  1. Use qs for most queries (BM25 is fast and usually sufficient)
  2. Use qf when you know the filename or want to browse
  3. Use qv only when BM25 misses the mark (requires CPU reranker)

Common Searches:
  qs "forge status"    - Infrastructure status
  qs "agent dispatch"  - How to dispatch tasks
  qs "orchestrator"    - Lead orchestration rules
  qs "node trinity"    - Trinity node configuration
  qs "10k mrr"         - Revenue strategy

See: docs/QMD_QUICK_REFERENCE.md
EOF
}

# -----------------------------------------------------------------------------
# Forge CLI Shortcuts (prefixed to avoid conflicts)
# -----------------------------------------------------------------------------
# Prefix 'f' for FORGE commands to avoid shell conflicts

# Project navigation
alias fstatus='forge-status'

# Environment management
alias fenv='forge-env'
alias fcheck='forge-check-env'

# Development servers
alias fapi='forge-api'
alias fweb='forge-web'

# Fleet operations (requires forge CLI)
alias ff='forge fleet'
alias fdispatch='forge dispatch'

# Note: forge CLI now respects FORGE_ROOT from ~/.forgerc, so it works from anywhere

# -----------------------------------------------------------------------------
# Forge Workflow Helpers
# -----------------------------------------------------------------------------

# Quick FORGE docs search using QMD
forge-docs() {
    local query="$1"
    if [[ -z "$query" ]]; then
        qmd-help
        return 0
    fi
    echo "🔍 Searching FORGE docs: $query"
    qmd search "$query"
}

# Navigate to FORGE root quickly
forge-root() {
    local root="${FORGE_ROOT:-$HOME/work/FORGE}"
    if [[ -d "$root" ]]; then
        cd "$root"
        echo "🏗️  FORGE Root: $root"
    else
        echo "❌ FORGE_ROOT not found: $root"
        return 1
    fi
}

# Check FORGE environment readiness
forge-ready() {
    local root="${FORGE_ROOT:-$HOME/work/FORGE}"
    local ready=true

    echo "🔧 FORGE Environment Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check FORGE_ROOT
    if [[ -d "$root" ]]; then
        echo "✅ FORGE_ROOT: $root"
    else
        echo "❌ FORGE_ROOT not found"
        ready=false
    fi

    # Check QMD
    if command -v qmd >/dev/null 2>&1; then
        echo "✅ QMD: $(qmd --version 2>/dev/null || echo 'installed')"
    else
        echo "❌ QMD not installed"
        ready=false
    fi

    # Check Forge CLI
    if command -v forge >/dev/null 2>&1; then
        echo "✅ Forge CLI: $(forge --version 2>/dev/null || echo 'installed')"
    else
        echo "⚠️  Forge CLI not found (optional)"
    fi

    # Check Node identification
    if [[ -n "$FORGE_NODE" ]]; then
        echo "✅ FORGE_NODE: $FORGE_NODE"
    else
        echo "⚠️  FORGE_NODE not set (optional for non-nodes)"
    fi

    echo ""
    if [[ "$ready" == true ]]; then
        echo "✅ Ready for FORGE development!"
        return 0
    else
        echo "❌ Some dependencies missing"
        return 1
    fi
}

# Export functions (zsh compatible)
autoload -z forge-docs forge-root forge-ready
