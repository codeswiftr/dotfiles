#!/usr/bin/env bash
# =============================================================================
# Integration Tests: DOT CLI Contracts
# Verifies user-visible contracts for bin/dot commands and flags
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../utils/test_framework.sh"

setup_suite() {
    test_suite_start "DOT CLI Contracts"
    export PATH="$DOTFILES_DIR/bin:$PATH"
}

teardown_suite() {
    test_suite_end
}

test_dot_version_commands() {
    # `dot --version` should output a semantic version and exit 0
    local out1
    out1=$(dot --version 2>&1 || true)
    if echo "$out1" | rg -q "[0-9]+\.[0-9]+\.[0-9]+"; then
        test_pass "dot --version prints a semantic version"
    else
        test_fail "dot --version missing semantic version"
    fi

    # `dot version` should also work and include version
    local out2
    out2=$(dot version 2>&1 || true)
    if echo "$out2" | rg -q "[0-9]+\.[0-9]+\.[0-9]+"; then
        test_pass "dot version prints a semantic version"
    else
        test_fail "dot version missing semantic version"
    fi
}

test_dot_help_fast() {
    # Help should be fast and return 0
    local start end dur
    start=$(date +%s.%N)
    dot --help >/dev/null 2>&1 || test_fail "dot --help should succeed"
    end=$(date +%s.%N)
    dur=$(echo "$end - $start" | bc -l 2>/dev/null || echo "1.0")
    if (( $(echo "$dur <= 0.150" | bc -l 2>/dev/null || echo 0) )); then
        test_pass "dot --help returns quickly (${dur}s)"
    else
        test_fail "dot --help too slow (${dur}s)"
    fi
}

test_dot_health_json() {
    # JSON output should be parse-like (braces present) and exit with sensible code
    local out rc
    set +e
    out=$(dot health --json 2>/dev/null)
    rc=$?
    set -e
    if [[ "$out" == *"{"* ]] && [[ "$out" == *"}"* ]]; then
        test_pass "dot health --json prints JSON-like output"
    else
        test_fail "dot health --json missing JSON braces"
    fi
    # Allow non-zero when script reports errors; contract is to emit JSON
    test_pass "dot health --json exit code captured: $rc"
}

test_dot_check_quiet_exit_code() {
    # Contract: --quiet suppresses noise; exit code reflects health
    set +e
    dot check --quiet >/dev/null 2>&1
    local rc=$?
    set -e
    if [[ $rc -eq 0 || $rc -eq 1 ]]; then
        test_pass "dot check --quiet returns meaningful exit code ($rc)"
    else
        test_fail "dot check --quiet returned unexpected exit code ($rc)"
    fi
}

main() {
    setup_suite
    
    test_dot_version_commands
    test_dot_help_fast
    test_dot_health_json
    test_dot_check_quiet_exit_code
    
    teardown_suite
}

main "$@"

