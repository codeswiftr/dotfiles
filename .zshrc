# =============================================================================
# Modern ZSH Configuration - 2025 Edition
# =============================================================================

# ----- Section: Core Shell Configuration -----
# Prevent duplicate PATH entries
typeset -U path PATH

# Enable colors
autoload -U colors && colors

# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# ----- Section: Modern Shell Tools -----
# Starship prompt (replaces oh-my-zsh themes)
eval "$(starship init zsh)"

# Zoxide (smart cd replacement)
eval "$(zoxide init zsh)"

# Atuin (better history)
eval "$(atuin init zsh)"

# ----- Section: PATH Configuration -----
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# Bun (JavaScript runtime)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Windsurf (AI Code Editor)
export PATH="/Users/bogdan/.codeium/windsurf/bin:$PATH"

# ----- Section: Language Version Management -----
# Mise (multi-language version manager)
eval "$(mise activate zsh)"

# ----- Section: Modern Aliases -----
# File operations (modern replacements)
alias ls="eza --icons --git"
alias ll="eza --icons --git -l"
alias la="eza --icons --git -la"
alias lt="eza --icons --git --tree"
alias cat="bat"
alias find="fd"
alias grep="rg"

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd="z"  # Use zoxide instead of cd

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

# Python development
alias py="python"
alias pir="uv add"
alias pir-dev="uv add --dev"
alias piu="uv sync"
alias pir-rm="uv remove"
alias py-fmt="ruff format ."
alias py-lint="ruff check ."
alias py-fix="ruff check --fix ."
alias py-test="python -m pytest"
alias py-cov="python -m pytest --cov"

# JavaScript development
alias ni="bun install"
alias nr="bun run"
alias nb="bun run build"
alias nd="bun run dev"
alias nt="bun test"

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

# ----- Section: AI Integration -----
# AI-powered development aliases
alias ai="aider"
alias ask="sgpt"
alias code-review="aider --review"
alias ai-commit="aider --commit"
alias ai-test="aider --test"
alias ai-doc="aider --doc"

# GitHub Copilot CLI
alias cop="gh copilot"
alias cop-explain="gh copilot explain"
alias cop-suggest="gh copilot suggest"

# ----- Section: Environment Variables -----
# Python environment
export UV_CACHE_DIR="$HOME/.cache/uv"
export RUFF_CACHE_DIR="$HOME/.cache/ruff"

# Themes
export BAT_THEME="gruvbox-dark"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ----- Section: Custom Functions -----
# Project switching with language detection
function proj() {
    local project=$(fd -t d -d 2 . ~/work ~/projects 2>/dev/null | fzf --preview "eza --tree --level=2 {}")
    if [[ -n "$project" ]]; then
        cd "$project"
        echo "📁 Switched to: $(basename $project)"
        
        # Auto-detect project type and setup environment
        if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
            echo "🐍 Python project detected"
            if command -v mise &> /dev/null; then
                mise use python@latest
            fi
        elif [[ -f "package.json" ]]; then
            echo "📦 JavaScript project detected"
            if command -v mise &> /dev/null; then
                mise use node@latest
            fi
        elif [[ -f "Package.swift" ]]; then
            echo "🍎 Swift project detected"
        elif [[ -f "Cargo.toml" ]]; then
            echo "🦀 Rust project detected"
        fi
    fi
}

# Tmux session management
function tmux-project() {
    local project_name=$(basename $(pwd))
    if tmux has-session -t "$project_name" 2>/dev/null; then
        tmux attach-session -t "$project_name"
    else
        tmux new-session -d -s "$project_name"
        tmux send-keys -t "$project_name" "clear" C-m
        tmux attach-session -t "$project_name"
    fi
}

# AI-powered project navigation
function ai-find() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: ai-find <search-query>"
        return 1
    fi
    rg --json "$query" | jq -r '.data.path.text' | sort -u | fzf --preview 'bat --color=always {}'
}

# Quick Python environment setup
function py-env() {
    local env_name=${1:-$(basename $(pwd))}
    if [[ ! -d ".venv" ]]; then
        echo "Creating virtual environment: $env_name"
        uv venv --python 3.12
        echo "Virtual environment created. Use 'source .venv/bin/activate' to activate."
    else
        echo "Virtual environment already exists."
    fi
}

# LinkedIn content creation helper
function linkedin-post() {
    local topic="$1"
    if [[ -z "$topic" ]]; then
        echo "Usage: linkedin-post <topic>"
        return 1
    fi
    echo "Creating LinkedIn post about: $topic"
    mkdir -p ~/content
    sgpt "Create a professional LinkedIn post about $topic, include relevant hashtags, make it engaging for tech professionals with 8+ years of Python experience" | tee ~/content/linkedin-$(date +%Y%m%d-%H%M).md
}

# Quick demo setup
function demo-setup() {
    local demo_name="$1"
    if [[ -z "$demo_name" ]]; then
        echo "Usage: demo-setup <demo-name>"
        return 1
    fi
    mkdir -p ~/demos/$demo_name
    cd ~/demos/$demo_name
    git init
    echo "# $demo_name Demo" > README.md
    echo "Demo created on $(date)" >> README.md
    git add README.md
    git commit -m "Initial commit: $demo_name demo setup"
    echo "✅ Demo '$demo_name' created at ~/demos/$demo_name"
}

# ----- Section: FZF Configuration -----
# Enhanced FZF with preview
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --preview 'bat --color=always --style=numbers --line-range=:500 {}'
    --preview-window=right:50%
    --color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374
    --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
    --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
"

# ----- Section: Completions -----
# Load completions
autoload -U compinit
compinit

# Bun completions
if [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# ----- Section: History Configuration -----
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ----- Section: Zsh Options -----
setopt AUTO_CD
setopt CORRECT
setopt CORRECT_ALL
setopt GLOB_COMPLETE
setopt HASH_LIST_ALL
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
setopt EXTENDED_GLOB

# ----- Section: Startup Message -----
echo "🚀 Modern ZSH Configuration Loaded - $(date)"
echo "🔧 Available tools: starship, zoxide, eza, bat, rg, fd, fzf, atuin"
echo "🐍 Python: $(python --version 2>/dev/null || echo 'Not configured')"
echo "📦 Node: $(node --version 2>/dev/null || echo 'Not configured')"
echo "🎯 Type 'proj' to switch projects, 'tmux-project' for tmux sessions"