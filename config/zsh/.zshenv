# Managed by dotfiles — do not edit directly
# Environment variables needed by all shell invocations (login, non-login, scripts)

# User + Homebrew bins must be visible to non-interactive SSH (Moshi starts
# mosh-server / detects herdr without loading interactive .zshrc).
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
[[ -d /usr/local/bin ]] && export PATH="/usr/local/bin:$PATH"

# Pyenv (only if installed)
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)" 2>/dev/null
fi
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
