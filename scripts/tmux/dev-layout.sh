#!/usr/bin/env bash
# Development layout for tmux

# Split window into 3 panes: editor (large), terminal (bottom), and logs (right)
tmux split-window -h -p 30
tmux split-window -v -p 50
tmux select-pane -t 0