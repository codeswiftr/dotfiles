# ============================================================================
# Web Development and PWA Configuration
# Enhanced tooling for FastAPI + LitPWA development workflow
# ============================================================================

# FastAPI development aliases and functions
alias fapi="fastapi dev"
alias fapi-run="fastapi run"
alias fapi-prod="fastapi run --host 0.0.0.0 --port 8000"
alias fapi-docs="open http://localhost:8000/docs"
alias fapi-redoc="open http://localhost:8000/redoc"

# Advanced FastAPI development functions
fastapi-init() {
    local project_name=${1:-"fastapi-app"}
    echo "🚀 Creating FastAPI project: $project_name"
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    # Initialize with uv
    uv init
    uv add fastapi uvicorn[standard] python-multipart python-jose[cryptography] passlib[bcrypt]
    uv add --dev pytest pytest-asyncio httpx pytest-cov ruff black
    
    # Create basic FastAPI structure
    mkdir -p app tests
    cat > app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="My FastAPI App", version="1.0.0")

# CORS middleware for frontend development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello FastAPI!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
EOF
    
    cat > tests/test_main.py << 'EOF'
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello FastAPI!"}

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
EOF
    
    echo "✅ FastAPI project '$project_name' created successfully!"
    echo "💡 Run: cd $project_name && fastapi dev app/main.py"
}

# Lit/LitElement development aliases
alias lit-dev="npm run dev"
alias lit-build="npm run build"
alias lit-serve="npm run serve"
alias lit-test="npm run test"

# LitElement project initialization
lit-init() {
    local project_name=${1:-"lit-app"}
    echo "🔥 Creating Lit project: $project_name"
    
    bun create lit "$project_name"
    cd "$project_name"
    
    # Add PWA-specific dependencies
    bun add workbox-cli workbox-webpack-plugin
    bun add --dev @web/dev-server @web/test-runner
    
    echo "✅ Lit project '$project_name' created with PWA support!"
}

# PWA development tools and functions
pwa-audit() {
    local url=${1:-"http://localhost:8000"}
    echo "🔍 Running PWA audit on: $url"
    
    if command -v lighthouse >/dev/null; then
        lighthouse "$url" --only-categories=pwa --chrome-flags="--headless"
    else
        echo "📱 Install Lighthouse: npm install -g lighthouse"
        echo "🌐 Or use online audit: https://web.dev/measure/"
    fi
}

pwa-manifest-validate() {
    local manifest=${1:-"manifest.json"}
    echo "📋 Validating PWA manifest: $manifest"
    
    if [[ -f "$manifest" ]]; then
        if command -v jq >/dev/null; then
            jq . "$manifest" > /dev/null && echo "✅ Manifest is valid JSON" || echo "❌ Invalid JSON in manifest"
        else
            echo "📦 Install jq for validation: brew install jq"
        fi
    else
        echo "❌ Manifest file not found: $manifest"
    fi
}

pwa-sw-generate() {
    echo "⚙️  Generating service worker..."
    
    if command -v workbox >/dev/null; then
        workbox generateSW workbox-config.js
        echo "✅ Service worker generated!"
    else
        echo "📦 Install Workbox CLI: npm install -g workbox-cli"
    fi
}

# Web development server functions
web-serve() {
    local port=${1:-8080}
    local dir=${2:-.}
    
    echo "🌐 Starting web server on port $port for directory: $dir"
    
    if command -v python3 >/dev/null; then
        cd "$dir" && python3 -m http.server "$port"
    elif command -v php >/dev/null; then
        cd "$dir" && php -S "localhost:$port"
    elif command -v bun >/dev/null; then
        cd "$dir" && bun x serve -p "$port"
    else
        echo "❌ No suitable web server found. Install Python, PHP, or Bun."
    fi
}

# Browser automation for development
browser-open() {
    local url=${1:-"http://localhost:8000"}
    local browser=${2:-"chrome"}
    
    case "$browser" in
        chrome|google-chrome)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open -a "Google Chrome" "$url"
            else
                google-chrome "$url"
            fi
            ;;
        firefox)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open -a "Firefox" "$url"
            else
                firefox "$url"
            fi
            ;;
        safari)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open -a "Safari" "$url"
            else
                echo "❌ Safari only available on macOS"
            fi
            ;;
        *)
            echo "🌐 Opening in default browser: $url"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open "$url"
            else
                xdg-open "$url"
            fi
            ;;
    esac
}

# Full-stack development workflow
fullstack-dev() {
    local backend_port=${1:-8000}
    local frontend_port=${2:-3000}
    
    echo "🚀 Starting full-stack development environment..."
    
    # Check if we're in a project with both backend and frontend
    if [[ -f "app/main.py" ]] || [[ -f "main.py" ]]; then
        echo "🐍 Starting FastAPI backend on port $backend_port..."
        fastapi dev app/main.py --port "$backend_port" &
        backend_pid=$!
    fi
    
    if [[ -f "package.json" ]] && grep -q "dev" package.json; then
        echo "🔥 Starting frontend development server on port $frontend_port..."
        PORT="$frontend_port" bun run dev &
        frontend_pid=$!
    fi
    
    # Open browsers
    sleep 2
    browser-open "http://localhost:$backend_port/docs" &
    browser-open "http://localhost:$frontend_port" &
    
    echo "✅ Full-stack environment running!"
    echo "🔗 Backend API: http://localhost:$backend_port"
    echo "🔗 Frontend: http://localhost:$frontend_port"
    echo "📚 API Docs: http://localhost:$backend_port/docs"
    echo ""
    echo "Press Ctrl+C to stop all services"
    
    # Cleanup function
    cleanup() {
        echo "🛑 Stopping development servers..."
        [[ -n $backend_pid ]] && kill $backend_pid 2>/dev/null
        [[ -n $frontend_pid ]] && kill $frontend_pid 2>/dev/null
        echo "✅ All servers stopped"
    }
    
    trap cleanup EXIT INT TERM
    wait
}

# Development environment health check
web-dev-check() {
    echo "🔍 Checking web development environment..."
    
    # Check essential tools
    local tools=("python3" "bun" "node" "npm")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null; then
            echo "✅ $tool: $(command -v "$tool")"
        else
            echo "❌ $tool: Not installed"
        fi
    done
    
    # Check Python packages
    echo ""
    echo "🐍 Python packages:"
    if command -v uv >/dev/null; then
        echo "✅ uv: $(uv --version)"
    else
        echo "❌ uv: Not installed (pip install uv)"
    fi
    
    # Check Node.js packages
    echo ""
    echo "📦 Node.js environment:"
    if command -v bun >/dev/null; then
        echo "✅ bun: $(bun --version)"
    else
        echo "❌ bun: Not installed"
    fi
    
    # Check web development tools
    echo ""
    echo "🌐 Web development tools:"
    local web_tools=("lighthouse" "workbox")
    for tool in "${web_tools[@]}"; do
        if command -v "$tool" >/dev/null; then
            echo "✅ $tool: Available"
        else
            echo "⚠️  $tool: Not installed (consider: npm install -g $tool)"
        fi
    done
    
    echo ""
    echo "🚀 Web development environment check complete!"
}