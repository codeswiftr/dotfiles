#!/bin/bash
# Validate CLI works from nested directories and resolves DOTFILES_DIR automatically
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$DOTFILES_DIR"

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
TESTS_RUN=0; TESTS_PASSED=0; TESTS_FAILED=0
pass(){ echo -e "${GREEN}[PASS]${NC} $1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

# 1) run from repo root
TESTS_RUN=$((TESTS_RUN + 1))
if "$DOTFILES_DIR/bin/dot" --help >/dev/null 2>&1; then pass "dot --help runs from root"; else fail "dot --help failed from root"; fi

# 2) run from nested dir
mkdir -p scripts/tmp-nest
pushd scripts/tmp-nest >/dev/null
TESTS_RUN=$((TESTS_RUN + 1))
if "$DOTFILES_DIR/bin/dot" --help >/dev/null 2>&1; then pass "dot --help runs from nested dir"; else fail "dot --help failed in nested dir"; fi
popd >/dev/null

# Summary
echo "Tests Run: $TESTS_RUN"; echo "Tests Passed: $TESTS_PASSED"; echo "Tests Failed: $TESTS_FAILED"
[[ $TESTS_FAILED -eq 0 ]]
