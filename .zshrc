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

# Windsurf (AI Code Editor) - Cross-platform path
if [[ -d "$HOME/.codeium/windsurf/bin" ]]; then
    export PATH="$HOME/.codeium/windsurf/bin:$PATH"
fi

# ----- Section: Language Version Management -----
# Mise (multi-language version manager)
eval "$(mise activate zsh)"

# ----- Section: Modern Aliases -----
# File operations (modern replacements with dependency checks)
if command -v eza &> /dev/null; then
    alias ls="eza --icons --git"
    alias ll="eza --icons --git -l"
    alias la="eza --icons --git -la"
    alias lt="eza --icons --git --tree"
fi

if command -v bat &> /dev/null; then
    alias cat="bat"
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

# Smart tmux sessionizer (enhanced project switching)
function tmux-sessionizer() {
    ~/.config/tmux/scripts/tmux-sessionizer
}

# Quick tmux session launcher
function tm() {
    if [[ $# -eq 0 ]]; then
        tmux-sessionizer
    else
        tmux-sessionizer "$1"
    fi
}

# Tmux session management aliases
alias ts="tmux list-sessions"       # List tmux sessions
alias ta="tmux attach-session -t"   # Attach to session by name
alias tk="tmux kill-session -t"     # Kill session by name
alias tn="tmux new-session -s"      # Create new named session

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

# ----- Section: Advanced AI Functions -----

# Context-aware Claude Code helper
function claude-context() {
    local prompt="$1"
    local context_files=""
    
    # Auto-detect relevant files based on project type
    if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
        context_files=$(find . -name "*.py" -not -path "./.venv/*" -not -path "./venv/*" | head -5)
    elif [[ -f "package.json" ]]; then
        context_files=$(find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -5)
    elif [[ -f "Package.swift" ]]; then
        context_files=$(find . -name "*.swift" | head -5)
    else
        context_files=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.swift" \) | head -3)
    fi
    
    if [[ -n "$context_files" ]]; then
        echo "📁 Including context files: $(echo $context_files | tr '\n' ' ')"
        claude "$prompt" $context_files
    else
        claude "$prompt"
    fi
}

# Multi-AI comparison for important decisions
function ai-compare() {
    local prompt="$1"
    if [[ -z "$prompt" ]]; then
        echo "Usage: ai-compare <question>"
        return 1
    fi
    
    echo "🤖 Getting opinions from multiple AI models..."
    echo "\n=== Claude Code Response ==="
    claude "$prompt"
    echo "\n=== Gemini Response ==="
    gemini "$prompt"
    echo "\n=== Comparison complete ==="
}

# Project analysis with AI
function ai-analyze() {
    local analysis_type=${1:-"overview"}
    
    case $analysis_type in
        "overview")
            echo "🔍 Analyzing project overview..."
            claude "Analyze this project structure and provide an overview of what it does, its architecture, and key components" $(find . -name "README*" -o -name "*.md" | head -3) $(find . -name "package.json" -o -name "pyproject.toml" -o -name "requirements.txt" | head -2)
            ;;
        "security")
            echo "🔒 Analyzing project security..."
            claude "Review this codebase for potential security vulnerabilities and suggest improvements" $(find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10)
            ;;
        "performance")
            echo "⚡ Analyzing project performance..."
            claude "Review this codebase for performance bottlenecks and optimization opportunities" $(find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10)
            ;;
        "documentation")
            echo "📚 Analyzing project documentation..."
            claude "Review this project's documentation and suggest improvements for clarity and completeness" $(find . -name "README*" -o -name "*.md" -o -name "docs/*" | head -5)
            ;;
        *)
            echo "Usage: ai-analyze [overview|security|performance|documentation]"
            ;;
    esac
}

# Error debugging with AI
function ai-debug() {
    local error_log="$1"
    if [[ -z "$error_log" ]]; then
        echo "Usage: ai-debug <error_message_or_log_file>"
        echo "   or: <command> 2>&1 | ai-debug"
        return 1
    fi
    
    if [[ -f "$error_log" ]]; then
        echo "🐛 Analyzing error log file: $error_log"
        claude "Help me debug this error. Analyze the error log and suggest solutions:" < "$error_log"
    else
        echo "🐛 Analyzing error message..."
        echo "$error_log" | claude "Help me debug this error. Analyze the error message and suggest solutions:"
    fi
}

# AI-powered git commit message generator
function ai-commit() {
    if ! git diff --cached --quiet; then
        echo "📝 Generating commit message based on staged changes..."
        local diff_output=$(git diff --cached)
        local commit_msg=$(echo "$diff_output" | claude "Generate a concise, descriptive git commit message for these changes. Follow conventional commit format:")
        echo "Suggested commit message:"
        echo "$commit_msg"
        echo "\nUse this commit message? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git commit -m "$commit_msg"
        fi
    else
        echo "No staged changes to commit"
    fi
}

# AI-powered code review before push
function ai-review-branch() {
    local branch=${1:-$(git branch --show-current)}
    local base_branch=${2:-"main"}
    
    echo "🔍 AI reviewing changes in branch '$branch' compared to '$base_branch'..."
    
    local changed_files=$(git diff --name-only $base_branch...$branch)
    if [[ -n "$changed_files" ]]; then
        echo "📁 Files changed: $(echo $changed_files | tr '\n' ' ')"
        git diff $base_branch...$branch | claude "Review this code diff for a pull request. Check for bugs, code quality, security issues, and suggest improvements:"
    else
        echo "No changes found between $base_branch and $branch"
    fi
}

# Quick AI code explanation
function explain() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: explain <file>"
        return 1
    fi
    
    if [[ -f "$file" ]]; then
        claude "Explain what this code does, its purpose, and how it works:" "$file"
    else
        echo "File not found: $file"
    fi
}

# AI-powered refactoring suggestions
function ai-refactor() {
    local file="$1"
    local focus="${2:-general}"
    
    if [[ -z "$file" ]]; then
        echo "Usage: ai-refactor <file> [focus]"
        echo "Focus options: general, performance, readability, testing"
        return 1
    fi
    
    if [[ -f "$file" ]]; then
        case $focus in
            "performance")
                claude "Suggest performance optimizations for this code:" "$file"
                ;;
            "readability")
                claude "Suggest improvements for code readability and maintainability:" "$file"
                ;;
            "testing")
                claude "Suggest testing strategies and write unit tests for this code:" "$file"
                ;;
            *)
                claude "Suggest refactoring improvements for this code (structure, clarity, best practices):" "$file"
                ;;
        esac
    else
        echo "File not found: $file"
    fi
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

# ----- Section: Dotfiles Version Management -----
DOTFILES_DIR="$HOME/dotfiles"

# Load version management functions
if [[ -f "$DOTFILES_DIR/lib/version.sh" ]]; then
    source "$DOTFILES_DIR/lib/version.sh"
    
    # Auto-check for updates (respects update interval)
    auto_update_check
fi

# Dotfiles management aliases
alias dotfiles-version="dotfiles_version"
alias dotfiles-update="dotfiles_update"
alias dotfiles-changelog="dotfiles_changelog"
alias df-version="dotfiles_version"
alias df-update="dotfiles_update"
alias df-changelog="dotfiles_changelog"
alias df-health="$DOTFILES_DIR/scripts/health-check.sh"

# ----- Section: Startup Message -----
echo "🚀 Modern ZSH Configuration Loaded - $(date '+%H:%M')"
echo "🔧 Available tools: starship, zoxide, eza, bat, rg, fd, fzf, atuin"
echo "🤖 AI tools: claude (cc), gemini (gg), aider (ai), copilot (cop)"
echo "🎯 Type 'proj' to switch projects, 'tm' for smart tmux sessions"
if [[ -f "$DOTFILES_DIR/VERSION" ]]; then
    echo "📦 Dotfiles version: $(cat $DOTFILES_DIR/VERSION) (use 'df-update' to check for updates)"
fi