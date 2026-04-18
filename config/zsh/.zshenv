# Managed by dotfiles — do not edit directly
# Environment variables needed by all shell invocations (login, non-login, scripts)

# Pyenv (single init — do NOT duplicate in .zprofile)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)" 2>/dev/null
