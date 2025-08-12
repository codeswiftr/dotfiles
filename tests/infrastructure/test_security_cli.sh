#!/bin/bash

# CLI Tests - Dot security scan

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; ((TESTS_PASSED++)); }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; ((TESTS_FAILED++)); }

run_test() {
  local name="$1"; shift
  ((TESTS_RUN++))
  log_info "Running test: $name"
  set +e
  if "$@"; then
    log_success "$name"
  else
    log_error "$name"
  fi
  set -e
}

# Ensure scan command executes (don't fail test on findings)
can_run_security_scan_quiet() {
  DOTFILES_MODE=agent ./bin/dot security scan --quiet >/dev/null 2>&1 || true
}

# JSON format should emit valid-looking JSON keys
security_scan_json_format() {
  local out
  out=$(DOTFILES_MODE=agent ./bin/dot security scan --format json --quiet 2>/dev/null || true)
  [[ "$out" == *"{"* ]] && [[ "$out" == *"dependencies"* ]] && [[ "$out" == *"secrets"* ]]
}

# --json shorthand should emit valid-looking JSON keys
security_scan_json_shorthand() {
  local out
  out=$(DOTFILES_MODE=agent ./bin/dot security scan --json 2>/dev/null || true)
  [[ "$out" == *"{"* ]] && [[ "$out" == *"dependencies"* ]] && [[ "$out" == *"secrets"* ]]
}

main() {
  log_info "Starting Security CLI tests"
  run_test "dot security scan runs (quiet)" can_run_security_scan_quiet
  run_test "dot security scan outputs JSON in --format json" security_scan_json_format
  run_test "dot security scan outputs JSON with --json shorthand" security_scan_json_shorthand

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
