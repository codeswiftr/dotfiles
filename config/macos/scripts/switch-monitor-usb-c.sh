#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Monitor → USB-C
# @raycast.mode silent
# @raycast.icon 🖥️
# @raycast.packageName Displays
# @raycast.description External display → USB-C (DDC 27)

exec "$(dirname "$0")/switch-display.sh" usb-c
