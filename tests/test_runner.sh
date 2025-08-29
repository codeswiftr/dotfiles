#!/bin/bash

# Dotfiles Testing Framework - Main Test Runner
# Orchestrates comprehensive testing across all categories with enhanced reporting

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced dependency checking (mise/asdf-friendly)
missing=0
check_dep() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo -e "${RED}[ERROR]${NC} Missing required dependency: $1"
    missing=1
  fi
}
check_python_module() {
  if ! python3 -c "import $1" >/dev/null 2>&1; then
    echo -e "${RED}[ERROR]${NC} Missing required Python module: $1"
    missing=1
  fi
}

# Check critical dependencies
check_dep shellcheck
check_dep yamllint
check_dep python3

# Check for performance testing dependencies
if ! command -v bc >/dev/null 2>&1; then
  echo -e "${YELLOW}[WARNING]${NC} bc (calculator) missing - performance tests will be skipped"
fi

# PyYAML is optional; tests will fallback if missing
if ! python3 -c "import yaml" >/dev/null 2>&1; then
  echo -e "${YELLOW}[WARNING]${NC} Optional Python module missing: yaml (PyYAML). Falling back to non-Python checks."
else
  : # yaml available
fi

if [[ $missing -eq 1 ]]; then
  echo -e "${YELLOW}[INFO]${NC} To install dependencies with mise:"
  echo "  mise install python@3.11"
  echo "  mise global python@3.11"
  echo "  mise exec python@3.11 -- pip install --user pyyaml"
  echo "  brew install shellcheck yamllint bc"
  exit 1
fi

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TEST_DIR/.." && pwd)"
RESULTS_DIR="$TEST_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$RESULTS_DIR/test_run_$TIMESTAMP.log"

# Enhanced test runner path
ENHANCED_RUNNER="$TEST_DIR/enhanced_test_runner.sh"

# Test execution modes
RUN_MODE="comprehensive"  # comprehensive, quick, category-specific
CATEGORY="all"           # all, infrastructure, unit, integration, performance
VERBOSE_MODE=false
QUICK_MODE=false

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_header() {
    echo -e "${CYAN}${BOLD}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$(printf '=%.0s' {1..60})${NC}" | tee -a "$LOG_FILE"
}

# Setup functions
setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Create results directory
    mkdir -p "$RESULTS_DIR"
    
    # Initialize log file
    cat > "$LOG_FILE" << EOF
Dotfiles Testing Framework - Test Run Log
==========================================
Start Time: $(date)
Platform: $OSTYPE
Test Directory: $TEST_DIR
Dotfiles Directory: $DOTFILES_DIR

EOF
    
    # Change to dotfiles directory
    cd "$DOTFILES_DIR"
    
    log_info "Environment setup complete"
}

# Test execution functions
run_test_category() {
    local category="$1"
    local test_file="$2"
    local test_path="$TEST_DIR/$category/$test_file"
    
    log_header "Running $category: $test_file"
    
    if [[ ! -f "$test_path" ]]; then
        log_error "Test file not found: $test_path"
        return 1
    fi
    
    if [[ ! -x "$test_path" ]]; then
        log_error "Test file not executable: $test_path"
        return 1
    fi
    
    # Run the test and capture output
    local start_time end_time duration
    start_time=$(date +%s)
    
    local test_output_file
    test_output_file=$(mktemp)
    
    # Run the test regardless of exit code to capture output
    local test_exit_code
    if command -v timeout >/dev/null 2>&1; then
        (cd "$DOTFILES_DIR" && timeout 60 bash "$test_path") > "$test_output_file" 2>&1
    else
        (cd "$DOTFILES_DIR" && bash "$test_path") > "$test_output_file" 2>&1
    fi
    test_exit_code=$?
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Always append test output to log
    cat "$test_output_file" >> "$LOG_FILE"
    
    # Extract test results from the test output
    local test_output
    test_output=$(grep -E "(Tests Run:|Tests Passed:|Tests Failed:)" "$test_output_file" || echo "")
    
    if [[ -n "$test_output" ]]; then
        local tests_run tests_passed tests_failed
        tests_run=$(echo "$test_output" | grep "Tests Run:" | grep -o '[0-9]\+' | head -1 || echo "0")
        tests_passed=$(echo "$test_output" | grep "Tests Passed:" | grep -o '[0-9]\+' | head -1 || echo "0")
        tests_failed=$(echo "$test_output" | grep "Tests Failed:" | grep -o '[0-9]\+' | head -1 || echo "0")
        
        # Ensure we have valid numbers
        tests_run=${tests_run:-0}
        tests_passed=${tests_passed:-0}
        tests_failed=${tests_failed:-0}
        
        if [[ "$tests_run" -gt 0 ]]; then
            TOTAL_TESTS=$((TOTAL_TESTS + tests_run))
            TOTAL_PASSED=$((TOTAL_PASSED + tests_passed))
            TOTAL_FAILED=$((TOTAL_FAILED + tests_failed))
            
            if [[ "$tests_failed" -gt 0 ]]; then
                log_error "$test_file completed with failures (${duration}s) - $tests_failed/$tests_run tests failed"
                FAILED_TESTS+=("$test_file")
            else
                log_success "$test_file completed successfully (${duration}s) - all $tests_run tests passed"
            fi
        else
            # If no test results found, consider this test script as having failed to run properly
            log_error "$test_file failed to produce test results (${duration}s)"
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
            FAILED_TESTS+=("$test_file")
        fi
    else
        # If no test results found but script may have run
        if [[ $test_exit_code -eq 0 ]]; then
            log_warning "$test_file completed but produced no test results (${duration}s)"
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
            TOTAL_PASSED=$((TOTAL_PASSED + 1))
        else
            log_error "$test_file failed to run (${duration}s)"
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
            FAILED_TESTS+=("$test_file")
        fi
    fi
    
    rm -f "$test_output_file"
    return 0
}

# Reporting functions
generate_summary_report() {
    local report_file="$RESULTS_DIR/summary_$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Dotfiles Testing Framework - Summary Report

**Test Run:** $TIMESTAMP  
**Platform:** $OSTYPE  
**Date:** $(date)

## Test Results Overview

| Metric | Value |
|--------|-------|
| Total Tests | $TOTAL_TESTS |
| Tests Passed | $TOTAL_PASSED |
| Tests Failed | $TOTAL_FAILED |
| Success Rate | $( [[ $TOTAL_TESTS -gt 0 ]] && echo $(( TOTAL_PASSED * 100 / TOTAL_TESTS )) || echo 0 )% |

## Test Categories

### Infrastructure Tests
EOF
    
    for test_file in "${INFRASTRUCTURE_TESTS[@]}"; do
        local status="✅ PASSED"
        if [[ ${#FAILED_TESTS[@]:-0} -gt 0 ]]; then
          for failed_test in "${FAILED_TESTS[@]}"; do
            if [[ "$failed_test" == "$test_file" ]]; then
                status="❌ FAILED"
                break
            fi
          done
        fi
        echo "- $test_file: $status" >> "$report_file"
    done
    
    if [[ ${#FAILED_TESTS[@]:-0} -gt 0 ]]; then
        cat >> "$report_file" << EOF

## Failed Tests

The following tests failed and require attention:

EOF
        for failed_test in "${FAILED_TESTS[@]}"; do
            echo "- $failed_test" >> "$report_file"
        done
    fi
    
    cat >> "$report_file" << EOF

## Recommendations

EOF
    
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        cat >> "$report_file" << EOF
🎉 **All tests passed!** Your dotfiles are in excellent condition.

### Next Steps
- Consider setting up automated testing with GitHub Actions
- Review performance optimization opportunities
- Update documentation based on test results
EOF
    else
        cat >> "$report_file" << EOF
⚠️ **Some tests failed.** Please review and address the failing tests.

### Immediate Actions Required
1. Review the detailed log file: \`$LOG_FILE\`
2. Fix the issues identified in failed tests
3. Re-run the tests to verify fixes
4. Consider adding additional tests for edge cases

### Prevention
- Set up pre-commit hooks to run tests automatically
- Add continuous integration to catch issues early
- Document any platform-specific requirements
EOF
    fi
    
    cat >> "$report_file" << EOF

## Detailed Logs

Full test execution logs are available in:
- Log file: \`$LOG_FILE\`
- Results directory: \`$RESULTS_DIR\`

---
*Report generated by Dotfiles Testing Framework*
EOF
    
    echo "$report_file"
}

# Main execution with enhanced testing framework
main() {
    local exit_code=0
    
    # Header
    log_header "Dotfiles Testing Framework v2.0"
    log_info "Starting comprehensive testing with category: $CATEGORY"
    
    # Setup test environment
    setup_test_environment
    
    # Check if enhanced test runner exists
    if [[ ! -f "$ENHANCED_RUNNER" ]]; then
        log_error "Enhanced test runner not found at: $ENHANCED_RUNNER"
        log_info "Falling back to legacy infrastructure tests only"
        run_legacy_tests
        exit_code=$?
    else
        # Use enhanced test runner for comprehensive testing
        run_enhanced_tests
        exit_code=$?
    fi
    
    exit $exit_code
}

# Run enhanced comprehensive tests
run_enhanced_tests() {
    log_info "Using enhanced test framework for comprehensive testing"
    
    # Build enhanced runner command
    local enhanced_cmd="$ENHANCED_RUNNER"
    
    # Add flags based on configuration
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        enhanced_cmd="$enhanced_cmd --verbose"
    fi
    
    if [[ "$QUICK_MODE" == "true" ]]; then
        enhanced_cmd="$enhanced_cmd --quick"
    fi
    
    if [[ "$CATEGORY" != "all" ]]; then
        enhanced_cmd="$enhanced_cmd --category $CATEGORY"
    fi
    
    # Execute enhanced test runner
    log_info "Executing: $enhanced_cmd"
    
    # Run and capture exit code
    if bash "$enhanced_cmd"; then
        log_success "Enhanced testing completed successfully"
        return 0
    else
        local enhanced_exit_code=$?
        log_error "Enhanced testing completed with failures (exit code: $enhanced_exit_code)"
        return $enhanced_exit_code
    fi
}

# Fallback to legacy infrastructure testing
run_legacy_tests() {
    log_warning "Running legacy infrastructure tests only"
    
    # Legacy infrastructure tests list
    local INFRASTRUCTURE_TESTS=(
        "test_installation.sh"
        "test_health_checks.sh"
        "test_configuration.sh"
        "test_linting.sh"
        "test_cli.sh"
        "test_security_cli.sh"
        "test_security_summary.sh"
        "test_security_summary_clean.sh"
        "test_security_gate.sh"
        "test_tmux_bindings.sh"
    )
    
    # Results tracking for legacy mode
    local TOTAL_TESTS=0
    local TOTAL_PASSED=0
    local TOTAL_FAILED=0
    local FAILED_TESTS=()
    
    # Run legacy infrastructure tests
    log_header "Infrastructure Tests (Legacy Mode)"
    for test_file in "${INFRASTRUCTURE_TESTS[@]}"; do
        if ! run_test_category "infrastructure" "$test_file"; then
            exit_code=1
        fi
        echo "" | tee -a "$LOG_FILE"
    done
    
    # Generate legacy summary
    generate_legacy_summary "$TOTAL_TESTS" "$TOTAL_PASSED" "$TOTAL_FAILED" "${FAILED_TESTS[@]}"
    
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Generate legacy summary report
generate_legacy_summary() {
    local total_tests="$1"
    local total_passed="$2"
    local total_failed="$3"
    shift 3
    local failed_tests=("$@")
    
    log_header "Test Results (Legacy Mode)"
    
    if [[ $total_tests -eq 0 ]]; then
        log_warning "No tests were executed!"
        return 1
    else
        log_info "Total Tests: $total_tests"
        log_info "Tests Passed: $total_passed"
        log_info "Tests Failed: $total_failed"
        
        if [[ $total_failed -eq 0 ]]; then
            log_success "All infrastructure tests passed! 🎉"
        else
            log_error "Some infrastructure tests failed! ❌"
            if [[ ${#failed_tests[@]} -gt 0 ]]; then
                log_info "Failed tests: ${failed_tests[*]}"
            fi
        fi
    fi
    
    # Generate basic report
    local report_file="$RESULTS_DIR/legacy_summary_$TIMESTAMP.md"
    cat > "$report_file" << EOF
# Dotfiles Testing Framework - Legacy Summary Report

**Test Run:** $TIMESTAMP  
**Mode:** Legacy Infrastructure Tests  
**Date:** $(date)

## Test Results Overview

| Metric | Value |
|--------|-------|
| Total Tests | $total_tests |
| Tests Passed | $total_passed |
| Tests Failed | $total_failed |
| Success Rate | $( [[ $total_tests -gt 0 ]] && echo $(( total_passed * 100 / total_tests )) || echo 0 )% |

EOF

    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        cat >> "$report_file" << EOF
## Failed Tests

The following tests failed:

EOF
        for failed_test in "${failed_tests[@]}"; do
            echo "- $failed_test" >> "$report_file"
        done
        echo "" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
## Recommendations

EOF
    
    if [[ $total_failed -eq 0 ]]; then
        cat >> "$report_file" << EOF
🎉 **All infrastructure tests passed!**

### Upgrade to Enhanced Testing
Consider upgrading to the enhanced testing framework for:
- Unit tests for better code coverage
- Integration tests for end-to-end validation  
- Performance tests for optimization insights
- Comprehensive reporting and analytics

Run \`./tests/test_runner.sh --help\` for enhanced testing options.
EOF
    else
        cat >> "$report_file" << EOF
⚠️ **Some tests failed.** Please review and address the failing tests.

### Immediate Actions Required
1. Review the detailed log file: \`$LOG_FILE\`
2. Fix the issues identified in failed tests
3. Re-run the tests to verify fixes

### Recommended Next Steps
- Upgrade to enhanced testing framework for better diagnostics
- Add unit tests to prevent regressions
- Set up continuous integration for automated testing
EOF
    fi
    
    log_info "Legacy summary report generated: $report_file"
    return 0
}

# Enhanced help function
show_help() {
    cat << EOF
Dotfiles Testing Framework v2.0 - Comprehensive Test Runner

Usage: $0 [OPTIONS]

Options:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output and detailed logging
  -q, --quick             Run only quick tests (skip performance tests)
  -c, --category CATEGORY Run specific test category
  -l, --legacy            Force legacy infrastructure-only testing

Test Categories:
  all                     All test categories (default)
  infrastructure         Installation, health checks, configuration
  unit                   Unit tests for individual functions and modules
  integration            End-to-end integration testing scenarios
  performance            Performance benchmarks and optimization tests

Examples:
  $0                              # Run all comprehensive tests
  $0 --category infrastructure    # Run only infrastructure tests
  $0 --category unit             # Run only unit tests
  $0 --quick --category unit     # Run unit tests in quick mode
  $0 --verbose --category all    # Run all tests with detailed output
  $0 --legacy                    # Use legacy testing framework

Enhanced Features:
  ✅ Multi-category testing (unit, integration, performance, infrastructure)
  ✅ Performance benchmarking with thresholds
  ✅ Comprehensive mocking and test isolation
  ✅ Detailed reporting with actionable insights
  ✅ Cross-platform compatibility testing
  ✅ Automatic fallback to legacy mode if needed

Results:
  Test results:     $RESULTS_DIR
  Execution logs:   Timestamped logs for debugging and tracking
  Reports:          Comprehensive markdown reports with recommendations

For more information: docs/testing.md
EOF
}

# Enhanced command line argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE_MODE=true
            log_info "Verbose mode enabled"
            shift
            ;;
        -q|--quick)
            QUICK_MODE=true
            log_info "Quick mode enabled - performance tests will be skipped"
            shift
            ;;
        -c|--category)
            if [[ -n "$2" ]] && [[ "$2" != -* ]]; then
                CATEGORY="$2"
                log_info "Test category: $CATEGORY"
                shift 2
            else
                log_error "--category requires an argument (all, infrastructure, unit, integration, performance)"
                show_help
                exit 1
            fi
            ;;
        -l|--legacy)
            RUN_MODE="legacy"
            log_info "Legacy mode enabled - will use original infrastructure testing only"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Force legacy mode if requested
if [[ "$RUN_MODE" == "legacy" ]]; then
    ENHANCED_RUNNER="/nonexistent/force_legacy"
fi

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi