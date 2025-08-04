# ============================================================================
# DOT CLI Backward Compatibility Aliases 
# Maintains compatibility with existing functions during transition
# ============================================================================

# Project initialization aliases
alias fastapi-init='_dot_legacy_wrapper dot project init fastapi'
alias ios-init='_dot_legacy_wrapper dot project init ios'
alias lit-init='_dot_legacy_wrapper dot project init lit'
alias fullstack-dev='_dot_legacy_wrapper dot project init fullstack'

# AI workflow aliases
alias ai-commit='_dot_legacy_wrapper dot ai commit'
alias ai-review-branch='_dot_legacy_wrapper dot ai review'
alias ai-analyze='_dot_legacy_wrapper dot ai analyze'
alias ai-debug='_dot_legacy_wrapper dot ai debug'
alias ai-compare='_dot_legacy_wrapper dot ai compare'
alias claude-context='_dot_legacy_wrapper dot ai context'

# Legacy wrapper function with deprecation notice
_dot_legacy_wrapper() {
    local legacy_command="$1"
    shift
    local new_command="$*"
    
    # Show deprecation notice once per session
    local deprecation_var="_SHOWN_DEPRECATION_$(echo "$legacy_command" | tr ' -' '_' | tr '[:lower:]' '[:upper:]')"
    
    if [[ -z "${(P)deprecation_var}" ]]; then
        echo "⚠️  DEPRECATED: This command will be removed in a future version."
        echo "   Use: $new_command"
        echo "   Legacy: $legacy_command"
        echo ""
        export "$deprecation_var=1"
    fi
    
    # Execute the new command
    eval "$new_command"
}

# Enhanced project aliases that work with new CLI
alias fastapi-dev='dot run dev'
alias fastapi-test='dot run test'
alias web-serve='dot run serve'
alias ios-build='dot run build'
alias ios-test='dot run test'

# Additional convenience aliases
alias project-init='dot project init'
alias project-list='dot project list'
alias ai-help='dot ai --help'
alias dot-help='dot --help'

# Legacy function names for compatibility
fastapi-db-upgrade() {
    echo "⚠️  DEPRECATED: Use 'dot db upgrade' instead"
    if [[ -f "alembic.ini" ]]; then
        if command -v uv >/dev/null 2>&1; then
            uv run alembic upgrade head
        else
            source venv/bin/activate 2>/dev/null || true
            alembic upgrade head
        fi
    else
        echo "❌ No Alembic configuration found."
    fi
}

fastapi-db-migrate() {
    local message=${1:-"Auto migration"}
    echo "⚠️  DEPRECATED: Use 'dot db migrate \"$message\"' instead"
    if [[ -f "alembic.ini" ]]; then
        if command -v uv >/dev/null 2>&1; then
            uv run alembic revision --autogenerate -m "$message"
        else
            source venv/bin/activate 2>/dev/null || true
            alembic revision --autogenerate -m "$message"
        fi
    else
        echo "❌ No Alembic configuration found."
    fi
}

# iOS development compatibility
ios-reset-simulator() {
    echo "⚠️  DEPRECATED: Use 'dot ios reset-simulator' instead"
    echo "🔄 Resetting iOS Simulator..."
    xcrun simctl shutdown all
    xcrun simctl erase all
    xcrun simctl boot 'iPhone 15 Pro'
    echo "✅ iOS Simulator reset complete"
}

swift-package-init() {
    echo "⚠️  DEPRECATED: Use 'dot project init ios' instead"
    dot project init ios "$@"
}

# Web development compatibility
pwa-audit() {
    local url=${1:-"http://localhost:8000"}
    echo "⚠️  DEPRECATED: Use 'dot test audit' instead"
    echo "🔍 Running PWA audit on: $url"
    
    if command -v lighthouse >/dev/null; then
        lighthouse "$url" --only-categories=pwa --chrome-flags="--headless"
    else
        echo "📱 Install Lighthouse: npm install -g lighthouse"
        echo "🌐 Or use online audit: https://web.dev/measure/"
    fi
}

web-dev-check() {
    echo "⚠️  DEPRECATED: Use 'dot check' instead"
    dot check
}

# Help system for legacy users
show-dot-migration() {
    cat << 'EOF'
🚀 DOT CLI Migration Guide

Your legacy commands have been consolidated into the unified DOT CLI:

PROJECT COMMANDS:
  fastapi-init <name>           →  dot project init fastapi <name>
  ios-init <name>               →  dot project init ios <name>
  lit-init <name>               →  dot project init lit <name>
  fullstack-dev <name>          →  dot project init fullstack <name>

AI COMMANDS:
  ai-commit                     →  dot ai commit
  ai-review-branch              →  dot ai review
  ai-analyze <type>             →  dot ai analyze <type>
  ai-debug <error>              →  dot ai debug <error>
  claude-context <prompt>       →  dot ai context <prompt>

DISCOVERY:
  Run 'dot --help' to see all available commands
  Run 'dot <category> --help' for category-specific help
  
BENEFITS:
  ✅ Unified command interface
  ✅ Better help system and discoverability  
  ✅ Consistent patterns across all tools
  ✅ Enhanced error handling and validation
  ✅ Auto-completion support

The legacy aliases will continue to work but show deprecation warnings.
EOF
}

# Auto-show migration guide for new terminal sessions (once per day)
_show_migration_guide_once() {
    local last_shown_file="$HOME/.dot_migration_shown"
    local today=$(date +%Y-%m-%d)
    
    if [[ ! -f "$last_shown_file" ]] || [[ "$(cat "$last_shown_file")" != "$today" ]]; then
        echo ""
        echo "🆕 DOT CLI has been updated! Your commands are now unified."
        echo "   Run 'show-dot-migration' for the migration guide."
        echo "   Run 'dot --help' to explore the new interface."
        echo ""
        echo "$today" > "$last_shown_file"
    fi
}

# Show migration guide once per day
_show_migration_guide_once