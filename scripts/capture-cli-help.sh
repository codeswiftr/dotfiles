#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"
OUT_DIR="src/--help"
mkdir -p "$OUT_DIR"

capture() {
  local name="$1"; shift
  local cmd=("$@")
  { "${cmd[@]}" --help || true; } > "$OUT_DIR/$name.txt" 2>&1 || true
}

if [[ -x "bin/dot" ]]; then
  capture dot--help bin/dot
  capture dot-project--help bin/dot project
  capture dot-ai--help bin/dot ai
  capture dot-test--help bin/dot test
  capture dot-security--help bin/dot security
  capture dot-perf--help bin/dot perf
  capture dot-nvim--help bin/dot nvim
else
  echo "bin/dot not found or not executable; skipping" >&2
fi

echo "Captured help into $OUT_DIR"