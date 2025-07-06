#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Project Management
# Interactive project scaffolding and management
# ============================================================================

# Project management command
dot_project() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "init")
            project_init "$@"
            ;;
        "list")
            project_list_templates
            ;;
        "switch")
            project_switch "$@"
            ;;
        "templates")
            project_list_templates
            ;;
        "-h"|"--help"|"")
            show_project_help
            ;;
        *)
            print_error "Unknown project subcommand: $subcommand"
            echo "Run 'dot project --help' for available commands."
            return 1
            ;;
    esac
}

# Initialize new project from template
project_init() {
    local template_type="${1:-}"
    local project_name="${2:-}"
    
    if [[ -z "$template_type" ]]; then
        echo "Available project templates:"
        project_list_templates
        echo ""
        echo -n "Enter project type: "
        read -r template_type
    fi
    
    if [[ -z "$project_name" ]]; then
        echo -n "Enter project name: "
        read -r project_name
    fi
    
    if [[ -z "$project_name" ]]; then
        print_error "Project name is required"
        return 1
    fi
    
    # Validate project name
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Project name must contain only letters, numbers, underscores, and hyphens"
        return 1
    fi
    
    # Check if directory already exists
    if [[ -d "$project_name" ]]; then
        print_error "Directory '$project_name' already exists"
        return 1
    fi
    
    print_info "${PROJECT} Creating $template_type project: $project_name"
    
    case "$template_type" in
        "fastapi"|"python-api")
            create_fastapi_project "$project_name"
            ;;
        "react"|"react-app")
            create_react_project "$project_name"
            ;;
        "nextjs"|"next")
            create_nextjs_project "$project_name"
            ;;
        "node"|"nodejs")
            create_node_project "$project_name"
            ;;
        "rust")
            create_rust_project "$project_name"
            ;;
        "go"|"golang")
            create_go_project "$project_name"
            ;;
        "python")
            create_python_project "$project_name"
            ;;
        "cli")
            create_cli_project "$project_name"
            ;;
        "docker")
            create_docker_project "$project_name"
            ;;
        *)
            print_error "Unknown template type: $template_type"
            echo "Run 'dot project list' to see available templates"
            return 1
            ;;
    esac
    
    print_success "Project '$project_name' created successfully!"
    print_info "Run 'cd $project_name && dot run dev' to start development"
}

# List available project templates
project_list_templates() {
    echo "📋 Available Project Templates:"
    echo ""
    echo "  🐍 Python Projects:"
    echo "    fastapi      - FastAPI REST API with modern tooling"
    echo "    python       - Generic Python project with poetry"
    echo ""
    echo "  🌐 Web Projects:"
    echo "    react        - React app with Vite and TypeScript"
    echo "    nextjs       - Next.js app with TypeScript"
    echo "    node         - Node.js project with TypeScript"
    echo ""
    echo "  🦀 Systems Projects:"
    echo "    rust         - Rust project with Cargo"
    echo "    go           - Go project with modules"
    echo ""
    echo "  🛠️  Tool Projects:"
    echo "    cli          - Command-line tool (multi-language)"
    echo "    docker       - Dockerized application"
}

# Switch between projects (using zoxide/fzf)
project_switch() {
    if command -v fzf >/dev/null 2>&1 && command -v zoxide >/dev/null 2>&1; then
        local selected_dir
        selected_dir=$(zoxide query --list | fzf --prompt="Select project: " --height=40% --layout=reverse)
        
        if [[ -n "$selected_dir" ]]; then
            print_info "Switching to: $selected_dir"
            cd "$selected_dir" || return 1
        fi
    else
        print_error "fzf and zoxide required for project switching"
        print_info "Install with: brew install fzf zoxide"
    fi
}

# Project template implementations
create_fastapi_project() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    # Initialize with uv if available, otherwise pip
    if command -v uv >/dev/null 2>&1; then
        uv init --python 3.11
        uv add fastapi uvicorn pytest httpx
        uv add --dev black isort mypy
    else
        python -m venv venv
        source venv/bin/activate
        pip install fastapi uvicorn pytest httpx black isort mypy
    fi
    
    # Create basic FastAPI structure
    mkdir -p app tests
    
    cat > app/main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI(title="API", version="1.0.0")

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
EOF
    
    cat > tests/test_main.py << 'EOF'
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}
EOF
    
    create_common_files "$name" "python"
}

create_react_project() {
    local name="$1"
    
    if command -v bun >/dev/null 2>&1; then
        bun create react-app "$name" --template typescript
    elif command -v npm >/dev/null 2>&1; then
        npx create-react-app "$name" --template typescript
    else
        print_error "Node.js/npm or Bun required for React projects"
        return 1
    fi
    
    cd "$name"
    create_common_files "$name" "node"
}

create_nextjs_project() {
    local name="$1"
    
    if command -v bun >/dev/null 2>&1; then
        bun create next-app "$name" --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
    elif command -v npm >/dev/null 2>&1; then
        npx create-next-app@latest "$name" --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
    else
        print_error "Node.js/npm or Bun required for Next.js projects"
        return 1
    fi
    
    cd "$name"
    create_common_files "$name" "node"
}

create_node_project() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    if command -v bun >/dev/null 2>&1; then
        bun init -y
        bun add -d typescript @types/node tsx
    else
        npm init -y
        npm install -D typescript @types/node tsx
    fi
    
    # Create TypeScript config
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
    
    mkdir -p src
    cat > src/index.ts << 'EOF'
console.log("Hello, TypeScript!");
EOF
    
    create_common_files "$name" "node"
}

create_python_project() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    if command -v uv >/dev/null 2>&1; then
        uv init --python 3.11
        uv add --dev pytest black isort mypy
    else
        python -m venv venv
        source venv/bin/activate
        pip install pytest black isort mypy
    fi
    
    mkdir -p src tests
    create_common_files "$name" "python"
}

create_rust_project() {
    local name="$1"
    
    if command -v cargo >/dev/null 2>&1; then
        cargo new "$name"
        cd "$name"
        create_common_files "$name" "rust"
    else
        print_error "Rust/Cargo required for Rust projects"
        return 1
    fi
}

create_go_project() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    if command -v go >/dev/null 2>&1; then
        go mod init "$name"
        
        cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
EOF
        
        create_common_files "$name" "go"
    else
        print_error "Go required for Go projects"
        return 1
    fi
}

create_cli_project() {
    local name="$1"
    echo "Select CLI tool language:"
    echo "1) Bash"
    echo "2) Python"
    echo "3) Rust"
    echo "4) Go"
    echo -n "Choice [1-4]: "
    read -r choice
    
    case "$choice" in
        1) create_bash_cli "$name" ;;
        2) create_python_cli "$name" ;;
        3) create_rust_cli "$name" ;;
        4) create_go_cli "$name" ;;
        *) print_error "Invalid choice" && return 1 ;;
    esac
}

create_bash_cli() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    cat > "$name" << EOF
#!/usr/bin/env bash
set -euo pipefail

show_help() {
    cat << 'HELP'
$name - A command-line tool

USAGE:
    $name [options] <command>

OPTIONS:
    -h, --help     Show this help message
    -v, --version  Show version information

COMMANDS:
    hello          Say hello
HELP
}

main() {
    case "\${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "$name v1.0.0"
            exit 0
            ;;
        hello)
            echo "Hello from $name!"
            ;;
        "")
            show_help
            exit 0
            ;;
        *)
            echo "Unknown command: \$1"
            echo "Run '$name --help' for usage."
            exit 1
            ;;
    esac
}

main "\$@"
EOF
    
    chmod +x "$name"
    create_common_files "$name" "bash"
}

create_docker_project() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF
    
    cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
EOF
    
    create_common_files "$name" "docker"
}

# Create common files for all project types
create_common_files() {
    local name="$1"
    local type="$2"
    
    # .gitignore
    case "$type" in
        "python")
            cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
venv/
env/
ENV/
.env
.venv
EOF
            ;;
        "node")
            cat > .gitignore << 'EOF'
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
dist/
build/
.next/
.cache/
EOF
            ;;
        "rust")
            cat > .gitignore << 'EOF'
/target/
Cargo.lock
*.rs.bk
*.pdb
EOF
            ;;
        "go")
            cat > .gitignore << 'EOF'
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
vendor/
EOF
            ;;
        *)
            cat > .gitignore << 'EOF'
.DS_Store
.env
.env.local
*.log
temp/
tmp/
EOF
            ;;
    esac
    
    # README.md
    cat > README.md << EOF
# $name

## Getting Started

### Development
\`\`\`bash
dot run dev
\`\`\`

### Testing
\`\`\`bash
dot run test
\`\`\`

### Production
\`\`\`bash
dot run prod
\`\`\`

## Features

- Modern development setup
- Integrated testing
- Performance optimized
- Security best practices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request
EOF
    
    # Initialize git repository
    git init
    git add .
    git commit -m "Initial project setup

🚀 Generated with DOT CLI

Co-Authored-By: Claude <noreply@anthropic.com>"
}

# Help function
show_project_help() {
    cat << 'EOF'
dot project - Project management and scaffolding

USAGE:
    dot project <command> [options]

COMMANDS:
    init <type> [name]    Create new project from template
    list                  List available project templates
    switch                Switch between projects (requires fzf + zoxide)
    templates             Alias for 'list'

PROJECT TYPES:
    fastapi              FastAPI REST API with modern tooling
    react                React app with Vite and TypeScript
    nextjs               Next.js app with TypeScript
    node                 Node.js project with TypeScript
    python               Generic Python project with poetry/uv
    rust                 Rust project with Cargo
    go                   Go project with modules
    cli                  Command-line tool (multi-language)
    docker               Dockerized application

OPTIONS:
    -h, --help           Show this help message

EXAMPLES:
    dot project init fastapi my-api
    dot project list
    dot project switch
EOF
}