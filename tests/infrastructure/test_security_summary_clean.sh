#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
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

fixture_json_clean() {
  cat > /tmp/security-scan-clean.json <<'JSON'
{"dependencies":"Dependencies: ✅ Clean","code":"Code Analysis: ✅ Clean","secrets":"Secret Scan: ✅ Clean","docker":"skipped","exit_code":0}
JSON
}

summary_shows_all_clean_and_traceability() {
  fixture_json_clean
  chmod +x scripts/security/summary.sh
  local out
  GITHUB_SHA=deadbeef scripts/security/summary.sh /tmp/security-scan-clean.json > /tmp/summary.md
  out=$(cat /tmp/summary.md)
  [[ "$out" == *"## Security Scan Summary"* ]] \
    && [[ "$out" == *"Commit: deadbeef"* ]] \
    && [[ "$out" == *"Timestamp (UTC):"* ]] \
    && [[ "$out" == *"All clean ✅"* ]]
}

main() {
  log_info "Starting Security Summary Clean tests"
  run_test "summary.sh emits all clean one-liner + traceability" summary_shows_all_clean_and_traceability

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
