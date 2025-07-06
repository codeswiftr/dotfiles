#!/usr/bin/env bash
# AI development layout for tmux

# Create 4 panes: editor (top-left), AI (top-right), terminal (bottom-left), git (bottom-right)
tmux split-window -h -p 50
tmux split-window -v -p 50
tmux select-pane -t 0
tmux split-window -v -p 50
tmux select-pane -t 0