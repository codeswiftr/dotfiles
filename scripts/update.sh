#!/usr/bin/env bash
# Update dotfiles + optional tools. Invoked by: just update
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
scope="all"
yes=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --self) scope="self"; shift ;;
    --tools) scope="tools"; shift ;;
    --yes|-y) yes=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: scripts/update.sh [--self|--tools] [--yes]

  (default)  git pull + relink + upgrade brew/npm/uv/mise + nvim plugins
  --self     git pull + relink only
  --tools    package managers + nvim plugins only
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

cd "$DOTFILES_DIR"

if [[ "$scope" != "tools" ]]; then
  echo "ℹ️  Updating dotfiles repository..."
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  Uncommitted changes detected"
    if [[ "$yes" != "true" ]]; then
      echo -n "Continue with pull? [y/N]: "
      read -r response
      [[ "$response" =~ ^[Yy]$ ]] || { echo "Cancelled"; exit 1; }
    fi
  fi
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@') || branch="main"
  old_head=$(git rev-parse HEAD)
  git pull origin "$branch"
  new_head=$(git rev-parse HEAD)
  if [[ "$old_head" != "$new_head" ]]; then
    git log --oneline "$old_head..$new_head" || true
  fi
  echo "ℹ️  Relinking..."
  bash "$DOTFILES_DIR/install.sh" link
fi

if [[ "$scope" != "self" ]]; then
  echo "ℹ️  Upgrading tools..."
  command -v brew >/dev/null 2>&1 && brew upgrade 2>/dev/null || true
  command -v npm >/dev/null 2>&1 && npm update -g 2>/dev/null || true
  command -v uv >/dev/null 2>&1 && uv tool upgrade --all 2>/dev/null || true
  command -v mise >/dev/null 2>&1 && mise upgrade 2>/dev/null || true
  if command -v nvim >/dev/null 2>&1; then
    nvim --headless -c 'Lazy! sync' -c 'qa' 2>/dev/null || true
  fi
fi

if command -v herdr >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1 || true
fi

echo "✅ Update completed — run 'exec zsh' to reload the shell"
