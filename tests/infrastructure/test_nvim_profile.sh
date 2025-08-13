#!/usr/bin/env bash
# Infrastructure Test: Nvim profile JSON
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TOTAL=0; PASSED=0; FAILED=0
pass(){ echo -e "${GREEN}[PASS]${NC} $1"; PASSED=$((PASSED+1)); TOTAL=$((TOTAL+1)); }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; FAILED=$((FAILED+1)); TOTAL=$((TOTAL+1)); }

# Expect JSON keys: tier, runs, average_ms
OUT=$(./bin/dot nvim profile 1 1 --json 2>/dev/null || true)
if echo "$OUT" | grep -q '"tier":1' && echo "$OUT" | grep -q '"average_ms"'; then
  pass "dot nvim profile --json outputs expected keys"
else
  fail "dot nvim profile --json missing expected keys"
fi

printf "Tests Run: %d\n" "$TOTAL"
printf "Tests Passed: %d\n" "$PASSED"
printf "Tests Failed: %d\n" "$FAILED"
exit $(( FAILED == 0 ? 0 : 1 ))
