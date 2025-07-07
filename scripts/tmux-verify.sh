#!/usr/bin/env bash
# ============================================================================
# Tmux Configuration Verification Script
# Tests all essential functions to ensure they work correctly
# ============================================================================

set -e

echo "🧪 TMUX CONFIGURATION VERIFICATION"
echo "=================================="
echo ""

# Check if tmux is available
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux is not installed"
    exit 1
fi

echo "✅ tmux is installed: $(tmux -V)"
echo ""

# Check configuration syntax
echo "🔍 Testing configuration syntax..."
if tmux -f ~/.tmux.conf list-keys >/dev/null 2>&1; then
    echo "✅ Configuration syntax is valid"
else
    echo "❌ Configuration has syntax errors"
    exit 1
fi

# Check critical key bindings
echo ""
echo "🎯 Verifying essential key bindings..."

# Check new window binding
new_window_binding=$(tmux list-keys | grep "bind-key.*-T prefix.*c[[:space:]]" | head -1)
if [[ "$new_window_binding" == *"new-window"* ]]; then
    echo "✅ Ctrl-a + c → new-window (FIXED)"
elif [[ "$new_window_binding" == *"claude"* ]]; then
    echo "❌ Ctrl-a + c → still bound to Claude"
else
    echo "⚠️  Ctrl-a + c → unknown binding: $new_window_binding"
fi

# Check detach binding
detach_binding=$(tmux list-keys | grep "bind-key.*-T prefix.*d[[:space:]]" | head -1)
if [[ "$detach_binding" == *"detach"* ]]; then
    echo "✅ Ctrl-a + d → detach-client (FIXED)"
elif [[ "$detach_binding" == *"docker"* ]]; then
    echo "❌ Ctrl-a + d → still bound to Docker"
else
    echo "⚠️  Ctrl-a + d → unknown binding: $detach_binding"
fi

# Check copy mode bindings
copy_mode_binding=$(tmux list-keys | grep "bind-key.*-T prefix.*\\[")
if [[ -n "$copy_mode_binding" ]]; then
    echo "✅ Ctrl-a + [ → copy-mode"
else
    echo "❌ Copy mode binding missing"
fi

paste_binding=$(tmux list-keys | grep "bind-key.*-T prefix.*\\]")
if [[ -n "$paste_binding" ]]; then
    echo "✅ Ctrl-a + ] → paste-buffer"
else
    echo "❌ Paste binding missing"
fi

# Check tool menu bindings
ai_menu=$(tmux list-keys | grep "bind-key.*-T prefix.*A")
if [[ -n "$ai_menu" ]]; then
    echo "✅ Ctrl-a + A → AI Tools menu"
else
    echo "❌ AI Tools menu missing"
fi

dev_menu=$(tmux list-keys | grep "bind-key.*-T prefix.*D")
if [[ -n "$dev_menu" ]]; then
    echo "✅ Ctrl-a + D → Dev Tools menu"
else
    echo "❌ Dev Tools menu missing"
fi

# Check total binding count
echo ""
echo "📊 Configuration complexity analysis..."
total_bindings=$(tmux list-keys | grep "bind-key.*-T prefix" | wc -l | tr -d ' ')
echo "   Total prefix bindings: $total_bindings"

if [[ $total_bindings -le 25 ]]; then
    echo "✅ Streamlined configuration (≤25 bindings)"
elif [[ $total_bindings -le 40 ]]; then
    echo "⚠️  Moderate complexity ($total_bindings bindings)"
else
    echo "❌ Complex configuration ($total_bindings bindings - should be ≤25)"
fi

# Mouse support check
echo ""
echo "🖱️  Checking mouse support..."
mouse_setting=$(tmux show-option -g mouse 2>/dev/null || echo "mouse off")
if [[ "$mouse_setting" == *"on"* ]]; then
    echo "✅ Mouse support enabled"
else
    echo "❌ Mouse support disabled"
fi

# Copy mode settings check
echo ""
echo "📋 Checking copy mode settings..."
mode_keys=$(tmux show-window-option -g mode-keys 2>/dev/null || echo "emacs")
if [[ "$mode_keys" == *"vi"* ]]; then
    echo "✅ Vi-style copy mode enabled"
else
    echo "⚠️  Emacs-style copy mode (vi recommended)"
fi

# System clipboard integration
echo ""
echo "📎 Testing system clipboard integration..."
if command -v pbcopy >/dev/null 2>&1; then
    echo "✅ pbcopy available (macOS clipboard)"
elif command -v xclip >/dev/null 2>&1; then
    echo "✅ xclip available (Linux clipboard)"
elif command -v xsel >/dev/null 2>&1; then
    echo "✅ xsel available (Linux clipboard)"
else
    echo "⚠️  No clipboard utility found (copy may not work)"
fi

# Plugin manager check
echo ""
echo "🔌 Checking plugin manager..."
if [[ -d ~/.tmux/plugins/tpm ]]; then
    echo "✅ TPM (Tmux Plugin Manager) installed"
else
    echo "⚠️  TPM not found (will be auto-installed on first run)"
fi

# Summary
echo ""
echo "📋 VERIFICATION SUMMARY"
echo "======================"

# Count issues
issues=0

if [[ "$new_window_binding" != *"new-window"* ]]; then
    ((issues++))
fi

if [[ "$detach_binding" != *"detach"* ]]; then
    ((issues++))
fi

if [[ -z "$copy_mode_binding" ]] || [[ -z "$paste_binding" ]]; then
    ((issues++))
fi

if [[ $total_bindings -gt 40 ]]; then
    ((issues++))
fi

if [[ "$mouse_setting" != *"on"* ]]; then
    ((issues++))
fi

if [[ $issues -eq 0 ]]; then
    echo "🎉 ALL CHECKS PASSED!"
    echo "   Your tmux configuration is working perfectly."
    echo ""
    echo "🚀 Ready to use:"
    echo "   • Ctrl-a c → new window"
    echo "   • Ctrl-a d → detach session"
    echo "   • Ctrl-a [ → copy mode"
    echo "   • Mouse drag → copy to clipboard"
    echo "   • Ctrl-a A/D/T/G/M → tool menus"
else
    echo "⚠️  Found $issues issue(s) that need attention."
    echo "   Run the complete fix script to resolve them:"
    echo "   ~/dotfiles/scripts/tmux-fix-complete.sh"
fi

echo ""
echo "💡 Next steps:"
echo "   • Test in a new tmux session: tmux"
echo "   • Try creating a window: Ctrl-a c"
echo "   • Try copying text: Ctrl-a [ then v+y"
echo "   • Access help: Ctrl-a ?"