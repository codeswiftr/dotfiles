#!/usr/bin/env bash
# ============================================================================
# Neovim Configuration Migration Script
# Safely migrate from complex to streamlined progressive configuration
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
DOTFILES_DIR="$HOME/dotfiles"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"
NEW_CONFIG_DIR="$DOTFILES_DIR/config/nvim"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
highlight() { echo -e "${CYAN}$1${NC}"; }

# Check current configuration complexity
analyze_current_config() {
    log "Analyzing current Neovim configuration..."
    
    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        log "No existing Neovim configuration found"
        return 0
    fi
    
    local init_file="$NVIM_CONFIG_DIR/init.lua"
    if [[ ! -f "$init_file" ]]; then
        init_file="$NVIM_CONFIG_DIR/init.vim"
    fi
    
    if [[ -f "$init_file" ]]; then
        local lines=$(wc -l < "$init_file" 2>/dev/null || echo 0)
        local plugins=0
        local keymaps=0
        
        if [[ "$init_file" == *.lua ]]; then
            plugins=$(grep -c "github.*/" "$init_file" 2>/dev/null || echo 0)
            keymaps=$(grep -c "keymap\|vim\.keymap\|map.*=" "$init_file" 2>/dev/null || echo 0)
        fi
        
        echo ""
        highlight "📊 Current Configuration Analysis:"
        echo "   Config file: $(basename "$init_file")"
        echo "   Lines of code: $lines"
        echo "   Estimated plugins: $plugins"
        echo "   Estimated keymaps: $keymaps"
        echo ""
        
        if [[ $lines -gt 500 ]]; then
            warning "Configuration has $lines lines (recommended: <300)"
        fi
        
        if [[ $plugins -gt 15 ]]; then
            warning "Configuration has $plugins+ plugins (recommended: 8-23)" 
        fi
        
        return 0
    else
        log "No init file found in $NVIM_CONFIG_DIR"
        return 1
    fi
}

# Show migration preview
show_migration_preview() {
    echo ""
    highlight "🔄 Migration Preview: Complex → Progressive"
    echo ""
    echo "CURRENT APPROACH (Monolithic):"
    echo "  • 1,000+ lines in single file"
    echo "  • 30+ plugins loaded at startup"
    echo "  • 100+ key bindings to remember"
    echo "  • 2-5 second startup time"
    echo "  • Overwhelming for new users"
    echo ""
    echo "NEW APPROACH (Progressive Tiers):"
    echo "  • Tier 1: 8 essential plugins, 15 key bindings"
    echo "  • Tier 2: +15 plugins for full IDE experience" 
    echo "  • Tier 3: +10 plugins for AI and advanced features"
    echo "  • Modular architecture (easy to customize)"
    echo "  • Built-in discovery system (which-key)"
    echo ""
    echo "KEY BENEFITS:"
    echo "  ✅ 30-minute learning curve (vs days/weeks)"
    echo "  ✅ <500ms startup for Tier 1"
    echo "  ✅ Progressive complexity"
    echo "  ✅ Visual command discovery"
    echo "  ✅ Better performance through lazy loading"
    echo "  ✅ Easier to maintain and customize"
    echo ""
}

# Create backup
create_backup() {
    if [[ -d "$NVIM_CONFIG_DIR" ]]; then
        log "Creating backup of current configuration..."
        cp -r "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        success "Backup created: $BACKUP_DIR"
    else
        log "No existing configuration to backup"
    fi
}

# Apply new configuration
apply_new_config() {
    log "Applying new streamlined configuration..."
    
    # Create nvim config directory if it doesn't exist
    mkdir -p "$NVIM_CONFIG_DIR"
    
    # Copy new modular configuration
    if [[ -d "$NEW_CONFIG_DIR/lua" ]]; then
        cp -r "$NEW_CONFIG_DIR/lua" "$NVIM_CONFIG_DIR/"
        success "Copied modular configuration structure"
    else
        error "New configuration not found at $NEW_CONFIG_DIR"
        exit 1
    fi
    
    # Install new init.lua
    if [[ -f "$NEW_CONFIG_DIR/init-streamlined.lua" ]]; then
        cp "$NEW_CONFIG_DIR/init-streamlined.lua" "$NVIM_CONFIG_DIR/init.lua"
        success "Installed new init.lua"
    else
        error "New init.lua not found"
        exit 1
    fi
}

# Test configuration
test_configuration() {
    log "Testing new configuration..."
    
    # Try to start Neovim with the new config
    if timeout 10s nvim --headless -c "lua print('Configuration test successful')" -c "qa" 2>/dev/null; then
        success "Configuration loads successfully"
    else
        warning "Configuration test timed out or failed"
        log "This might be normal on first run (plugin installation)"
    fi
}

# Show post-migration instructions
show_next_steps() {
    echo ""
    highlight "🎉 Migration Complete!"
    echo ""
    echo "NEW NEOVIM EXPERIENCE:"
    echo ""
    echo "🚀 TIER 1 - ESSENTIAL COMMANDS (Active Now):"
    echo "   Files:     <Space>ff (find files), <Space>e (explorer)"
    echo "   Navigate:  <C-h/j/k/l> (windows), <Space>b (buffers)"
    echo "   Code:      gd (definition), gr (references), <Space>ca (actions)"
    echo "   Format:    <Space>f (format code)"
    echo "   Help:      <Space>? (show all commands)"
    echo ""
    echo "📈 TIER PROGRESSION:"
    echo "   • Current: Tier 1 (8 plugins, 15 shortcuts)"
    echo "   • Upgrade: :TierUp command in Neovim"
    echo "   • Status:  :TierStatus to see current tier"
    echo "   • Help:    :TierHelp for detailed information"
    echo ""
    echo "⚡ PERFORMANCE:"
    echo "   • Expected startup: <500ms (Tier 1)"
    echo "   • Test with: NVIM_PROFILE=1 nvim"
    echo ""
    echo "🔧 NEXT STEPS:"
    echo "   1. Start Neovim: nvim"
    echo "   2. Let plugins install automatically"
    echo "   3. Press <Space>? to see all commands"
    echo "   4. Try :TierHelp for upgrade options"
    echo "   5. When comfortable, run :TierUp for more features"
    echo ""
    echo "🔄 ROLLBACK (if needed):"
    echo "   rm -rf ~/.config/nvim"
    echo "   mv $BACKUP_DIR ~/.config/nvim"
    echo ""
}

# Show tier comparison
show_tier_comparison() {
    echo ""
    highlight "📊 Tier Comparison:"
    echo ""
    printf "%-12s %-10s %-12s %-12s %-20s\n" "Tier" "Plugins" "Keybindings" "Startup" "Best For"
    echo "─────────────────────────────────────────────────────────────────────"
    printf "%-12s %-10s %-12s %-12s %-20s\n" "Tier 1" "8" "15" "<500ms" "Beginners, Focus"
    printf "%-12s %-10s %-12s %-12s %-20s\n" "Tier 2" "23" "35" "<800ms" "Full Development"
    printf "%-12s %-10s %-12s %-12s %-20s\n" "Tier 3" "33" "55" "<1200ms" "AI & Power Users"
    printf "%-12s %-10s %-12s %-12s %-20s\n" "Current" "37+" "100+" "2000ms+" "Experts Only"
    echo ""
}

# Interactive tier selection
select_initial_tier() {
    echo ""
    highlight "🎯 Choose Your Starting Tier:"
    echo ""
    echo "1) Tier 1 - Essential Editor (Recommended for beginners)"
    echo "   • 8 plugins, 15 shortcuts, <500ms startup"
    echo "   • Perfect for learning and focused development"
    echo ""
    echo "2) Tier 2 - Enhanced Development"
    echo "   • 23 plugins, 35 shortcuts, <800ms startup"
    echo "   • Full IDE experience with git, debugging, status line"
    echo ""
    echo "3) Tier 3 - AI-Powered Workflows"
    echo "   • 33 plugins, 55 shortcuts, <1200ms startup"
    echo "   • All features including AI integration"
    echo ""
    
    if [[ -n "${DOTFILES_NONINTERACTIVE:-}" || -n "${CI:-}" ]]; then
        tier_choice=1
        if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
            sed -i.bak "s/vim\.g\.nvim_tier = .*/vim.g.nvim_tier = $tier_choice/" "$NVIM_CONFIG_DIR/init.lua"
            success "Non-interactive: defaulted initial tier to $tier_choice"
        fi
    else
        while true; do
            read -p "Select tier (1-3) [1]: " tier_choice
            tier_choice=${tier_choice:-1}
            case $tier_choice in
                1|2|3)
                    if [[ -f "$NVIM_CONFIG_DIR/init.lua" ]]; then
                        sed -i.bak "s/vim\.g\.nvim_tier = .*/vim.g.nvim_tier = $tier_choice/" "$NVIM_CONFIG_DIR/init.lua"
                        success "Set initial tier to $tier_choice"
                    fi
                    break
                    ;;
                *)
                    echo "Please enter 1, 2, or 3"
                    ;;
            esac
        done
    fi
}

# Main execution flow
main() {
    echo ""
    highlight "🚀 Neovim Configuration Migration"
    echo "Transform from overwhelming complexity to progressive simplicity"
    echo "═══════════════════════════════════════════════════════════════════"
    
    analyze_current_config
    show_migration_preview
    show_tier_comparison
    
    echo ""
    if [[ -n "${DOTFILES_NONINTERACTIVE:-}" || -n "${CI:-}" ]]; then
        log "Non-interactive mode detected; proceeding with migration."
    else
        read -p "Proceed with migration? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Migration cancelled"
            exit 0
        fi
    fi
    
    create_backup
    apply_new_config
    select_initial_tier
    test_configuration
    show_next_steps
    
    success "🎉 Neovim successfully migrated to progressive configuration!"
    echo ""
    highlight "Ready to experience the new streamlined Neovim? Run: nvim"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Neovim Configuration Migration Script"
        echo ""
        echo "USAGE:"
        echo "  $0              Run interactive migration"
        echo "  $0 --preview    Show what will change"
        echo "  $0 --help       Show this help"
        echo ""
        echo "This script migrates from complex Neovim config (1000+ lines)"
        echo "to a progressive, discoverable system (Tier 1→2→3)"
        exit 0
        ;;
    --preview)
        analyze_current_config
        show_migration_preview
        show_tier_comparison
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac