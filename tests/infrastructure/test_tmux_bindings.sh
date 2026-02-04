#!/usr/bin/env bash
# Simple guardrail test: tmux config must use c/d for their standard purposes
# c should bind to new-window, d should bind to detach-client

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
cd "$ROOT_DIR"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: c should be bound to new-window
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "bind.*c.*new-window" config/tmux/tmux.conf 2>/dev/null; then
  echo "[OK] 'c' is bound to new-window (standard)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "[FAIL] 'c' should be bound to new-window" >&2
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: d should be bound to detach
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "bind.*d.*detach" config/tmux/tmux.conf 2>/dev/null; then
  echo "[OK] 'd' is bound to detach-client (standard)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "[FAIL] 'd' should be bound to detach-client" >&2
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

cat <<EOF
Tests Run: $TESTS_RUN
Tests Passed: $TESTS_PASSED
Tests Failed: $TESTS_FAILED
EOF

[[ $TESTS_FAILED -eq 0 ]]
