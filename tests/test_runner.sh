#!/bin/bash

# Dotfiles Testing Framework - Main Test Runner
# Runs all infrastructure tests and provides comprehensive reporting

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$TEST_DIR/.." && pwd)"
RESULTS_DIR="$TEST_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$RESULTS_DIR/test_run_$TIMESTAMP.log"

# Test categories
INFRASTRUCTURE_TESTS=(
    "test_installation.sh"
    "test_health_checks.sh"
    "test_configuration.sh"
)

# Results tracking
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
FAILED_TESTS=()

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
    
    if (cd "$DOTFILES_DIR" && timeout 30 "$test_path") > "$test_output_file" 2>&1; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        log_success "$test_file completed successfully (${duration}s)"
        
        # Append test output to log
        cat "$test_output_file" >> "$LOG_FILE"
        
        # Extract test results from the test output
        local test_output
        test_output=$(grep -E "(Tests Run:|Tests Passed:|Tests Failed:)" "$test_output_file" || echo "")
        
        if [[ -n "$test_output" ]]; then
            local tests_run tests_passed tests_failed
            tests_run=$(echo "$test_output" | grep "Tests Run:" | grep -o '[0-9]*' | head -1)
            tests_passed=$(echo "$test_output" | grep "Tests Passed:" | grep -o '[0-9]*' | head -1)
            tests_failed=$(echo "$test_output" | grep "Tests Failed:" | grep -o '[0-9]*' | head -1)
            
            if [[ -n "$tests_run" ]]; then
                TOTAL_TESTS=$((TOTAL_TESTS + tests_run))
                TOTAL_PASSED=$((TOTAL_PASSED + tests_passed))
                TOTAL_FAILED=$((TOTAL_FAILED + tests_failed))
                
                if [[ "$tests_failed" -gt 0 ]]; then
                    FAILED_TESTS+=("$test_file")
                fi
            fi
        fi
        
        rm -f "$test_output_file"
        return 0
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        log_error "$test_file failed (${duration}s)"
        
        # Append test output to log even on failure
        cat "$test_output_file" >> "$LOG_FILE"
        
        FAILED_TESTS+=("$test_file")
        rm -f "$test_output_file"
        return 1
    fi
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
        for failed_test in "${FAILED_TESTS[@]}"; do
            if [[ "$failed_test" == "$test_file" ]]; then
                status="❌ FAILED"
                break
            fi
        done
        echo "- $test_file: $status" >> "$report_file"
    done
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
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

# Main execution
main() {
    local exit_code=0
    
    # Header
    log_header "Dotfiles Testing Framework"
    log_info "Starting comprehensive dotfiles testing..."
    
    # Setup
    setup_test_environment
    
    # Run infrastructure tests
    log_header "Infrastructure Tests"
    for test_file in "${INFRASTRUCTURE_TESTS[@]}"; do
        if ! run_test_category "infrastructure" "$test_file"; then
            exit_code=1
        fi
        echo "" | tee -a "$LOG_FILE"
    done
    
    # Generate reports
    log_header "Test Results"
    
    if [[ $TOTAL_TESTS -eq 0 ]]; then
        log_warning "No tests were executed!"
        exit_code=1
    else
        log_info "Total Tests: $TOTAL_TESTS"
        log_info "Tests Passed: $TOTAL_PASSED"
        log_info "Tests Failed: $TOTAL_FAILED"
        
        if [[ $TOTAL_FAILED -eq 0 ]]; then
            log_success "All tests passed! 🎉"
        else
            log_error "Some tests failed! ❌"
            log_info "Failed tests: ${FAILED_TESTS[*]}"
            exit_code=1
        fi
    fi
    
    # Generate summary report
    local report_file
    report_file=$(generate_summary_report)
    log_info "Summary report generated: $report_file"
    
    # Display quick summary
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        local success_rate
        success_rate=$(( TOTAL_PASSED * 100 / TOTAL_TESTS ))
        
        echo "" | tee -a "$LOG_FILE"
        log_header "Quick Summary"
        echo "Success Rate: $success_rate%" | tee -a "$LOG_FILE"
        echo "Log File: $LOG_FILE" | tee -a "$LOG_FILE"
        echo "Report File: $report_file" | tee -a "$LOG_FILE"
    fi
    
    exit $exit_code
}

# Help function
show_help() {
    cat << EOF
Dotfiles Testing Framework - Main Test Runner

Usage: $0 [OPTIONS]

Options:
  -h, --help     Show this help message
  -v, --verbose  Enable verbose output
  --quick        Run only quick tests (skip performance tests)
  --category     Run specific test category (infrastructure)

Examples:
  $0                    # Run all tests
  $0 --category infrastructure  # Run only infrastructure tests
  $0 --quick            # Run quick tests only

Test Categories:
  infrastructure        # Installation, health checks, configuration

Results:
  All test results are saved in: $RESULTS_DIR
  Detailed logs are saved with timestamps for tracking

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        --quick)
            log_info "Quick mode enabled"
            shift
            ;;
        --category)
            log_info "Category mode: $2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi