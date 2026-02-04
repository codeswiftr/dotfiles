#!/bin/bash

# CLI Tests - Dot health command

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

run_test() {
  local name="$1"; shift
  TESTS_RUN=$((TESTS_RUN + 1))
  log_info "Running test: $name"
  if "$@"; then
    log_success "$name"
  else
    log_error "$name"
  fi
}

test_dot_health_human() {
  "$DOTFILES_DIR/bin/dot" health >/dev/null 2>&1
}

test_dot_health_json() {
  local out
  out=$("$DOTFILES_DIR/bin/dot" health --json 2>/dev/null)
  [[ "$out" == *"{"* ]] && [[ "$out" == *"}"* ]]
}

main() {
  log_info "Starting CLI tests"
  run_test "dot health runs (human)" test_dot_health_human
  run_test "dot health outputs JSON with --json" test_dot_health_json

  echo
  echo "Tests Run: $TESTS_RUN"
  echo "Tests Passed: $TESTS_PASSED"
  echo "Tests Failed: $TESTS_FAILED"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    exit 0
  else
    exit 1
  fi
}

main "$@"
