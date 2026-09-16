#!/usr/bin/env bash
# Switch external display input via m1ddc (DDC/CI).
# Usage: switch-display.sh usb-c|hdmi|toggle
# Env: M1DDC_DISPLAY=1 (default), M1DDC=/path/to/m1ddc
set -euo pipefail

M1DDC="${M1DDC:-$(command -v m1ddc 2>/dev/null || true)}"
M1DDC="${M1DDC:-/opt/homebrew/bin/m1ddc}"
DISPLAY_NUM="${M1DDC_DISPLAY:-1}"

if [[ ! -x "$M1DDC" ]]; then
  echo "m1ddc not found (brew install m1ddc)" >&2
  exit 1
fi

case "${1:-}" in
  usb-c|usbc|27) code=27 ;;
  hdmi|17)       code=17 ;;
  toggle)
    cur="$("$M1DDC" display "$DISPLAY_NUM" get input 2>/dev/null || true)"
    if [[ "$cur" == "27" ]]; then code=17; else code=27; fi
    ;;
  *)
    echo "Usage: $(basename "$0") usb-c|hdmi|toggle" >&2
    exit 2
    ;;
esac

exec "$M1DDC" display "$DISPLAY_NUM" set input "$code"
