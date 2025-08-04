#!/bin/bash

# Dotfiles Health Check Testing Framework
# Tests health check accuracy and system validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    log_info "Running test: $test_name"
    
    # Disable exit on error for test execution
    set +e
    if $test_function; then
        log_success "$test_name"
    else
        log_error "$test_name"
    fi
    # Re-enable exit on error
    set -e
}

# Test functions
test_health_check_exists() {
    [[ -f "scripts/health-check.sh" ]] && [[ -x "scripts/health-check.sh" ]]
}

test_health_check_runs() {
    timeout 30 bash -c './scripts/health-check.sh >/dev/null 2>&1'
}

test_health_check_basic_output() {
    local output
    output=$(./scripts/health-check.sh 2>&1)
    [[ -n "$output" ]] # Should produce some output
}

test_shell_detection() {
    # Test if health check can detect current shell
    local output
    output=$(./scripts/health-check.sh 2>&1)
    [[ "$output" == *"shell"* ]] || [[ "$output" == *"zsh"* ]] || [[ "$output" == *"bash"* ]]
}

test_os_detection() {
    # Test if health check can detect OS
    local output
    output=$(./scripts/health-check.sh 2>&1)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        [[ "$output" == *"macOS"* ]] || [[ "$output" == *"Darwin"* ]]
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        [[ "$output" == *"Linux"* ]] || [[ "$output" == *"Ubuntu"* ]]
    fi
}

test_git_availability() {
    # Test if health check verifies git availability
    if command -v git >/dev/null 2>&1; then
        local output
        output=$(./scripts/health-check.sh 2>&1)
        [[ "$output" == *"git"* ]] || [[ "$output" != *"missing"* ]]
    fi
}

test_homebrew_detection() {
    # Test homebrew detection on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local output
        output=$(./scripts/health-check.sh 2>&1)
        if command -v brew >/dev/null 2>&1; then
            [[ "$output" == *"brew"* ]] || [[ "$output" == *"Homebrew"* ]]
        fi
    fi
}

test_python_detection() {
    # Test Python detection
    if command -v python3 >/dev/null 2>&1; then
        local output
        output=$(./scripts/health-check.sh 2>&1)
        [[ "$output" == *"python"* ]] || [[ "$output" == *"Python"* ]]
    fi
}

test_node_detection() {
    # Test Node.js detection
    if command -v node >/dev/null 2>&1; then
        local output
        output=$(./scripts/health-check.sh 2>&1)
        [[ "$output" == *"node"* ]] || [[ "$output" == *"Node"* ]]
    fi
}

test_health_check_exit_codes() {
    # Test that health check returns appropriate exit codes
    local exit_code
    ./scripts/health-check.sh >/dev/null 2>&1
    exit_code=$?
    # Should exit with 0 for success or specific error codes
    [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 1 ]] || [[ $exit_code -eq 2 ]]
}

test_health_check_performance() {
    # Test that health check completes in reasonable time
    local start_time end_time duration
    start_time=$(date +%s%N)
    ./scripts/health-check.sh >/dev/null 2>&1
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
    
    # Should complete in less than 10 seconds
    [[ $duration -lt 10000 ]]
}

test_health_check_verbose_mode() {
    # Test if health check supports verbose output
    if ./scripts/health-check.sh --help 2>&1 | grep -q "verbose\|--verbose\|-v"; then
        local output
        output=$(./scripts/health-check.sh --verbose 2>&1 || ./scripts/health-check.sh -v 2>&1)
        [[ -n "$output" ]]
    else
        return 0 # Skip if verbose mode not supported
    fi
}

test_health_check_json_output() {
    # Test if health check supports JSON output
    if ./scripts/health-check.sh --help 2>&1 | grep -q "json\|--json"; then
        local output
        output=$(./scripts/health-check.sh --json 2>&1)
        [[ "$output" == *"{"* ]] && [[ "$output" == *"}"* ]]
    else
        return 0 # Skip if JSON output not supported
    fi
}

test_dotfiles_structure_validation() {
    # Test if health check validates dotfiles structure
    local output
    output=$(./scripts/health-check.sh 2>&1)
    # Should check for key directories/files
    [[ "$output" == *"config"* ]] || [[ "$output" == *"lib"* ]] || [[ "$output" == *"install"* ]]
}

test_version_consistency() {
    # Test if health check validates version consistency
    if [[ -f "VERSION" ]] && [[ -f "lib/version.sh" ]]; then
        local output
        output=$(./scripts/health-check.sh 2>&1)
        # Should not report version inconsistencies
        [[ "$output" != *"version mismatch"* ]] && [[ "$output" != *"version error"* ]]
    fi
}

test_configuration_validation() {
    # Test if health check validates configuration files
    local output
    output=$(./scripts/health-check.sh 2>&1)
    # Should not report configuration errors
    [[ "$output" != *"config error"* ]] && [[ "$output" != *"configuration invalid"* ]]
}

# Integration tests
test_health_check_after_install() {
    # Test health check after a dry-run install
    timeout 30 bash -c './install.sh --dry-run install minimal >/dev/null 2>&1'
    timeout 30 bash -c './scripts/health-check.sh >/dev/null 2>&1'
}

# Main test execution
main() {
    log_info "Starting Dotfiles Health Check Testing Framework"
    log_info "Platform: $OSTYPE"
    log_info "Date: $(date)"
    echo
    
    # Basic health check tests
    run_test "Health check script exists and is executable" test_health_check_exists
    run_test "Health check runs without errors" test_health_check_runs
    run_test "Health check produces output" test_health_check_basic_output
    run_test "Health check returns appropriate exit codes" test_health_check_exit_codes
    
    # Detection tests
    run_test "Shell detection works" test_shell_detection
    run_test "OS detection works" test_os_detection
    run_test "Git availability check works" test_git_availability
    run_test "Homebrew detection works (macOS)" test_homebrew_detection
    run_test "Python detection works" test_python_detection
    run_test "Node.js detection works" test_node_detection
    
    # Feature tests
    run_test "Verbose mode works" test_health_check_verbose_mode
    run_test "JSON output works" test_health_check_json_output
    
    # Validation tests
    run_test "Dotfiles structure validation works" test_dotfiles_structure_validation
    run_test "Version consistency check works" test_version_consistency
    run_test "Configuration validation works" test_configuration_validation
    
    # Performance tests
    run_test "Health check completes in reasonable time" test_health_check_performance
    
    # Integration tests
    run_test "Health check works after install" test_health_check_after_install
    
    # Results
    echo
    log_info "Test Results Summary:"
    echo "  Tests Run: $TESTS_RUN"
    echo "  Tests Passed: $TESTS_PASSED"
    echo "  Tests Failed: $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed!"
        exit 0
    else
        log_error "Some tests failed!"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi