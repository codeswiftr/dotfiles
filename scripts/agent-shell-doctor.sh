#!/usr/bin/env bash
# Check for shell state that commonly confuses coding agents.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

watched_aliases=(cat less grep find ls man vim vi tmux python python3 pip pip3 node npm npx)
watched_vars=(FORGE_API_URL PAGER GIT_PAGER MANPAGER BAT_PAGER LESS)
profile_files=("$HOME/.profile" "$HOME/.zprofile" "$HOME/.zshrc.local" "$HOME/.env.local")

status=0

section() {
  printf '\n== %s ==\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
  status=1
}

ok() {
  printf 'OK: %s\n' "$1"
}

section "Agent-safe shell"
agent_output="$(DOTFILES_DIR="$DOTFILES_DIR" DOTFILES_MODE=agent zsh -fc 'source "$DOTFILES_DIR/.zshrc" >/dev/null 2>&1; agent-safe-status' 2>/dev/null || true)"
if [[ -z "$agent_output" ]]; then
  warn "agent-safe shell did not start cleanly"
else
  printf '%s\n' "$agent_output"
fi

section "Standard command aliases"
alias_output="$(DOTFILES_DIR="$DOTFILES_DIR" DOTFILES_MODE=agent zsh -fc 'source "$DOTFILES_DIR/.zshrc" >/dev/null 2>&1; alias cat less grep find ls man vim vi tmux python python3 pip pip3 node npm npx 2>/dev/null || true' 2>/dev/null || true)"
if [[ -n "$alias_output" ]]; then
  printf '%s\n' "$alias_output"
  warn "agent mode still aliases one or more standard command names"
else
  ok "agent mode leaves standard command names unaliased"
fi

section "Profile hazards"
found_profile_hazard=0
for file in "${profile_files[@]}"; do
  [[ -f "$file" ]] || continue
  while IFS=: read -r lineno kind name; do
    [[ -n "${lineno:-}" ]] || continue
    found_profile_hazard=1
    printf 'WARN: %s:%s defines %s %s\n' "$file" "$lineno" "$kind" "$name"
  done < <(
    awk '
      /^[[:space:]]*(export[[:space:]]+)?FORGE_API_URL[[:space:]=]/ { print NR ":env:FORGE_API_URL" }
      /^[[:space:]]*alias[[:space:]]+(cat|less|grep|find|ls|man|vim|vi|tmux|python|python3|pip|pip3|node|npm|npx)=/ {
        line=$0
        sub(/^[[:space:]]*alias[[:space:]]+/, "", line)
        sub(/=.*/, "", line)
        print NR ":alias:" line
      }
    ' "$file"
  )
done
if [[ "$found_profile_hazard" -eq 0 ]]; then
  ok "no watched aliases or FORGE_API_URL found in local profile files"
else
  warn "move these into dotfiles-managed local modules or guard them with DOTFILES_AGENT_SAFE"
fi

section "Native escape aliases"
escape_output="$(DOTFILES_DIR="$DOTFILES_DIR" zsh -fc 'source "$DOTFILES_DIR/.zshrc" >/dev/null 2>&1; alias _cat _grep _find _ls _tmux _python3 2>/dev/null' 2>/dev/null || true)"
printf '%s\n' "$escape_output"
for required in _cat _grep _find _ls _tmux _python3; do
  if ! grep -q "^${required}=" <<<"$escape_output"; then
    warn "missing native escape alias: $required"
  fi
done

exit "$status"
