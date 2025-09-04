#!/usr/bin/env bash
# Unit Test: create_incremental_backup (Epic 4.1)
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
TOTAL=0; PASSED=0; FAILED=0
pass(){ echo -e "${GREEN}[PASS]${NC} $1"; PASSED=$((PASSED+1)); TOTAL=$((TOTAL+1)); }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; FAILED=$((FAILED+1)); TOTAL=$((TOTAL+1)); }

REPO_DIR="$(cd "$(dirname "$0")"/../../.. && pwd)"
SANDBOX_HOME="$(mktemp -d)"
export HOME="$SANDBOX_HOME"
export DOTFILES_DIR="$REPO_DIR"
export BACKUP_COMPRESSION="none"

source "$REPO_DIR/lib/backup-restore.sh"
init_backup_system

# Seed content
mkdir -p "$HOME/.config"
echo "v1" > "$HOME/.config/inc_marker.txt"

# Base full backup
BASE_NAME="unit-base-$(date +%Y%m%d%H%M%S)"
backup_create "full" "$BASE_NAME" "Base full"

# Change a file
sleep 1
echo "v2" > "$HOME/.config/inc_marker.txt"

# Incremental backup
INC_NAME="unit-inc-$(date +%Y%m%d%H%M%S)"
# Pass include path explicitly to ensure deterministic scope
backup_create "incremental" "$INC_NAME" "Inc" "$HOME/.config"
INC_PATH="$BACKUP_DIR/$INC_NAME"

if [[ -d "$INC_PATH" ]]; then pass "Incremental dir created"; else fail "Incremental dir missing"; fi

# The changed file should exist under data/home/.config/inc_marker.txt
if [[ -f "$INC_PATH/data/home/.config/inc_marker.txt" ]]; then
  pass "Changed file captured in incremental"
else
  fail "Changed file missing in incremental"
fi

printf "Tests Run: %d\n" "$TOTAL"
printf "Tests Passed: %d\n" "$PASSED"
printf "Tests Failed: %d\n" "$FAILED"

rm -rf "$SANDBOX_HOME"
exit $(( FAILED == 0 ? 0 : 1 ))
