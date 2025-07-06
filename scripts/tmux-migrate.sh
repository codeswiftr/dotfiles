#!/usr/bin/env bash
# ============================================================================
# Tmux Configuration Migration Script
# Safely migrate from complex to streamlined tmux configuration
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
DOTFILES_DIR="$HOME/dotfiles"
CURRENT_CONFIG="$HOME/.tmux.conf"
NEW_CONFIG="$DOTFILES_DIR/.tmux.conf.new"
BACKUP_CONFIG="$HOME/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check current configuration complexity
analyze_current_config() {
    if [[ ! -f "$CURRENT_CONFIG" ]]; then
        log "No existing tmux configuration found"
        return 0
    fi
    
    local bindings=$(grep -c "^bind" "$CURRENT_CONFIG" 2>/dev/null || echo 0)
    local lines=$(wc -l < "$CURRENT_CONFIG" 2>/dev/null || echo 0)
    
    echo ""
    echo "📊 Current Configuration Analysis:"
    echo "   Lines of config: $lines"
    echo "   Key bindings: $bindings"
    echo ""
    
    if [[ $bindings -gt 30 ]]; then
        warning "Your current config has $bindings key bindings (recommended: <15)"
        echo "   This migration will simplify to 10 essential bindings"
    elif [[ $bindings -gt 15 ]]; then
        warning "Your current config has $bindings key bindings (recommended: <15)" 
        echo "   This migration will streamline your configuration"
    else
        log "Your current config is already reasonably simple"
    fi
}

# Show what will change
show_migration_preview() {
    echo ""
    echo "🔄 Migration Preview:"
    echo ""
    echo "CURRENT APPROACH (Complex):"
    echo "  • 66+ key bindings across multiple files"
    echo "  • All features loaded at once"
    echo "  • No discovery system"
    echo "  • Overwhelming for new users"
    echo ""
    echo "NEW APPROACH (Progressive):"
    echo "  • Tier 1: 10 essential bindings (loaded by default)"
    echo "  • Tier 2: 15 intermediate shortcuts (optional)"
    echo "  • Tier 3: 20+ advanced features (optional)"
    echo "  • Built-in help system (Ctrl-a ?)"
    echo "  • Visual feedback and guidance"
    echo ""
    echo "KEY BENEFITS:"
    echo "  ✅ Faster learning curve"
    echo "  ✅ Better discoverability" 
    echo "  ✅ Reduced cognitive load"
    echo "  ✅ Progressive complexity"
    echo "  ✅ Visual guidance system"
    echo ""
}

# Backup current configuration
backup_config() {
    if [[ -f "$CURRENT_CONFIG" ]]; then
        log "Backing up current configuration to: $BACKUP_CONFIG"
        cp "$CURRENT_CONFIG" "$BACKUP_CONFIG"
        success "Configuration backed up successfully"
    fi
}

# Apply new configuration
apply_new_config() {
    log "Applying new streamlined configuration..."
    
    if [[ -f "$NEW_CONFIG" ]]; then
        cp "$NEW_CONFIG" "$CURRENT_CONFIG"
        success "New configuration applied"
    else
        error "New configuration file not found: $NEW_CONFIG"
        exit 1
    fi
}

# Test configuration
test_config() {
    log "Testing new configuration..."
    
    if tmux source-file "$CURRENT_CONFIG" 2>/dev/null; then
        success "Configuration loads successfully"
    else
        error "Configuration has syntax errors"
        log "Restoring backup..."
        if [[ -f "$BACKUP_CONFIG" ]]; then
            cp "$BACKUP_CONFIG" "$CURRENT_CONFIG"
            warning "Backup restored. Please check the new configuration."
        fi
        exit 1
    fi
}

# Show next steps
show_next_steps() {
    echo ""
    echo "🎉 Migration Complete!"
    echo ""
    echo "ESSENTIAL SHORTCUTS (Tier 1 - Active Now):"
    echo "  Ctrl-a |     Split horizontal"
    echo "  Ctrl-a -     Split vertical"
    echo "  Ctrl-a h/j/k/l  Navigate panes"
    echo "  Ctrl-a c     New window"
    echo "  Ctrl-a x     Close pane" 
    echo "  Ctrl-a d     Detach session"
    echo "  Ctrl-a s     Session picker"
    echo "  Ctrl-a r     Reload config"
    echo "  Ctrl-a ?     Help menu"
    echo ""
    echo "NEXT STEPS:"
    echo "  1. Restart tmux: tmux kill-server && tmux"
    echo "  2. Try the new shortcuts above"
    echo "  3. Press Ctrl-a ? for interactive help"
    echo "  4. When ready for more features:"
    echo "     Edit ~/.tmux.conf and uncomment Tier 2 bindings"
    echo ""
    echo "ROLLBACK:"
    echo "  If you want to revert: cp $BACKUP_CONFIG ~/.tmux.conf"
    echo ""
}

# Show tier advancement instructions
show_tier_instructions() {
    echo ""
    echo "🚀 Advancing Through Tiers:"
    echo ""
    echo "TIER 1 (Current): 10 Essential Commands"
    echo "  Perfect for beginners and focused development"
    echo ""
    echo "TIER 2: +15 Intermediate Commands"
    echo "  Ready? Edit ~/.tmux.conf and uncomment:"
    echo "  # source-file \"\$TMUX_CONFIG_DIR/bindings-tier2.conf\""
    echo ""
    echo "TIER 3: +20 Advanced Commands" 
    echo "  For power users. Uncomment:"
    echo "  # source-file \"\$TMUX_CONFIG_DIR/bindings-tier3.conf\""
    echo ""
    echo "Each tier builds on the previous one."
    echo "You can enable/disable tiers anytime by editing ~/.tmux.conf"
    echo ""
}

# Main execution
main() {
    echo "🚀 Tmux Configuration Migration"
    echo "From complex to streamlined developer experience"
    echo "=============================================="
    
    analyze_current_config
    show_migration_preview
    
    echo ""
    read -p "Proceed with migration? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Migration cancelled"
        exit 0
    fi
    
    backup_config
    apply_new_config
    test_config
    show_next_steps
    show_tier_instructions
    
    success "Tmux successfully migrated to streamlined configuration!"
}

# Handle help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Tmux Configuration Migration Script"
    echo ""
    echo "USAGE:"
    echo "  $0              Run interactive migration"
    echo "  $0 --preview    Show what will change"
    echo "  $0 --help       Show this help"
    echo ""
    echo "This script migrates from complex tmux config (66+ bindings)"
    echo "to a progressive, discoverable system (10 → 25 → 45 bindings)"
    echo ""
    exit 0
fi

# Handle preview flag
if [[ "${1:-}" == "--preview" ]]; then
    analyze_current_config
    show_migration_preview
    exit 0
fi

# Run main migration
main "$@"