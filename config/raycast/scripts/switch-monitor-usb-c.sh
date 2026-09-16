#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Monitor → USB-C
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Displays
#
# Documentation:
# @raycast.description Set external display 1 input to USB-C (DDC 27)
# @raycast.author Bogdan

set -euo pipefail
M1DDC="${M1DDC:-$(command -v m1ddc || true)}"
M1DDC="${M1DDC:-/opt/homebrew/bin/m1ddc}"
exec "$M1DDC" display 1 set input 27
