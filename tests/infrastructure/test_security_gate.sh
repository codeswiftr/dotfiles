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

make_fixture() {
  local code="$1"
  cat > /tmp/security-scan.json <<JSON
{"dependencies":"Dependencies: ❌ Vulnerabilities found","code":"Code Analysis: ⚠️  Issues found","secrets":"Secret Scan: ✅ Clean","docker":"skipped","exit_code":${code}}
JSON
}

fails_when_env_true_and_exit_code_nonzero() {
  make_fixture 1
  chmod +x scripts/security/gate.sh || true
  if SECURITY_FAIL_ON=true scripts/security/gate.sh /tmp/security-scan.json >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

succeeds_when_env_false_even_if_nonzero() {
  make_fixture 1
  chmod +x scripts/security/gate.sh || true
  if SECURITY_FAIL_ON=false scripts/security/gate.sh /tmp/security-scan.json >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

succeeds_when_exit_code_zero_even_if_env_true() {
  make_fixture 0
  chmod +x scripts/security/gate.sh || true
  if SECURITY_FAIL_ON=true scripts/security/gate.sh /tmp/security-scan.json >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

main() {
  log_info "Starting Security Gate tests"
  run_test "fails when SECURITY_FAIL_ON=true and exit_code=1" fails_when_env_true_and_exit_code_nonzero
  run_test "succeeds when SECURITY_FAIL_ON=false and exit_code=1" succeeds_when_env_false_even_if_nonzero
  run_test "succeeds when exit_code=0 and SECURITY_FAIL_ON=true" succeeds_when_exit_code_zero_even_if_env_true

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
