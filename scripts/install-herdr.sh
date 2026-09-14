#!/usr/bin/env bash
# Install Herdr (agent multiplexer). Prefer brew; else herdr.dev installer.
set -euo pipefail

if command -v herdr >/dev/null 2>&1; then
  echo "herdr already available: $(command -v herdr)"
  exit 0
fi

if [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
  brew install herdr
elif command -v herdr >/dev/null 2>&1; then
  :
else
  curl -fsSL https://herdr.dev/install.sh | sh
fi

command -v herdr >/dev/null 2>&1 || {
  echo "herdr install failed" >&2
  exit 1
}
echo "herdr ready: $(herdr --version 2>/dev/null | head -1 || command -v herdr)"
