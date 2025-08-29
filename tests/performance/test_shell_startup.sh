#!/usr/bin/env bash
# =============================================================================
# Performance Tests - Shell Startup Benchmarks
# Measures shell startup time and performance-critical operations
# =============================================================================

set -euo pipefail

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load test framework
source "$SCRIPT_DIR/../utils/test_framework.sh"

# =============================================================================
# Performance Test Configuration
# =============================================================================

# Performance thresholds (in seconds)
SHELL_STARTUP_THRESHOLD="0.350"    # 350ms maximum startup time
DOT_CLI_THRESHOLD="0.100"          # 100ms for DOT CLI basic commands
CONFIG_LOAD_THRESHOLD="0.200"      # 200ms for configuration loading

# Number of iterations for averaging
BENCHMARK_ITERATIONS=10

# =============================================================================
# Test Setup and Teardown
# =============================================================================

setup_performance_test() {
    test_init "Shell Startup Performance Tests"
    
    # Create test environment
    export TEST_DOTFILES_DIR="$TEST_TEMP_DIR/dotfiles"
    mkdir -p "$TEST_DOTFILES_DIR"
    
    # Copy essential configuration files
    cp -r "$DOTFILES_DIR/config" "$TEST_DOTFILES_DIR/"
    cp -r "$DOTFILES_DIR/bin" "$TEST_DOTFILES_DIR/"
    cp -r "$DOTFILES_DIR/lib" "$TEST_DOTFILES_DIR/"
    cp "$DOTFILES_DIR/.zshrc" "$TEST_DOTFILES_DIR/" 2>/dev/null || true
    
    # Make binaries executable
    chmod +x "$TEST_DOTFILES_DIR/bin"/* 2>/dev/null || true
    
    log_verbose "Performance test environment set up"
}

teardown_performance_test() {
    test_cleanup
}

# =============================================================================
# Benchmark Utility Functions
# =============================================================================

# Measure command execution time with high precision
benchmark_command() {
    local command="$1"
    local iterations="${2:-$BENCHMARK_ITERATIONS}"
    local total_time=0
    local i
    
    log_verbose "Benchmarking command: $command ($iterations iterations)"
    
    for ((i=1; i<=iterations; i++)); do
        local start_time end_time duration
        start_time=$(date +%s.%N)
        
        # Execute command (suppress output for clean benchmarking)
        eval "$command" >/dev/null 2>&1 || true
        
        end_time=$(date +%s.%N)
        duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        total_time=$(echo "$total_time + $duration" | bc -l 2>/dev/null || echo "$total_time")
        
        log_verbose "Iteration $i: ${duration}s"
    done
    
    # Calculate average
    local average_time
    average_time=$(echo "scale=6; $total_time / $iterations" | bc -l 2>/dev/null || echo "0")
    echo "$average_time"
}

# Compare benchmark result against threshold
assert_performance_threshold() {
    local actual_time="$1"
    local threshold="$2"  
    local description="$3"
    
    # Convert to milliseconds for display
    local actual_ms threshold_ms
    actual_ms=$(echo "scale=1; $actual_time * 1000" | bc -l 2>/dev/null || echo "0")
    threshold_ms=$(echo "scale=1; $threshold * 1000" | bc -l 2>/dev/null || echo "0")
    
    if (( $(echo "$actual_time <= $threshold" | bc -l 2>/dev/null || echo 0) )); then
        ((TEST_PASS_COUNT++))
        log_success "$description (${actual_ms}ms, threshold: ${threshold_ms}ms)"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$description (${actual_ms}ms, threshold: ${threshold_ms}ms)"
        return 1
    fi
}

# =============================================================================
# Shell Startup Performance Tests  
# =============================================================================

test_zsh_startup_time() {
    log_info "Testing Zsh startup time"
    
    # Create minimal test zshrc
    local test_zshrc="$TEST_TEMP_DIR/test_zshrc"
    cat > "$test_zshrc" << 'EOF'
# Minimal zshrc for startup testing
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [[ -f "$DOTFILES_DIR/config/zsh/core.zsh" ]]; then
    source "$DOTFILES_DIR/config/zsh/core.zsh"
fi
exit 0
EOF
    
    # Benchmark zsh startup with our configuration
    local startup_time
    startup_time=$(benchmark_command "ZDOTDIR='$TEST_TEMP_DIR' zsh -c 'source $test_zshrc'" 5)
    
    assert_performance_threshold "$startup_time" "$SHELL_STARTUP_THRESHOLD" \
        "Zsh startup should be under ${SHELL_STARTUP_THRESHOLD}s"
}

test_zsh_startup_with_history() {
    log_info "Testing Zsh startup time with history configuration"
    
    # Set up history configuration
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    
    # Create test zshrc with history configuration
    local test_zshrc="$TEST_TEMP_DIR/test_zshrc_history"
    cat > "$test_zshrc" << 'EOF'
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [[ -f "$DOTFILES_DIR/config/zsh/history-enhanced.zsh" ]]; then
    source "$DOTFILES_DIR/config/zsh/history-enhanced.zsh"
fi
exit 0
EOF
    
    # Benchmark with history enhancements
    local startup_time
    startup_time=$(benchmark_command "ZDOTDIR='$TEST_TEMP_DIR' zsh -c 'source $test_zshrc'" 5)
    
    assert_performance_threshold "$startup_time" "$SHELL_STARTUP_THRESHOLD" \
        "Zsh with history enhancements should be under ${SHELL_STARTUP_THRESHOLD}s"
}

test_configuration_loading_performance() {
    log_info "Testing individual configuration loading performance"
    
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    
    # Test core configuration loading
    if [[ -f "$TEST_DOTFILES_DIR/config/zsh/core.zsh" ]]; then
        local core_time
        core_time=$(benchmark_command "source '$TEST_DOTFILES_DIR/config/zsh/core.zsh'" 10)
        
        assert_performance_threshold "$core_time" "$CONFIG_LOAD_THRESHOLD" \
            "Core zsh configuration loading"
    else
        skip_test "Core zsh configuration not found"
    fi
    
    # Test history configuration loading
    if [[ -f "$TEST_DOTFILES_DIR/config/zsh/history-enhanced.zsh" ]]; then
        local history_time
        history_time=$(benchmark_command "source '$TEST_DOTFILES_DIR/config/zsh/history-enhanced.zsh'" 10)
        
        assert_performance_threshold "$history_time" "$CONFIG_LOAD_THRESHOLD" \
            "History configuration loading"
    else
        skip_test "History configuration not found"
    fi
}

test_dot_cli_performance() {
    log_info "Testing DOT CLI command performance"
    
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    export PATH="$TEST_DOTFILES_DIR/bin:$PATH"
    
    # Test DOT CLI help command
    if [[ -f "$TEST_DOTFILES_DIR/bin/dot" ]]; then
        local help_time
        help_time=$(benchmark_command "dot --help" 5)
        
        assert_performance_threshold "$help_time" "$DOT_CLI_THRESHOLD" \
            "DOT CLI help command"
        
        # Test DOT CLI version command
        local version_time  
        version_time=$(benchmark_command "dot version" 5)
        
        assert_performance_threshold "$version_time" "0.050" \
            "DOT CLI version command should be very fast"
    else
        skip_test "DOT CLI binary not found"
    fi
}

test_tool_loading_performance() {
    log_info "Testing tool loading performance"
    
    # Test common tool version checks (these should be fast)
    local tools=("git --version" "zsh --version" "python3 --version")
    
    for tool_cmd in "${tools[@]}"; do
        local tool_name
        tool_name=$(echo "$tool_cmd" | cut -d' ' -f1)
        
        if command -v "$tool_name" >/dev/null 2>&1; then
            local tool_time
            tool_time=$(benchmark_command "$tool_cmd" 3)
            
            assert_performance_threshold "$tool_time" "0.500" \
                "Tool version check: $tool_name"
        else
            skip_test "Tool not available: $tool_name"
        fi
    done
}

test_memory_usage_baseline() {
    log_info "Testing memory usage baseline"
    
    # Get memory usage of basic shell
    local baseline_memory
    baseline_memory=$(bash -c 'ps -o rss= -p $$' 2>/dev/null || echo "0")
    
    # Get memory usage with our configuration
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    local configured_memory
    configured_memory=$(zsh -c '
        if [[ -f "$DOTFILES_DIR/config/zsh/core.zsh" ]]; then
            source "$DOTFILES_DIR/config/zsh/core.zsh"
        fi
        ps -o rss= -p $$
    ' 2>/dev/null || echo "0")
    
    # Calculate memory overhead
    local memory_overhead=$((configured_memory - baseline_memory))
    
    log_info "Memory usage: baseline=${baseline_memory}KB, configured=${configured_memory}KB, overhead=${memory_overhead}KB"
    
    # Memory overhead should be reasonable (less than 50MB)
    assert_true "[[ $memory_overhead -lt 51200 ]]" \
        "Memory overhead should be under 50MB (actual: ${memory_overhead}KB)"
}

test_startup_performance_regression() {
    log_info "Testing for performance regressions"
    
    # Run startup test multiple times to check consistency
    local times=()
    local i
    
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    
    for ((i=1; i<=5; i++)); do
        local start_time end_time duration
        start_time=$(date +%s.%N)
        
        # Simulate realistic startup
        zsh -c 'source ~/.zshrc 2>/dev/null || true; exit 0' 2>/dev/null || true
        
        end_time=$(date +%s.%N)
        duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        times+=("$duration")
    done
    
    # Calculate variance to detect inconsistent performance
    local total=0
    for time in "${times[@]}"; do
        total=$(echo "$total + $time" | bc -l 2>/dev/null || echo "$total")
    done
    local average=$(echo "scale=6; $total / ${#times[@]}" | bc -l 2>/dev/null || echo "0")
    
    # Check that all times are reasonably close to average (within 50%)
    local max_variance
    max_variance=$(echo "$average * 1.5" | bc -l 2>/dev/null || echo "999")
    
    local consistent=true
    for time in "${times[@]}"; do
        if (( $(echo "$time > $max_variance" | bc -l 2>/dev/null || echo 0) )); then
            consistent=false
            break
        fi
    done
    
    if [[ "$consistent" == "true" ]]; then
        ((TEST_PASS_COUNT++))
        log_success "Startup performance is consistent (avg: ${average}s)"
    else
        ((TEST_FAIL_COUNT++))
        log_error "Startup performance is inconsistent"
        log_error "Times: ${times[*]}"
    fi
}

# =============================================================================
# Performance Monitoring and Reporting
# =============================================================================

generate_performance_report() {
    log_info "Generating performance report"
    
    local report_file="$TEST_TEMP_DIR/performance_report.md"
    
    cat > "$report_file" << EOF
# Dotfiles Performance Report

Generated: $(date)
Test Environment: $(uname -a)

## Performance Thresholds

- Shell Startup: < ${SHELL_STARTUP_THRESHOLD}s
- DOT CLI Commands: < ${DOT_CLI_THRESHOLD}s  
- Configuration Loading: < ${CONFIG_LOAD_THRESHOLD}s

## Test Results

$(test_summary 2>&1 | tail -n +2)

## Recommendations

EOF
    
    # Add recommendations based on results
    if [[ $TEST_FAIL_COUNT -gt 0 ]]; then
        cat >> "$report_file" << EOF
- Review failed performance tests above
- Consider optimizing slow configuration files
- Check for expensive operations in shell startup
EOF
    else
        cat >> "$report_file" << EOF
- All performance tests passed ✅
- Current configuration meets performance requirements
EOF
    fi
    
    log_info "Performance report saved to: $report_file"
}

# =============================================================================
# Test Runner
# =============================================================================

run_performance_tests() {
    setup_performance_test
    
    # Check for required tools
    if ! command -v bc >/dev/null 2>&1; then
        log_error "bc (calculator) is required for performance tests"
        return 1
    fi
    
    # Run performance tests
    run_test "test_zsh_startup_time" "Zsh Startup Time"
    run_test "test_zsh_startup_with_history" "Zsh Startup with History"
    run_test "test_configuration_loading_performance" "Configuration Loading Performance"
    run_test "test_dot_cli_performance" "DOT CLI Performance"
    run_test "test_tool_loading_performance" "Tool Loading Performance" 
    run_test "test_memory_usage_baseline" "Memory Usage Baseline"
    run_test "test_startup_performance_regression" "Startup Performance Regression"
    
    # Generate performance report
    generate_performance_report
    
    teardown_performance_test
    
    # Return test results
    test_summary
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_performance_tests
fi