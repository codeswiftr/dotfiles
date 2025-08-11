#!/usr/bin/env bash
# Exit non-zero when gating is enabled and scan exit_code != 0
# Usage: gate.sh path/to/security-scan.json
set -euo pipefail

file="${1:-}"
if [[ -z "$file" || ! -f "$file" ]]; then
  echo "Usage: $0 path/to/security-scan.json" >&2
  exit 2
fi

if command -v jq >/dev/null 2>&1; then
  exit_code=$(jq -r '.exit_code // 1' "$file" 2>/dev/null || echo 1)
else
  content=$(tr -d '\n' < "$file")
  exit_code=$(echo "$content" | sed -n 's/.*\"exit_code\":\([0-9][0-9]*\).*/\1/p')
  [[ -z "$exit_code" ]] && exit_code=1
fi

fail_on=${SECURITY_FAIL_ON:-false}
if [[ "$fail_on" == "true" && "$exit_code" -ne 0 ]]; then
  echo "Security gate: failing build (exit_code=$exit_code)" >&2
  exit 1
fi

echo "Security gate: passing (exit_code=$exit_code, SECURITY_FAIL_ON=${fail_on})"
