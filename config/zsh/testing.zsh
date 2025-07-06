# =============================================================================
# Testing Configuration
# Modern testing framework aliases, functions, and utilities
# =============================================================================

# Only load if in development environment
[[ -z "$DOTFILES_MINIMAL" ]] || return 0

# =============================================================================
# Testing Tool Aliases
# =============================================================================

# API Testing with Bruno
if command -v bruno &> /dev/null; then
    alias bt="bruno"
    alias bt-run="bruno run"
    alias bt-env="bruno env"
    alias bt-new="bruno new"
    alias bt-test="bruno test"
fi

# E2E Testing with Playwright
if command -v bun &> /dev/null && [[ -n "$(bun pm ls -g 2>/dev/null | grep @playwright/test)" ]]; then
    alias pw="bunx playwright"
    alias pw-test="bunx playwright test"
    alias pw-ui="bunx playwright test --ui"
    alias pw-debug="bunx playwright test --debug"
    alias pw-report="bunx playwright show-report"
    alias pw-install="bunx playwright install"
    alias pw-codegen="bunx playwright codegen"
    alias pw-trace="bunx playwright trace"
fi

# Enhanced Python Testing
if command -v pytest &> /dev/null; then
    alias pt="pytest"
    alias pt-cov="pytest --cov --cov-report=html"
    alias pt-watch="pytest-watch"
    alias pt-parallel="pytest -n auto"
    alias pt-benchmark="pytest --benchmark-only"
    alias pt-fast="pytest -x --tb=short"
    alias pt-verbose="pytest -vvs"
    alias pt-failed="pytest --lf"
    alias pt-new="pytest --ff"
fi

# Load Testing with k6
if command -v k6 &> /dev/null; then
    alias k6-run="k6 run"
    alias k6-cloud="k6 cloud"
    alias k6-archive="k6 archive"
    alias k6-inspect="k6 inspect"
    alias k6-status="k6 status"
fi

# Swift Testing
if command -v swift &> /dev/null; then
    alias swift-test="swift test"
    alias swift-test-parallel="swift test --parallel"
    alias swift-test-verbose="swift test --verbose"
fi

if command -v xcodebuild &> /dev/null; then
    alias xcode-test="xcodebuild test"
    alias xcode-test-sim="xcodebuild test -destination 'platform=iOS Simulator,name=iPhone 15'"
fi

# =============================================================================
# Testing Functions
# =============================================================================

# Initialize testing for current project
function testing-init() {
    local project_type="${1:-auto}"
    
    echo "🧪 Initializing testing environment..."
    
    # Auto-detect project type
    if [[ "$project_type" == "auto" ]]; then
        if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then
            project_type="python"
        elif [[ -f "package.json" ]]; then
            project_type="javascript"
        elif [[ -f "Package.swift" ]] || [[ -f "*.xcodeproj" ]]; then
            project_type="swift"
        elif [[ -f "Cargo.toml" ]]; then
            project_type="rust"
        else
            echo "❓ Could not detect project type. Please specify: python, javascript, swift, rust"
            return 1
        fi
    fi
    
    echo "📁 Detected project type: $project_type"
    
    case "$project_type" in
        "python")
            testing-init-python
            ;;
        "javascript")
            testing-init-javascript
            ;;
        "swift")
            testing-init-swift
            ;;
        "rust")
            testing-init-rust
            ;;
        *)
            echo "❌ Unsupported project type: $project_type"
            return 1
            ;;
    esac
}

# Initialize Python testing
function testing-init-python() {
    echo "🐍 Setting up Python testing environment..."
    
    # Check if we have a virtual environment or uv project
    if [[ -f "pyproject.toml" ]] && command -v uv &> /dev/null; then
        echo "📦 Installing Python testing dependencies with uv..."
        uv add --dev pytest pytest-asyncio pytest-cov pytest-mock pytest-xdist pytest-benchmark pytest-watch httpx factory-boy freezegun
    elif [[ -f "requirements.txt" ]] || [[ -f "setup.py" ]]; then
        echo "📦 Installing Python testing dependencies with pip..."
        pip install pytest pytest-asyncio pytest-cov pytest-mock pytest-xdist pytest-benchmark pytest-watch httpx factory-boy freezegun
    fi
    
    # Create basic test structure
    mkdir -p tests
    [[ ! -f "tests/__init__.py" ]] && touch "tests/__init__.py"
    
    # Create pytest configuration
    if [[ ! -f "pytest.ini" ]] && [[ ! -f "pyproject.toml" ]]; then
        cat > pytest.ini << 'EOF'
[tool:pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = --strict-markers --strict-config --cov --cov-report=term-missing
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
EOF
    fi
    
    # Create sample test files based on detected frameworks
    if [[ -f "main.py" ]] && grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
        testing-create-fastapi-tests
    fi
    
    echo "✅ Python testing environment ready!"
    echo "📝 Run 'pt' to start testing"
}

# Initialize JavaScript/TypeScript testing
function testing-init-javascript() {
    echo "📦 Setting up JavaScript/TypeScript testing environment..."
    
    if command -v bun &> /dev/null; then
        echo "📦 Installing Playwright with bun..."
        bun add -D @playwright/test
        
        # Create basic playwright config
        if [[ ! -f "playwright.config.ts" ]] && [[ ! -f "playwright.config.js" ]]; then
            cat > playwright.config.ts << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
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
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF
        fi
        
        # Create test directory and sample test
        mkdir -p tests
        if [[ ! -f "tests/example.spec.ts" ]]; then
            cat > tests/example.spec.ts << 'EOF'
import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/.*?/);
});
EOF
        fi
        
        echo "📝 Installing Playwright browsers (this may take a while)..."
        bunx playwright install --with-deps chromium
    fi
    
    echo "✅ JavaScript testing environment ready!"
    echo "📝 Run 'pw-test' to start testing"
}

# Initialize Swift testing
function testing-init-swift() {
    echo "🍎 Setting up Swift testing environment..."
    
    # Create Tests directory if it doesn't exist
    mkdir -p Tests
    
    # Add testing dependencies to Package.swift if it exists
    if [[ -f "Package.swift" ]]; then
        echo "📦 Swift testing dependencies should be added to Package.swift manually"
        echo "🔗 Consider adding: swift-testing, ViewInspector, swift-snapshot-testing"
    fi
    
    echo "✅ Swift testing environment ready!"
    echo "📝 Run 'swift-test' to start testing"
}

# Create FastAPI test templates
function testing-create-fastapi-tests() {
    echo "🚀 Creating FastAPI test templates..."
    
    cat > tests/test_main.py << 'EOF'
import pytest
from fastapi.testclient import TestClient
from httpx import AsyncClient

# Import your FastAPI app here
# from main import app

# client = TestClient(app)

@pytest.mark.asyncio
async def test_read_main():
    """Test the main endpoint."""
    # async with AsyncClient(app=app, base_url="http://test") as ac:
    #     response = await ac.get("/")
    # assert response.status_code == 200
    pass

def test_read_main_sync():
    """Test the main endpoint synchronously."""
    # response = client.get("/")
    # assert response.status_code == 200
    pass
EOF

    cat > tests/conftest.py << 'EOF'
import pytest
from fastapi.testclient import TestClient
from httpx import AsyncClient

# Import your FastAPI app and dependencies here
# from main import app
# from database import get_db

@pytest.fixture
def client():
    """Test client fixture."""
    # return TestClient(app)
    pass

@pytest.fixture
async def async_client():
    """Async test client fixture."""
    # async with AsyncClient(app=app, base_url="http://test") as ac:
    #     yield ac
    pass

@pytest.fixture
def db_session():
    """Database session fixture for testing."""
    # Create test database session
    # Yield session
    # Clean up
    pass
EOF
}

# Run comprehensive test suite for current project
function test-all() {
    echo "🧪 Running comprehensive test suite..."
    
    local exit_code=0
    
    # Python tests
    if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] || [[ -d "tests" ]] && command -v pytest &> /dev/null; then
        echo "🐍 Running Python tests..."
        pytest --cov --cov-report=term-missing
        exit_code=$((exit_code + $?))
    fi
    
    # JavaScript/TypeScript tests
    if [[ -f "playwright.config.ts" ]] || [[ -f "playwright.config.js" ]] && command -v bun &> /dev/null; then
        echo "🌐 Running Playwright tests..."
        bunx playwright test
        exit_code=$((exit_code + $?))
    fi
    
    # Swift tests
    if [[ -f "Package.swift" ]] && command -v swift &> /dev/null; then
        echo "🍎 Running Swift tests..."
        swift test
        exit_code=$((exit_code + $?))
    fi
    
    # Rust tests
    if [[ -f "Cargo.toml" ]] && command -v cargo &> /dev/null; then
        echo "🦀 Running Rust tests..."
        cargo test
        exit_code=$((exit_code + $?))
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        echo "✅ All tests passed!"
    else
        echo "❌ Some tests failed (exit code: $exit_code)"
    fi
    
    return $exit_code
}

# Generate comprehensive test report
function test-report() {
    echo "📊 Generating test report..."
    
    local report_dir="test-reports"
    mkdir -p "$report_dir"
    
    # Python coverage report
    if command -v pytest &> /dev/null && [[ -d "tests" ]]; then
        echo "📈 Generating Python coverage report..."
        pytest --cov --cov-report=html:"$report_dir/python-coverage"
        pytest --cov --cov-report=json:"$report_dir/python-coverage.json"
    fi
    
    # Playwright report
    if command -v bun &> /dev/null && [[ -f "playwright.config.ts" ]]; then
        echo "🎭 Generating Playwright report..."
        bunx playwright test --reporter=html
        [[ -d "playwright-report" ]] && cp -r "playwright-report" "$report_dir/"
    fi
    
    echo "📋 Test reports generated in: $report_dir"
    echo "🌐 Open reports:"
    [[ -f "$report_dir/python-coverage/index.html" ]] && echo "  Python: file://$PWD/$report_dir/python-coverage/index.html"
    [[ -f "$report_dir/playwright-report/index.html" ]] && echo "  Playwright: file://$PWD/$report_dir/playwright-report/index.html"
}

# Test specific file or pattern
function test-file() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "❌ Please specify a file to test"
        return 1
    fi
    
    # Determine test type based on file extension
    case "${file##*.}" in
        "py")
            pytest "$file" -v
            ;;
        "ts"|"js")
            bunx playwright test "$file"
            ;;
        "swift")
            swift test --filter "${file%.*}"
            ;;
        "rs")
            cargo test "${file%.*}"
            ;;
        *)
            echo "❓ Unknown test file type: $file"
            return 1
            ;;
    esac
}

# Watch tests and re-run on changes
function test-watch() {
    local pattern="${1:-.}"
    
    echo "👀 Watching for changes in: $pattern"
    
    if command -v pytest-watch &> /dev/null; then
        pytest-watch --runner "pytest -x --tb=short"
    elif command -v watchexec &> /dev/null; then
        watchexec -e py,js,ts -r "test-all"
    else
        echo "❌ No watch tool available. Install pytest-watch or watchexec"
        return 1
    fi
}

# Performance and load testing
function test-load() {
    local script="${1:-loadtest.js}"
    
    if [[ ! -f "$script" ]]; then
        echo "📝 Creating basic load test script: $script"
        cat > "$script" << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 20 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  let response = http.get('http://localhost:8000/');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
EOF
        echo "✅ Created basic load test script"
        echo "📝 Edit $script to customize your load test"
    fi
    
    if command -v k6 &> /dev/null; then
        echo "🚀 Running load test..."
        k6 run "$script"
    else
        echo "❌ k6 not installed. Install with: brew install k6"
        return 1
    fi
}

# =============================================================================
# Testing Utilities
# =============================================================================

# Show testing status and available tools
function testing-status() {
    echo "🧪 Testing Environment Status"
    echo "============================="
    
    # Check available testing tools
    echo "\n📋 Available Testing Tools:"
    command -v bruno &> /dev/null && echo "  ✅ Bruno (API testing) - $(bruno --version 2>/dev/null || echo 'installed')"
    command -v bun &> /dev/null && [[ -n "$(bun pm ls -g 2>/dev/null | grep @playwright/test)" ]] && echo "  ✅ Playwright (E2E testing) - $(bunx playwright --version 2>/dev/null || echo 'installed')"
    command -v pytest &> /dev/null && echo "  ✅ Pytest (Python testing) - $(pytest --version 2>/dev/null | head -1)"
    command -v k6 &> /dev/null && echo "  ✅ k6 (Load testing) - $(k6 version --quiet 2>/dev/null || echo 'installed')"
    command -v swift &> /dev/null && echo "  ✅ Swift Testing - $(swift --version 2>/dev/null | head -1)"
    
    # Check project-specific test setups
    echo "\n📁 Current Project Testing:"
    [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] && echo "  🐍 Python testing configured"
    [[ -f "playwright.config.ts" ]] || [[ -f "playwright.config.js" ]] && echo "  🎭 Playwright testing configured"
    [[ -f "Package.swift" ]] && echo "  🍎 Swift testing available"
    [[ -f "Cargo.toml" ]] && echo "  🦀 Rust testing available"
    [[ -d "tests" ]] && echo "  📂 Tests directory exists ($(find tests -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.swift" -o -name "*.rs" | wc -l | tr -d ' ') test files)"
    
    echo "\n🔧 Quick Commands:"
    echo "  testing-init [type]  Initialize testing for project"
    echo "  test-all            Run all tests"
    echo "  test-report         Generate comprehensive test report"
    echo "  test-watch          Watch and re-run tests on changes"
    echo "  test-load [script]  Run load tests with k6"
}

# Clean up test artifacts
function test-clean() {
    echo "🧹 Cleaning up test artifacts..."
    
    # Python
    [[ -d ".pytest_cache" ]] && rm -rf .pytest_cache && echo "  🐍 Cleaned pytest cache"
    [[ -d "htmlcov" ]] && rm -rf htmlcov && echo "  📊 Cleaned Python coverage reports"
    [[ -f ".coverage" ]] && rm -f .coverage && echo "  📈 Cleaned coverage data"
    
    # Playwright
    [[ -d "playwright-report" ]] && rm -rf playwright-report && echo "  🎭 Cleaned Playwright reports"
    [[ -d "test-results" ]] && rm -rf test-results && echo "  📸 Cleaned Playwright test results"
    
    # General
    [[ -d "test-reports" ]] && rm -rf test-reports && echo "  📋 Cleaned test reports"
    
    echo "✅ Test cleanup complete"
}

# =============================================================================
# Completion and Help
# =============================================================================

# Auto-completion for testing functions
if [[ -n "$ZSH_VERSION" ]] && command -v compdef >/dev/null 2>&1; then
    compdef '_files -g "*.py"' test-file 2>/dev/null || true
    compdef '_files -g "*.js"' test-load 2>/dev/null || true
fi

# =============================================================================
# Load Testing Tools (conditional)
# =============================================================================

# Only load if tools are installed and not in minimal mode
[[ -z "$DOTFILES_FAST_MODE" ]] || return 0

# Source any additional testing configurations
[[ -f "$HOME/.config/testing/custom.zsh" ]] && source "$HOME/.config/testing/custom.zsh"

# Testing environment ready message
if [[ -n "$DOTFILES_VERBOSE" ]]; then
    echo "🧪 Testing framework loaded - run 'testing-status' for details"
fi