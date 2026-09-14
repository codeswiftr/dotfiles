# ============================================================================
# FORGE loader — helpers live in forge-mono, not this public repo
# ============================================================================

[[ -n "$DOTFILES_SSH" ]] && return 0

: "${FORGE_ROOT:=$HOME/work/forge-mono}"
export FORGE_ROOT

_forge_rc="$FORGE_ROOT/shell/forge.zsh"
if [[ -f "$_forge_rc" ]]; then
    source "$_forge_rc"
fi
unset _forge_rc
