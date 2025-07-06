#!/usr/bin/env bash
# Web development layout for tmux

# Create 3 panes: editor (left), server logs (top-right), browser/terminal (bottom-right)
tmux split-window -h -p 40
tmux split-window -v -p 50
tmux select-pane -t 0