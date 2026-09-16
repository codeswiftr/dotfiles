#!/usr/bin/env bash
# Shared helpers for global git hooks (core.hooksPath → ~/.config/git/hooks).
# shellcheck shell=bash

hooks_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

hooks_dotfiles_dir() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$here/.." && pwd
}

# Run the pre-commit framework when this repo has a config.
hooks_run_precommit() {
  local stage="$1"
  shift
  local root config
  root="$(hooks_repo_root)"
  [[ -n "$root" ]] || return 0
  config=""
  if [[ -f "$root/.pre-commit-config.yaml" ]]; then
    config="$root/.pre-commit-config.yaml"
  elif [[ -f "$root/.pre-commit-config.yml" ]]; then
    config="$root/.pre-commit-config.yml"
  else
    return 0
  fi
  command -v pre-commit >/dev/null 2>&1 || return 0
  (cd "$root" && PRE_COMMIT_COLOR=always pre-commit run --config "$config" --hook-stage "$stage" "$@")
}

# Fast secret-ish scan of staged paths (blocks). Skips docs/markdown/examples.
hooks_scan_staged_secrets() {
  local root file pat found=0
  root="$(hooks_repo_root)"
  [[ -n "$root" ]] || return 0
  cd "$root" || return 0

  local -a patterns=(
    'password\s*[:=]'
    'api[_-]?key\s*[:=]'
    '(^|[^a-z])secret\s*[:=]'
    'private[_-]?key\s*[:=]'
    'BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY'
  )

  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    [[ "$file" == docs/* || "$file" == *.md || "$file" == *.example || "$file" == *.sample ]] && continue
    [[ "$file" == .pre-commit-config.y*ml || "$file" == hooks/_common.sh ]] && continue
    grep -qiE '(example|sample|template|fixture)' <<<"$file" && continue
    for pat in "${patterns[@]}"; do
      if command -v rg >/dev/null 2>&1; then
        if rg -n -i -e "$pat" -- "$file" 2>/dev/null | rg -v '# (Example|Template|Test)' >/dev/null; then
          echo "pre-commit: possible secret in $file (/$pat/)" >&2
          found=1
        fi
      elif grep -nEi "$pat" "$file" 2>/dev/null | grep -vE '# (Example|Template|Test)' >/dev/null; then
        echo "pre-commit: possible secret in $file (/$pat/)" >&2
        found=1
      fi
    done
  done < <(git diff --cached --name-only --diff-filter=ACM)

  return "$found"
}
