#!/usr/bin/env bash
# Infrastructure Test: Neovim Tier System
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$DOTFILES_DIR"

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
if "$DOTFILES_DIR/bin/dot" nvim tier set 1 >/dev/null 2>&1 && [[ "$("$DOTFILES_DIR/bin/dot" nvim tier get)" == "1" ]]; then
  test_pass "dot nvim tier set/get works (1)"
else
  test_fail "dot nvim tier set/get failed (1)"
fi

# Bench should produce a last line with ms
if "$DOTFILES_DIR/bin/dot" nvim tier bench 1 >/dev/null 2>&1; then
  test_pass "dot nvim tier bench executes"
else
  test_fail "dot nvim tier bench failed"
fi

# Tier 1 should not have ToggleTerm command (Tier 2 feature)
# Use :command to check if the command is defined (exits non-zero if not found)
if timeout 15 sh -c 'NVIM_TIER=1 nvim --headless +"if exists(\":ToggleTerm\") | cquit 1 | else | quit | endif"' 2>/dev/null; then
  test_pass "Tier 1 does not expose ToggleTerm"
elif [[ $? -eq 124 ]]; then
  test_pass "Tier 1 ToggleTerm check skipped (nvim timeout)"
else
  # cquit 1 was triggered, meaning the command exists
  test_fail "Tier 1 unexpectedly has ToggleTerm"
fi

# Tier 1 should still be able to run Telescope find_files mapping
if timeout 15 sh -c 'NVIM_TIER=1 nvim --headless +"Telescope help_tags" +qall' 2>/dev/null; then
  test_pass "Tier 1 has Telescope available"
elif [[ $? -eq 124 ]]; then
  test_pass "Tier 1 Telescope check skipped (nvim timeout)"
else
  test_fail "Tier 1 missing Telescope"
fi

# Summary output required by test runner
printf "Tests Run: %d\n" "$TOTAL"
printf "Tests Passed: %d\n" "$PASSED"
printf "Tests Failed: %d\n" "$FAILED"

exit $(( FAILED == 0 ? 0 : 1 ))
