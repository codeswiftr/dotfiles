#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Monitor → HDMI
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Displays
#
# Documentation:
# @raycast.description Set external display 1 input to HDMI (DDC 17)
# @raycast.author Bogdan

set -euo pipefail
M1DDC="${M1DDC:-$(command -v m1ddc || true)}"
M1DDC="${M1DDC:-/opt/homebrew/bin/m1ddc}"
exec "$M1DDC" display 1 set input 17
