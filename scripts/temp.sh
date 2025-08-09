#!/usr/bin/env bash
# Cross-platform CPU temperature (best-effort)

set -euo pipefail

case "${OSTYPE:-}" in
  darwin*)
    if command -v istats >/dev/null 2>&1; then
      istats cpu temp --value-only
    else
      echo "istats not installed" >&2
      exit 1
    fi
    ;;
  linux*)
    if command -v vcgencmd >/dev/null 2>&1; then
      vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*'
    elif command -v sensors >/dev/null 2>&1; then
      sensors 2>/dev/null | rg -m1 -o '[+\-]?[0-9]+\.[0-9]+(?=°C)' || true
    else
      echo "no temperature tool found" >&2
      exit 1
    fi
    ;;
  *)
    echo "unsupported platform" >&2
    exit 1
    ;;
esac
