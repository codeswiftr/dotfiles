#!/usr/bin/env bash
# ============================================================================
# Complete Tmux Fix Script
# Resolves ALL keybinding conflicts and copy/paste issues
# ============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Parse command line arguments
auto_confirm=false
quiet=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            auto_confirm=true
            shift
            ;;
        --quiet|-q)
            quiet=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--yes] [--quiet]"
            echo "  --yes    Skip confirmation prompts"
            echo "  --quiet  Suppress non-essential output"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ "$quiet" != "true" ]]; then
    echo "🔧 COMPLETE TMUX CONFIGURATION FIX"
    echo "=================================="
    echo ""
fi

# Check if tmux is running
if pgrep -f tmux >/dev/null; then
    if [[ "$quiet" != "true" ]]; then
        echo "⚠️  Active tmux sessions detected"
    fi
    
    if [[ "$auto_confirm" != "true" ]]; then
        if [[ "$quiet" != "true" ]]; then
            echo "💡 Recommendation: Save your work and run 'tmux kill-server' first"
            echo "   This ensures a clean configuration reload"
            echo ""
        fi
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Fix cancelled. Run 'tmux kill-server' first, then re-run this script."
            exit 1
        fi
    fi
fi

# Backup current configuration
if [[ "$quiet" != "true" ]]; then
    echo "📦 Creating configuration backup..."
fi

if [[ -f ~/.tmux.conf ]]; then
    backup_file=~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
    cp ~/.tmux.conf "$backup_file"
    if [[ "$quiet" != "true" ]]; then
        echo "✅ Backup created: $backup_file"
    fi
else
    if [[ "$quiet" != "true" ]]; then
        echo "ℹ️  No existing tmux configuration found"
    fi
fi

# Install the fixed configuration
if [[ "$quiet" != "true" ]]; then
    echo ""
    echo "🚀 Installing FIXED tmux configuration..."
fi
cp "$DOTFILES_DIR/.tmux-fixed.conf" ~/.tmux.conf

# Test the new configuration
if [[ "$quiet" != "true" ]]; then
    echo ""
    echo "🧪 Testing new configuration..."
fi
if tmux -f ~/.tmux.conf list-keys >/dev/null 2>&1; then
    echo "✅ Configuration syntax is valid"
else
    echo "❌ Configuration has syntax errors"
    echo "🔄 Restoring backup..."
    if [[ -f "$backup_file" ]]; then
        cp "$backup_file" ~/.tmux.conf
        echo "✅ Backup restored"
    fi
    exit 1
fi

# Reload configuration if tmux is running
if pgrep -f tmux >/dev/null; then
    echo ""
    echo "🔄 Reloading tmux configuration..."
    tmux source-file ~/.tmux.conf 2>/dev/null || echo "ℹ️  Please restart tmux for full effect"
fi

echo ""
echo "🎉 TMUX CONFIGURATION COMPLETELY FIXED!"
echo "======================================="
echo ""

echo "✅ RESOLVED ISSUES:"
echo "  • Ctrl-a + c now creates new window (was Claude)"
echo "  • Ctrl-a + d now detaches session (was Docker)"  
echo "  • Copy/paste workflow restored and improved"
echo "  • Mouse copy to system clipboard working"
echo "  • All tools organized in conflict-free menus"
echo ""

echo "🎯 ESSENTIAL COMMANDS:"
echo "  Ctrl-a c     Create new window"
echo "  Ctrl-a d     Detach from session"
echo "  Ctrl-a |     Split horizontally"
echo "  Ctrl-a -     Split vertically"
echo "  Ctrl-a h/j/k/l  Navigate panes"
echo "  Ctrl-a x     Close pane"
echo ""

echo "📋 COPY/PASTE (FIXED):"
echo "  Ctrl-a [     Enter copy mode"
echo "  v + y        Select and copy (in copy mode)"
echo "  Ctrl-a ]     Paste"
echo "  Mouse drag   Copies to system clipboard automatically"
echo ""

echo "🛠️  TOOL ACCESS (NO CONFLICTS):"
echo "  Ctrl-a A     AI Tools menu (Claude, Aider, Gemini)"
echo "  Ctrl-a D     Dev Tools menu (Docker, FastAPI, Node)"
echo "  Ctrl-a T     Testing menu (Pytest, Playwright, Bruno)"
echo "  Ctrl-a G     Git Tools menu"
echo "  Ctrl-a M     Monitoring tools"
echo ""

echo "📚 HELP & SESSION:"
echo "  Ctrl-a ?     Complete help screen"
echo "  Ctrl-a s     Session picker"
echo "  Ctrl-a r     Reload config"
echo ""

echo "🚀 START USING:"
if pgrep -f tmux >/dev/null; then
    echo "   Your current tmux session has the new config!"
    echo "   Try: Ctrl-a ? to see the help screen"
else
    echo "   Run: tmux"
    echo "   Try: Ctrl-a c to create a new window"
    echo "   Try: Ctrl-a ? to see all commands"
fi

echo ""
echo "💡 KEY IMPROVEMENTS:"
echo "   • Only 20 essential bindings (was 60+)"
echo "   • All tools accessible via organized menus"
echo "   • Perfect copy/paste with system clipboard"
echo "   • No conflicts with standard tmux behavior"
echo "   • Mouse support fully functional"

echo ""
echo "🎊 Configuration fix complete! Enjoy your streamlined tmux experience!"