#!/usr/bin/env bash
# ============================================================================
# Tmux Configuration Diagnostics
# Shows keybinding conflicts and current configuration issues
# ============================================================================

echo "🔍 Tmux Configuration Diagnostics"
echo "=================================="
echo ""

# Check if tmux is running
if ! pgrep -f tmux >/dev/null; then
    echo "⚠️  No tmux sessions are currently running"
    echo "💡 Start tmux first, then run this script"
    echo ""
fi

echo "🔧 Current Configuration File:"
if [[ -f ~/.tmux.conf ]]; then
    echo "✅ ~/.tmux.conf exists"
    echo "📄 First few lines:"
    head -5 ~/.tmux.conf | sed 's/^/   /'
else
    echo "❌ No ~/.tmux.conf found"
fi

echo ""
echo "🎯 Key Binding Analysis:"
echo ""

# Check for conflicting 'c' binding
echo "🔸 Ctrl-a + c binding:"
if command -v tmux >/dev/null && pgrep -f tmux >/dev/null; then
    tmux list-keys | grep "bind-key.*-T prefix.*c[[:space:]]" | head -1 | sed 's/^/   /'
    c_binding=$(tmux list-keys | grep "bind-key.*-T prefix.*c[[:space:]]" | head -1)
    if [[ "$c_binding" == *"claude"* ]]; then
        echo "   ❌ PROBLEM: 'c' launches Claude instead of creating window"
    elif [[ "$c_binding" == *"new-window"* ]]; then
        echo "   ✅ CORRECT: 'c' creates new window"
    else
        echo "   ⚠️  UNKNOWN: Unexpected binding"
    fi
else
    echo "   ⚠️  Cannot check (tmux not running)"
fi

echo ""

# Check for conflicting 'd' binding
echo "🔸 Ctrl-a + d binding:"
if command -v tmux >/dev/null && pgrep -f tmux >/dev/null; then
    tmux list-keys | grep "bind-key.*-T prefix.*d[[:space:]]" | head -1 | sed 's/^/   /'
    d_binding=$(tmux list-keys | grep "bind-key.*-T prefix.*d[[:space:]]" | head -1)
    if [[ "$d_binding" == *"docker"* ]]; then
        echo "   ❌ PROBLEM: 'd' launches Docker instead of detaching"
    elif [[ "$d_binding" == *"detach"* ]]; then
        echo "   ✅ CORRECT: 'd' detaches session"
    else
        echo "   ⚠️  UNKNOWN: Unexpected binding"
    fi
else
    echo "   ⚠️  Cannot check (tmux not running)"
fi

echo ""
echo "📊 Configuration Summary:"

# Count total bindings
if command -v tmux >/dev/null && pgrep -f tmux >/dev/null; then
    total_bindings=$(tmux list-keys | grep "bind-key.*-T prefix" | wc -l)
    echo "   Total prefix bindings: $total_bindings"
    
    if [[ $total_bindings -gt 20 ]]; then
        echo "   ⚠️  Complex configuration detected (>20 bindings)"
        echo "   💡 Consider using streamlined config for simplicity"
    elif [[ $total_bindings -le 15 ]]; then
        echo "   ✅ Streamlined configuration (≤15 bindings)"
    else
        echo "   ℹ️  Moderate configuration complexity"
    fi
else
    echo "   ⚠️  Cannot analyze (tmux not running)"
fi

echo ""
echo "🚀 Recommended Actions:"

# Check current config type
if [[ -f ~/.tmux.conf ]]; then
    if grep -q "streamlined" ~/.tmux.conf; then
        echo "   ✅ You're already using the streamlined configuration"
        echo "   💡 If you're still having issues, try: tmux kill-server && tmux"
    elif grep -q "development.conf\|ai-integration" ~/.tmux.conf; then
        echo "   🔧 You're using the complex configuration"
        echo "   💡 Run: ~/dotfiles/scripts/tmux-fix.sh"
        echo "   💡 This will switch to streamlined config with only 10 essential bindings"
    else
        echo "   ❓ Unknown configuration type"
        echo "   💡 Consider running: ~/dotfiles/scripts/tmux-fix.sh"
    fi
else
    echo "   📝 No tmux configuration found"
    echo "   💡 Run: ~/dotfiles/scripts/tmux-fix.sh"
fi

echo ""
echo "🎯 Quick Fix:"
echo "   ~/dotfiles/scripts/tmux-fix.sh"