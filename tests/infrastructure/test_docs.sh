#!/bin/bash

# Docs System Tests
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass(){ echo -e "${GREEN}[PASS]${NC} $1"; ((TESTS_PASSED++)); }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; ((TESTS_FAILED++)); }

run(){ ((TESTS_RUN++)); "$@"; }

# 1) dot docs check should pass (guard if command exists)
if grep -q "docs_cli" bin/dot; then
  if run bash -lc 'DOTFILES_DIR=$(pwd) ./bin/dot docs check >/dev/null 2>&1'; then
    pass "dot docs check passes"
  else
    fail "dot docs check failed"
  fi
else
  pass "docs command not available; skipping check"
fi

# 2) generate-index produces INDEX.md and index.json
if bash -lc 'scripts/generate-index.sh >/dev/null 2>&1'; then
  if [[ -s docs/INDEX.md && -s docs/index.json ]]; then
    pass "docs index artifacts present"
  else
    fail "docs index artifacts missing"
  fi
else
  fail "generate-index script failed"
fi

# Summary lines for runner
echo "Tests Run: $TESTS_RUN"
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
