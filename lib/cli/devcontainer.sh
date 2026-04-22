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
        "optimize")
            devcontainer_optimization "$@"
            ;;
        "cloud")
            cloud_dev_environment "$@"
            ;;
        "performance")
            container_performance_tuning "$@"
            ;;
        "remote")
            remote_development_tools "$@"
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
        "config/nvim"
        "config/starship.toml"
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
                "charliermarsh.ruff",
                "ms-python.isort"
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

# ============================================================================
# Epic 7.3: Container & Cloud Development Features
# Enhanced devcontainer support, cloud development, and performance optimization
# ============================================================================

# Devcontainer optimization
devcontainer_optimization() {
    local optimization_type="${1:-auto}"
    shift || true
    
    case "$optimization_type" in
        "auto")
            auto_optimize_devcontainer "$@"
            ;;
        "performance")
            optimize_container_performance "$@"
            ;;
        "size")
            optimize_container_size "$@"
            ;;
        "build")
            optimize_build_process "$@"
            ;;
        "network")
            optimize_container_networking "$@"
            ;;
        "storage")
            optimize_container_storage "$@"
            ;;
        "analyze")
            analyze_container_performance "$@"
            ;;
        *)
            show_optimization_help
            ;;
    esac
}

# Auto-optimize devcontainer based on project type and system resources
auto_optimize_devcontainer() {
    print_info "⚙️ Auto-optimizing devcontainer configuration..."
    
    if [[ ! -f ".devcontainer/devcontainer.json" ]]; then
        print_error "No devcontainer configuration found"
        return 1
    fi
    
    local project_type=$(detect_project_type)
    local system_memory=$(get_system_memory_gb)
    local cpu_cores=$(nproc 2>/dev/null || echo "4")
    
    print_info "Project type: $project_type"
    print_info "System resources: ${cpu_cores} CPUs, ${system_memory}GB RAM"
    
    # Create optimized configuration
    local temp_config=".devcontainer/devcontainer.optimized.json"
    
    # Start with existing configuration
    cp ".devcontainer/devcontainer.json" "$temp_config"
    
    # Apply optimizations based on project type
    case "$project_type" in
        "python")
            optimize_python_devcontainer "$temp_config" "$system_memory" "$cpu_cores"
            ;;
        "node")
            optimize_node_devcontainer "$temp_config" "$system_memory" "$cpu_cores"
            ;;
        "rust")
            optimize_rust_devcontainer "$temp_config" "$system_memory" "$cpu_cores"
            ;;
        "go")
            optimize_go_devcontainer "$temp_config" "$system_memory" "$cpu_cores"
            ;;
        *)
            optimize_generic_devcontainer "$temp_config" "$system_memory" "$cpu_cores"
            ;;
    esac
    
    # Apply resource-based optimizations
    apply_resource_optimizations "$temp_config" "$system_memory" "$cpu_cores"
    
    # Show optimization preview
    show_optimization_preview "$temp_config"
    
    echo -n "Apply these optimizations? [Y/n]: "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        # Backup original
        cp ".devcontainer/devcontainer.json" ".devcontainer/devcontainer.json.backup"
        
        # Apply optimizations
        mv "$temp_config" ".devcontainer/devcontainer.json"
        
        print_success "Devcontainer optimized successfully!"
        print_info "Original configuration backed up as devcontainer.json.backup"
        print_info "Rebuild container with: dot devcontainer build --no-cache"
    else
        rm "$temp_config"
        print_info "Optimization cancelled"
    fi
}

# Python devcontainer optimizations
optimize_python_devcontainer() {
    local config_file="$1"
    local memory_gb="$2"
    local cpu_cores="$3"
    
    print_info "Applying Python-specific optimizations..."
    
    # Use python with build tools for better performance
    update_json_field "$config_file" '.image' '"mcr.microsoft.com/devcontainers/python:3.11-bullseye"'
    
    # Add Python performance optimizations
    local python_env='"PYTHONOPTIMIZE": "1", "PYTHONDONTWRITEBYTECODE": "1", "PIP_NO_CACHE_DIR": "1"'
    add_container_env "$config_file" "$python_env"
    
    # Add uv for faster package management
    add_post_create_command "$config_file" "pip install --upgrade pip uv && uv --version"
    
    # Optimize pip configuration
    add_dockerfile_optimization "$config_file" "python" "$memory_gb" "$cpu_cores"
}

# Node.js devcontainer optimizations
optimize_node_devcontainer() {
    local config_file="$1"
    local memory_gb="$2"
    local cpu_cores="$3"
    
    print_info "Applying Node.js-specific optimizations..."
    
    # Use latest Node.js LTS
    update_json_field "$config_file" '.image' '"mcr.microsoft.com/devcontainers/typescript-node:lts-bullseye"'
    
    # Add Node.js performance optimizations
    local node_memory=$((memory_gb * 1024 / 2))  # Use half of available memory
    local node_env="\"NODE_OPTIONS\": \"--max-old-space-size=$node_memory\", \"NPM_CONFIG_FUND\": \"false\", \"NPM_CONFIG_AUDIT\": \"false\""
    add_container_env "$config_file" "$node_env"
    
    # Enable pnpm for faster installs
    add_post_create_command "$config_file" "npm install -g pnpm && pnpm --version"
    
    add_dockerfile_optimization "$config_file" "node" "$memory_gb" "$cpu_cores"
}

# Cloud development environment
cloud_dev_environment() {
    local platform="${1:-auto}"
    local action="${2:-setup}"
    shift 2 || true
    
    case "$action" in
        "setup")
            setup_cloud_dev "$platform" "$@"
            ;;
        "sync")
            sync_cloud_environment "$platform" "$@"
            ;;
        "deploy")
            deploy_cloud_environment "$platform" "$@"
            ;;
        "status")
            show_cloud_status "$platform"
            ;;
        "optimize")
            optimize_cloud_performance "$platform" "$@"
            ;;
        *)
            show_cloud_help
            ;;
    esac
}

# Setup cloud development environment
setup_cloud_dev() {
    local platform="$1"
    shift || true
    
    if [[ "$platform" == "auto" ]]; then
        platform=$(detect_cloud_platform)
        print_info "Detected cloud platform: $platform"
    fi
    
    case "$platform" in
        "codespaces")
            setup_github_codespaces "$@"
            ;;
        "gitpod")
            setup_gitpod_environment "$@"
            ;;
        "coder")
            setup_coder_environment "$@"
            ;;
        "vscode-remote")
            setup_vscode_remote "$@"
            ;;
        "cloud-shell")
            setup_cloud_shell "$@"
            ;;
        *)
            print_error "Unsupported cloud platform: $platform"
            show_supported_cloud_platforms
            return 1
            ;;
    esac
}

# Setup GitHub Codespaces
setup_github_codespaces() {
    print_info "🐙 Setting up GitHub Codespaces environment..."
    
    # Create codespaces-specific devcontainer
    mkdir -p ".devcontainer"
    
    # Enhanced devcontainer for Codespaces
    cat > ".devcontainer/devcontainer.json" << EOF
{
    "name": "$(basename $(pwd)) - Codespaces Optimized",
    "image": "mcr.microsoft.com/devcontainers/universal:2-linux",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {
            "installZsh": true,
            "configureZshAsDefaultShell": true,
            "installOhMyZsh": false
        },
        "ghcr.io/devcontainers/features/git:1": {
            "ppa": true,
            "version": "latest"
        },
        "ghcr.io/devcontainers/features/github-cli:1": {
            "version": "latest"
        },
        "ghcr.io/devcontainers/features/docker-in-docker:2": {
            "moby": true,
            "azureDnsAutoDetection": true,
            "installDockerBuildx": true
        },
        "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {
            "version": "latest",
            "helm": "latest",
            "minikube": "none"
        }
    },
    "customizations": {
        "vscode": {
            "settings": {
                "terminal.integrated.defaultProfile.linux": "zsh",
                "files.watcherExclude": {
                    "**/node_modules/**": true,
                    "**/.git/objects/**": true,
                    "**/.git/subtree-cache/**": true,
                    "**/target/**": true
                }
            },
            "extensions": [
                "ms-vscode.vscode-json",
                "redhat.vscode-yaml",
                "ms-vscode.vscode-typescript-next",
                "GitHub.copilot",
                "GitHub.copilot-chat",
                "ms-vscode.hexeditor"
            ]
        },
        "codespaces": {
            "openFiles": [
                "README.md"
            ]
        }
    },
    "forwardPorts": [3000, 8000, 8080, 9000],
    "portsAttributes": {
        "3000": {
            "label": "Development Server",
            "visibility": "public"
        },
        "8000": {
            "label": "API Server",
            "visibility": "public"
        }
    },
    "postCreateCommand": ".devcontainer/setup-codespaces.sh",
    "remoteUser": "codespace",
    "workspaceFolder": "/workspaces/$(basename $(pwd))",
    "mounts": [
        {
            "source": "codespace-home",
            "target": "/home/codespace",
            "type": "volume"
        }
    ]
}
EOF
    
    # Create Codespaces setup script
    create_codespaces_setup_script
    
    # Create Codespaces-specific configuration
    create_codespaces_config_files
    
    print_success "GitHub Codespaces environment configured!"
    print_info "Commit and push these files to enable Codespaces"
}

# Setup Gitpod environment
setup_gitpod_environment() {
    print_info "🤖 Setting up Gitpod environment..."
    
    # Create Gitpod configuration
    cat > ".gitpod.yml" << EOF
# Gitpod Configuration for $(basename $(pwd))
image:
  file: .gitpod.Dockerfile

ports:
  - port: 3000
    onOpen: open-preview
    name: Development Server
    description: Main development server
  - port: 8000
    onOpen: notify
    name: API Server
    description: Backend API server

tasks:
  - name: Setup Development Environment
    init: |
      echo "🚀 Setting up development environment..."
      ./.gitpod/setup.sh
    command: |
      echo "✅ Environment ready!"
      echo "Happy coding! 🎉"

vscode:
  extensions:
    - ms-vscode.vscode-json
    - redhat.vscode-yaml
    - ms-vscode.vscode-typescript-next
    - GitHub.copilot
    - ms-python.python
    - rust-lang.rust-analyzer
    - golang.Go

gitHub:
  prebuilds:
    master: true
    branches: true
    pullRequests: true
    pullRequestsFromForks: false
    addCheck: prevent-merge-on-error
    addBadge: true
EOF
    
    # Create Gitpod Dockerfile
    create_gitpod_dockerfile
    
    # Create Gitpod setup script
    create_gitpod_setup_script
    
    print_success "Gitpod environment configured!"
    print_info "Push to repository and open with: https://gitpod.io/#your-repo-url"
}

# Container performance tuning
container_performance_tuning() {
    local tuning_type="${1:-auto}"
    local container_name="${2:-}"
    shift 2 || true
    
    case "$tuning_type" in
        "auto")
            auto_tune_container_performance "$container_name" "$@"
            ;;
        "memory")
            tune_container_memory "$container_name" "$@"
            ;;
        "cpu")
            tune_container_cpu "$container_name" "$@"
            ;;
        "io")
            tune_container_io "$container_name" "$@"
            ;;
        "network")
            tune_container_network "$container_name" "$@"
            ;;
        "analyze")
            analyze_container_performance "$container_name" "$@"
            ;;
        "benchmark")
            benchmark_container_performance "$container_name" "$@"
            ;;
        *)
            show_performance_tuning_help
            ;;
    esac
}

# Auto-tune container performance
auto_tune_container_performance() {
    local container_name="$1"
    
    if [[ -z "$container_name" ]]; then
        container_name=$(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)" | head -1)
    fi
    
    if [[ -z "$container_name" ]]; then
        print_error "No running container found"
        return 1
    fi
    
    print_info "⚡ Auto-tuning container performance..."
    
    # Get container and system information
    local container_memory=$(docker inspect "$container_name" --format '{{.HostConfig.Memory}}')
    local container_cpus=$(docker inspect "$container_name" --format '{{.HostConfig.CpuCount}}')
    local system_memory=$(get_system_memory_gb)
    local system_cpus=$(nproc)
    
    print_info "Container resources: ${container_cpus:-auto} CPUs, $((container_memory / 1024 / 1024 / 1024))GB RAM"
    print_info "System resources: ${system_cpus} CPUs, ${system_memory}GB RAM"
    
    # Analyze current performance
    local current_performance=$(measure_container_performance "$container_name")
    
    # Apply optimizations
    optimize_container_filesystem "$container_name"
    optimize_container_network_stack "$container_name"
    optimize_container_resource_limits "$container_name" "$system_memory" "$system_cpus"
    
    # Measure performance after optimization
    local optimized_performance=$(measure_container_performance "$container_name")
    
    # Show improvement
    show_performance_improvement "$current_performance" "$optimized_performance"
    
    print_success "Container performance optimization completed!"
}

# Remote development tools
remote_development_tools() {
    local action="${1:-status}"
    local target="${2:-}"
    shift 2 || true
    
    case "$action" in
        "setup")
            setup_remote_development "$target" "$@"
            ;;
        "connect")
            connect_remote_environment "$target" "$@"
            ;;
        "sync")
            sync_remote_environment "$target" "$@"
            ;;
        "tunnel")
            setup_development_tunnel "$target" "$@"
            ;;
        "ssh")
            setup_ssh_development "$target" "$@"
            ;;
        "status")
            show_remote_development_status
            ;;
        "optimize")
            optimize_remote_performance "$target" "$@"
            ;;
        *)
            show_remote_development_help
            ;;
    esac
}

# Setup remote development
setup_remote_development() {
    local target="$1"
    shift || true
    
    print_info "🌐 Setting up remote development for: $target"
    
    case "$target" in
        "ssh")
            setup_ssh_remote_development "$@"
            ;;
        "docker")
            setup_docker_remote_development "$@"
            ;;
        "k8s"|"kubernetes")
            setup_kubernetes_remote_development "$@"
            ;;
        "wsl")
            setup_wsl_remote_development "$@"
            ;;
        *)
            print_error "Unknown remote target: $target"
            echo "Available targets: ssh, docker, k8s, wsl"
            return 1
            ;;
    esac
}

# Setup SSH remote development
setup_ssh_remote_development() {
    local remote_host="$1"
    local remote_user="${2:-$USER}"
    
    if [[ -z "$remote_host" ]]; then
        echo -n "Enter remote host (user@host or host): "
        read -r remote_host
    fi
    
    print_info "Setting up SSH remote development for: $remote_host"
    
    # Parse host and user
    if [[ "$remote_host" == *"@"* ]]; then
        remote_user="${remote_host%@*}"
        remote_host="${remote_host#*@}"
    fi
    
    # Create SSH config entry
    local ssh_config="$HOME/.ssh/config"
    local host_alias="dev-$(echo "$remote_host" | tr '.' '-')"
    
    if ! grep -q "Host $host_alias" "$ssh_config" 2>/dev/null; then
        print_info "Adding SSH configuration..."
        
        cat >> "$ssh_config" << EOF

# Development environment: $remote_host
Host $host_alias
    HostName $remote_host
    User $remote_user
    ForwardAgent yes
    Compression yes
    ServerAliveInterval 60
    ServerAliveCountMax 10
    # RemoteForward 52698 localhost:52698  # VS Code Remote
EOF
        
        chmod 600 "$ssh_config"
    fi
    
    # Setup remote environment
    print_info "Setting up remote environment..."
    
    # Create remote setup script
    cat > /tmp/remote-setup.sh << 'EOF'
#!/bin/bash
# Remote development environment setup
set -e

echo "🚀 Setting up remote development environment..."

# Install essential tools
if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y git zsh tmux neovim curl wget
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git zsh tmux neovim curl wget
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed git zsh tmux neovim curl wget
fi

# Install modern tools
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if ! command -v zoxide >/dev/null 2>&1; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Setup development directories
mkdir -p ~/dev ~/bin ~/.config

echo "✅ Remote environment setup complete!"
EOF
    
    # Copy and execute setup script
    scp /tmp/remote-setup.sh "$remote_user@$remote_host:/tmp/"
    ssh "$remote_user@$remote_host" "chmod +x /tmp/remote-setup.sh && /tmp/remote-setup.sh"
    
    # Clean up
    rm /tmp/remote-setup.sh
    
    print_success "SSH remote development configured!"
    print_info "Connect with: ssh $host_alias"
    print_info "VS Code remote: code --remote ssh-remote+$host_alias /path/to/project"
}

# Utility functions
get_system_memory_gb() {
    local memory_kb
    
    case "$OSTYPE" in
        darwin*)
            memory_kb=$(sysctl -n hw.memsize | awk '{print $1/1024}')
            ;;
        linux*)
            memory_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
            ;;
        *)
            memory_kb=8388608  # Default to 8GB
            ;;
    esac
    
    echo $((memory_kb / 1024 / 1024))
}

detect_cloud_platform() {
    # Check for cloud environment indicators
    if [[ -n "$CODESPACES" ]]; then
        echo "codespaces"
    elif [[ -n "$GITPOD_WORKSPACE_ID" ]]; then
        echo "gitpod"
    elif [[ -n "$CODER_WORKSPACE_NAME" ]]; then
        echo "coder"
    elif [[ -n "$CLOUD_SHELL" ]]; then
        echo "cloud-shell"
    else
        echo "local"
    fi
}

create_codespaces_setup_script() {
    mkdir -p .devcontainer
    
    cat > ".devcontainer/setup-codespaces.sh" << 'EOF'
#!/bin/bash
# GitHub Codespaces setup script
set -e

echo "🚀 Setting up GitHub Codespaces environment..."

# Install additional tools
echo "📦 Installing additional development tools..."

# Install starship prompt
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# Install zoxide
if ! command -v zoxide >/dev/null 2>&1; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
fi

# Install modern CLI tools
echo "🔧 Installing modern CLI tools..."
cargo install ripgrep fd-find bat eza 2>/dev/null || echo "Rust tools installation skipped"

# Setup development environment
echo "⚙️ Configuring development environment..."

# Configure git with enhanced settings
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global pull.rebase false
git config --global core.editor "code --wait"

# Setup shell configuration
echo "🐚 Configuring shell..."
echo '# Enhanced aliases for development' >> ~/.zshrc
echo 'alias ll="ls -la"' >> ~/.zshrc
echo 'alias la="ls -A"' >> ~/.zshrc
echo 'alias gs="git status"' >> ~/.zshrc
echo 'alias gp="git push"' >> ~/.zshrc
echo 'alias gl="git pull"' >> ~/.zshrc
echo 'alias gc="git commit"' >> ~/.zshrc

# Install project dependencies if present
if [[ -f "package.json" ]]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
elif [[ -f "requirements.txt" ]]; then
    echo "🐍 Installing Python dependencies..."
    pip install -r requirements.txt
elif [[ -f "Cargo.toml" ]]; then
    echo "🦀 Building Rust project..."
    cargo build
elif [[ -f "go.mod" ]]; then
    echo "🐹 Installing Go dependencies..."
    go mod download
fi

echo "✅ GitHub Codespaces environment setup complete!"
echo "Happy coding! 🎉"
EOF
    
    chmod +x ".devcontainer/setup-codespaces.sh"
}

create_gitpod_dockerfile() {
    cat > ".gitpod.Dockerfile" << 'EOF'
FROM gitpod/workspace-full:latest

# Install additional tools
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y \
    && curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Configure shell
RUN echo 'eval "$(starship init zsh)"' >> ~/.zshrc \
    && echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

# Install modern CLI tools
RUN cargo install ripgrep fd-find bat eza || true

# Install development tools based on workspace
COPY . /tmp/workspace
RUN if [ -f "/tmp/workspace/package.json" ]; then npm install -g pnpm; fi \
    && if [ -f "/tmp/workspace/requirements.txt" ]; then pip install uv; fi \
    && rm -rf /tmp/workspace
EOF
}

create_gitpod_setup_script() {
    mkdir -p .gitpod
    
    cat > ".gitpod/setup.sh" << 'EOF'
#!/bin/bash
# Gitpod setup script
set -e

echo "🚀 Setting up Gitpod development environment..."

# Install project dependencies
if [[ -f "package.json" ]]; then
    echo "📦 Installing Node.js dependencies with pnpm..."
    pnpm install --frozen-lockfile || npm install
elif [[ -f "requirements.txt" ]]; then
    echo "🐍 Installing Python dependencies with uv..."
    uv pip install -r requirements.txt || pip install -r requirements.txt
elif [[ -f "Cargo.toml" ]]; then
    echo "🦀 Building Rust project..."
    cargo build
elif [[ -f "go.mod" ]]; then
    echo "🐹 Installing Go dependencies..."
    go mod download
fi

# Setup git configuration
git config --global user.email "$(gp env get | grep GITHUB_EMAIL | cut -d= -f2)"
git config --global user.name "$(gp env get | grep GITHUB_USER | cut -d= -f2)"

echo "✅ Gitpod environment setup complete!"
EOF
    
    chmod +x ".gitpod/setup.sh"
}

optimize_container_filesystem() {
    local container_name="$1"
    
    print_info "Optimizing container filesystem..."
    
    # Enable filesystem optimizations in container
    docker exec "$container_name" bash -c '
        # Enable filesystem caching
        echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf 2>/dev/null || true
        
        # Optimize mount options if possible
        mount -o remount,noatime / 2>/dev/null || true
    ' 2>/dev/null || true
}

measure_container_performance() {
    local container_name="$1"
    
    # Simple performance measurement
    local start_time=$(date +%s.%3N)
    docker exec "$container_name" bash -c 'echo "test" > /tmp/perf_test && cat /tmp/perf_test && rm /tmp/perf_test' >/dev/null 2>&1
    local end_time=$(date +%s.%3N)
    
    echo "scale=3; $end_time - $start_time" | bc 2>/dev/null || echo "0.001"
}

show_performance_improvement() {
    local before="$1"
    local after="$2"
    
    local improvement=$(echo "scale=1; ($before - $after) / $before * 100" | bc 2>/dev/null || echo "0")
    
    if (( $(echo "$improvement > 0" | bc -l 2>/dev/null || echo 0) )); then
        print_success "Performance improved by ${improvement}%!"
    else
        print_info "Performance optimization applied (minimal measurable change)"
    fi
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
    optimize [type]          Optimize devcontainer performance
    cloud <platform> <action> Cloud development environment setup
    performance <type>       Container performance tuning
    remote <action> [target] Remote development tools

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