# 🧪 **Testing Frameworks Guide**

Your development environment now includes comprehensive testing capabilities for modern web development with **FastAPI**, **Lit PWA**, and **SwiftUI**.

## 🚀 **Quick Start**

### **Check Testing Status**
```bash
testing-status
```

### **Initialize Testing for Your Project**
```bash
# Auto-detect project type and setup testing
testing-init

# Or specify project type
testing-init python    # FastAPI/Python projects
testing-init javascript # Lit PWA/JavaScript projects
testing-init swift     # SwiftUI projects
```

### **Run All Tests**
```bash
test-all
```

## 🛠️ **Testing Tools Overview**

### **🌐 Bruno - API Testing**
Modern, Git-friendly API testing tool for FastAPI backends.

**Key Features:**
- ✅ **Git-friendly** - Text-based collections, version control ready
- ✅ **CLI support** - Scriptable and CI/CD friendly  
- ✅ **No cloud dependency** - Works offline
- ✅ **Modern UI** - Better UX than Postman
- ✅ **Environment management** - Dev/staging/prod configs

**Quick Commands:**
```bash
# Open Bruno interface
bt

# Run collection from CLI
bt-run my-collection.json

# Switch environment
bt-env development
```

### **🎭 Playwright - E2E Testing**
Modern web testing framework for Lit PWA applications.

**Key Features:**
- ✅ **Multi-browser support** - Chromium, Firefox, Safari
- ✅ **Auto-wait** - No flaky tests from timing issues
- ✅ **TypeScript first** - Better DX for modern frontends
- ✅ **Built-in debugging** - Screenshots, videos, traces
- ✅ **Mobile testing** - PWA compatibility

**Quick Commands:**
```bash
# Run tests
pw-test

# Run with UI mode
pw-ui

# Debug specific test
pw-debug test-file.spec.ts

# Generate test code
pw-codegen localhost:3000
```

### **🐍 Pytest Enhanced - Python Testing**
Comprehensive Python testing setup optimized for FastAPI.

**Included Packages:**
- ✅ **pytest-asyncio** - Async test support
- ✅ **pytest-cov** - Coverage reporting
- ✅ **pytest-mock** - Mocking utilities
- ✅ **pytest-xdist** - Parallel execution
- ✅ **pytest-benchmark** - Performance testing
- ✅ **httpx** - Async HTTP client for API testing

**Quick Commands:**
```bash
# Run tests with coverage
pt-cov

# Watch mode (re-run on changes)
pt-watch

# Run tests in parallel
pt-parallel

# Benchmark tests only
pt-benchmark
```

### **⚡ k6 - Load Testing**
Modern load testing tool for API performance validation.

**Key Features:**
- ✅ **JavaScript DSL** - Familiar syntax
- ✅ **Developer-friendly** - Code-based scenarios
- ✅ **Modern protocols** - HTTP/2, WebSockets, gRPC
- ✅ **CI/CD integration** - Easy automation

**Quick Commands:**
```bash
# Run basic load test
test-load

# Run custom k6 script
k6-run my-loadtest.js

# Run with cloud integration
k6-cloud my-script.js
```

### **🍎 Swift Testing - iOS Development**
Modern Swift testing utilities for SwiftUI applications.

**Included Tools:**
- ✅ **Swift Testing** - Modern unit testing framework
- ✅ **XCUITest** - UI testing capabilities
- ✅ **ViewInspector** - SwiftUI view testing
- ✅ **SnapshotTesting** - Visual regression testing

**Quick Commands:**
```bash
# Run Swift tests
swift-test

# Run with parallel execution
swift-test-parallel

# Xcode testing
xcode-test
```

## 📁 **Project Templates**

### **Bruno API Collections**
Pre-built collections for common FastAPI patterns:

```bash
# Copy FastAPI basic collection
cp ~/dotfiles/templates/testing/bruno/fastapi-basic.json ./api-tests/

# Collections include:
# - Health checks
# - Authentication flows
# - CRUD operations
# - Environment configurations
```

### **Playwright Test Suites**
Ready-to-use test templates for Lit PWA:

```bash
# Copy Lit component tests
cp ~/dotfiles/templates/testing/playwright/lit-component.spec.ts ./tests/

# Copy PWA functionality tests  
cp ~/dotfiles/templates/testing/playwright/pwa-functionality.spec.ts ./tests/

# Templates include:
# - Component testing
# - PWA features (offline, manifest, service worker)
# - Accessibility testing
# - Visual regression testing
```

### **Pytest Templates**
Comprehensive FastAPI testing examples:

```bash
# Copy FastAPI test template
cp ~/dotfiles/templates/testing/pytest/test_fastapi.py ./tests/

# Template includes:
# - Async/sync testing
# - Database integration
# - Authentication testing
# - Performance benchmarks
```

### **k6 Load Testing Scripts**
Performance testing templates:

```bash
# Copy API load test script
cp ~/dotfiles/templates/testing/k6/api-load-test.js ./

# Script includes:
# - Multiple testing scenarios
# - Authentication flows
# - CRUD operation testing
# - Custom metrics
```

## 🎯 **Testing Workflows**

### **FastAPI Backend Testing**

1. **Setup Testing Environment**
   ```bash
   testing-init python
   ```

2. **Run Unit Tests**
   ```bash
   pt-cov                    # Tests with coverage
   pt-watch                  # Watch mode for development
   ```

3. **API Integration Testing**
   ```bash
   bt-run api-tests.json     # Bruno API tests
   ```

4. **Load Testing**
   ```bash
   test-load                 # k6 performance tests
   ```

### **Lit PWA Frontend Testing**

1. **Setup Testing Environment**
   ```bash
   testing-init javascript
   ```

2. **Component Testing**
   ```bash
   pw-test                   # Run all Playwright tests
   pw-ui                     # Interactive test runner
   ```

3. **PWA Feature Testing**
   ```bash
   pw-test pwa-functionality.spec.ts
   ```

4. **Visual Regression Testing**
   ```bash
   pw-test --update-snapshots
   ```

### **SwiftUI iOS Testing**

1. **Setup Testing Environment**
   ```bash
   testing-init swift
   ```

2. **Unit Testing**
   ```bash
   swift-test
   ```

3. **UI Testing**
   ```bash
   xcode-test
   ```

## ⚙️ **Configuration**

### **Project-Specific Setup**

Each project type gets customized testing configuration:

**Python/FastAPI:**
- `pytest.ini` - Test configuration
- `conftest.py` - Test fixtures
- `tests/` - Test directory structure

**JavaScript/Lit:**
- `playwright.config.ts` - Playwright configuration
- `tests/` - Test specifications
- Component and PWA testing utilities

**Swift/SwiftUI:**
- `Package.swift` - Testing dependencies
- `Tests/` - Test directory
- Snapshot and UI testing setup

### **Environment Configuration**

**Bruno Environments:**
```json
{
  "environments": [
    {
      "name": "Development",
      "variables": [
        { "name": "base_url", "value": "http://localhost:8000" },
        { "name": "username", "value": "dev@example.com" }
      ]
    },
    {
      "name": "Staging", 
      "variables": [
        { "name": "base_url", "value": "https://staging-api.example.com" }
      ]
    }
  ]
}
```

**Playwright Configuration:**
```typescript
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } }
  ]
});
```

## 🔧 **Tmux Integration**

Quick testing shortcuts in tmux:

| Shortcut | Action |
|----------|--------|
| `Prefix + T` | Run all tests |
| `Prefix + B` | Open Bruno |
| `Prefix + P` | Playwright UI mode |
| `Prefix + K` | Run k6 load test |
| `Prefix + t` | pytest watch mode |
| `Prefix + S` | Testing status |

## 📊 **Test Reporting**

### **Generate Comprehensive Reports**
```bash
test-report
```

This creates:
- **Python coverage** - HTML reports in `test-reports/python-coverage/`
- **Playwright results** - HTML reports in `test-reports/playwright-report/`
- **k6 performance** - JSON and HTML reports

### **Continuous Integration**

**GitHub Actions Integration:**
```yaml
- name: Run Python Tests
  run: pytest --cov --cov-report=xml

- name: Run Playwright Tests
  run: bunx playwright test

- name: Run Load Tests
  run: k6 run --out json=results.json loadtest.js
```

## 🎛️ **Advanced Usage**

### **Custom Test Functions**

```bash
# Test specific files
test-file tests/test_api.py
test-file tests/components.spec.ts

# Watch tests and re-run on changes
test-watch

# Load testing with custom scenarios
test-load custom-loadtest.js

# Clean test artifacts
test-clean
```

### **Performance Testing**

```bash
# Benchmark specific tests
pt-benchmark

# k6 with different load patterns
k6-run --stage 1m:10,5m:20,1m:0 script.js

# Profile test performance
pt-verbose --benchmark-only
```

### **Debugging Tests**

```bash
# Playwright debugging
pw-debug --headed tests/app.spec.ts

# Python debugging with pdb
pt -s --pdb

# k6 debugging
k6-inspect script.js
```

## 🚨 **Troubleshooting**

### **Common Issues**

**Playwright browser installation:**
```bash
bunx playwright install
```

**Python dependency issues:**
```bash
uv sync  # Refresh Python environment
testing-init python  # Reinstall test dependencies
```

**k6 permission issues:**
```bash
chmod +x loadtest.js
```

**Swift testing setup:**
```bash
# Ensure Xcode Command Line Tools
xcode-select --install
```

### **Performance Issues**

**Slow test startup:**
```bash
# Use fast mode for testing
export DOTFILES_FAST_MODE=1
```

**Memory issues with large test suites:**
```bash
# Run tests in smaller batches
pt-parallel -n 2  # Limit parallel workers
```

## 📚 **Learning Resources**

### **Documentation**
- [Bruno Documentation](https://docs.usebruno.com/)
- [Playwright Testing](https://playwright.dev/)
- [pytest Documentation](https://docs.pytest.org/)
- [k6 Load Testing](https://k6.io/docs/)
- [Swift Testing](https://developer.apple.com/documentation/testing)

### **Best Practices**
1. **Start with unit tests** - Build confidence with fast, isolated tests
2. **Add integration tests** - Test component interactions
3. **Include E2E tests** - Verify complete user journeys
4. **Regular load testing** - Ensure performance under load
5. **Automate in CI/CD** - Catch issues early

## 🎉 **Summary**

Your testing framework now provides:

✅ **Complete coverage** for FastAPI, Lit PWA, and SwiftUI development  
✅ **Modern tools** with excellent developer experience  
✅ **Integrated workflow** with your existing development environment  
✅ **Template projects** for quick setup  
✅ **Performance testing** capabilities  
✅ **CI/CD ready** configurations  

**You now have enterprise-grade testing capabilities that scale with your projects!** 🚀

---

**Quick Reference:**
- 🧪 `testing-status` - Check setup
- 🚀 `testing-init` - Setup new project
- ⚡ `test-all` - Run everything
- 📊 `test-report` - Generate reports
- 🎯 `test-watch` - Development mode