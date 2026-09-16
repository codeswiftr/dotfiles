#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Monitor → HDMI
# @raycast.mode silent
# @raycast.icon 🖥️
# @raycast.packageName Displays
# @raycast.description External display → HDMI (DDC 17)

exec "$(dirname "$0")/switch-display.sh" hdmi
