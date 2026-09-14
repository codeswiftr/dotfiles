#!/usr/bin/env bash
# Health check for the dotfiles environment. Invoked by: just check
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
quiet=false
machine=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet|-q) quiet=true; shift ;;
    --machine|-m|--json) machine=true; quiet=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage: scripts/check.sh [--quiet] [--json]

Checks essential tools, shell, and config symlinks.
EOF
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

essential_tools=(zsh git nvim herdr starship eza bat rg fd fzf)

tool_ok() {
  case "$1" in
    bat) command -v bat &>/dev/null || command -v batcat &>/dev/null ;;
    fd) command -v fd &>/dev/null || command -v fdfind &>/dev/null ;;
    *) command -v "$1" &>/dev/null ;;
  esac
}

if [[ "$machine" == "true" ]]; then
  tools_json="{"
  first=true
  for tool in "${essential_tools[@]}"; do
    ok=false
    tool_ok "$tool" && ok=true
    [[ "$first" == "true" ]] || tools_json+=","
    first=false
    tools_json+="\"$tool\":{\"ok\":$ok}"
  done
  tools_json+="}"
  configs_json="{"
  configs_json+="\"zsh\":$([[ -L "$HOME/.zshrc" ]] && echo true || echo false),"
  configs_json+="\"herdr\":$([[ -L "$HOME/.config/herdr/config.toml" ]] && echo true || echo false),"
  configs_json+="\"nvim\":$([[ -L "$HOME/.config/nvim" ]] && echo true || echo false)"
  configs_json+="}"
  printf '{"status":"ok","tools":%s,"configs":%s,"timestamp":"%s"}\n' \
    "$tools_json" "$configs_json" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  exit 0
fi

exit_code=0

if [[ ! -f "$DOTFILES_DIR/justfile" ]] || [[ ! -f "$DOTFILES_DIR/install.sh" ]]; then
  [[ "$quiet" != "true" ]] && echo "❌ Dotfiles directory looks wrong: $DOTFILES_DIR" >&2
  exit_code=1
fi

missing=()
for tool in "${essential_tools[@]}"; do
  if ! tool_ok "$tool"; then
    missing+=("$tool")
    exit_code=1
  fi
done

if [[ "$quiet" != "true" ]]; then
  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "✅ All essential tools installed"
  else
    echo "❌ Missing tools: ${missing[*]}"
  fi
fi

if [[ "${SHELL:-}" != *zsh* ]]; then
  [[ "$quiet" != "true" ]] && echo "⚠️  Default shell is not zsh"
  exit_code=1
fi

for config in "$HOME/.zshrc" "$HOME/.config/herdr/config.toml" "$HOME/.config/nvim"; do
  if [[ ! -L "$config" ]]; then
    [[ "$quiet" != "true" ]] && echo "⚠️  Config not symlinked: $config"
    exit_code=1
  fi
done

if command -v herdr >/dev/null 2>&1; then
  [[ "$quiet" != "true" ]] && echo "✅ Herdr available ($(herdr --version 2>/dev/null | head -1 || echo herdr))"
elif [[ "$quiet" != "true" ]]; then
  echo "⚠️  Herdr not on PATH"
fi

if [[ "$quiet" != "true" ]]; then
  if [[ $exit_code -eq 0 ]]; then
    echo "✅ All systems operational"
  else
    echo "❌ Issues detected. Run: ./setup   or   just link"
  fi
fi

exit "$exit_code"
