# ============================================================================
# Modern Aliases
# Enhanced aliases for modern CLI tools and development workflows
# ============================================================================

# File operations (modern replacements with dependency checks)
if command -v eza &> /dev/null; then
    alias ls="eza --icons --git"
    alias ll="eza --icons --git -l"
    alias la="eza --icons --git -la"
    alias lt="eza --icons --git --tree"
    alias lg="eza --icons --git -la --git"
fi

if command -v bat &> /dev/null; then
    alias cat="bat"
    alias less="bat"
fi

if command -v fd &> /dev/null; then
    alias find="fd"
fi

if command -v rg &> /dev/null; then
    alias grep="rg"
fi

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias j="z"   # Jump with zoxide (keeps original cd intact)

# Docker aliases
alias dc="docker compose"
alias dcc="docker context"
alias dk="docker"
alias dkps="docker ps"
alias dki="docker images"

# Git aliases (enhanced)
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias glog="git log --oneline --graph --all"
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"

# Python development with uv
alias py="python"
alias pir="uv add"
alias pir-dev="uv add --dev"
alias piu="uv sync"
alias pir-rm="uv remove"
alias pir-lock="uv lock"
alias pir-export="uv export"
alias py-init="uv init"
alias py-run="uv run"
alias py-tool="uv tool"
alias py-python="uv python"
alias py-venv="uv venv"
alias py-fmt="uv run ruff format ."
alias py-lint="uv run ruff check ."
alias py-fix="uv run ruff check --fix ."
alias py-test="uv run pytest"
alias py-cov="uv run pytest --cov"

# JavaScript development with Bun
alias ni="bun install"
alias nr="bun run"
alias nb="bun run build"
alias nd="bun run dev"
alias nt="bun test"
alias nx="bunx"
alias nc="bun create"
alias nu="bun update"
alias na="bun add"
alias nad="bun add --dev"
alias nrm="bun remove"

# FastAPI specific
alias fapi="fastapi dev"
alias fapi-run="fastapi run"

# AI/ML tools
alias jlab="jupyter lab"
alias jbook="jupyter notebook"

# System aliases
alias src="source ~/.zshrc"
alias reload="source ~/.zshrc"
alias man="~/dotfiles/viman"
alias vim="nvim"
alias vi="nvim"

# AI Integration aliases
alias ai="aider"
alias ask="sgpt"
alias aider-review="aider --review"
alias aider-test="aider --test"
alias aider-doc="aider --doc"

# Claude Code CLI aliases
alias claude="claude"
alias cc="claude"
alias ccr="claude --review"
alias ccd="claude --doc"
alias cce="claude --explain"

# Gemini CLI aliases  
alias gem="gemini"
alias gg="gemini"
alias ggr="gemini --review"
alias ggd="gemini --doc"
alias gge="gemini --explain"

# GitHub Copilot CLI
alias cop="gh copilot"
alias cop-explain="gh copilot explain"
alias cop-suggest="gh copilot suggest"

# Modern tool shortcuts
alias dev-optimize="optimize-dev-tools"
alias dev-update="update-dev-tools"
alias uv-opt="uv-optimize"
alias bun-opt="bun-optimize" 
alias mise-opt="mise-optimize"

# Tmux session management aliases
alias ts="tmux list-sessions"       # List tmux sessions
alias ta="tmux attach-session -t"   # Attach to session by name
alias tk="tmux kill-session -t"     # Kill session by name
alias tn="tmux new-session -s"      # Create new named session