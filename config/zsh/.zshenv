# Managed by dotfiles — do not edit directly
# Environment variables needed by all shell invocations (login, non-login, scripts)

# Pyenv (only if installed)
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)" 2>/dev/null
fi
