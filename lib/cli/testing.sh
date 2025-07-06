#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Testing Module
# Comprehensive testing framework integration
# ============================================================================

# Colors and emojis for consistent output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SUCCESS="✅"
ERROR="❌"
INFO="ℹ️"
TEST="🧪"
ROCKET="🚀"
GEAR="⚙️"

# Utility functions
print_success() { echo -e "${GREEN}${SUCCESS} $1${NC}"; }
print_error() { echo -e "${RED}${ERROR} $1${NC}"; }
print_info() { echo -e "${BLUE}${INFO} $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Main testing command dispatcher
dot_testing() {
    local subcommand="${1:-help}"
    
    case "$subcommand" in
        "help"|"-h"|"--help")
            show_testing_help
            ;;
        "run")
            shift
            run_tests "$@"
            ;;
        "quick")
            shift
            run_quick_tests "$@"
            ;;
        "infrastructure"|"infra")
            shift
            run_infrastructure_tests "$@"
            ;;
        "security")
            shift
            run_security_tests "$@"
            ;;
        "performance"|"perf")
            shift
            run_performance_tests "$@"
            ;;
        "watch")
            shift
            watch_tests "$@"
            ;;
        "coverage")
            shift
            generate_coverage "$@"
            ;;
        "report")
            shift
            generate_test_report "$@"
            ;;
        "init")
            shift
            initialize_project_testing "$@"
            ;;
        "setup")
            shift
            setup_testing_environment "$@"
            ;;
        "benchmark")
            shift
            run_benchmarks "$@"
            ;;
        *)
            print_error "Unknown testing command: $subcommand"
            echo ""
            show_testing_help
            exit 1
            ;;
    esac
}

# Help system
show_testing_help() {
    cat << 'EOF'
🧪 DOT CLI - Testing Module

USAGE:
    dot testing <command> [options]

COMMANDS:
    run [category]           Run comprehensive test suite
    quick                   Run quick tests only
    infrastructure          Run infrastructure tests
    security               Run security validation tests
    performance            Run performance tests
    watch [pattern]        Watch and auto-run tests
    coverage               Generate test coverage report
    report                 Generate comprehensive test report
    init [framework]       Initialize testing for project
    setup                  Setup testing environment
    benchmark              Run performance benchmarks

CATEGORIES:
    all                    Run all test categories
    unit                   Unit tests only
    integration           Integration tests only
    e2e                   End-to-end tests only
    api                   API tests only

FRAMEWORKS:
    pytest                Python testing with pytest
    playwright            Browser testing with Playwright
    bruno                 API testing with Bruno
    k6                    Load testing with k6
    jest                  JavaScript testing with Jest

OPTIONS:
    --verbose             Verbose output
    --parallel           Run tests in parallel
    --watch              Watch mode
    --coverage           Generate coverage
    --timeout <seconds>  Set timeout
    --filter <pattern>   Filter tests by pattern
    --dry-run           Show what would be tested

EXAMPLES:
    dot testing run                    # Run all tests
    dot testing quick                  # Quick smoke tests
    dot testing infrastructure        # Infrastructure tests
    dot testing watch --filter api    # Watch API tests
    dot testing init pytest           # Setup pytest
    dot testing benchmark             # Performance benchmarks
    dot testing report --coverage     # Full report with coverage

EOF
}

# Core testing functions
run_tests() {
    local category="${1:-all}"
    local options=()
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                options+=("--verbose")
                shift
                ;;
            --parallel|-p)
                options+=("--parallel")
                shift
                ;;
            --coverage|-c)
                options+=("--coverage")
                shift
                ;;
            --timeout)
                options+=("--timeout" "$2")
                shift 2
                ;;
            --filter)
                options+=("--filter" "$2")
                shift 2
                ;;
            --dry-run)
                options+=("--dry-run")
                shift
                ;;
            *)
                category="$1"
                shift
                ;;
        esac
    done
    
    print_info "Running tests: $category"
    
    case "$category" in
        "all")
            run_all_tests "${options[@]}"
            ;;
        "unit")
            run_unit_tests "${options[@]}"
            ;;
        "integration")
            run_integration_tests "${options[@]}"
            ;;
        "e2e")
            run_e2e_tests "${options[@]}"
            ;;
        "api")
            run_api_tests "${options[@]}"
            ;;
        *)
            print_error "Unknown test category: $category"
            exit 1
            ;;
    esac
}

run_all_tests() {
    print_info "Running comprehensive test suite..."
    
    # Run dotfiles infrastructure tests
    if [[ -f "$DOTFILES_DIR/tests/test_runner.sh" ]]; then
        print_info "Running dotfiles infrastructure tests..."
        "$DOTFILES_DIR/tests/test_runner.sh" "$@"
    fi
    
    # Run project tests if in a project
    run_project_tests "$@"
    
    print_success "All tests completed!"
}

run_quick_tests() {
    print_info "Running quick test suite..."
    
    # Quick infrastructure tests
    if [[ -f "$DOTFILES_DIR/tests/infrastructure/test_installation.sh" ]]; then
        timeout 30 "$DOTFILES_DIR/tests/infrastructure/test_installation.sh" || true
    fi
    
    # Quick project tests
    if [[ -f "package.json" ]]; then
        npm test -- --passWithNoTests || true
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        python -m pytest --maxfail=1 -q || true
    elif [[ -f "Cargo.toml" ]]; then
        cargo test --quiet || true
    fi
    
    print_success "Quick tests completed!"
}

run_infrastructure_tests() {
    print_info "Running infrastructure tests..."
    
    if [[ -f "$DOTFILES_DIR/tests/test_runner.sh" ]]; then
        "$DOTFILES_DIR/tests/test_runner.sh" --category infrastructure "$@"
    else
        print_warning "Infrastructure test runner not found"
    fi
}

run_security_tests() {
    print_info "Running security tests..."
    
    # Run security scan
    if command -v semgrep >/dev/null 2>&1; then
        semgrep --config=auto .
    fi
    
    # Run dependency security check
    if [[ -f "package.json" ]]; then
        npm audit || true
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        if command -v safety >/dev/null 2>&1; then
            safety check || true
        fi
    fi
    
    print_success "Security tests completed!"
}

run_performance_tests() {
    print_info "Running performance tests..."
    
    # Run load tests if k6 is available
    if command -v k6 >/dev/null 2>&1 && [[ -f "tests/load/basic.js" ]]; then
        k6 run tests/load/basic.js
    fi
    
    # Run performance benchmarks
    run_benchmarks "$@"
    
    print_success "Performance tests completed!"
}

run_project_tests() {
    print_info "Detecting and running project tests..."
    
    # Detect project type and run appropriate tests
    if [[ -f "package.json" ]]; then
        run_javascript_tests "$@"
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        run_python_tests "$@"
    elif [[ -f "Cargo.toml" ]]; then
        run_rust_tests "$@"
    elif [[ -f "go.mod" ]]; then
        run_go_tests "$@"
    elif [[ -f "composer.json" ]]; then
        run_php_tests "$@"
    else
        print_info "No recognized project structure for testing"
    fi
}

run_javascript_tests() {
    print_info "Running JavaScript/TypeScript tests..."
    
    if command -v bun >/dev/null 2>&1 && [[ -f "bun.lockb" ]]; then
        bun test "$@"
    elif [[ -f "package.json" ]]; then
        if npm run test --if-present; then
            print_success "JavaScript tests passed"
        else
            print_warning "JavaScript tests failed or not configured"
        fi
    fi
    
    # Run Playwright tests if available
    if [[ -d "tests/e2e" ]] || [[ -d "e2e" ]]; then
        if command -v bunx >/dev/null 2>&1; then
            bunx playwright test || true
        elif command -v npx >/dev/null 2>&1; then
            npx playwright test || true
        fi
    fi
}

run_python_tests() {
    print_info "Running Python tests..."
    
    if command -v uv >/dev/null 2>&1; then
        uv run pytest "$@" || true
    elif command -v pytest >/dev/null 2>&1; then
        pytest "$@" || true
    elif [[ -f "manage.py" ]]; then
        python manage.py test || true
    else
        python -m unittest discover || true
    fi
}

run_rust_tests() {
    print_info "Running Rust tests..."
    cargo test "$@"
}

run_go_tests() {
    print_info "Running Go tests..."
    go test ./... "$@"
}

run_php_tests() {
    print_info "Running PHP tests..."
    
    if [[ -f "vendor/bin/phpunit" ]]; then
        vendor/bin/phpunit "$@"
    elif command -v phpunit >/dev/null 2>&1; then
        phpunit "$@"
    fi
}

run_unit_tests() {
    print_info "Running unit tests..."
    
    if [[ -f "package.json" ]]; then
        npm run test:unit --if-present || npm test -- --testPathPattern=unit || true
    elif command -v pytest >/dev/null 2>&1; then
        pytest tests/unit/ "$@" || true
    fi
}

run_integration_tests() {
    print_info "Running integration tests..."
    
    if [[ -f "package.json" ]]; then
        npm run test:integration --if-present || npm test -- --testPathPattern=integration || true
    elif command -v pytest >/dev/null 2>&1; then
        pytest tests/integration/ "$@" || true
    fi
}

run_e2e_tests() {
    print_info "Running end-to-end tests..."
    
    # Playwright E2E tests
    if [[ -d "tests/e2e" ]] || [[ -d "e2e" ]]; then
        if command -v bunx >/dev/null 2>&1; then
            bunx playwright test "$@"
        elif command -v npx >/dev/null 2>&1; then
            npx playwright test "$@"
        fi
    fi
    
    # Cypress tests
    if [[ -d "cypress" ]]; then
        npx cypress run "$@" || true
    fi
}

run_api_tests() {
    print_info "Running API tests..."
    
    # Bruno API tests
    if [[ -d "tests/api" ]] && command -v bruno >/dev/null 2>&1; then
        bruno run tests/api/ || true
    fi
    
    # Postman/Newman tests
    if [[ -f "postman_collection.json" ]] && command -v newman >/dev/null 2>&1; then
        newman run postman_collection.json || true
    fi
}

# Testing environment setup
setup_testing_environment() {
    print_info "Setting up testing environment..."
    
    # Install testing dependencies based on project type
    if [[ -f "package.json" ]]; then
        setup_javascript_testing
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        setup_python_testing
    fi
    
    print_success "Testing environment setup completed!"
}

setup_javascript_testing() {
    print_info "Setting up JavaScript testing..."
    
    if command -v bun >/dev/null 2>&1; then
        bun add -d jest @types/jest
        bun add -d @playwright/test
    else
        npm install --save-dev jest @types/jest
        npm install --save-dev @playwright/test
    fi
}

setup_python_testing() {
    print_info "Setting up Python testing..."
    
    if command -v uv >/dev/null 2>&1; then
        uv add --dev pytest pytest-asyncio pytest-cov pytest-mock
        uv add --dev playwright
    else
        pip install pytest pytest-asyncio pytest-cov pytest-mock
        pip install playwright
    fi
}

initialize_project_testing() {
    local framework="${1:-auto}"
    
    print_info "Initializing project testing with: $framework"
    
    case "$framework" in
        "auto")
            detect_and_init_testing
            ;;
        "pytest")
            init_pytest_testing
            ;;
        "playwright")
            init_playwright_testing
            ;;
        "bruno")
            init_bruno_testing
            ;;
        "k6")
            init_k6_testing
            ;;
        "jest")
            init_jest_testing
            ;;
        *)
            print_error "Unknown testing framework: $framework"
            exit 1
            ;;
    esac
}

detect_and_init_testing() {
    if [[ -f "package.json" ]]; then
        init_jest_testing
        init_playwright_testing
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        init_pytest_testing
    fi
    
    # Always setup API testing
    init_bruno_testing
}

init_pytest_testing() {
    print_info "Initializing pytest testing..."
    
    mkdir -p tests/{unit,integration,fixtures}
    
    cat > tests/conftest.py << 'EOF'
"""Pytest configuration and fixtures."""
import pytest
import asyncio
from typing import Generator


@pytest.fixture(scope="session")
def event_loop() -> Generator[asyncio.AbstractEventLoop, None, None]:
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def mock_env(monkeypatch):
    """Mock environment variables."""
    test_vars = {
        "ENVIRONMENT": "test",
        "DEBUG": "true",
    }
    for key, value in test_vars.items():
        monkeypatch.setenv(key, value)
EOF
    
    cat > tests/unit/test_example.py << 'EOF'
"""Example unit tests."""
import pytest


def test_example():
    """Example test case."""
    assert True


@pytest.mark.asyncio
async def test_async_example():
    """Example async test case."""
    assert True
EOF
    
    print_success "Pytest testing initialized!"
}

init_playwright_testing() {
    print_info "Initializing Playwright testing..."
    
    mkdir -p tests/e2e
    
    cat > tests/e2e/example.spec.js << 'EOF'
import { test, expect } from '@playwright/test';

test('homepage loads', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Home/);
});
EOF
    
    cat > playwright.config.js << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://127.0.0.1:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://127.0.0.1:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF
    
    print_success "Playwright testing initialized!"
}

init_bruno_testing() {
    print_info "Initializing Bruno API testing..."
    
    mkdir -p tests/api/auth tests/api/users
    
    cat > tests/api/bruno.json << 'EOF'
{
  "version": "1",
  "name": "API Tests",
  "type": "collection",
  "ignore": [
    "node_modules",
    ".git"
  ]
}
EOF
    
    cat > tests/api/auth/login.bru << 'EOF'
meta {
  name: Login
  type: http
  seq: 1
}

post {
  url: {{baseUrl}}/auth/login
  body: json
  auth: none
}

body:json {
  {
    "email": "test@example.com",
    "password": "password123"
  }
}

tests {
  test("should return 200", function() {
    expect(res.getStatus()).to.equal(200);
  });
  
  test("should return access token", function() {
    expect(res.getBody().access_token).to.be.a('string');
  });
}
EOF
    
    print_success "Bruno API testing initialized!"
}

init_k6_testing() {
    print_info "Initializing k6 load testing..."
    
    mkdir -p tests/load
    
    cat > tests/load/basic.js << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10, // 10 virtual users
  duration: '30s',
};

export default function () {
  const response = http.get('http://localhost:3000');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
EOF
    
    print_success "k6 load testing initialized!"
}

init_jest_testing() {
    print_info "Initializing Jest testing..."
    
    mkdir -p tests/{unit,integration}
    
    cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js', '**/tests/**/*.spec.js'],
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/index.js',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
};
EOF
    
    cat > tests/unit/example.test.js << 'EOF'
describe('Example Test Suite', () => {
  test('should pass', () => {
    expect(true).toBe(true);
  });
  
  test('should handle async operations', async () => {
    const result = await Promise.resolve('success');
    expect(result).toBe('success');
  });
});
EOF
    
    print_success "Jest testing initialized!"
}

# Watch mode
watch_tests() {
    local pattern="${1:-}"
    
    print_info "Starting test watch mode..."
    
    if [[ -f "package.json" ]]; then
        if command -v bun >/dev/null 2>&1; then
            bun test --watch "$pattern"
        else
            npm run test:watch --if-present || npm test -- --watch "$pattern"
        fi
    elif command -v pytest >/dev/null 2>&1; then
        if command -v pytest-watch >/dev/null 2>&1; then
            ptw -- "$pattern"
        else
            print_warning "Install pytest-watch for watch mode: pip install pytest-watch"
        fi
    fi
}

# Coverage and reporting
generate_coverage() {
    print_info "Generating test coverage..."
    
    if [[ -f "package.json" ]]; then
        npm run test:coverage --if-present || npm test -- --coverage
    elif command -v pytest >/dev/null 2>&1; then
        pytest --cov=. --cov-report=html --cov-report=term
    fi
    
    print_success "Coverage report generated!"
}

generate_test_report() {
    print_info "Generating comprehensive test report..."
    
    local report_dir="test-reports"
    mkdir -p "$report_dir"
    
    # Run tests with reporting
    if [[ -f "package.json" ]]; then
        npm test -- --reporter=json > "$report_dir/test-results.json" || true
    elif command -v pytest >/dev/null 2>&1; then
        pytest --junitxml="$report_dir/pytest.xml" --html="$report_dir/report.html" || true
    fi
    
    print_success "Test report generated in $report_dir/"
}

# Benchmarking
run_benchmarks() {
    print_info "Running performance benchmarks..."
    
    # Benchmark shell startup time
    benchmark_shell_startup
    
    # Benchmark dotfiles operations
    benchmark_dotfiles_operations
    
    # Project-specific benchmarks
    if [[ -f "package.json" ]]; then
        benchmark_javascript_project
    elif [[ -f "pyproject.toml" ]]; then
        benchmark_python_project
    fi
    
    print_success "Benchmarks completed!"
}

benchmark_shell_startup() {
    print_info "Benchmarking shell startup time..."
    
    local total_time=0
    local iterations=5
    
    for i in $(seq 1 $iterations); do
        local start_time=$(date +%s%N)
        zsh -i -c exit
        local end_time=$(date +%s%N)
        local time_ms=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + time_ms))
        echo "  Iteration $i: ${time_ms}ms"
    done
    
    local avg_time=$((total_time / iterations))
    echo "  Average startup time: ${avg_time}ms"
    
    if [[ $avg_time -lt 1000 ]]; then
        print_success "Shell startup time is excellent (<1s)"
    elif [[ $avg_time -lt 2000 ]]; then
        print_info "Shell startup time is good (<2s)"
    else
        print_warning "Shell startup time is slow (>2s) - consider optimization"
    fi
}

benchmark_dotfiles_operations() {
    print_info "Benchmarking dotfiles operations..."
    
    # Benchmark health check
    if [[ -f "$DOTFILES_DIR/scripts/health-check.sh" ]]; then
        local start_time=$(date +%s%N)
        "$DOTFILES_DIR/scripts/health-check.sh" >/dev/null 2>&1 || true
        local end_time=$(date +%s%N)
        local time_ms=$(( (end_time - start_time) / 1000000 ))
        echo "  Health check: ${time_ms}ms"
    fi
    
    # Benchmark installer dry run
    if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
        local start_time=$(date +%s%N)
        "$DOTFILES_DIR/install.sh" --dry-run profiles >/dev/null 2>&1 || true
        local end_time=$(date +%s%N)
        local time_ms=$(( (end_time - start_time) / 1000000 ))
        echo "  Installer dry-run: ${time_ms}ms"
    fi
}

benchmark_javascript_project() {
    print_info "Benchmarking JavaScript project..."
    
    if command -v bun >/dev/null 2>&1; then
        echo "  Build time:"
        time bun run build >/dev/null 2>&1 || true
        
        echo "  Test time:"
        time bun test >/dev/null 2>&1 || true
    fi
}

benchmark_python_project() {
    print_info "Benchmarking Python project..."
    
    if command -v pytest >/dev/null 2>&1; then
        echo "  Test time:"
        time pytest --tb=no -q >/dev/null 2>&1 || true
    fi
}

# Export functions for direct use
export -f dot_testing