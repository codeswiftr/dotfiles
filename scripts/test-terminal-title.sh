#!/usr/bin/env bash
# ============================================================================
# Test Script for macOS Terminal Window Title
# Tests whether terminal title setting works correctly
# ============================================================================

set -euo pipefail

echo "🧪 Testing macOS Terminal window title functionality..."
echo ""

# Test 1: Basic title setting
echo "📝 Test 1: Setting basic title..."
printf '\033]2;Test Title 1\007'
echo "   Terminal window title should now show: 'Test Title 1'"
echo "   Check your Terminal.app window title bar!"
sleep 3

# Test 2: Title with session info
echo ""
echo "📝 Test 2: Setting title with session info..."
if [[ -n "$TMUX" ]]; then
    session_name=$(tmux display-message -p '#S' 2>/dev/null)
    window_name=$(tmux display-message -p '#W' 2>/dev/null)
    window_index=$(tmux display-message -p '#I' 2>/dev/null)
    
    title="$session_name:$window_index.$window_name"
    printf '\033]2;%s\007' "$title"
    echo "   Terminal window title should now show: '$title'"
    echo "   (Session: $session_name, Window: $window_index.$window_name)"
else
    title="No Tmux Session"
    printf '\033]2;%s\007' "$title"
    echo "   Terminal window title should now show: '$title'"
    echo "   (Not in a tmux session)"
fi
sleep 3

# Test 3: Dynamic title
echo ""
echo "📝 Test 3: Setting dynamic title based on current directory..."
current_dir=$(basename "$PWD")
title="Terminal: $current_dir"
printf '\033]2;%s\007' "$title"
echo "   Terminal window title should now show: '$title'"
sleep 3

# Test 4: Reset to default
echo ""
echo "📝 Test 4: Resetting to default..."
printf '\033]2;Terminal\007'
echo "   Terminal window title should now show: 'Terminal'"
sleep 2

echo ""
echo "✅ Test complete!"
echo ""
echo "🔍 What to check:"
echo "   • Look at your Terminal.app window title bar (not tmux status line)"
echo "   • The title should have changed 4 times during this test"
echo "   • If you saw the titles change, the functionality is working!"
echo ""
echo "💡 If it didn't work, check:"
echo "   • Terminal.app Preferences > Profiles > Window > Title"
echo "   • Make sure 'Window title' shows: 'Active Process Name'"
echo "   • Or try: 'Command arguments' or 'Custom string'"