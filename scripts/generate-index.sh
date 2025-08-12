#!/usr/bin/env bash
set -euo pipefail
# Generate docs/INDEX.md and docs/index.json excluding generated artifacts
# Excludes: .git/**, tests/results/**, .pytest_cache/**

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

DATE_STR="$(date +%Y-%m-%d)"

exclude_predicate() {
  local path="$1"
  case "$path" in
    ./.git/*|.git|./tests/results/*|./tests/results|./.pytest_cache/*|./.pytest_cache)
      return 0;;
    *)
      return 1;;
  esac
}

# Collect top-level files
ROOT_FILES=()
while IFS= read -r f; do ROOT_FILES+=("$f"); done < <(find . -maxdepth 1 -type f \( ! -name ".DS_Store" \) -print | sed 's|^\./||' | sort)

# Collect top-level directories (exclude .git)
TOP_DIRS=()
while IFS= read -r d; do TOP_DIRS+=("$d"); done < <(find . -maxdepth 1 -type d -print | sed 's|^\./||' | sort | grep -v '^$' | grep -v '^\.git$')

# Build per-directory file lists (serialized mapping file)
DIR_MAP_FILE=$(mktemp)
> "$DIR_MAP_FILE"
for dir in "${TOP_DIRS[@]}"; do
  [[ "$dir" == "." ]] && continue
  # Skip excluded dirs completely
  if exclude_predicate "./$dir"; then
    continue
  fi
  files=$(find "$dir" -type f -print | while read -r f; do
    # Exclusions
    if exclude_predicate "./$f"; then
      continue
    fi
    printf '%s
' "$f"
  done | sort)
  printf '%s\0%s\0' "$dir" "$files" >> "$DIR_MAP_FILE"
done

# Write docs/index.json (rootFiles + dirs mapping)
JSON_PATH="docs/index.json"
{
  printf '{\n'
  printf '  "generated": "%s",\n' "$DATE_STR"
  printf '  "rootFiles": [\n'
  first=1
  for f in "${ROOT_FILES[@]}"; do
    [[ $first -eq 0 ]] && printf ',\n'
    printf '    "%s"' "$f"
    first=0
  done
  printf '\n  ],\n'
  printf '  "dirs": {\n'
  dfirst=1
  for dir in "${TOP_DIRS[@]}"; do
    [[ "$dir" == "." || "$dir" == ".git" ]] && continue
    if exclude_predicate "./$dir"; then
      continue
    fi
    files_str=$(awk -v RS='\0' -v ORS='' -v D="$dir" '{ if ($0==D) { getline; print; } }' "$DIR_MAP_FILE")
    [[ $dfirst -eq 0 ]] && printf ',\n'
    printf '    "%s": [' "$dir"
    if [[ -n "$files_str" ]]; then
      # Print as JSON strings
      printf '\n'
      ffirst=1
      while IFS= read -r rel; do
        [[ -z "$rel" ]] && continue
        [[ $ffirst -eq 0 ]] && printf ',\n'
        # Trim dir/ prefix
        rel_trimmed="${rel#${dir}/}"
        printf '      "%s"' "$rel_trimmed"
        ffirst=0
      done <<< "$files_str"
      printf '\n    ]'
    else
      printf ']'
    fi
    dfirst=0
  done
  printf '\n  },\n'
  printf '  "notes": [\n'
  printf '    "Excluded .git directory",\n'
  printf '    "Excluded generated artifacts: tests/results and .pytest_cache"\n'
  printf '  ]\n'
  printf '}\n'
} > "$JSON_PATH"

# Write docs/INDEX.md (simplified, hierarchical)
MD_PATH="docs/INDEX.md"
{
  printf '## Repository Index (auto-generated)\n\n'
  printf 'Generated: %s\n\n' "$DATE_STR"
  printf 'This index lists files for quick navigation. Excludes `.git/`, `tests/results/`, and `.pytest_cache/`.\n\n'
  printf '### Top-level files\n'
  for f in "${ROOT_FILES[@]}"; do
    printf -- '- `%s`\n' "$f"
  done
  printf '\n### Directories\n\n'
  for dir in "${TOP_DIRS[@]}"; do
    [[ "$dir" == "." || "$dir" == ".git" ]] && continue
    if exclude_predicate "./$dir"; then
      continue
    fi
    files_str=$(awk -v RS='\0' -v ORS='' -v D="$dir" '{ if ($0==D) { getline; print; } }' "$DIR_MAP_FILE")
    count=0
    [[ -n "$files_str" ]] && count=$(printf '%s\n' "$files_str" | sed '/^$/d' | wc -l | tr -d ' ')
    printf '#### `%s` (%d)\n' "$dir" "$count"
    if [[ -n "$files_str" ]]; then
      while IFS= read -r rel; do
        [[ -z "$rel" ]] && continue
        printf -- '- `%s`\n' "$rel"
      done <<< "$files_str"
    else
      printf -- '- (empty)\n'
    fi
    printf '\n'
  done
  printf '\nNotes\n- Excluded: `.git/`\n- Excluded from index: `tests/results/**`, `.pytest_cache/**` (generated)\n'
} > "$MD_PATH"

rm -f "$DIR_MAP_FILE"
echo "Index updated: $MD_PATH and $JSON_PATH"
