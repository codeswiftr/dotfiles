#!/usr/bin/env bash
# Render a concise Markdown summary from security-scan.json
# Usage: summary.sh path/to/security-scan.json
set -euo pipefail

file="${1:-}"
if [[ -z "$file" || ! -f "$file" ]]; then
  echo "Usage: $0 path/to/security-scan.json" >&2
  exit 2
fi

if command -v jq >/dev/null 2>&1; then
  deps=$(jq -r '.dependencies // "unknown"' "$file" 2>/dev/null || echo "unknown")
  code=$(jq -r '.code // "unknown"' "$file" 2>/dev/null || echo "unknown")
  secrets=$(jq -r '.secrets // "unknown"' "$file" 2>/dev/null || echo "unknown")
  docker=$(jq -r '.docker // "skipped"' "$file" 2>/dev/null || echo "skipped")
  exit_code=$(jq -r '.exit_code // 1' "$file" 2>/dev/null || echo 1)
else
  content=$(tr -d '\n' < "$file")
  extract_field() {
    local key="$1"
    echo "$content" | sed -n "s/.*\"${key}\":\"\([^\"]*\)\".*/\1/p"
  }
  extract_num_field() {
    local key="$1"
    echo "$content" | sed -n "s/.*\"${key}\":\([0-9][0-9]*\).*/\1/p"
  }
  deps=$(extract_field "dependencies")
  code=$(extract_field "code")
  secrets=$(extract_field "secrets")
  docker=$(extract_field "docker")
  exit_code=$(extract_num_field "exit_code")
fi

[[ -z "$deps" ]] && deps="unknown"
[[ -z "$code" ]] && code="unknown"
[[ -z "$secrets" ]] && secrets="unknown"
[[ -z "$docker" ]] && docker="skipped"
[[ -z "$exit_code" ]] && exit_code=1

status_emoji() {
  case "$1" in
    *✅*|*Secure*|*Clean*) echo "✅";;
    *⚠️*|*Issues*|*detected*) echo "⚠️";;
    *❌*|*Vulnerabilities*|*failed*) echo "❌";;
    *skipped*|*unknown*) echo "➖";;
    *) echo "⚠️";;
  esac
}

echo "## Security Scan Summary"

echo "- Dependencies: $(status_emoji "$deps") $deps"
echo "- Code Analysis: $(status_emoji "$code") $code"
echo "- Secrets: $(status_emoji "$secrets") $secrets"
echo "- Docker: $(status_emoji "$docker") $docker"

echo "\nExit code: $exit_code"
