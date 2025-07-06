#!/usr/bin/env bash
# ============================================================================
# Fix Tmux Keybinding Conflicts
# Switches from complex to streamlined tmux configuration
# ============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

echo "🔧 Fixing tmux keybinding conflicts..."
echo ""

# Backup current tmux configuration
if [[ -f ~/.tmux.conf ]]; then
    echo "📦 Backing up current tmux configuration..."
    cp ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup created: ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
else
    echo "ℹ️  No existing tmux configuration found"
fi

# Use streamlined configuration
echo "🚀 Installing streamlined tmux configuration..."
cp "$DOTFILES_DIR/.tmux-streamlined.conf" ~/.tmux.conf

# Kill existing tmux sessions to force reload
if pgrep -f tmux >/dev/null; then
    echo "🔄 Reloading tmux configuration..."
    tmux source-file ~/.tmux.conf 2>/dev/null || echo "ℹ️  Will reload when you start tmux"
else
    echo "ℹ️  No active tmux sessions to reload"
fi

echo ""
echo "✅ Tmux configuration fixed!"
echo ""
echo "🎯 Now Ctrl-a + c will correctly create a new window"
echo ""
echo "📚 Quick reference:"
echo "  Ctrl-a c     Create new window (FIXED!)"
echo "  Ctrl-a |     Split horizontally"
echo "  Ctrl-a -     Split vertically"
echo "  Ctrl-a h/j/k/l  Navigate panes"
echo "  Ctrl-a ?     Help screen"
echo "  Ctrl-a T     Tier upgrade options"
echo ""
echo "🚀 Start tmux to experience the streamlined configuration!"