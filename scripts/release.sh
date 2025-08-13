#!/usr/bin/env bash
# Simple release helper: bumps VERSION and prepares tag/changelog
set -euo pipefail

usage(){ cat <<EOF
Usage: $0 [--dry-run] <major|minor|patch>
EOF
}

DRY=false
if [[ ${1:-} == "--dry-run" ]]; then DRY=true; shift; fi
PART=${1:-}
[[ -n "$PART" ]] || { usage; exit 1; }

VERSION_FILE="VERSION"
[[ -f "$VERSION_FILE" ]] || { echo "VERSION file not found" >&2; exit 1; }
CUR=$(tr -d '\n' < "$VERSION_FILE")
# Expect forms like YYYY.M.N or semver X.Y.Z
IFS='.' read -r A B C <<<"$CUR"

a_is_year=false
if [[ $A =~ ^[0-9]{4}$ ]]; then a_is_year=true; fi

bump(){ local x=$1; echo $((x+1)); }

case "$PART" in
  major)
    if $a_is_year; then NEW="$((A+1)).0.0"; else NEW="$(bump "$A").0.0"; fi ;;
  minor)
    if $a_is_year; then NEW="$A.$((B+1)).0"; else NEW="$A.$((B+1)).0"; fi ;;
  patch)
    NEW="$A.$B.$((C+1))" ;;
  *) usage; exit 1;;
 esac

if $DRY; then
  echo "Would bump $CUR -> $NEW"
  echo "Would create tag v$NEW"
  exit 0
fi

echo "$NEW" > "$VERSION_FILE"
if command -v git >/dev/null 2>&1; then
  git add "$VERSION_FILE"
  git commit -m "release: bump version to $NEW"
  git tag -a "v$NEW" -m "Release v$NEW"
fi

echo "Version bumped to $NEW"
