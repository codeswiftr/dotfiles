#!/usr/bin/env bash
set -euo pipefail

# Cleanup generated test artifacts
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

rm -f tests/results/*.log tests/results/*.md 2>/dev/null || true

echo "Cleaned tests/results artifacts."