#!/usr/bin/env bash
# Unit Test: create_full_backup (Epic 4.1)
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TOTAL=0; PASSED=0; FAILED=0
pass(){ echo -e "${GREEN}[PASS]${NC} $1"; PASSED=$((PASSED+1)); TOTAL=$((TOTAL+1)); }
fail(){ echo -e "${RED}[FAIL]${NC} $1"; FAILED=$((FAILED+1)); TOTAL=$((TOTAL+1)); }

# Isolate HOME/DOTFILES_DIR to a temp sandbox
REPO_DIR="$(cd "$(dirname "$0")"/../.. && pwd)"
SANDBOX_HOME="$(mktemp -d)"
export HOME="$SANDBOX_HOME"
export DOTFILES_DIR="$REPO_DIR"

# Avoid compression to simplify assertions
export BACKUP_COMPRESSION="none"

# Source backup library
source "$REPO_DIR/lib/backup-restore.sh"

# Initialize
init_backup_system

# Create a small file to ensure we back up at least one real file
mkdir -p "$HOME/.config"
echo "hello" > "$HOME/.config/unit_test_marker.txt"

# Create a deterministic backup name
BACKUP_NAME="unit-full-$(date +%Y%m%d%H%M%S)"

if backup_create "full" "$BACKUP_NAME" "Unit test full backup"; then
  :
else
  fail "backup_create returned non-zero"
fi

BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Assertions
if [[ -d "$BACKUP_PATH" ]]; then
  pass "Backup directory created: $BACKUP_PATH"
else
  fail "Backup directory not found: $BACKUP_PATH"
fi

if [[ -f "$BACKUP_PATH/MANIFEST.json" ]]; then
  pass "Manifest created"
else
  fail "Manifest missing"
fi

if [[ -f "$BACKUP_PATH/checksums.sha256" ]]; then
  pass "Checksum file created"
else
  fail "Checksum file missing"
fi

# Summary
printf "Tests Run: %d\n" "$TOTAL"
printf "Tests Passed: %d\n" "$PASSED"
printf "Tests Failed: %d\n" "$FAILED"

# Cleanup sandbox
rm -rf "$SANDBOX_HOME"

exit $(( FAILED == 0 ? 0 : 1 ))
