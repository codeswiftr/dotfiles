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

# Prompt: starship if available, minimal fallback otherwise
if _has starship; then
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

# Core aliases (no external tool deps)
_has eza  && alias ls='eza --group-directories-first' \
           && alias ll='eza -lhF --group-directories-first --git' \
           && alias la='eza -lhAF --group-directories-first --git' \
           || { alias ll='ls -lhF'; alias la='ls -lhAF'; }

_has bat  && alias cat='bat --paging=never'
_has rg   && alias grep='rg'
_has fd   && alias find='fd'
_has nvim && alias vim='nvim' && alias vi='nvim'

# History (essential everywhere)
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Skip atuin in SSH (interactive history sync not needed on servers)
# Skip forge-tools, fleet-dashboard, ai-enhanced in SSH
