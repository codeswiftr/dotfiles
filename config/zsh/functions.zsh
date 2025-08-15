# ============================================================================
# Custom Functions
# Project management, development workflows, and utility functions
# ============================================================================

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

# dot reload wrapper: reload all configs in the current interactive shell
dot-reload() {
    # 1) tmux: reload server-side config
    if command -v tmux >/dev/null 2>&1; then
        tmux source-file ~/.tmux.conf 2>/dev/null || true
    fi
    # 2) mise: refresh shims
    if command -v mise >/dev/null 2>&1; then
        mise reshim >/dev/null 2>&1 || true
    fi
    # 3) zsh: re-source configs in-place to avoid spawning a subshell
    if [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc"
        echo "✅ Reloaded shell configuration (zsh)"
    fi
}

# Alias for convenience (muscle memory)
alias dot-reload='dot-reload'

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

# AI-powered project navigation
function ai-find() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: ai-find <search-query>"
        return 1
    fi
    rg --json "$query" | jq -r '.data.path.text' | sort -u | fzf --preview 'bat --color=always {}'
}

# Quick Python environment setup with uv
function py-env() {
    local env_name=${1:-$(basename $(pwd))}
    if [[ ! -d ".venv" ]]; then
        echo "🐍 Creating virtual environment: $env_name"
        uv venv --python 3.12
        echo "✅ Virtual environment created. Activating..."
        source .venv/bin/activate
        if [[ -f "pyproject.toml" ]]; then
            echo "📦 Installing dependencies from pyproject.toml..."
            uv sync
        fi
    else
        echo "🔄 Virtual environment already exists. Activating..."
        source .venv/bin/activate
    fi
}

# Modern Python project initialization
function py-new() {
    local project_name="$1"
    if [[ -z "$project_name" ]]; then
        echo "Usage: py-new <project-name>"
        return 1
    fi
    
    echo "🚀 Creating new Python project: $project_name"
    mkdir -p "$project_name"
    cd "$project_name"
    
    # Initialize with uv
    uv init --name "$project_name" --python 3.12
    
    # Create basic project structure
    mkdir -p src/"$project_name" tests docs
    
    # Add common development dependencies
    uv add --dev pytest pytest-cov ruff mypy
    
    # Create basic files
    echo "# $project_name\n\nA modern Python project.\n" > README.md
    echo "*.pyc\n__pycache__/\n.venv/\n.pytest_cache/\n.coverage\n.mypy_cache/\n" > .gitignore
    
    # Initialize git
    git init
    git add .
    git commit -m "Initial commit: Setup $project_name with uv"
    
    echo "✅ Project '$project_name' created successfully!"
    echo "💡 Next steps:"
    echo "   - cd $project_name"
    echo "   - py-env (to activate virtual environment)"
    echo "   - Start coding in src/$project_name/"
}

# Bun project initialization
function js-new() {
    local project_name="$1"
    local template="${2:-vanilla}"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: js-new <project-name> [template]"
        echo "Templates: vanilla, react, next, svelte, vue"
        return 1
    fi
    
    echo "🚀 Creating new JavaScript project: $project_name"
    
    case "$template" in
        "react")
            bun create react-app "$project_name"
            ;;
        "next")
            bun create next-app "$project_name"
            ;;
        "svelte")
            bun create svelte-app "$project_name"
            ;;
        "vue")
            bun create vue-app "$project_name"
            ;;
        *)
            bun create "$project_name"
            ;;
    esac
    
    cd "$project_name"
    echo "✅ Project '$project_name' created successfully!"
    echo "💡 Next steps:"
    echo "   - bun install (if needed)"
    echo "   - bun run dev (to start development server)"
}

# Smart project setup based on language detection
function project-setup() {
    local current_dir=$(pwd)
    local project_name=$(basename "$current_dir")
    
    echo "🔍 Analyzing project structure..."
    
    if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
        echo "🐍 Python project detected"
        py-env
        if command -v mise >/dev/null 2>&1; then
            mise use python@latest
        fi
    elif [[ -f "package.json" ]]; then
        echo "📦 JavaScript project detected"
        if [[ ! -d "node_modules" ]]; then
            echo "📦 Installing dependencies..."
            bun install
        fi
        if command -v mise >/dev/null 2>&1; then
            mise use node@latest
        fi
    elif [[ -f "Cargo.toml" ]]; then
        echo "🦀 Rust project detected"
        if command -v mise >/dev/null 2>&1; then
            mise use rust@latest
        fi
    elif [[ -f "go.mod" ]]; then
        echo "🐹 Go project detected"
        if command -v mise >/dev/null 2>&1; then
            mise use go@latest
        fi
    else
        echo "❓ Unknown project type. Creating basic setup..."
        if [[ ! -f ".gitignore" ]]; then
            echo "Creating basic .gitignore..."
            echo ".DS_Store\n*.log\n*.tmp\n" > .gitignore
        fi
        if [[ ! -f "README.md" ]]; then
            echo "Creating basic README.md..."
            echo "# $project_name\n\nProject description goes here.\n" > README.md
        fi
    fi
    
    # Initialize git if not already done
    if [[ ! -d ".git" ]]; then
        echo "📁 Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit"
    fi
    
    echo "✅ Project setup complete!"
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