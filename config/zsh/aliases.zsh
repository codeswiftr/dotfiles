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
elif command -v batcat &> /dev/null; then
    # Ubuntu/Debian installs bat as batcat
    alias bat="batcat"
    alias cat="batcat"
    alias less="batcat"
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
# gc is defined as a smart function in ai-enhanced.zsh (falls back to git commit)
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

# Database migrations (SQLModel/Alembic)
alias alembic="uv run alembic"
alias db-migrate="uv run alembic upgrade head"
alias db-revision="uv run alembic revision --autogenerate -m"
alias db-history="uv run alembic history"
alias db-down="uv run alembic downgrade -1"
alias db-current="uv run alembic current"

# Vite development
alias vite="bunx vite"
alias vbuild="bun run build"
alias vpreview="bun run preview"
alias vdev="bun run dev"

# TailwindCSS v4
alias tw="bunx tailwindcss"
alias tw-build="bunx tailwindcss -o dist/styles.css --minify"
alias tw-watch="bunx tailwindcss -o dist/styles.css --watch"

# Railway deployment
alias rw="railway"
alias rwup="railway up"
alias rwlogs="railway logs"
alias rwrun="railway run"
alias rwlink="railway link"
alias rwenv="railway variables"
alias rwdeploy="railway up --detach"
alias rwopen="railway open"

# Cloudflare (Wrangler)
alias cf="wrangler"
alias cfpages="wrangler pages"
alias cfdeploy="wrangler pages deploy"
alias cfdev="wrangler pages dev"
alias cfsecret="wrangler secret"
alias cflogin="wrangler login"
alias cflist="wrangler pages project list"

# AI/ML tools
alias jlab="jupyter lab"
alias jbook="jupyter notebook"

# System aliases
alias src="source ~/.zshrc"
alias reload="dot-reload"
alias man="${DOTFILES_DIR}/viman"
alias vim="nvim"
alias vi="nvim"

# ============================================================================
# AI Agent Aliases
# NOTE: Primary AI aliases are in config/agents/agents.zsh
# Only legacy/misc AI-related aliases below
# ============================================================================

# GitHub Copilot CLI
alias cop="gh copilot"
alias cop-explain="gh copilot explain"
alias cop-suggest="gh copilot suggest"

# Legacy compatibility
alias ask="sgpt"

# Modern tool shortcuts
alias dev-optimize="optimize-dev-tools"
alias dev-update="update-dev-tools"
alias uv-opt="uv-optimize"
alias bun-opt="bun-optimize" 
alias mise-opt="mise-optimize"

# Tmux session management aliases
alias ts="tmux list-sessions"       # List tmux sessions
alias tl="tmux list-sessions"       # Common muscle memory: tl -> list

# Auto-resume tmux: attach to existing session or create new one
tmux() {
    if [[ $# -eq 0 ]]; then
        # No arguments: auto-attach or create
        if command tmux has-session 2>/dev/null; then
            command tmux attach-session
        else
            command tmux new-session
        fi
    else
        # Pass through any arguments to real tmux
        command tmux "$@"
    fi
}
# Attach to session by name; if no param, open interactive picker
ta() {
    if [[ -n "$1" ]]; then
        tmux attach-session -t "$1"
        return
    fi
    # Interactive session picker
    local choice=""
    if command -v fzf >/dev/null 2>&1; then
        # fzf picker with window preview
        choice=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --prompt='ta > ' --height 40% --reverse --preview 'tmux list-windows -t {}' --preview-window=down,50% || true)
    else
        local sessions=($(tmux list-sessions -F "#S" 2>/dev/null))
        if [[ ${#sessions[@]} -eq 0 ]]; then
            echo "No tmux sessions found. Create one with: tn <name>"
            return 1
        fi
        echo "Available sessions: ${sessions[*]}"
        read -r "choice?Attach to session: "
    fi
    if [[ -n "$choice" ]]; then
        tmux attach-session -t "$choice"
    else
        echo "Cancelled"
    fi
}
alias tk="tmux kill-session -t"     # Kill session by name
alias tn="tmux new-session -s"      # Create new named session

# Tmux clipboard aliases
alias tcopy="${DOTFILES_DIR}/scripts/tmux-clipboard.sh copy"
alias tpaste="${DOTFILES_DIR}/scripts/tmux-clipboard.sh paste"
alias tclip-status="${DOTFILES_DIR}/scripts/tmux-clipboard.sh status"
alias tclip-test="${DOTFILES_DIR}/scripts/tmux-clipboard.sh test"

# Health check convenience
alias dot-health="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/health-check.sh"

# Development helpers
alias api="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/dev-api.sh"
alias pwa="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/dev-web.sh"
alias swiftui="${DOTFILES_DIR:-$HOME/dotfiles}/scripts/dev-ios.sh preview"
