# ============================================================================
# Development Tool Optimization Functions
# Performance tuning and optimization for modern development tools
# ============================================================================

# uv optimization - cache management
function uv-optimize() {
    echo "🔧 Optimizing uv cache and settings..."
    
    # Clean old cache entries
    uv cache clean
    
    # Set optimized environment variables
    export UV_CACHE_DIR="$HOME/.cache/uv"
    export UV_TOOL_DIR="$HOME/.local/share/uv/tools"
    export UV_LINK_MODE="copy"  # Faster than symlinks on some systems
    export UV_COMPILE_BYTECODE="1"  # Pre-compile for faster imports
    
    echo "✅ uv optimization complete!"
    echo "💡 Benefits: Faster package installation and imports"
}

# Bun optimization - performance tuning
function bun-optimize() {
    echo "🔧 Optimizing Bun configuration..."
    
    # Create optimized bunfig.toml if it doesn't exist
    if [[ ! -f "$HOME/.bunfig.toml" ]]; then
        cat > "$HOME/.bunfig.toml" << 'EOF'
[install]
# Use faster cache strategy
cache = true
auto = "fallback"

[install.scopes]
# Add any organization scopes here
# "@your-org" = { "url" = "https://npm.your-org.com", "token" = "$YOUR_TOKEN" }
EOF
        echo "📝 Created optimized ~/.bunfig.toml"
    fi
    
    # Set performance environment variables
    export BUN_INSTALL_CACHE_DIR="$HOME/.bun/cache"
    export BUN_TMPDIR="/tmp/bun"
    mkdir -p "$BUN_TMPDIR"
    
    echo "✅ Bun optimization complete!"
    echo "💡 Benefits: Faster package installation and bundling"
}

# Mise optimization - faster version switching
function mise-optimize() {
    echo "🔧 Optimizing mise configuration..."
    
    # Create optimized mise config if it doesn't exist
    mkdir -p "$HOME/.config/mise"
    if [[ ! -f "$HOME/.config/mise/config.toml" ]]; then
        cat > "$HOME/.config/mise/config.toml" << 'EOF'
[tools]
# Global tool versions
python = "3.12"
node = "22"

[settings]
# Performance optimizations
legacy_version_file = false
plugin_autoupdate_last_check_duration = "7d"
paranoid = false
always_keep_download = true
always_keep_install = true

[aliases]
# Convenient aliases
py = "python"
js = "node"
EOF
        echo "📝 Created optimized ~/.config/mise/config.toml"
    fi
    
    # Set performance environment variables
    export MISE_USE_TOML="1"  # Faster than parsing .tool-versions
    export MISE_PARANOID="0"  # Disable extra security checks for speed
    
    echo "✅ Mise optimization complete!"
    echo "💡 Benefits: Faster tool switching and startup"
}

# All-in-one optimization
function optimize-dev-tools() {
    echo "🚀 Running comprehensive development tools optimization..."
    echo ""
    
    uv-optimize
    echo ""
    bun-optimize
    echo ""
    mise-optimize
    echo ""
    
    # Source performance optimizations
    if [[ -f "$DOTFILES_DIR/lib/performance.sh" ]]; then
        source "$DOTFILES_DIR/lib/performance.sh"
        init_performance_optimizations 2>/dev/null
    fi
    
    echo "🎉 All development tools optimized!"
    echo "💡 Run 'perf-benchmark-startup' to see improvements"
}

# Quick tool updates
function update-dev-tools() {
    echo "🔄 Updating development tools..."
    
    # Update uv
    if command -v uv >/dev/null 2>&1; then
        echo "📦 Updating uv..."
        uv self update
    fi
    
    # Update bun
    if command -v bun >/dev/null 2>&1; then
        echo "📦 Updating bun..."
        bun upgrade
    fi
    
    # Update mise and tools
    if command -v mise >/dev/null 2>&1; then
        echo "📦 Updating mise..."
        mise self-update
        echo "📦 Updating mise tools..."
        mise upgrade
    fi
    
    echo "✅ Development tools updated!"
}