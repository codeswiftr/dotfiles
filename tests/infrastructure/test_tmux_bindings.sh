#!/usr/bin/env bash
# Simple guardrail test: tmux Tier-1 must not override core defaults
# Ensures Ctrl-a c (new-window) and Ctrl-a d (detach) are not rebound

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
cd "$ROOT_DIR"

# Restrict search to tmux config directory to keep it fast and deterministic
violations=$(rg -n -e "^\s*(bind|bind-key)\s+(c|d)(\s|$)" config/tmux -g "**/*.conf" || true)

TESTS_RUN=1
TESTS_PASSED=0
TESTS_FAILED=0

if [[ -n "$violations" ]]; then
  echo "[FAIL] Forbidden tmux bindings detected:" >&2
  echo "$violations" >&2
  TESTS_FAILED=1
else
  echo "[OK] No forbidden tmux bindings found"
  TESTS_PASSED=1
fi

cat <<EOF
Tests Run: $TESTS_RUN
Tests Passed: $TESTS_PASSED
Tests Failed: $TESTS_FAILED
EOF

exit $TESTS_FAILED
