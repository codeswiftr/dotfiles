#!/bin/bash

# Docs System Tests
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$DOTFILES_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Test 1: dot docs check should pass (if command exists)
if grep -q "docs_cli" "$DOTFILES_DIR/bin/dot"; then
    if DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/bin/dot" docs check >/dev/null 2>&1; then
        pass "dot docs check passes"
    else
        fail "dot docs check failed"
    fi
else
    pass "docs command not available; skipping check"
fi

# Test 2: Check if index files exist or can be generated
if [[ -s docs/INDEX.md && -s docs/index.json ]]; then
    pass "docs index artifacts present"
elif ./scripts/generate-index.sh >/dev/null 2>&1; then
    if [[ -s docs/INDEX.md && -s docs/index.json ]]; then
        pass "docs index artifacts generated successfully"
    else
        fail "docs index artifacts missing after generation"
    fi
else
    fail "generate-index script failed"
fi

# Summary
echo "Tests Run: $TESTS_RUN"
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"

exit $TESTS_FAILED