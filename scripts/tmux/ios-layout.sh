#!/usr/bin/env bash
# ============================================================================
# iOS/SwiftUI Development Layout for Tmux
# Optimized 4-pane layout for iOS app development workflow
# ============================================================================

set -euo pipefail

# Get the current session name
session_name=$(tmux display-message -p '#S')
window_name="iOS-Dev"

# Create new window or use current one
if tmux list-windows -F "#{window_name}" | grep -q "^${window_name}$"; then
    echo "🔄 Reusing existing iOS development window"
    tmux select-window -t "$window_name"
    tmux kill-pane -a  # Kill all panes except current
else
    echo "🍎 Creating new iOS development window"
    tmux new-window -n "$window_name"
fi

# Layout for iOS Development:
# +------------------+----------+
# |                  | Simulator|
# |     Xcode/       | Controls |
# |    Editor        |  (25%)   |
# |     (75%)        |----------|
# |                  |  Build   |
# |                  |  Logs    |
# +------------------+----------+
# |    Terminal/Swift (25%)     |
# +------------------------------+

# Split window into main editor (left) and side panels (right)
tmux split-window -h -p 25

# Split the right pane vertically for simulator controls (top) and build logs (bottom)
tmux select-pane -t 1
tmux split-window -v -p 50

# Split the left pane horizontally for editor (top) and terminal (bottom)
tmux select-pane -t 0
tmux split-window -v -p 25

# Setup each pane
echo "🔧 Setting up iOS development panes..."

# Pane 0: Xcode/Editor (main development)
tmux select-pane -t 0
tmux send-keys "echo '🍎 Xcode/Editor pane - Main development workspace'" C-m
tmux send-keys "echo '💡 Open Xcode: xcode or open -a Xcode'" C-m
tmux send-keys "echo '📱 Or use Neovim for Swift: nvim Sources/App/main.swift'" C-m

# Pane 1: Terminal/Swift Commands (bottom left)
tmux select-pane -t 1
tmux send-keys "echo '⚡ Swift Terminal - Commands and package management'" C-m
tmux send-keys "echo '🔨 Swift build: swift build'" C-m
tmux send-keys "echo '🧪 Swift test: swift test'" C-m
tmux send-keys "echo '📦 Swift packages: swift package --help'" C-m

# Pane 2: iOS Simulator Controls (top right)
tmux select-pane -t 2
tmux send-keys "echo '📱 iOS Simulator Controls'" C-m
tmux send-keys "echo '🚀 Launch simulator: simulator'" C-m
tmux send-keys "echo '📋 List devices: ios-list'" C-m
tmux send-keys "echo '📸 Screenshot: ios-screenshot ~/Desktop/screenshot.png'" C-m

# Pane 3: Build Logs and Monitoring (bottom right)
tmux select-pane -t 3
tmux send-keys "echo '📊 Build Logs and Monitoring'" C-m
tmux send-keys "echo '🔨 Quick build: ios-quick-build'" C-m
tmux send-keys "echo '🧪 Quick test: ios-quick-test'" C-m
tmux send-keys "echo '📱 App logs: ios-logs'" C-m

# Set pane titles
tmux select-pane -t 0 -T "Xcode/Editor"
tmux select-pane -t 1 -T "Swift Terminal"
tmux select-pane -t 2 -T "Simulator"
tmux select-pane -t 3 -T "Build Logs"

# Enable pane titles display
tmux set-option -g pane-border-status top
tmux set-option -g pane-border-format "#{pane_title}"

# Start in the editor pane
tmux select-pane -t 0

# Auto-setup iOS development environment
echo "🔧 Setting up iOS development environment..."

# Start iOS Simulator in the background if not running
tmux select-pane -t 2
tmux send-keys "ios-setup-development" C-m

# Return to editor pane
tmux select-pane -t 0

echo "✅ iOS development layout ready!"
echo "📋 Layout:"
echo "   • Pane 0 (Xcode/Editor): Main development with Xcode or Neovim"
echo "   • Pane 1 (Swift Terminal): Swift Package Manager and commands"
echo "   • Pane 2 (Simulator): iOS Simulator controls and device management"
echo "   • Pane 3 (Build Logs): Xcode build output and app logs"
echo ""
echo "🚀 Quick start:"
echo "   1. Open Xcode project: xcode or xcodeproj"
echo "   2. Start simulator: simulator (in simulator pane)"
echo "   3. Build project: ios-quick-build (in build logs pane)"
echo "   4. Run tests: ios-quick-test"
echo ""
echo "📱 iOS Simulator shortcuts:"
echo "   • List devices: ios-list"
echo "   • Take screenshot: ios-screenshot ~/Desktop/app-screenshot.png"
echo "   • View logs: ios-logs"