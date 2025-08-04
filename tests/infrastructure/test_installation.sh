#!/bin/bash

# Dotfiles Installation Testing Framework
# Tests the declarative installer and installation process

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

# Test configuration
TEST_DIR="/tmp/dotfiles_test_$(date +%s)"
BACKUP_DIR="/tmp/dotfiles_backup_$(date +%s)"

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

# Setup test environment
setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    
    # We'll test in the current directory instead of copying
    # This avoids issues with large directories and git repos
    log_info "Running tests in current directory"
}

# Cleanup test environment
cleanup_test_environment() {
    log_info "Cleaning up test environment..."
    
    # Remove test directory
    rm -rf "$TEST_DIR"
}

# Test functions
test_installer_exists() {
    [[ -f "install.sh" ]] && [[ -x "install.sh" ]]
}

test_config_file_exists() {
    [[ -f "config/tools.yaml" ]]
}

test_installer_help() {
    ./install.sh --help >/dev/null 2>&1
}

test_dry_run_mode() {
    ./install.sh --dry-run profiles >/dev/null 2>&1
}

test_profiles_command() {
    local output
    output=$(./install.sh profiles 2>&1)
    [[ "$output" == *"minimal"* ]] && [[ "$output" == *"standard"* ]]
}

test_yaml_syntax() {
    # Check if tools.yaml is valid YAML
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import yaml; yaml.safe_load(open('config/tools.yaml'))" 2>/dev/null
    else
        # Basic syntax check
        grep -q "profiles:" config/tools.yaml && 
        grep -q "minimal:" config/tools.yaml && 
        grep -q "standard:" config/tools.yaml
    fi
}

test_required_directories() {
    [[ -d "config" ]] && 
    [[ -d "lib" ]] && 
    [[ -d "scripts" ]]
}

test_health_check_script() {
    [[ -f "scripts/health-check.sh" ]] && [[ -x "scripts/health-check.sh" ]]
}

test_version_management() {
    [[ -f "lib/version.sh" ]] && [[ -f "VERSION" ]]
}

test_minimal_profile_dry_run() {
    timeout 30 bash -c './install.sh --dry-run install minimal >/dev/null 2>&1'
}

test_standard_profile_dry_run() {
    timeout 30 bash -c './install.sh --dry-run install standard >/dev/null 2>&1'
}

test_full_profile_dry_run() {
    timeout 30 bash -c './install.sh --dry-run install full >/dev/null 2>&1'
}

test_cross_platform_detection() {
    # Test that installer can detect platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        grep -q "macos" install.sh || grep -q "darwin" install.sh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        grep -q "linux" install.sh || grep -q "ubuntu" install.sh
    fi
}

test_error_handling() {
    # Test invalid profile
    ! ./install.sh install invalid_profile >/dev/null 2>&1
}

test_dot_command_structure() {
    [[ -f "lib/cli/core.sh" ]] && 
    [[ -f "lib/cli/ai.sh" ]] && 
    [[ -f "lib/cli/security.sh" ]]
}

# Performance tests
test_startup_time() {
    local start_time end_time duration
    start_time=$(date +%s%N)
    ./install.sh --help >/dev/null 2>&1
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
    
    # Should start in less than 1 second
    [[ $duration -lt 1000 ]]
}

# Main test execution
main() {
    log_info "Starting Dotfiles Installation Testing Framework"
    log_info "Platform: $OSTYPE"
    log_info "Date: $(date)"
    echo
    
    # Setup
    setup_test_environment
    
    # Basic installer tests
    run_test "Installer script exists and is executable" test_installer_exists
    run_test "Configuration file exists" test_config_file_exists
    run_test "Installer help command works" test_installer_help
    run_test "Dry run mode works" test_dry_run_mode
    run_test "Profiles command works" test_profiles_command
    run_test "YAML syntax is valid" test_yaml_syntax
    
    # Structure tests
    run_test "Required directories exist" test_required_directories
    run_test "Health check script exists" test_health_check_script
    run_test "Version management files exist" test_version_management
    run_test "DOT command structure is valid" test_dot_command_structure
    
    # Profile tests
    run_test "Minimal profile dry run works" test_minimal_profile_dry_run
    run_test "Standard profile dry run works" test_standard_profile_dry_run
    run_test "Full profile dry run works" test_full_profile_dry_run
    
    # Platform tests
    run_test "Cross-platform detection works" test_cross_platform_detection
    
    # Error handling tests
    run_test "Error handling for invalid profiles" test_error_handling
    
    # Performance tests
    run_test "Installer startup time is reasonable" test_startup_time
    
    # Cleanup
    cleanup_test_environment
    
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