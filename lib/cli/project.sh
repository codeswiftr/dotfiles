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
        "ai-init")
            ai_project_init "$@"
            ;;
        "ai-analyze")
            ai_project_analyze "$@"
            ;;
        "ai-enhance")
            ai_project_enhance "$@"
            ;;
        "ai-suggest")
            ai_project_suggest "$@"
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
            create_fastapi_project "$project_name" "${3:-true}"
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
        "lit"|"lit-element")
            create_lit_project "$project_name"
            ;;
        "ios"|"ios-swift")
            create_ios_project "$project_name" "${3:-app}"
            ;;
        "fullstack")
            create_fullstack_project "$project_name"
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
    echo "    lit          - Lit/LitElement PWA with modern tooling"
    echo "    fullstack    - Full-stack FastAPI + Lit project"
    echo ""
    echo "  🦀 Systems Projects:"
    echo "    rust         - Rust project with Cargo"
    echo "    go           - Go project with modules"
    echo ""
    echo "  📱 Mobile Projects:"
    echo "    ios          - iOS/SwiftUI project with modern tooling"
    echo ""
    echo "  🛠️  Tool Projects:"
    echo "    cli          - Command-line tool (multi-language)"
    echo "    docker       - Dockerized application"
    echo ""
    echo "  🤖 AI-Powered Templates:"
    echo "    ai-init      - AI-guided project creation"
    echo "    ai-analyze   - Analyze requirements and suggest templates"
    echo "    ai-enhance   - Enhance existing project with AI suggestions"
    echo "    ai-suggest   - Get AI recommendations for project structure"
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

# Create Lit/LitElement PWA project
create_lit_project() {
    local name="$1"
    print_info "Creating Lit project: $name"
    
    if command -v bun >/dev/null 2>&1; then
        bun create lit "$name"
        cd "$name"
        
        # Add PWA-specific dependencies
        bun add workbox-cli workbox-webpack-plugin
        bun add --dev @web/dev-server @web/test-runner
        
        print_success "Lit project '$name' created with PWA support!"
    else
        mkdir -p "$name"
        cd "$name"
        
        # Initialize with npm
        npm init -y
        npm install lit @lit/reactive-element @lit/localize
        npm install --save-dev @web/dev-server @web/test-runner typescript
        
        # Create basic Lit structure
        mkdir -p src
        cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lit App</title>
    <script type="module" src="./my-app.js"></script>
</head>
<body>
    <my-app></my-app>
</body>
</html>
EOF
        
        cat > src/my-app.js << 'EOF'
import { LitElement, html, css } from 'lit';

export class MyApp extends LitElement {
    static properties = {
        message: { type: String }
    };

    static styles = css`
        :host {
            display: block;
            padding: 25px;
            color: var(--my-app-text-color, #000);
        }
    `;

    constructor() {
        super();
        this.message = 'Hello from Lit!';
    }

    render() {
        return html`
            <h1>${this.message}</h1>
            <p>Welcome to your Lit PWA!</p>
        `;
    }
}

customElements.define('my-app', MyApp);
EOF
        
        print_success "Lit project '$name' created!"
    fi
    
    create_common_files "$name" "node"
}

# Create iOS/SwiftUI project
create_ios_project() {
    local name="$1"
    local template="${2:-app}"
    
    print_info "Creating iOS project: $name"
    
    # Check if Xcode command line tools are available
    if ! command -v xcodebuild >/dev/null 2>&1; then
        print_error "Xcode command line tools not found. Install with: xcode-select --install"
        return 1
    fi
    
    case "$template" in
        "app"|"swiftui")
            create_ios_swiftui_app "$name"
            ;;
        "package"|"spm")
            create_swift_package "$name"
            ;;
        *)
            print_error "Unknown iOS template: $template"
            echo "Available templates: app, swiftui, package, spm"
            return 1
            ;;
    esac
    
    create_common_files "$name" "swift"
    print_success "iOS project '$name' created successfully!"
}

create_ios_swiftui_app() {
    local name="$1"
    mkdir -p "$name"
    cd "$name"
    
    # Create basic SwiftUI app structure
    mkdir -p "$name" "${name}Tests" "${name}UITests"
    
    # Create Package.swift for dependencies
    cat > Package.swift << EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "$name",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "$name",
            targets: ["$name"]
        ),
    ],
    dependencies: [
        // Add your dependencies here
    ],
    targets: [
        .target(
            name: "$name",
            dependencies: []
        ),
        .testTarget(
            name: "${name}Tests",
            dependencies: ["$name"]
        ),
    ]
)
EOF
    
    # Create main app file
    cat > "$name/${name}App.swift" << EOF
import SwiftUI

@main
struct ${name}App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF
    
    # Create content view
    cat > "$name/ContentView.swift" << EOF
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, $name!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
EOF
    
    # Create test file
    cat > "${name}Tests/${name}Tests.swift" << EOF
import XCTest
@testable import $name

final class ${name}Tests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        XCTAssertTrue(true)
    }
}
EOF
    
    print_info "Basic SwiftUI app structure created"
    print_info "Run 'swift build' to build, or open in Xcode"
}

create_swift_package() {
    local name="$1"
    
    if command -v swift >/dev/null 2>&1; then
        swift package init --type library --name "$name"
        cd "$name"
        print_info "Swift package created with SPM"
    else
        print_error "Swift not found. Install Xcode or Swift toolchain"
        return 1
    fi
}

# Create full-stack project (FastAPI + Lit)
create_fullstack_project() {
    local name="$1"
    print_info "Creating full-stack project: $name"
    
    mkdir -p "$name"
    cd "$name"
    
    # Create backend directory with FastAPI
    print_info "Setting up FastAPI backend..."
    mkdir -p backend
    cd backend
    
    if command -v uv >/dev/null 2>&1; then
        uv init
        uv add fastapi uvicorn[standard] python-multipart
        uv add --dev pytest httpx
    else
        python -m venv venv
        source venv/bin/activate
        pip install fastapi uvicorn[standard] python-multipart pytest httpx
    fi
    
    # Create FastAPI backend structure
    mkdir -p app
    cat > app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

app = FastAPI(title="Full-Stack App API", version="1.0.0")

# CORS middleware for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve static files from frontend build
app.mount("/static", StaticFiles(directory="../frontend/dist"), name="static")

@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "service": "api"}

@app.get("/api/hello")
async def hello():
    return {"message": "Hello from FastAPI!"}
EOF
    
    cd ..
    
    # Create frontend directory with Lit
    print_info "Setting up Lit frontend..."
    mkdir -p frontend
    cd frontend
    
    if command -v bun >/dev/null 2>&1; then
        bun init -y
        bun add lit @lit/reactive-element
        bun add --dev @web/dev-server vite typescript
    else
        npm init -y
        npm install lit @lit/reactive-element
        npm install --save-dev @web/dev-server vite typescript
    fi
    
    # Create frontend structure
    mkdir -p src
    cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Full-Stack App</title>
    <script type="module" src="./app.js"></script>
</head>
<body>
    <full-stack-app></full-stack-app>
</body>
</html>
EOF
    
    cat > src/app.js << 'EOF'
import { LitElement, html, css } from 'lit';

export class FullStackApp extends LitElement {
    static properties = {
        apiMessage: { type: String },
        loading: { type: Boolean }
    };

    static styles = css`
        :host {
            display: block;
            padding: 2rem;
            font-family: system-ui, sans-serif;
        }
        .loading {
            opacity: 0.6;
        }
        button {
            padding: 0.5rem 1rem;
            margin: 1rem 0;
            background: #007acc;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background: #005999;
        }
    `;

    constructor() {
        super();
        this.apiMessage = '';
        this.loading = false;
    }

    async fetchFromAPI() {
        this.loading = true;
        try {
            const response = await fetch('/api/hello');
            const data = await response.json();
            this.apiMessage = data.message;
        } catch (error) {
            this.apiMessage = 'Error connecting to API';
        } finally {
            this.loading = false;
        }
    }

    render() {
        return html`
            <h1>Full-Stack Lit + FastAPI App</h1>
            <p>Frontend: Lit</p>
            <p>Backend: FastAPI</p>
            
            <button @click=${this.fetchFromAPI} ?disabled=${this.loading}>
                ${this.loading ? 'Loading...' : 'Test API Connection'}
            </button>
            
            ${this.apiMessage ? html`
                <div class=${this.loading ? 'loading' : ''}>
                    <strong>API Response:</strong> ${this.apiMessage}
                </div>
            ` : ''}
        `;
    }
}

customElements.define('full-stack-app', FullStackApp);
EOF
    
    # Add package.json scripts
    cat > package.json << EOF
{
  "name": "$name-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite serve src --port 3000",
    "build": "vite build src",
    "preview": "vite preview"
  },
  "dependencies": {
    "lit": "^3.0.0",
    "@lit/reactive-element": "^2.0.0"
  },
  "devDependencies": {
    "@web/dev-server": "^0.4.0",
    "vite": "^5.0.0",
    "typescript": "^5.0.0"
  }
}
EOF
    
    cd ..
    
    # Create root-level scripts
    cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting full-stack development environment..."

# Start backend in background
cd backend
if command -v uv >/dev/null 2>&1; then
    uv run fastapi dev app/main.py --port 8000 &
else
    source venv/bin/activate
    fastapi dev app/main.py --port 8000 &
fi
backend_pid=$!

# Start frontend
cd ../frontend
if command -v bun >/dev/null 2>&1; then
    bun run dev &
else
    npm run dev &
fi
frontend_pid=$!

echo "✅ Services started:"
echo "  🔗 Frontend: http://localhost:3000"
echo "  🔗 Backend API: http://localhost:8000"
echo "  📚 API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop all services"

# Cleanup function
cleanup() {
    echo "🛑 Stopping services..."
    kill $backend_pid $frontend_pid 2>/dev/null
    echo "✅ All services stopped"
}

trap cleanup EXIT INT TERM
wait
EOF
    
    chmod +x start-dev.sh
    
    print_success "Full-stack project '$name' created!"
    print_info "Run './start-dev.sh' to start both frontend and backend"
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
    
AI-POWERED COMMANDS:
    ai-init <description> AI-guided project creation
    ai-analyze [dir]      Analyze project and suggest improvements
    ai-enhance [dir]      Apply AI enhancements to existing project
    ai-suggest <context>  Get AI project idea suggestions

PROJECT TYPES:
    fastapi              FastAPI REST API with modern tooling
    react                React app with Vite and TypeScript
    nextjs               Next.js app with TypeScript
    node                 Node.js project with TypeScript
    lit                  Lit/LitElement PWA with modern tooling
    fullstack            Full-stack FastAPI + Lit project
    python               Generic Python project with poetry/uv
    rust                 Rust project with Cargo
    go                   Go project with modules
    ios                  iOS/SwiftUI project with modern tooling
    cli                  Command-line tool (multi-language)
    docker               Dockerized application

OPTIONS:
    -h, --help           Show this help message

EXAMPLES:
    dot project init fastapi my-api
    dot project list
    dot project switch
    dot project ai-init "Build a task management API"
    dot project ai-analyze ./my-project
    dot project ai-enhance ./my-project
EOF
}

# ============================================================================
# AI-Powered Project Scaffolding
# ============================================================================

# AI-guided project initialization
ai_project_init() {
    local description="$*"
    
    if [[ -z "$description" ]]; then
        echo "🤖 AI-Powered Project Creation"
        echo "Describe your project idea, and I'll help you create the perfect template."
        echo ""
        echo -n "Project description: "
        read -r description
    fi
    
    if [[ -z "$description" ]]; then
        print_error "Project description is required for AI initialization"
        return 1
    fi
    
    print_info "🤖 Analyzing project requirements with AI..."
    
    # Use AI to analyze requirements and suggest template
    local ai_response
    ai_response=$(ai_analyze_requirements "$description")
    
    if [[ $? -ne 0 ]]; then
        print_error "AI analysis failed. Falling back to interactive template selection."
        project_init
        return $?
    fi
    
    echo "🤖 AI Analysis Results:"
    echo "$ai_response"
    echo ""
    
    # Extract suggestions from AI response
    local suggested_template
    local suggested_name
    local suggested_features
    
    suggested_template=$(echo "$ai_response" | grep -o "TEMPLATE: [a-z]*" | cut -d' ' -f2)
    suggested_name=$(echo "$ai_response" | grep -o "NAME: [a-zA-Z0-9_-]*" | cut -d' ' -f2)
    suggested_features=$(echo "$ai_response" | grep -A 10 "FEATURES:" | tail -n +2)
    
    # Interactive confirmation
    echo "🎯 AI Recommendations:"
    echo "  Template: ${suggested_template:-unknown}"
    echo "  Name: ${suggested_name:-auto-generated}"
    echo ""
    
    if [[ -n "$suggested_features" ]]; then
        echo "📋 Suggested Features:"
        echo "$suggested_features"
        echo ""
    fi
    
    echo -n "Use AI recommendations? (Y/n): "
    read -r confirm
    
    if [[ "$confirm" =~ ^[Nn] ]]; then
        print_info "Using manual template selection..."
        project_init
        return $?
    fi
    
    # Use AI suggestions or prompt for missing info
    local template="${suggested_template}"
    local name="${suggested_name}"
    
    if [[ -z "$template" ]]; then
        project_list_templates
        echo -n "Select template: "
        read -r template
    fi
    
    if [[ -z "$name" ]]; then
        echo -n "Enter project name: "
        read -r name
    fi
    
    # Create project with AI enhancements
    print_info "🚀 Creating AI-enhanced $template project: $name"
    
    # Standard project creation
    project_init "$template" "$name"
    
    # AI enhancements
    if [[ -d "$name" ]]; then
        print_info "🤖 Applying AI enhancements..."
        cd "$name"
        ai_enhance_project "$description" "$template"
        cd ..
        
        print_success "🎉 AI-powered project '$name' created successfully!"
        print_info "🤖 AI enhancements include:"
        print_info "  • Intelligent code generation"
        print_info "  • Optimized configurations"
        print_info "  • Smart dependencies"
        print_info "  • Best practice implementations"
    fi
}

# Analyze project requirements with AI
ai_analyze_requirements() {
    local description="$1"
    local ai_provider="${AI_PROVIDER:-claude}"
    
    # Create analysis prompt
    local prompt="Analyze this project description and recommend the best template and configuration:

PROJECT DESCRIPTION: $description

Please provide recommendations in this format:
TEMPLATE: [fastapi|react|nextjs|node|lit|fullstack|python|rust|go|ios|cli|docker]
NAME: [suggested-project-name]
FEATURES:
- Feature 1
- Feature 2
- Feature 3

REASONING:
Explain why you chose this template and these features.

DEPENDENCIES:
List key dependencies this project will likely need.

CONFIGURATION:
Suggest important configuration considerations."
    
    # Call AI service
    case "$ai_provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                echo "$prompt" | claude --quiet
            else
                print_error "Claude CLI not available. Install with: pip install claude-api"
                return 1
            fi
            ;;
        "gemini")
            if command -v gemini >/dev/null 2>&1; then
                echo "$prompt" | gemini --quiet
            else
                print_error "Gemini CLI not available"
                return 1
            fi
            ;;
        *)
            print_error "Unsupported AI provider: $ai_provider"
            print_info "Set AI_PROVIDER to: claude, gemini"
            return 1
            ;;
    esac
}

# Enhance existing project with AI suggestions
ai_enhance_project() {
    local description="$1"
    local template="$2"
    local ai_provider="${AI_PROVIDER:-claude}"
    
    print_info "🤖 Generating AI enhancements for $template project..."
    
    # Create enhancement prompt
    local prompt="I have a $template project. Please suggest specific enhancements:

PROJECT DESCRIPTION: $description
PROJECT TYPE: $template

Please provide:
1. Additional useful files to create
2. Configuration optimizations
3. Code improvements
4. Development workflow suggestions
5. Testing strategies
6. Security considerations

Focus on practical, immediately actionable improvements."
    
    local suggestions
    case "$ai_provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                suggestions=$(echo "$prompt" | claude --quiet)
            else
                print_warning "Claude CLI not available - skipping AI enhancements"
                return 0
            fi
            ;;
        "gemini")
            if command -v gemini >/dev/null 2>&1; then
                suggestions=$(echo "$prompt" | gemini --quiet)
            else
                print_warning "Gemini CLI not available - skipping AI enhancements"
                return 0
            fi
            ;;
        *)
            print_warning "Unsupported AI provider - skipping AI enhancements"
            return 0
            ;;
    esac
    
    # Apply AI suggestions
    if [[ -n "$suggestions" ]]; then
        # Create AI suggestions file
        cat > .ai-enhancements.md << EOF
# AI Enhancement Suggestions

Generated: $(date)
Provider: $ai_provider

## Suggestions

$suggestions

## How to Apply

Review these suggestions and implement them gradually:
1. Read through each suggestion
2. Implement the ones that fit your use case
3. Test thoroughly
4. Update documentation

Run \`dot ai enhance\` again anytime for updated suggestions.
EOF
        
        print_success "✨ AI enhancements saved to .ai-enhancements.md"
        print_info "💡 Review and apply suggestions that fit your needs"
    fi
}

# Analyze existing project and suggest improvements
ai_project_analyze() {
    local project_dir="${1:-.}"
    
    if [[ ! -d "$project_dir" ]]; then
        print_error "Directory not found: $project_dir"
        return 1
    fi
    
    print_info "🤖 Analyzing project structure..."
    
    cd "$project_dir"
    
    # Gather project information
    local project_info=""
    
    # Detect project type
    if [[ -f "package.json" ]]; then
        project_info+="PROJECT_TYPE: Node.js/JavaScript\n"
        project_info+="PACKAGE_JSON: $(cat package.json | head -20)\n"
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        project_info+="PROJECT_TYPE: Python\n"
        [[ -f "pyproject.toml" ]] && project_info+="PYPROJECT: $(cat pyproject.toml | head -20)\n"
    elif [[ -f "Cargo.toml" ]]; then
        project_info+="PROJECT_TYPE: Rust\n"
        project_info+="CARGO: $(cat Cargo.toml | head -20)\n"
    elif [[ -f "go.mod" ]]; then
        project_info+="PROJECT_TYPE: Go\n"
        project_info+="GO_MOD: $(cat go.mod)\n"
    fi
    
    # File structure
    project_info+="FILES: $(find . -maxdepth 2 -type f | head -20)\n"
    project_info+="DIRECTORIES: $(find . -maxdepth 2 -type d | head -10)\n"
    
    # Create analysis prompt
    local prompt="Analyze this project and provide improvement suggestions:

$project_info

Please provide:
1. Project health assessment (1-10 score)
2. Key improvement areas
3. Missing best practices
4. Security considerations
5. Performance optimization opportunities
6. Developer experience improvements
7. Specific actionable recommendations

Focus on practical, high-impact improvements."
    
    local analysis
    case "${AI_PROVIDER:-claude}" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                analysis=$(echo "$prompt" | claude --quiet)
            else
                print_error "Claude CLI not available"
                return 1
            fi
            ;;
        "gemini")
            if command -v gemini >/dev/null 2>&1; then
                analysis=$(echo "$prompt" | gemini --quiet)
            else
                print_error "Gemini CLI not available"
                return 1
            fi
            ;;
        *)
            print_error "No AI provider configured"
            return 1
            ;;
    esac
    
    echo "🤖 AI Project Analysis:"
    echo "========================"
    echo "$analysis"
    
    # Save analysis
    cat > .ai-analysis.md << EOF
# AI Project Analysis

Generated: $(date)
Provider: ${AI_PROVIDER:-claude}

## Analysis Results

$analysis

## Next Steps

1. Review the recommendations above
2. Prioritize improvements based on your needs
3. Implement changes incrementally
4. Run analysis again after improvements: \`dot project ai-analyze\`
EOF
    
    print_success "📊 Analysis saved to .ai-analysis.md"
}

# AI project suggestions based on current context
ai_project_suggest() {
    local context="${1:-}"
    
    if [[ -z "$context" ]]; then
        echo "🤖 AI Project Suggestions"
        echo "What kind of project suggestions do you need?"
        echo ""
        echo "Examples:"
        echo "  • 'web app for task management'"
        echo "  • 'CLI tool for developers'"
        echo "  • 'mobile app idea'"
        echo "  • 'microservice architecture'"
        echo ""
        echo -n "Context: "
        read -r context
    fi
    
    if [[ -z "$context" ]]; then
        print_error "Context is required for AI suggestions"
        return 1
    fi
    
    print_info "🤖 Generating project suggestions..."
    
    local prompt="Suggest 3-5 specific project ideas based on this context: $context

For each suggestion, provide:
1. Project name and brief description
2. Key features (3-5 features)
3. Technology stack recommendation
4. Estimated complexity (1-10)
5. Potential impact/usefulness
6. Getting started steps

Focus on practical, buildable projects that solve real problems."
    
    local suggestions
    case "${AI_PROVIDER:-claude}" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                suggestions=$(echo "$prompt" | claude --quiet)
            else
                print_error "Claude CLI not available"
                return 1
            fi
            ;;
        "gemini")
            if command -v gemini >/dev/null 2>&1; then
                suggestions=$(echo "$prompt" | gemini --quiet)
            else
                print_error "Gemini CLI not available"
                return 1
            fi
            ;;
        *)
            print_error "No AI provider configured"
            return 1
            ;;
    esac
    
    echo "🤖 AI Project Suggestions:"
    echo "=========================="
    echo "$suggestions"
    
    echo ""
    echo "💡 To create one of these projects:"
    echo "   dot project ai-init \"[describe the project you want]\""
}