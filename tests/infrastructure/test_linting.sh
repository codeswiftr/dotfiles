#!/bin/bash
# Dotfiles Linting Test
# Runs shellcheck on all shell scripts and yamllint on all YAML files

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  TOTAL_FAILED=$((TOTAL_FAILED+1))
}

pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
  TOTAL_PASSED=$((TOTAL_PASSED+1))
}

# Check dependencies first
if ! command -v shellcheck >/dev/null 2>&1; then
  echo -e "${YELLOW}[SKIP]${NC} shellcheck not available - skipping shell script linting"
  SHELL_FILES=""
else
  SHELL_FILES=$(find bin/ lib/ scripts/ tests/ -type f -name "*.sh" 2>/dev/null || echo "")
fi

if ! command -v yamllint >/dev/null 2>&1; then
  echo -e "${YELLOW}[SKIP]${NC} yamllint not available - skipping YAML linting"
  YAML_FILES=""
else
  YAML_FILES=$(find config/ templates/ docs/ -type f \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null || echo "")
fi

# Shellcheck
for file in $SHELL_FILES; do
  if [[ -f "$file" ]]; then
    TOTAL_TESTS=$((TOTAL_TESTS+1))
    if shellcheck "$file" >/dev/null 2>&1; then
      pass "shellcheck: $file"
    else
      fail "shellcheck: $file"
    fi
  fi
done

# Yamllint
for file in $YAML_FILES; do
  if [[ -f "$file" ]]; then
    TOTAL_TESTS=$((TOTAL_TESTS+1))
    if yamllint "$file" >/dev/null 2>&1; then
      pass "yamllint: $file"
    else
      fail "yamllint: $file"
    fi
  fi
done

# Summary
echo "Tests Run: $TOTAL_TESTS"
echo "Tests Passed: $TOTAL_PASSED"
echo "Tests Failed: $TOTAL_FAILED"

if [[ $TOTAL_FAILED -eq 0 ]]; then
  exit 0
else
  exit 1
fi
