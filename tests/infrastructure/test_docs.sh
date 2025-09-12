#!/bin/bash

# Docs System Tests  
set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() { 
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail() { 
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

# Test 1: dot docs check should pass (if command exists)
if grep -q "docs_cli" bin/dot; then
    if DOTFILES_DIR=$(pwd) ./bin/dot docs check >/dev/null 2>&1; then
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