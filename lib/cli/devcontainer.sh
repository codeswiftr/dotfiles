#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Devcontainer Support
# Enterprise-grade development container management
# ============================================================================

# Devcontainer command dispatcher
dot_devcontainer() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "init")
            devcontainer_init "$@"
            ;;
        "build")
            devcontainer_build "$@"
            ;;
        "up")
            devcontainer_up "$@"
            ;;
        "down")
            devcontainer_down "$@"
            ;;
        "exec")
            devcontainer_exec "$@"
            ;;
        "status")
            devcontainer_status
            ;;
        "templates")
            devcontainer_list_templates
            ;;
        "sync")
            devcontainer_sync_dotfiles "$@"
            ;;
        "logs")
            devcontainer_logs "$@"
            ;;
        "-h"|"--help"|"")
            show_devcontainer_help
            ;;
        *)
            print_error "Unknown devcontainer subcommand: $subcommand"
            echo "Run 'dot devcontainer --help' for available commands."
            return 1
            ;;
    esac
}

# Initialize devcontainer configuration
devcontainer_init() {
    local template="${1:-auto}"
    local name="${2:-$(basename $(pwd))}"
    
    print_info "🐳 Initializing devcontainer for: $name"
    
    # Auto-detect project type if not specified
    if [[ "$template" == "auto" ]]; then
        template=$(detect_project_type)
        print_info "Detected project type: $template"
    fi
    
    # Create .devcontainer directory
    mkdir -p .devcontainer
    
    # Generate devcontainer.json based on template
    case "$template" in
        "python"|"fastapi"|"django")
            create_python_devcontainer "$name"
            ;;
        "node"|"react"|"nextjs"|"typescript")
            create_node_devcontainer "$name"
            ;;
        "rust")
            create_rust_devcontainer "$name"
            ;;
        "go"|"golang")
            create_go_devcontainer "$name"
            ;;
        "full-stack")
            create_fullstack_devcontainer "$name"
            ;;
        "data-science")
            create_datascience_devcontainer "$name"
            ;;
        "universal")
            create_universal_devcontainer "$name"
            ;;
        *)
            print_error "Unknown template: $template"
            echo "Available templates: python, node, rust, go, full-stack, data-science, universal"
            return 1
            ;;
    esac
    
    # Create common files
    create_devcontainer_features
    create_devcontainer_scripts
    create_dotfiles_sync_config
    
    print_success "Devcontainer initialized successfully!"
    print_info "Run 'dot devcontainer build' to build the container"
}

# Build devcontainer
devcontainer_build() {
    local force=false
    local no_cache=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            --no-cache)
                no_cache=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    if [[ ! -f ".devcontainer/devcontainer.json" ]]; then
        print_error "No devcontainer configuration found"
        echo "Run 'dot devcontainer init' first"
        return 1
    fi
    
    print_info "🔨 Building devcontainer..."
    
    local build_args=()
    
    if [[ "$no_cache" == "true" ]]; then
        build_args+=("--no-cache")
    fi
    
    if command -v devcontainer >/dev/null 2>&1; then
        devcontainer build "${build_args[@]}" .
    elif command -v docker >/dev/null 2>&1; then
        # Fallback to Docker if devcontainer CLI not available
        local dockerfile=".devcontainer/Dockerfile"
        if [[ -f "$dockerfile" ]]; then
            docker build "${build_args[@]}" -f "$dockerfile" -t "devcontainer-$(basename $(pwd))" .
        else
            print_error "No Dockerfile found in .devcontainer/"
            return 1
        fi
    else
        print_error "Neither devcontainer CLI nor Docker found"
        echo "Install Docker and optionally the DevContainer CLI"
        return 1
    fi
    
    print_success "Devcontainer built successfully!"
}

# Start devcontainer
devcontainer_up() {
    local detach=false
    local sync_dotfiles=true
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --detach|-d)
                detach=true
                shift
                ;;
            --no-sync)
                sync_dotfiles=false
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    if [[ ! -f ".devcontainer/devcontainer.json" ]]; then
        print_error "No devcontainer configuration found"
        return 1
    fi
    
    print_info "🚀 Starting devcontainer..."
    
    if command -v devcontainer >/dev/null 2>&1; then
        if [[ "$detach" == "true" ]]; then
            devcontainer up --workspace-folder .
        else
            devcontainer up --workspace-folder . --remove-existing-container
        fi
    else
        # Fallback using docker-compose if available
        if [[ -f ".devcontainer/docker-compose.yml" ]]; then
            docker-compose -f .devcontainer/docker-compose.yml up -d
        else
            print_error "DevContainer CLI not available and no docker-compose.yml found"
            return 1
        fi
    fi
    
    # Sync dotfiles if requested
    if [[ "$sync_dotfiles" == "true" ]]; then
        print_info "📦 Syncing dotfiles..."
        devcontainer_sync_dotfiles
    fi
    
    print_success "Devcontainer started successfully!"
    
    if [[ "$detach" != "true" ]]; then
        print_info "Run 'dot devcontainer exec bash' to enter the container"
    fi
}

# Stop devcontainer
devcontainer_down() {
    print_info "🛑 Stopping devcontainer..."
    
    if command -v devcontainer >/dev/null 2>&1; then
        # Get container ID and stop it
        local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
        if [[ -n "$container_id" ]]; then
            docker stop "$container_id"
            docker rm "$container_id"
        fi
    elif [[ -f ".devcontainer/docker-compose.yml" ]]; then
        docker-compose -f .devcontainer/docker-compose.yml down
    else
        print_warning "Unable to determine how to stop devcontainer"
    fi
    
    print_success "Devcontainer stopped!"
}

# Execute command in devcontainer
devcontainer_exec() {
    local command=("$@")
    
    if [[ ${#command[@]} -eq 0 ]]; then
        command=("bash")
    fi
    
    local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
    
    if [[ -z "$container_id" ]]; then
        print_error "No running devcontainer found"
        echo "Run 'dot devcontainer up' first"
        return 1
    fi
    
    print_info "📡 Executing in devcontainer: ${command[*]}"
    docker exec -it "$container_id" "${command[@]}"
}

# Show devcontainer status
devcontainer_status() {
    echo "🐳 Devcontainer Status:"
    echo ""
    
    # Check if devcontainer exists
    if [[ -f ".devcontainer/devcontainer.json" ]]; then
        echo "Configuration: ✅ Found (.devcontainer/devcontainer.json)"
        
        # Show configuration details
        if command -v jq >/dev/null 2>&1; then
            local image=$(jq -r '.image // .build.dockerfile // "unknown"' .devcontainer/devcontainer.json)
            local name=$(jq -r '.name // "unknown"' .devcontainer/devcontainer.json)
            echo "  Name: $name"
            echo "  Image: $image"
        fi
    else
        echo "Configuration: ❌ Not found"
    fi
    
    # Check if container is running
    local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)" 2>/dev/null)
    if [[ -n "$container_id" ]]; then
        echo "Status: ✅ Running (container: ${container_id:0:12})"
        
        # Show container details
        local image=$(docker inspect "$container_id" --format '{{.Config.Image}}' 2>/dev/null)
        local created=$(docker inspect "$container_id" --format '{{.Created}}' 2>/dev/null)
        echo "  Image: $image"
        echo "  Created: $created"
    else
        echo "Status: ⏹️  Stopped"
    fi
    
    # Check Docker availability
    if command -v docker >/dev/null 2>&1; then
        echo "Docker: ✅ Available"
    else
        echo "Docker: ❌ Not available"
    fi
    
    # Check DevContainer CLI
    if command -v devcontainer >/dev/null 2>&1; then
        echo "DevContainer CLI: ✅ Available"
    else
        echo "DevContainer CLI: ❌ Not available (install: npm install -g @devcontainers/cli)"
    fi
}

# Sync dotfiles to devcontainer
devcontainer_sync_dotfiles() {
    local force=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
    
    if [[ -z "$container_id" ]]; then
        print_error "No running devcontainer found"
        return 1
    fi
    
    print_info "📦 Syncing dotfiles to devcontainer..."
    
    # Copy essential dotfiles
    local dotfiles_to_sync=(
        ".zshrc"
        ".tmux.conf"
        ".gitconfig"
        ".config/nvim"
        ".config/starship.toml"
    )
    
    for dotfile in "${dotfiles_to_sync[@]}"; do
        if [[ -e "$DOTFILES_DIR/$dotfile" ]]; then
            print_info "Syncing: $dotfile"
            
            # Create parent directory in container
            local parent_dir=$(dirname "/home/vscode/$dotfile")
            docker exec "$container_id" mkdir -p "$parent_dir"
            
            # Copy file to container
            docker cp "$DOTFILES_DIR/$dotfile" "$container_id:/home/vscode/$dotfile"
        fi
    done
    
    # Install essential tools in container
    print_info "Installing essential tools..."
    docker exec "$container_id" bash -c "
        # Update package lists
        sudo apt-get update >/dev/null 2>&1 || true
        
        # Install essential tools
        sudo apt-get install -y zsh tmux neovim git curl wget >/dev/null 2>&1 || true
        
        # Install modern tools
        curl -fsSL https://starship.rs/install.sh | sh -s -- --yes >/dev/null 2>&1 || true
    "
    
    print_success "Dotfiles synced successfully!"
}

# Template creators
create_python_devcontainer() {
    local name="$1"
    
    cat > .devcontainer/devcontainer.json << EOF
{
    "name": "$name",
    "image": "mcr.microsoft.com/devcontainers/python:3.11",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {
            "installZsh": true,
            "configureZshAsDefaultShell": true,
            "installOhMyZsh": false
        },
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {}
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-python.python",
                "ms-python.black-formatter",
                "ms-python.isort",
                "charliermarsh.ruff"
            ]
        }
    },
    "forwardPorts": [8000, 5000],
    "postCreateCommand": "pip install --user -e . && pip install --user -r requirements-dev.txt",
    "remoteUser": "vscode",
    "workspaceFolder": "/workspaces/$name",
    "mounts": [
        "source=\${localWorkspaceFolder}/.devcontainer/dotfiles,target=/home/vscode/.dotfiles,type=bind,consistency=cached"
    ]
}
EOF

    # Create Python-specific Dockerfile if needed
    cat > .devcontainer/Dockerfile << 'EOF'
FROM mcr.microsoft.com/devcontainers/python:3.11

# Install additional Python tools
RUN pip install --upgrade pip uv poetry

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Setup user environment
USER vscode
WORKDIR /workspaces
EOF
}

create_node_devcontainer() {
    local name="$1"
    
    cat > .devcontainer/devcontainer.json << EOF
{
    "name": "$name",
    "image": "mcr.microsoft.com/devcontainers/typescript-node:18",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {
            "installZsh": true,
            "configureZshAsDefaultShell": true,
            "installOhMyZsh": false
        },
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {}
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.vscode-typescript-next",
                "esbenp.prettier-vscode",
                "dbaeumer.vscode-eslint",
                "bradlc.vscode-tailwindcss"
            ]
        }
    },
    "forwardPorts": [3000, 5173, 8080],
    "postCreateCommand": "npm install",
    "remoteUser": "node",
    "workspaceFolder": "/workspaces/$name"
}
EOF
}

create_universal_devcontainer() {
    local name="$1"
    
    cat > .devcontainer/devcontainer.json << EOF
{
    "name": "$name Universal Dev Environment",
    "image": "mcr.microsoft.com/devcontainers/universal:2",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {
            "installZsh": true,
            "configureZshAsDefaultShell": true,
            "installOhMyZsh": false
        },
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {},
        "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {},
        "ghcr.io/devcontainers/features/terraform:1": {}
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-python.python",
                "ms-vscode.vscode-typescript-next",
                "rust-lang.rust-analyzer",
                "golang.go",
                "hashicorp.terraform"
            ]
        }
    },
    "forwardPorts": [3000, 8000, 8080],
    "postCreateCommand": "/workspaces/$name/.devcontainer/setup.sh",
    "remoteUser": "codespace",
    "workspaceFolder": "/workspaces/$name"
}
EOF
}

# Utility functions
detect_project_type() {
    if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
        echo "python"
    elif [[ -f "package.json" ]]; then
        if grep -q "next" package.json; then
            echo "nextjs"
        elif grep -q "react" package.json; then
            echo "react"
        else
            echo "node"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "go.mod" ]]; then
        echo "go"
    elif [[ -f "docker-compose.yml" ]] && [[ -f "package.json" ]] && [[ -f "requirements.txt" ]]; then
        echo "full-stack"
    else
        echo "universal"
    fi
}

create_devcontainer_features() {
    mkdir -p .devcontainer/features
    
    # Create custom dotfiles feature
    mkdir -p .devcontainer/features/dotfiles
    cat > .devcontainer/features/dotfiles/devcontainer-feature.json << 'EOF'
{
    "id": "dotfiles",
    "version": "1.0.0",
    "name": "Personal Dotfiles",
    "description": "Installs and configures personal dotfiles"
}
EOF

    cat > .devcontainer/features/dotfiles/install.sh << 'EOF'
#!/bin/bash
set -e

echo "Installing personal dotfiles..."

# Install essential tools
apt-get update
apt-get install -y zsh tmux neovim git curl wget

# Install starship prompt
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

# Setup user directories
mkdir -p /home/vscode/.config

echo "Dotfiles feature installation complete!"
EOF

    chmod +x .devcontainer/features/dotfiles/install.sh
}

create_devcontainer_scripts() {
    mkdir -p .devcontainer/scripts
    
    # Create setup script
    cat > .devcontainer/setup.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Setting up development environment..."

# Sync dotfiles if available
if [[ -d "/workspaces/$(basename $(pwd))/.devcontainer/dotfiles" ]]; then
    echo "📦 Syncing dotfiles..."
    cp -r /workspaces/$(basename $(pwd))/.devcontainer/dotfiles/. /home/vscode/
fi

# Install project dependencies
if [[ -f "package.json" ]]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
fi

if [[ -f "requirements.txt" ]]; then
    echo "🐍 Installing Python dependencies..."
    pip install -r requirements.txt
fi

if [[ -f "Cargo.toml" ]]; then
    echo "🦀 Installing Rust dependencies..."
    cargo build
fi

echo "✅ Development environment ready!"
EOF

    chmod +x .devcontainer/setup.sh
}

create_dotfiles_sync_config() {
    mkdir -p .devcontainer/dotfiles
    
    # Create a minimal sync configuration
    cat > .devcontainer/dotfiles/.zshrc << 'EOF'
# Minimal ZSH configuration for devcontainer
export ZSH_DISABLE_COMPFIX=true

# Load essential configurations
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Basic aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

echo "🐳 Welcome to the devcontainer environment!"
EOF
}

devcontainer_list_templates() {
    echo "🐳 Available DevContainer Templates:"
    echo ""
    echo "Language-Specific:"
    echo "  python        - Python with modern tooling (uv, poetry)"
    echo "  node          - Node.js with TypeScript support"
    echo "  rust          - Rust development environment"
    echo "  go            - Go development environment"
    echo ""
    echo "Framework-Specific:"
    echo "  fastapi       - FastAPI with PostgreSQL and Redis"
    echo "  react         - React with Vite and modern tooling"
    echo "  nextjs        - Next.js with full-stack capabilities"
    echo ""
    echo "Multi-Purpose:"
    echo "  full-stack    - Full-stack with multiple languages"
    echo "  data-science  - Python with Jupyter and ML libraries"
    echo "  universal     - GitHub Codespaces universal image"
    echo ""
    echo "Usage: dot devcontainer init <template> [name]"
}

devcontainer_logs() {
    local container_id=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
    
    if [[ -z "$container_id" ]]; then
        print_error "No running devcontainer found"
        return 1
    fi
    
    docker logs "$container_id" "$@"
}

# Help function
show_devcontainer_help() {
    cat << 'EOF'
dot devcontainer - Enterprise development container management

USAGE:
    dot devcontainer <command> [options]

COMMANDS:
    init [template] [name]   Initialize devcontainer configuration
    build [--no-cache]       Build the devcontainer image
    up [--detach]            Start the devcontainer
    down                     Stop and remove the devcontainer
    exec [command]           Execute command in running container
    status                   Show devcontainer status
    templates                List available templates
    sync [--force]           Sync dotfiles to container
    logs [options]           Show container logs

TEMPLATES:
    python, node, rust, go   Language-specific environments
    fastapi, react, nextjs   Framework-specific setups
    full-stack, universal    Multi-purpose environments
    data-science             Python with ML/data tools
    auto                     Auto-detect based on project

OPTIONS:
    --force                  Force operation without prompts
    --detach, -d            Run container in background
    --no-cache              Build without using cache
    --no-sync               Skip dotfiles synchronization
    -h, --help              Show this help message

FEATURES:
    • Automatic dotfiles synchronization
    • Multi-language support with optimized toolchains
    • VSCode integration with recommended extensions
    • Port forwarding for web development
    • Docker-in-Docker support for containerized workflows
    • Enterprise security features and compliance

EXAMPLES:
    dot devcontainer init python my-api    # Python environment
    dot devcontainer build --no-cache      # Clean build
    dot devcontainer up --detach           # Background start
    dot devcontainer exec python app.py   # Run in container
    dot devcontainer sync --force          # Force sync dotfiles

PREREQUISITES:
    • Docker Desktop or Docker Engine
    • DevContainer CLI (optional): npm install -g @devcontainers/cli
    • VSCode with Dev Containers extension (recommended)
EOF
}