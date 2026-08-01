# =============================================================================
# Minimal Tool Initialization — SSH sessions and lightweight environments
# Only loads tools that are present, with zero mandatory dependencies.
# =============================================================================

# Universal has-command helper
_has() { command -v "$1" >/dev/null 2>&1; }

# mise activation (fast Rust binary, acceptable even in SSH)
if _has mise; then
    eval "$(mise activate zsh --quiet 2>/dev/null)"
fi

# Prompt: starship if available, minimal fallback otherwise. Starship exits
# non-zero under TERM=dumb, which breaks headless test and agent shells.
if [[ "${TERM:-}" != "dumb" ]] && _has starship; then
    eval "$(starship init zsh)"
else
    PS1='%n@%m %~%# '
fi

# zoxide: smarter cd (fast enough for SSH)
if _has zoxide; then
    eval "$(zoxide init zsh)"
else
    alias z='cd'
fi

# fzf key bindings only (no heavy preview config)
if _has fzf; then
    source <(fzf --zsh 2>/dev/null) 2>/dev/null || true
fi

# Aliases (ls/cat/grep/find/…) live in aliases.zsh — keep this file init-only.

# History (essential everywhere)
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Skip atuin in SSH (interactive history sync not needed on servers)
# Skip forge-tools, fleet-dashboard, ai-enhanced in SSH
