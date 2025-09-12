#!/usr/bin/env bash
# Infrastructure Test: Neovim Tier System
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[INFO]${NC} Testing Neovim tier CLI and isolation"

TOTAL=0
PASSED=0
FAILED=0

test_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASSED=$((PASSED+1)); TOTAL=$((TOTAL+1)); }
test_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAILED=$((FAILED+1)); TOTAL=$((TOTAL+1)); }

# dot nvim tier set/get
if ./bin/dot nvim tier set 1 >/dev/null 2>&1 && [[ "$(./bin/dot nvim tier get)" == "1" ]]; then
  test_pass "dot nvim tier set/get works (1)"
else
  test_fail "dot nvim tier set/get failed (1)"
fi

# Bench should produce a last line with ms
if ./bin/dot nvim tier bench 1 >/dev/null 2>&1; then
  test_pass "dot nvim tier bench executes"
else
  test_fail "dot nvim tier bench failed"
fi

# Tier 1 should not have ToggleTerm command (Tier 2 feature)
if NVIM_TIER=1 nvim --headless +"silent! ToggleTerm" +qall >/dev/null 2>&1; then
  # If no error, command existed; that's a failure for tier isolation
  test_fail "Tier 1 unexpectedly has ToggleTerm"
else
  test_pass "Tier 1 does not expose ToggleTerm"
fi

# Tier 1 should still be able to run Telescope find_files mapping
if NVIM_TIER=1 nvim --headless +"Telescope help_tags" +qall >/dev/null 2>&1; then
  test_pass "Tier 1 has Telescope available"
else
  test_fail "Tier 1 missing Telescope"
fi

# Summary output required by test runner
printf "Tests Run: %d\n" "$TOTAL"
printf "Tests Passed: %d\n" "$PASSED"
printf "Tests Failed: %d\n" "$FAILED"

exit $(( FAILED == 0 ? 0 : 1 ))
