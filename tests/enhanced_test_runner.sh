#!/usr/bin/env bash
# =============================================================================
# Enhanced Dotfiles Testing Framework - Main Test Runner
# Supports unit, integration, performance, security, and infrastructure tests
# =============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$RESULTS_DIR/test_run_$TIMESTAMP.log"

# Test configuration
QUICK_MODE=false
VERBOSE_MODE=false
CATEGORY="all"
PARALLEL_TESTS=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Test results tracking (bash 3.x compatible)
TEST_RESULTS_FILE="$RESULTS_DIR/test_results_$$.tmp"
TEST_TIMES_FILE="$RESULTS_DIR/test_times_$$.tmp"
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

# =============================================================================
# Utility Functions
# =============================================================================

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
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}${BOLD}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$(printf '=%.0s' {1..60})${NC}" | tee -a "$LOG_FILE"
}

log_verbose() {
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1" | tee -a "$LOG_FILE"
    fi
}

# =============================================================================
# Test Discovery and Execution
# =============================================================================

discover_tests() {
    local category="$1"
    local tests=()
    
    case "$category" in
        "infrastructure")
            if [[ -d "$SCRIPT_DIR/infrastructure" ]]; then
                while IFS= read -r -d '' test_file; do
                    tests+=("$test_file")
                done < <(find "$SCRIPT_DIR/infrastructure" -name "*.sh" -print0)
            fi
            ;;
        "unit")
            if [[ -d "$SCRIPT_DIR/unit" ]]; then
                while IFS= read -r -d '' test_file; do
                    tests+=("$test_file")
                done < <(find "$SCRIPT_DIR/unit" -name "*.sh" -print0)
            fi
            ;;
        "integration")
            if [[ -d "$SCRIPT_DIR/integration" ]]; then
                while IFS= read -r -d '' test_file; do
                    tests+=("$test_file")
                done < <(find "$SCRIPT_DIR/integration" -name "*.sh" -print0)
            fi
            ;;
        "performance")
            if [[ "$QUICK_MODE" == "true" ]]; then
                log_info "Skipping performance tests in quick mode"
                return 0
            fi
            if [[ -d "$SCRIPT_DIR/performance" ]]; then
                while IFS= read -r -d '' test_file; do
                    tests+=("$test_file")
                done < <(find "$SCRIPT_DIR/performance" -name "*.sh" -print0)
            fi
            ;;
        "security")
            log_info "Discovering security tests..."
            # Run the comprehensive security system tests
            if [[ -f "$SCRIPT_DIR/test_security_system.sh" ]]; then
                tests+=("$SCRIPT_DIR/test_security_system.sh")
            fi
            ;;
        "all")
            discover_tests "infrastructure"
            discover_tests "unit"
            discover_tests "integration" 
            discover_tests "performance"
            discover_tests "security"
            return 0
            ;;
        *)
            log_error "Unknown test category: $category"
            return 1
            ;;
    esac
    
    # Execute discovered tests
    for test_file in "${tests[@]}"; do
        execute_test "$test_file" "$category"
    done
}

execute_test() {
    local test_file="$1"
    local category="$2"
    local test_name
    test_name=$(basename "$test_file" .sh)
    
    log_info "Running test: $category/$test_name"
    log_verbose "Test file: $test_file"
    
    # Record start time
    local start_time
    start_time=$(date +%s)
    
    # Create temporary output file
    local output_file="$RESULTS_DIR/${test_name}_output_$TIMESTAMP.log"
    
    # Set up test environment
    export TEST_TEMP_DIR="$RESULTS_DIR/temp_${test_name}_$$"
    export TEST_VERBOSE="$VERBOSE_MODE"
    
    # Execute the test
    local exit_code=0
    if bash "$test_file" > "$output_file" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # Record end time
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Process results
    process_test_results "$test_name" "$category" "$exit_code" "$duration" "$output_file"
    
    # Clean up temporary files
    rm -f "$output_file"
    rm -rf "$TEST_TEMP_DIR" 2>/dev/null || true
}

process_test_results() {
    local test_name="$1"
    local category="$2"
    local exit_code="$3"
    local duration="$4"
    local output_file="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    TEST_TIMES["$test_name"]=$duration
    
    if [[ $exit_code -eq 0 ]]; then
        # Success
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
        TEST_RESULTS["$test_name"]="PASSED"
        log_success "$category/$test_name completed successfully (${duration}s)"
        
        # Log any additional success information from test output
        if [[ -f "$output_file" ]] && [[ "$VERBOSE_MODE" == "true" ]]; then
            log_verbose "Test output for $test_name:"
            cat "$output_file" | head -20 >> "$LOG_FILE"
        fi
    else
        # Failure
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
        TEST_RESULTS["$test_name"]="FAILED"
        log_error "$category/$test_name failed with exit code $exit_code (${duration}s)"
        
        # Log error details
        if [[ -f "$output_file" ]]; then
            log_error "Error output for $test_name:"
            cat "$output_file" | tail -50 | tee -a "$LOG_FILE"
        fi
    fi
}

# =============================================================================
# Reporting Functions
# =============================================================================

generate_comprehensive_report() {
    local report_file="$RESULTS_DIR/comprehensive_report_$TIMESTAMP.md"
    
    cat > "$report_file" << EOF
# Comprehensive Dotfiles Test Report

**Generated:** $(date)  
**Platform:** $(uname -a)  
**Test Category:** $CATEGORY  
**Quick Mode:** $QUICK_MODE  

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Tests | $TOTAL_TESTS |
| Passed | $TOTAL_PASSED |
| Failed | $TOTAL_FAILED |
| Skipped | $TOTAL_SKIPPED |
| Success Rate | $( [[ $TOTAL_TESTS -gt 0 ]] && echo $(( TOTAL_PASSED * 100 / TOTAL_TESTS )) || echo 0 )% |
| Total Duration | $(( $(printf '%s\n' "${TEST_TIMES[@]}" | paste -sd+ | bc 2>/dev/null || echo 0) ))s |

## Test Results by Category

EOF

    # Generate results by category
    for category in "infrastructure" "unit" "integration" "performance" "security"; do
        if [[ -d "$SCRIPT_DIR/$category" ]]; then
            echo "### $category Tests" >> "$report_file"
            echo "" >> "$report_file"
            
            local found_tests=false
            for test_name in "${!TEST_RESULTS[@]}"; do
                if [[ -f "$SCRIPT_DIR/$category/${test_name}.sh" ]]; then
                    found_tests=true
                    local status="${TEST_RESULTS[$test_name]}"
                    local duration="${TEST_TIMES[$test_name]:-0}"
                    local icon="❌"
                    if [[ "$status" == "PASSED" ]]; then
                        icon="✅"
                    fi
                    echo "- $test_name: $icon $status (${duration}s)" >> "$report_file"
                fi
            done
            
            if [[ "$found_tests" == "false" ]]; then
                echo "- No tests executed in this category" >> "$report_file"
            fi
            echo "" >> "$report_file"
        fi
    done
    
    # Add performance insights if performance tests were run
    if [[ "$QUICK_MODE" == "false" ]] && [[ -d "$SCRIPT_DIR/performance" ]]; then
        cat >> "$report_file" << EOF
## Performance Insights

EOF
        
        # Find slowest tests
        local slowest_tests
        slowest_tests=$(printf '%s %s\n' "${!TEST_TIMES[@]}" "${TEST_TIMES[@]}" | sort -k2 -nr | head -5)
        
        echo "### Slowest Tests" >> "$report_file"
        echo "" >> "$report_file"
        while read -r test_name duration; do
            if [[ -n "$test_name" && -n "$duration" ]]; then
                echo "- $test_name: ${duration}s" >> "$report_file"
            fi
        done <<< "$slowest_tests"
        echo "" >> "$report_file"
    fi
    
    # Add failure analysis
    if [[ $TOTAL_FAILED -gt 0 ]]; then
        cat >> "$report_file" << EOF
## Failure Analysis

The following tests failed and require attention:

EOF
        for test_name in "${!TEST_RESULTS[@]}"; do
            if [[ "${TEST_RESULTS[$test_name]}" == "FAILED" ]]; then
                echo "### $test_name" >> "$report_file"
                echo "- **Status:** Failed" >> "$report_file"
                echo "- **Duration:** ${TEST_TIMES[$test_name]:-0}s" >> "$report_file"
                echo "- **Recommendation:** Check logs for detailed error information" >> "$report_file"
                echo "" >> "$report_file"
            fi
        done
    fi
    
    # Add recommendations
    cat >> "$report_file" << EOF
## Recommendations

EOF
    
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        cat >> "$report_file" << EOF
🎉 **All tests passed!** Your dotfiles testing framework is working excellently.

### Next Steps
1. Consider adding more edge case tests
2. Set up continuous integration to run tests automatically
3. Monitor performance metrics over time
4. Expand test coverage for new features
EOF
    else
        cat >> "$report_file" << EOF
⚠️ **Some tests failed.** Immediate action required.

### Action Plan
1. **Review failed tests:** Check the detailed logs for each failed test
2. **Fix underlying issues:** Address the root causes identified in the failures
3. **Re-run tests:** Verify that fixes resolve the issues
4. **Add regression tests:** Prevent similar issues in the future

### Prevention Strategy
- Set up pre-commit hooks to run critical tests
- Implement continuous integration for all pull requests
- Add monitoring for test execution times and success rates
- Regular test maintenance and updates
EOF
    fi
    
    cat >> "$report_file" << EOF

## Detailed Information

- **Full logs:** \`$LOG_FILE\`
- **Test results directory:** \`$RESULTS_DIR\`
- **Framework version:** Enhanced Test Runner v2.0

---
*Report generated by Enhanced Dotfiles Testing Framework*
EOF
    
    echo "$report_file"
}

display_summary() {
    echo ""
    log_header "Test Execution Summary"
    
    if [[ $TOTAL_TESTS -eq 0 ]]; then
        log_warning "No tests were executed!"
        return 1
    fi
    
    local success_rate
    success_rate=$(( TOTAL_PASSED * 100 / TOTAL_TESTS ))
    
    log_info "Tests executed: $TOTAL_TESTS"
    log_info "Passed: $TOTAL_PASSED"
    log_info "Failed: $TOTAL_FAILED"
    log_info "Success rate: $success_rate%"
    
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        log_success "All tests passed! 🎉"
        return 0
    else
        log_error "Some tests failed! Review the logs for details."
        return 1
    fi
}

# =============================================================================
# Setup and Cleanup
# =============================================================================

setup_test_environment() {
    log_info "Setting up enhanced test environment..."
    
    # Create results directory
    mkdir -p "$RESULTS_DIR"
    
    # Initialize log file
    cat > "$LOG_FILE" << EOF
Enhanced Dotfiles Testing Framework - Test Run Log
==================================================
Start Time: $(date)
Platform: $(uname -a)
Category: $CATEGORY
Quick Mode: $QUICK_MODE
Verbose Mode: $VERBOSE_MODE

EOF
    
    # Check dependencies
    local missing_deps=()
    for dep in "bash" "bc" "date"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi
    
    log_verbose "Test environment setup complete"
}

cleanup_test_environment() {
    log_verbose "Cleaning up test environment..."
    
    # Remove temporary files
    find "$RESULTS_DIR" -name "temp_*" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$RESULTS_DIR" -name "*_output_*.log" -mtime +7 -delete 2>/dev/null || true
    
    log_verbose "Cleanup complete"
}

# =============================================================================
# Help and Usage
# =============================================================================

show_help() {
    cat << EOF
Enhanced Dotfiles Testing Framework

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -q, --quick             Run only quick tests (skip performance tests)
    -c, --category CATEGORY Run specific test category
    -p, --parallel          Run tests in parallel (experimental)

CATEGORIES:
    infrastructure         Infrastructure and configuration tests
    unit                   Unit tests for individual functions
    integration           End-to-end integration tests
    performance           Performance and benchmark tests
    security              Security and compliance tests (Epic 6)
    all                   All test categories (default)

EXAMPLES:
    $0                              # Run all tests
    $0 --category unit              # Run only unit tests
    $0 --quick --category unit      # Run unit tests in quick mode
    $0 --verbose --category all     # Run all tests with verbose output

RESULTS:
    All test results are saved in: $RESULTS_DIR
    Logs include timestamps for tracking and debugging

For more information, see: docs/testing.md
EOF
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    local exit_code=0
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
                log_verbose "Verbose mode enabled"
                shift
                ;;
            -q|--quick)
                QUICK_MODE=true
                log_info "Quick mode enabled"
                shift
                ;;
            -c|--category)
                CATEGORY="$2"
                log_info "Category: $CATEGORY"
                shift 2
                ;;
            -p|--parallel)
                PARALLEL_TESTS=true
                log_info "Parallel mode enabled (experimental)"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Setup
    setup_test_environment || exit 1
    
    # Main test execution
    log_header "Enhanced Dotfiles Testing Framework"
    log_info "Starting test execution for category: $CATEGORY"
    
    # Discover and run tests
    if ! discover_tests "$CATEGORY"; then
        exit_code=1
    fi
    
    # Generate comprehensive report
    local report_file
    report_file=$(generate_comprehensive_report)
    log_info "Comprehensive report generated: $report_file"
    
    # Display summary
    if ! display_summary; then
        exit_code=1
    fi
    
    # Cleanup
    cleanup_test_environment
    
    # Final status
    if [[ $exit_code -eq 0 ]]; then
        log_success "Testing completed successfully!"
    else
        log_error "Testing completed with failures!"
    fi
    
    exit $exit_code
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi