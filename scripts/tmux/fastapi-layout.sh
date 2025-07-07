#!/usr/bin/env bash
# ============================================================================
# FastAPI Development Layout for Tmux
# Optimized 4-pane layout for API development workflow
# ============================================================================

set -euo pipefail

# Get the current session name
session_name=$(tmux display-message -p '#S')
window_name="FastAPI-Dev"

# Create new window or use current one
if tmux list-windows -F "#{window_name}" | grep -q "^${window_name}$"; then
    echo "🔄 Reusing existing FastAPI development window"
    tmux select-window -t "$window_name"
    tmux kill-pane -a  # Kill all panes except current
else
    echo "🚀 Creating new FastAPI development window"
    tmux new-window -n "$window_name"
fi

# Layout: 
# +------------------+----------+
# |                  |   API    |
# |    Editor/IDE    |  Docs    |
# |      (70%)       |  (30%)   |
# |                  |----------|
# |                  |  Tests   |
# +------------------+----------+
# |     Terminal/Logs (30%)     |
# +------------------------------+

# Split window into main editor (left) and side panels (right)
tmux split-window -h -p 30

# Split the right pane vertically for API docs (top) and tests (bottom)
tmux select-pane -t 1
tmux split-window -v -p 50

# Split the left pane horizontally for editor (top) and terminal (bottom)
tmux select-pane -t 0
tmux split-window -v -p 25

# Setup each pane
echo "🔧 Setting up development panes..."

# Pane 0: Editor/IDE (main development)
tmux select-pane -t 0
tmux send-keys "echo '📝 Editor pane - Start your editor here'" C-m
tmux send-keys "echo '💡 Suggested: nvim app/main.py'" C-m

# Pane 1: Terminal/Logs (bottom left)
tmux select-pane -t 1
tmux send-keys "echo '⚡ Terminal pane - For commands and logs'" C-m
tmux send-keys "echo '🚀 To start FastAPI: fastapi dev app/main.py'" C-m

# Pane 2: API Documentation (top right)
tmux select-pane -t 2
tmux send-keys "echo '📚 API Documentation pane'" C-m
tmux send-keys "echo '🌐 FastAPI docs will open here once server starts'" C-m
tmux send-keys "echo '💡 Run: browser-open http://localhost:8000/docs'" C-m

# Pane 3: Tests and Monitoring (bottom right)
tmux select-pane -t 3
tmux send-keys "echo '🧪 Testing pane'" C-m
tmux send-keys "echo '🔍 Run tests with: uv run pytest'" C-m
tmux send-keys "echo '📊 Watch tests: uv run pytest-watch'" C-m

# Set pane titles
tmux select-pane -t 0 -T "Editor"
tmux select-pane -t 1 -T "Terminal"
tmux select-pane -t 2 -T "API Docs"
tmux select-pane -t 3 -T "Tests"

# Enable pane titles display
tmux set-option -g pane-border-status top
tmux set-option -g pane-border-format "#{pane_title}"

# Start in the editor pane
tmux select-pane -t 0

echo "✅ FastAPI development layout ready!"
echo "📋 Layout:"
echo "   • Pane 0 (Editor): Main development workspace"
echo "   • Pane 1 (Terminal): Commands, logs, server output"
echo "   • Pane 2 (API Docs): Browser for API documentation"
echo "   • Pane 3 (Tests): Test runner and monitoring"
echo ""
echo "🚀 Quick start:"
echo "   1. Switch to terminal pane: Ctrl-a → select pane 1"
echo "   2. Start FastAPI: fastapi dev app/main.py"
echo "   3. Switch to docs pane: Ctrl-a → select pane 2"
echo "   4. Open API docs: browser-open http://localhost:8000/docs"