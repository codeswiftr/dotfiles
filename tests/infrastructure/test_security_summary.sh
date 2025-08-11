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

fixture_json() {
  cat > /tmp/security-scan.json <<'JSON'
{"dependencies":"Dependencies: ❌ Vulnerabilities found","code":"Code Analysis: ⚠️  Issues found","secrets":"Secret Scan: ✅ Clean","docker":"skipped","exit_code":1}
JSON
}

summary_generates_markdown() {
  fixture_json
  chmod +x scripts/security/summary.sh
  local out
  out=$(scripts/security/summary.sh /tmp/security-scan.json)
  [[ "$out" == *"## Security Scan Summary"* ]] \
    && [[ "$out" == *"Dependencies:"* ]] \
    && [[ "$out" == *"Code Analysis:"* ]] \
    && [[ "$out" == *"Secrets:"* ]]
}

main() {
  log_info "Starting Security Summary tests"
  run_test "summary.sh renders markdown from JSON" summary_generates_markdown

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
