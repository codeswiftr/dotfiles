# Host: nova (this machine)
# Machine-local PATH and tools — no secrets (use ~/.env.local for those).

# kimi-code CLI install location
[[ -d "$HOME/.kimi-code/bin" ]] && export PATH="$HOME/.kimi-code/bin:$PATH"

# Grok Build CLI
if [[ -d "$HOME/.grok/bin" ]]; then
    export PATH="$HOME/.grok/bin:$PATH"
    fpath=("$HOME/.grok/completions/zsh" $fpath)
fi

# Atuin env file (init handled by tools-*.zsh)
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

# OpenCode user install
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

# Bun completions (binary PATH set in defaults.zsh)
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
