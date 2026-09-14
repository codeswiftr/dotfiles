#!/usr/bin/env bash
# Reload Herdr config + mise shims. Invoked by: just reload
# For a full interactive shell resync, use the zsh function: reload / dot-reload
set -euo pipefail

if command -v herdr >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1 || true
  echo "✅ Herdr config reloaded"
else
  echo "⚠️  herdr not on PATH"
fi

if command -v mise >/dev/null 2>&1; then
  mise reshim >/dev/null 2>&1 || true
  echo "✅ mise shims refreshed"
fi
