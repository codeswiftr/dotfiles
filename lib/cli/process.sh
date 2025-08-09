#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Process Management
# Development process orchestration with overmind/foreman
# ============================================================================

# Process management command dispatcher
dot_run() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "dev")
            process_start_dev "$@"
            ;;
        "test")
            process_start_test "$@"
            ;;
        "prod")
            process_start_prod "$@"
            ;;
        "start")
            process_start_custom "$@"
            ;;
        "stop")
            process_stop "$@"
            ;;
        "restart")
            process_restart "$@"
            ;;
        "status")
            process_status "$@"
            ;;
        "logs")
            process_logs "$@"
            ;;
        "ps")
            process_list
            ;;
        "init")
            process_init_procfile "$@"
            ;;
        "templates")
            process_list_templates
            ;;
        "-h"|"--help"|"")
            show_process_help
            ;;
        *)
            print_error "Unknown process subcommand: $subcommand"
            echo "Run 'dot run --help' for available commands."
            return 1
            ;;
    esac
}

# Start development environment
process_start_dev() {
    local procfile="Procfile"
    local env_file=".env"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --procfile|-f)
                procfile="$2"
                shift 2
                ;;
            --env)
                env_file="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Auto-detect development setup if no Procfile
    if [[ ! -f "$procfile" ]]; then
        process_auto_detect_dev
        return $?
    fi
    
    print_info "🚀 Starting development environment..."
    
    local runner=$(detect_process_runner)
    
    case "$runner" in
        "overmind")
            process_start_overmind "$procfile" "$env_file"
            ;;
        "foreman")
            process_start_foreman "$procfile" "$env_file"
            ;;
        "docker-compose")
            process_start_docker_compose
            ;;
        *)
            print_error "No process runner available"
            echo "Install overmind, foreman, or docker-compose"
            return 1
            ;;
    esac
}

# Start test environment
process_start_test() {
    print_info "🧪 Starting test environment..."
    
    # Check for test runners and start appropriate processes
    if [[ -f "package.json" ]]; then
        if grep -q "test:watch" package.json; then
            npm run test:watch
        elif grep -q "vitest" package.json; then
            npx vitest
        elif grep -q "jest" package.json; then
            npm test -- --watch
        else
            npm test
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "pytest.ini" ]]; then
        if command -v pytest >/dev/null 2>&1; then
            pytest --watch-fs . || pytest -f
        else
            python -m pytest
        fi
    elif [[ -f "Cargo.toml" ]]; then
        cargo watch -x test
    elif [[ -f "go.mod" ]]; then
        if command -v gotestsum >/dev/null 2>&1; then
            gotestsum --watch
        else
            go test ./... -watch
        fi
    else
        print_warning "No test configuration detected"
        echo "Create a test script or use 'dot run start' with a custom Procfile"
    fi
}

# Auto-detect development setup
process_auto_detect_dev() {
    print_info "Auto-detecting development setup..."
    
    local commands=()
    
    # Frontend development
    if [[ -f "package.json" ]]; then
        if grep -q "dev" package.json; then
            commands+=("web: npm run dev")
        elif grep -q "start" package.json; then
            commands+=("web: npm start")
        elif grep -q "serve" package.json; then
            commands+=("web: npm run serve")
        fi
        
        # Add type checking if available
        if grep -q "typescript" package.json && grep -q "tsc" package.json; then
            commands+=("typecheck: npm run typecheck -- --watch")
        fi
    fi
    
    # Backend development
    if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        if [[ -f "main.py" ]]; then
            if grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null; then
                commands+=("api: uvicorn main:app --reload --host 0.0.0.0 --port 8000")
            elif grep -q "flask" requirements.txt pyproject.toml 2>/dev/null; then
                commands+=("api: flask run --host=0.0.0.0 --port=5000 --debug")
            elif grep -q "django" requirements.txt pyproject.toml 2>/dev/null; then
                commands+=("api: python manage.py runserver 0.0.0.0:8000")
            else
                commands+=("api: python main.py")
            fi
        fi
    fi
    
    # Rust development
    if [[ -f "Cargo.toml" ]]; then
        commands+=("app: cargo watch -x run")
    fi
    
    # Go development
    if [[ -f "go.mod" ]]; then
        if [[ -f "main.go" ]]; then
            commands+=("app: go run main.go")
        fi
    fi
    
    # Database services
    if [[ -f "docker-compose.yml" ]] && grep -q "postgres\|mysql\|redis" docker-compose.yml; then
        commands+=("db: docker-compose up postgres redis")
    fi
    
    if [[ ${#commands[@]} -eq 0 ]]; then
        print_warning "Could not auto-detect development setup"
        echo "Create a Procfile or use 'dot run init' to generate one"
        return 1
    fi
    
    # Create temporary Procfile
    local temp_procfile="/tmp/Procfile.auto"
    printf '%s\n' "${commands[@]}" > "$temp_procfile"
    
    print_info "Auto-detected processes:"
    cat "$temp_procfile"
    echo ""
    
    echo -n "Start these processes? [Y/n]: "
    read -r response
    if [[ "$response" =~ ^[Yy]$|^$ ]]; then
        local runner=$(detect_process_runner)
        case "$runner" in
            "overmind")
                process_start_overmind "$temp_procfile" ""
                ;;
            "foreman")
                process_start_foreman "$temp_procfile" ""
                ;;
            *)
                print_error "No process runner available"
                return 1
                ;;
        esac
    fi
}

# Process runner implementations
process_start_overmind() {
    local procfile="$1"
    local env_file="$2"
    
    local args=("-f" "$procfile")
    
    if [[ -n "$env_file" && -f "$env_file" ]]; then
        args+=("--env" "$env_file")
    fi
    
    if command -v overmind >/dev/null 2>&1; then
        overmind start "${args[@]}"
    else
        print_error "Overmind not found. Install with: brew install overmind"
        return 1
    fi
}

process_start_foreman() {
    local procfile="$1"
    local env_file="$2"
    
    local args=("-f" "$procfile")
    
    if [[ -n "$env_file" && -f "$env_file" ]]; then
        args+=("--env" "$env_file")
    fi
    
    if command -v foreman >/dev/null 2>&1; then
        foreman start "${args[@]}"
    else
        print_error "Foreman not found. Install with: gem install foreman"
        return 1
    fi
}

process_start_docker_compose() {
    if [[ -f "docker-compose.yml" ]]; then
        docker-compose up
    elif [[ -f "docker-compose.yaml" ]]; then
        docker-compose -f docker-compose.yaml up
    else
        print_error "No docker-compose file found"
        return 1
    fi
}

# Process control
process_stop() {
    local signal="SIGTERM"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                signal="SIGKILL"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    print_info "🛑 Stopping processes..."
    
    if command -v overmind >/dev/null 2>&1 && [[ -f ".overmind.sock" ]]; then
        overmind stop
    elif pgrep -f "foreman" >/dev/null; then
        pkill -$signal -f "foreman"
    elif [[ -f "docker-compose.yml" ]]; then
        docker-compose down
    else
        print_warning "No running processes found to stop"
    fi
}

process_restart() {
    local process_name="$1"
    
    if [[ -n "$process_name" ]]; then
        if command -v overmind >/dev/null 2>&1 && [[ -f ".overmind.sock" ]]; then
            overmind restart "$process_name"
        else
            print_error "Process restart requires overmind"
            return 1
        fi
    else
        process_stop
        sleep 2
        process_start_dev
    fi
}

process_status() {
    echo "📊 Process Status:"
    echo ""
    
    # Check overmind
    if command -v overmind >/dev/null 2>&1 && [[ -f ".overmind.sock" ]]; then
        echo "Overmind Processes:"
        overmind ps
        return 0
    fi
    
    # Check foreman processes
    if pgrep -f "foreman" >/dev/null; then
        echo "Foreman Processes:"
        pgrep -fl "foreman"
        return 0
    fi
    
    # Check docker-compose
    if [[ -f "docker-compose.yml" ]]; then
        echo "Docker Compose Services:"
        docker-compose ps
        return 0
    fi
    
    echo "No managed processes running"
}

process_logs() {
    local process_name="$1"
    local follow=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --follow|-f)
                follow=true
                shift
                ;;
            *)
                process_name="$1"
                shift
                ;;
        esac
    done
    
    if command -v overmind >/dev/null 2>&1 && [[ -f ".overmind.sock" ]]; then
        if [[ -n "$process_name" ]]; then
            overmind logs "$process_name"
        else
            overmind logs
        fi
    elif [[ -f "docker-compose.yml" ]]; then
        local args=()
        if [[ "$follow" == "true" ]]; then
            args+=("-f")
        fi
        if [[ -n "$process_name" ]]; then
            docker-compose logs "${args[@]}" "$process_name"
        else
            docker-compose logs "${args[@]}"
        fi
    else
        print_error "No managed processes found"
        return 1
    fi
}

process_list() {
    echo "🔍 Active Processes:"
    echo ""
    
    # Show system processes related to development
    local dev_processes=(
        "node"
        "python"
        "cargo"
        "go run"
        "uvicorn"
        "flask"
        "django"
        "webpack"
        "vite"
        "next"
    )
    
    for proc in "${dev_processes[@]}"; do
        local pids=$(pgrep -f "$proc" 2>/dev/null || true)
        if [[ -n "$pids" ]]; then
            echo "$proc processes:"
            ps -p $pids -o pid,ppid,pcpu,pmem,etime,command
            echo ""
        fi
    done
}

# Initialize Procfile
process_init_procfile() {
    local template="${1:-auto}"
    
    if [[ -f "Procfile" ]]; then
        echo -n "Procfile already exists. Overwrite? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    case "$template" in
        "auto")
            generate_auto_procfile
            ;;
        "web")
            generate_web_procfile
            ;;
        "api")
            generate_api_procfile
            ;;
        "fullstack")
            generate_fullstack_procfile
            ;;
        "microservices")
            generate_microservices_procfile
            ;;
        *)
            print_error "Unknown template: $template"
            echo "Available templates: auto, web, api, fullstack, microservices"
            return 1
            ;;
    esac
    
    print_success "Procfile created successfully!"
    print_info "Edit Procfile to customize your processes"
    print_info "Run 'dot run dev' to start development environment"
}

generate_auto_procfile() {
    cat > Procfile << 'EOF'
# Auto-generated Procfile
# Edit this file to customize your development processes

EOF
    
    # Detect and add appropriate processes
    if [[ -f "package.json" ]]; then
        if grep -q "dev" package.json; then
            echo "web: npm run dev" >> Procfile
        elif grep -q "start" package.json; then
            echo "web: npm start" >> Procfile
        fi
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        if [[ -f "main.py" ]]; then
            echo "api: python main.py" >> Procfile
        fi
    fi
    
    if [[ -f "docker-compose.yml" ]]; then
        echo "services: docker-compose up postgres redis" >> Procfile
    fi
}

generate_fullstack_procfile() {
    cat > Procfile << 'EOF'
# Full-stack development environment
web: npm run dev
api: uvicorn main:app --reload --host 0.0.0.0 --port 8000
db: docker-compose up postgres redis
worker: celery worker -A app.celery --loglevel=info
typecheck: npm run typecheck -- --watch
EOF
}

# Utility functions
detect_process_runner() {
    if command -v overmind >/dev/null 2>&1; then
        echo "overmind"
    elif command -v foreman >/dev/null 2>&1; then
        echo "foreman"
    elif command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    else
        echo ""
    fi
}

process_list_templates() {
    echo "📋 Available Procfile Templates:"
    echo ""
    echo "  auto           - Auto-detect based on project structure"
    echo "  web            - Frontend web application"
    echo "  api            - Backend API service"
    echo "  fullstack      - Full-stack application with services"
    echo "  microservices  - Multi-service architecture"
    echo ""
    echo "Usage: dot run init <template>"
}

# Help function
show_process_help() {
    cat << 'EOF'
dot run - Development process management

USAGE:
    dot run <command> [options]

COMMANDS:
    dev                      Start development environment
    test                     Start test environment with watch mode
    prod                     Start production simulation
    start [--procfile file]  Start custom process configuration
    stop [--force]           Stop all managed processes
    restart [process]        Restart all or specific process
    status                   Show running process status
    logs [process] [-f]      Show process logs
    ps                       List active development processes
    init [template]          Initialize Procfile configuration
    templates                List available Procfile templates
    
CROSS-STACK COMMANDS:
    fullstack                Start full-stack development (frontend + backend + db)
    deploy <env>             Deploy cross-stack application
    e2e                      Start end-to-end testing environment
    stack                    Analyze current stack and suggest workflows

PROCESS RUNNERS:
    overmind                 Preferred process manager (tmux-based)
    foreman                  Ruby-based process manager
    docker-compose           Container-based process management

AUTO-DETECTION:
    Automatically detects and starts appropriate development processes:
    • Frontend: npm run dev, npm start
    • Backend: uvicorn, flask, django, cargo run, go run
    • Services: postgres, redis via docker-compose
    • Type checking: tsc --watch

OPTIONS:
    --procfile, -f <file>    Use specific Procfile
    --env <file>             Load environment variables from file
    --force                  Force stop processes
    --follow, -f             Follow log output
    -h, --help               Show this help message

PROCFILE FORMAT:
    process_name: command to run
    web: npm run dev
    api: uvicorn main:app --reload
    worker: celery worker -A app

EXAMPLES:
    dot run dev                    # Auto-detect and start development
    dot run test                   # Start test watchers
    dot run start --procfile Procfile.prod
    dot run restart web            # Restart specific process
    dot run logs api --follow      # Follow API logs
    dot run init fullstack         # Create full-stack Procfile
    dot run fullstack              # Start full-stack development
    dot run e2e                    # Run end-to-end tests
    dot run deploy staging         # Deploy to staging environment
    dot run stack                  # Analyze project stack

INSTALLATION:
    # Install overmind (recommended)
    brew install overmind
    
    # Or install foreman
    gem install foreman
EOF
}

# ============================================================================
# Cross-Stack Development Workflows
# ============================================================================

# Start full-stack development environment
process_start_fullstack() {
    print_info "🏗️ Starting full-stack development environment..."
    
    # Check for full-stack project structure
    if [[ ! -d "frontend" && ! -d "backend" ]]; then
        # Try to detect monorepo structure
        if [[ -d "packages" ]]; then
            print_info "📦 Detected monorepo structure"
            process_start_monorepo
            return $?
        elif [[ -d "apps" ]]; then
            print_info "📱 Detected apps structure"
            process_start_apps_structure
            return $?
        else
            print_warning "No full-stack structure detected"
            echo "Expected: frontend/ and backend/ directories"
            echo "Or: packages/ (monorepo) or apps/ structure"
            echo ""
            echo "Create structure with: dot project init fullstack"
            return 1
        fi
    fi
    
    local services=()
    local ports=()
    
    # Database services first
    if [[ -f "docker-compose.yml" ]]; then
        print_info "🗄️ Starting database services..."
        if docker-compose up -d postgres redis mongodb 2>/dev/null; then
            services+=("Database services")
            print_success "✅ Database services started"
        fi
    fi
    
    # Backend service
    if [[ -d "backend" ]]; then
        print_info "🔧 Starting backend service..."
        if [[ -f "backend/main.py" ]]; then
            (cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000) &
            services+=("Backend API (port 8000)")
            ports+=(8000)
        elif [[ -f "backend/package.json" ]]; then
            (cd backend && npm run dev) &
            services+=("Backend (Node.js)")
        fi
    fi
    
    # Wait a moment for backend to start
    sleep 2
    
    # Frontend service
    if [[ -d "frontend" ]]; then
        print_info "🌐 Starting frontend service..."
        if [[ -f "frontend/package.json" ]]; then
            (cd frontend && npm run dev) &
            services+=("Frontend (port 3000)")
            ports+=(3000)
        fi
    fi
    
    # Wait for services to be ready
    sleep 3
    
    print_success "🚀 Full-stack environment started!"
    echo ""
    echo "📍 Services running:"
    for service in "${services[@]}"; do
        echo "  ✅ $service"
    done
    
    echo ""
    echo "🌐 Access your application:"
    for port in "${ports[@]}"; do
        case $port in
            3000) echo "  🖥️  Frontend: http://localhost:3000" ;;
            8000) echo "  🔧 Backend API: http://localhost:8000" ;;
            *) echo "  🔗 Service: http://localhost:$port" ;;
        esac
    done
    
    # Show API docs link if backend port 8000 is present
    for p in "${ports[@]}"; do
        if [[ "$p" == "8000" ]]; then
            echo "  📚 API Docs: http://localhost:8000/docs"
            break
        fi
    done
    
    # Setup cleanup
    echo ""
    echo "Press Ctrl+C to stop all services"
    
    cleanup_fullstack() {
        echo ""
        print_info "🛑 Stopping full-stack services..."
        jobs -p | xargs kill 2>/dev/null
        if [[ -f "docker-compose.yml" ]]; then
            docker-compose stop 2>/dev/null
        fi
        print_success "✅ All services stopped"
    }
    
    trap cleanup_fullstack EXIT INT TERM
    wait
}

# Start monorepo development
process_start_monorepo() {
    print_info "📦 Starting monorepo development..."
    
    # Look for nx, lerna, or rush
    if [[ -f "nx.json" ]]; then
        print_info "Using Nx monorepo"
        npx nx run-many --target=serve --all --parallel=3
    elif [[ -f "lerna.json" ]]; then
        print_info "Using Lerna monorepo"
        npx lerna run dev --parallel
    elif [[ -f "rush.json" ]]; then
        print_info "Using Rush monorepo"
        rush build --parallelism 3
    else
        # Manual package detection
        local packages=($(find packages -name "package.json" -exec dirname {} \;))
        print_info "Found ${#packages[@]} packages"
        
        for package in "${packages[@]}"; do
            local name=$(basename "$package")
            print_info "Starting $name..."
            (cd "$package" && npm run dev 2>/dev/null || npm start 2>/dev/null) &
        done
        
        wait
    fi
}

# Start apps structure development
process_start_apps_structure() {
    print_info "📱 Starting apps development..."
    
    local apps=($(find apps -name "package.json" -exec dirname {} \; 2>/dev/null))
    
    if [[ ${#apps[@]} -eq 0 ]]; then
        print_warning "No apps found with package.json"
        return 1
    fi
    
    for app in "${apps[@]}"; do
        local name=$(basename "$app")
        print_info "Starting $name..."
        (cd "$app" && npm run dev 2>/dev/null || npm start 2>/dev/null) &
    done
    
    echo "Started ${#apps[@]} applications"
    wait
}

# Cross-stack deployment
process_deploy() {
    local environment="${1:-staging}"
    
    print_info "🚀 Deploying cross-stack application to $environment..."
    
    # Check for deployment configuration
    if [[ -f "deploy.yml" ]] || [[ -f ".github/workflows/deploy.yml" ]]; then
        print_info "Using GitHub Actions deployment"
        gh workflow run deploy.yml --ref main -f environment="$environment"
    elif [[ -f "docker-compose.prod.yml" ]]; then
        print_info "Using Docker Compose deployment"
        docker-compose -f docker-compose.prod.yml up -d
    elif [[ -f "Dockerfile" ]]; then
        print_info "Building and deploying Docker container"
        docker build -t "app:$environment" .
        # Add deployment logic here based on your infrastructure
    else
        print_warning "No deployment configuration found"
        echo "Create one of:"
        echo "  • .github/workflows/deploy.yml (GitHub Actions)"
        echo "  • docker-compose.prod.yml (Docker Compose)"
        echo "  • Dockerfile (Container deployment)"
        return 1
    fi
    
    print_success "🎉 Deployment to $environment initiated!"
}

# End-to-end testing environment
process_start_e2e() {
    print_info "🧪 Starting end-to-end testing environment..."
    
    # Start application in test mode
    if [[ -f "docker-compose.test.yml" ]]; then
        print_info "Using Docker Compose test environment"
        docker-compose -f docker-compose.test.yml up -d
        sleep 5  # Wait for services to be ready
    else
        # Start full-stack in background for testing
        process_start_fullstack &
        local fullstack_pid=$!
        sleep 10  # Wait for services to be ready
    fi
    
    # Run end-to-end tests
    if [[ -f "playwright.config.js" ]]; then
        print_info "Running Playwright E2E tests"
        npx playwright test
    elif [[ -f "cypress.config.js" ]]; then
        print_info "Running Cypress E2E tests"
        npx cypress run
    elif [[ -f "package.json" ]] && grep -q "e2e" package.json; then
        print_info "Running npm E2E tests"
        npm run e2e
    elif [[ -f "tests/e2e" ]]; then
        print_info "Running custom E2E tests"
        cd tests/e2e && npm test
    else
        print_warning "No E2E test configuration found"
        echo "Install one of:"
        echo "  • Playwright: npm install @playwright/test"
        echo "  • Cypress: npm install cypress"
        echo "  • Or create tests/e2e directory"
        return 1
    fi
    
    # Cleanup
    if [[ -n "${fullstack_pid:-}" ]]; then
        kill $fullstack_pid 2>/dev/null
    fi
    
    if [[ -f "docker-compose.test.yml" ]]; then
        docker-compose -f docker-compose.test.yml down
    fi
}

# Analyze current stack and suggest workflows
process_analyze_stack() {
    print_info "🔍 Analyzing project stack..."
    
    local stack_info=""
    local technologies=()
    local suggestions=()
    
    # Frontend technologies
    if [[ -f "package.json" ]]; then
        local frontend_deps=$(grep -E "(react|vue|angular|svelte|lit)" package.json || true)
        if [[ -n "$frontend_deps" ]]; then
            technologies+=("Frontend")
            if grep -q "react" package.json; then
                stack_info+="Frontend: React\n"
            elif grep -q "vue" package.json; then
                stack_info+="Frontend: Vue.js\n"
            elif grep -q "angular" package.json; then
                stack_info+="Frontend: Angular\n"
            elif grep -q "lit" package.json; then
                stack_info+="Frontend: Lit\n"
            fi
        fi
        
        # Build tools
        if grep -q "vite" package.json; then
            stack_info+="Build Tool: Vite\n"
        elif grep -q "webpack" package.json; then
            stack_info+="Build Tool: Webpack\n"
        fi
    fi
    
    # Backend technologies
    if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        technologies+=("Python Backend")
        if grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null; then
            stack_info+="Backend: FastAPI (Python)\n"
        elif grep -q "flask" requirements.txt pyproject.toml 2>/dev/null; then
            stack_info+="Backend: Flask (Python)\n"
        elif grep -q "django" requirements.txt pyproject.toml 2>/dev/null; then
            stack_info+="Backend: Django (Python)\n"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        technologies+=("Rust Backend")
        stack_info+="Backend: Rust\n"
    elif [[ -f "go.mod" ]]; then
        technologies+=("Go Backend")
        stack_info+="Backend: Go\n"
    fi
    
    # Database
    if [[ -f "docker-compose.yml" ]]; then
        if grep -q "postgres" docker-compose.yml; then
            technologies+=("PostgreSQL")
            stack_info+="Database: PostgreSQL\n"
        fi
        if grep -q "redis" docker-compose.yml; then
            technologies+=("Redis")
            stack_info+="Cache: Redis\n"
        fi
        if grep -q "mongodb" docker-compose.yml; then
            technologies+=("MongoDB")
            stack_info+="Database: MongoDB\n"
        fi
    fi
    
    # Mobile
    if [[ -d "ios" ]] && [[ -f "ios/*.xcodeproj" ]]; then
        technologies+=("iOS")
        stack_info+="Mobile: iOS (Swift)\n"
    fi
    
    # Display analysis
    echo "🏗️ Stack Analysis Results:"
    echo "=========================="
    echo ""
    echo "📋 Detected Technologies:"
    for tech in "${technologies[@]}"; do
        echo "  ✅ $tech"
    done
    
    echo ""
    echo "🔧 Technology Details:"
    echo -e "$stack_info"
    
    # Generate suggestions
    echo "💡 Workflow Suggestions:"
    
    has_frontend=false
    has_py_backend=false
    for t in "${technologies[@]}"; do
        [[ "$t" == "Frontend" ]] && has_frontend=true
        [[ "$t" == "Python Backend" ]] && has_py_backend=true
    done
    if $has_frontend && $has_py_backend; then
        suggestions+=("Use 'dot run fullstack' for integrated development")
        suggestions+=("Use 'dot run e2e' for end-to-end testing")
    fi
    
    has_ios=false
    has_py_backend=false
    for t in "${technologies[@]}"; do
        [[ "$t" == "iOS" ]] && has_ios=true
        [[ "$t" == "Python Backend" ]] && has_py_backend=true
    done
    if $has_ios && $has_py_backend; then
        suggestions+=("Use 'dot run dev' for mobile + API development")
        suggestions+=("Consider adding backend API versioning for mobile compatibility")
    fi
    
    if [[ -f "docker-compose.yml" ]]; then
        suggestions+=("Use 'docker-compose up -d' for isolated development")
        suggestions+=("Consider 'dot run deploy' for container-based deployment")
    fi
    
    if [[ ${#technologies[@]} -gt 2 ]]; then
        suggestions+=("Complex stack detected - consider microservices architecture")
        suggestions+=("Use 'dot project ai-analyze' for AI-powered optimization suggestions")
    fi
    
    for suggestion in "${suggestions[@]}"; do
        echo "  💡 $suggestion"
    done
    
    echo ""
    echo "🚀 Quick Actions:"
    echo "  dot run fullstack    # Start all services"
    echo "  dot run e2e          # Run end-to-end tests"
    echo "  dot run deploy       # Deploy application"
    echo "  dot project ai-analyze  # Get AI suggestions"
}