#!/usr/bin/env bash
# =============================================================================
# Test Framework Utilities
# Provides reusable testing functions and assertions
# =============================================================================

set -euo pipefail

# Test configuration
TEST_FRAMEWORK_VERSION="1.0.0"
TEST_TEMP_DIR="${TEST_TEMP_DIR:-/tmp/dotfiles_tests_$$}"
TEST_VERBOSE="${TEST_VERBOSE:-false}"
TEST_CLEANUP="${TEST_CLEANUP:-true}"

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TEST_PASS_COUNT=0
TEST_FAIL_COUNT=0
TEST_SKIP_COUNT=0

# Backward-compatible counters for legacy test scripts
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0

# =============================================================================
# Core Test Functions
# =============================================================================

# Initialize test environment
test_init() {
    local test_name="${1:-unknown_test}"
    
    # Create temporary directory
    mkdir -p "$TEST_TEMP_DIR"
    
    # Set up test environment
    export TEST_NAME="$test_name"
    export TEST_START_TIME="$(date +%s)"
    
    # Initialize counters
    TEST_PASS_COUNT=0
    TEST_FAIL_COUNT=0
    TEST_SKIP_COUNT=0
    
    log_info "Initializing test: $test_name"
}

# Clean up test environment
test_cleanup() {
    if [[ "$TEST_CLEANUP" == "true" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Print test results summary
test_summary() {
    local total=$((TEST_PASS_COUNT + TEST_FAIL_COUNT + TEST_SKIP_COUNT))
    local end_time="$(date +%s)"
    local duration=$((end_time - TEST_START_TIME))
    
    echo
    echo "=============================================="
    echo "Test Results for: $TEST_NAME"
    echo "=============================================="
    echo -e "${GREEN}PASSED: $TEST_PASS_COUNT${NC}"
    echo -e "${RED}FAILED: $TEST_FAIL_COUNT${NC}"
    echo -e "${YELLOW}SKIPPED: $TEST_SKIP_COUNT${NC}"
    echo "TOTAL: $total"
    echo "DURATION: ${duration}s"
    echo "=============================================="
    
    if [[ $TEST_FAIL_COUNT -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

# =============================================================================
# Logging Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[SKIP]${NC} $1" >&2
}

log_verbose() {
    if [[ "$TEST_VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1" >&2
    fi
}

# =============================================================================
# Legacy Compatibility Helpers (test_* API)
# =============================================================================

# Start a test suite (legacy API)
test_suite_start() {
    local suite_name="${1:-test_suite}"
    test_init "$suite_name"
}

# End a test suite (legacy API) and print summary in expected format
test_suite_end() {
    # Synchronize aggregate counters for legacy expectations
    TOTAL_TESTS=$((TEST_PASS_COUNT + TEST_FAIL_COUNT + TEST_SKIP_COUNT))
    TOTAL_PASSED=$((TEST_PASS_COUNT))
    TOTAL_FAILED=$((TEST_FAIL_COUNT))

    # Print standard summary lines for parsers
    echo "Tests Run: $TOTAL_TESTS"
    echo "Tests Passed: $TOTAL_PASSED"
    echo "Tests Failed: $TOTAL_FAILED"

    # Also print the verbose framework summary
    test_summary || true
}

# Describe current test (legacy API)
test_description() {
    local msg="${1:-}"
    [[ -n "$msg" ]] && log_info "$msg"
}

# Mark pass (legacy API)
test_pass() {
    local msg="${1:-Test passed}"
    ((TEST_PASS_COUNT++))
    log_success "$msg"
}

# Mark fail (legacy API)
test_fail() {
    local msg="${1:-Test failed}"
    ((TEST_FAIL_COUNT++))
    log_error "$msg"
    return 1
}

# Mark skip (legacy API)
test_skip() {
    local msg="${1:-Test skipped}"
    ((TEST_SKIP_COUNT++))
    log_warning "$msg"
}

# =============================================================================
# Assertion Functions
# =============================================================================

# Assert that two values are equal
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$actual" == "$expected" ]]; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        log_verbose "Expected: '$expected', Got: '$actual'"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Expected: '$expected', Got: '$actual'"
        return 1
    fi
}

# Assert that two values are not equal
assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$actual" != "$not_expected" ]]; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Expected NOT: '$not_expected', Got: '$actual'"
        return 1
    fi
}

# Assert that a condition is true
assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if eval "$condition"; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Condition failed: $condition"
        return 1
    fi
}

# Assert that a condition is false
assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    if ! eval "$condition"; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Condition should have failed: $condition"
        return 1
    fi
}

# Assert that a file exists
assert_file_exists() {
    local file_path="$1"
    local message="${2:-File should exist: $file_path}"
    
    assert_true "[[ -f '$file_path' ]]" "$message"
}

# Assert that a directory exists
assert_dir_exists() {
    local dir_path="$1"
    local message="${2:-Directory should exist: $dir_path}"
    
    assert_true "[[ -d '$dir_path' ]]" "$message"
}

# Assert that a command succeeds
assert_command_success() {
    local command="$1"
    local message="${2:-Command should succeed: $command}"
    
    if eval "$command" >/dev/null 2>&1; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Command failed: $command"
        return 1
    fi
}

# Assert that a command fails
assert_command_failure() {
    local command="$1"
    local message="${2:-Command should fail: $command}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Command should have failed: $command"
        return 1
    fi
}

# Assert that output contains a string
assert_output_contains() {
    local command="$1"
    local expected_string="$2"
    local message="${3:-Output should contain: $expected_string}"
    
    local output
    if output=$(eval "$command" 2>&1); then
        if [[ "$output" == *"$expected_string"* ]]; then
            ((TEST_PASS_COUNT++))
            log_success "$message"
            return 0
        else
            ((TEST_FAIL_COUNT++))
            log_error "$message"
            log_error "Expected string '$expected_string' not found in output"
            log_verbose "Command output: $output"
            return 1
        fi
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Command failed to execute: $command"
        return 1
    fi
}

# Skip a test with a message
skip_test() {
    local message="${1:-Test skipped}"
    
    ((TEST_SKIP_COUNT++))
    log_warning "$message"
}

# =============================================================================
# Utility Functions
# =============================================================================

# Create a temporary file
create_temp_file() {
    local filename="${1:-test_file}"
    local content="${2:-}"
    
    local temp_file="$TEST_TEMP_DIR/$filename"
    mkdir -p "$(dirname "$temp_file")"
    
    if [[ -n "$content" ]]; then
        echo "$content" > "$temp_file"
    else
        touch "$temp_file"
    fi
    
    echo "$temp_file"
}

# Create a temporary directory
create_temp_dir() {
    local dirname="${1:-test_dir}"
    
    local temp_dir="$TEST_TEMP_DIR/$dirname"
    mkdir -p "$temp_dir"
    
    echo "$temp_dir"
}

# Run a test function with proper setup and teardown
run_test() {
    local test_function="$1"
    local test_description="${2:-$test_function}"
    
    log_info "Running test: $test_description"
    
    # Run the test function
    if "$test_function"; then
        log_verbose "Test function completed successfully"
    else
        log_verbose "Test function had failures"
    fi
}

# =============================================================================
# Performance Testing Functions
# =============================================================================

# Measure execution time of a command
time_command() {
    local command="$1"
    local start_time end_time duration
    
    start_time=$(date +%s.%N)
    eval "$command" >/dev/null 2>&1
    end_time=$(date +%s.%N)
    
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    echo "$duration"
}

# Assert that a command executes within a time limit
assert_time_limit() {
    local command="$1"
    local max_time="$2"
    local message="${3:-Command should execute within ${max_time}s}"
    
    local actual_time
    actual_time=$(time_command "$command")
    
    if (( $(echo "$actual_time <= $max_time" | bc -l 2>/dev/null || echo 0) )); then
        ((TEST_PASS_COUNT++))
        log_success "$message (took ${actual_time}s)"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message (took ${actual_time}s, limit: ${max_time}s)"
        return 1
    fi
}