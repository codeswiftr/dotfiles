#!/bin/bash
# Release script tests (dry run)
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
TESTS_RUN=0; TESTS_PASSED=0; TESTS_FAILED=0
pass(){ echo -e "${GREEN}[PASS]${NC} $1"; ((TESTS_PASSED++)); }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; ((TESTS_FAILED++)); }
run(){ ((TESTS_RUN++)); "$@"; }

CUR=$(tr -d '\n' < VERSION)
# dry-run minor bump should print both current and next
OUT=$(bash scripts/release.sh --dry-run minor || true)
if [[ "$OUT" == *"Would bump"* && "$OUT" == *"->"* ]]; then pass "release dry-run prints bump info"; else fail "release dry-run output unexpected"; fi

# Ensure VERSION file unchanged
AFTER=$(tr -d '\n' < VERSION)
if [[ "$CUR" == "$AFTER" ]]; then pass "release dry-run leaves VERSION unchanged"; else fail "VERSION changed on dry-run"; fi

# Summary
echo "Tests Run: $TESTS_RUN"; echo "Tests Passed: $TESTS_PASSED"; echo "Tests Failed: $TESTS_FAILED"
[[ $TESTS_FAILED -eq 0 ]]
