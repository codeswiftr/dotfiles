#!/usr/bin/env bash
# =============================================================================
# Integration Test - Full Installation Flow
# Tests the complete dotfiles installation process end-to-end
# =============================================================================

set -euo pipefail

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load test framework
source "$SCRIPT_DIR/../utils/test_framework.sh"
source "$SCRIPT_DIR/../utils/mock_helpers.sh"

# =============================================================================
# Test Configuration
# =============================================================================

INSTALL_TIMEOUT=60  # Maximum time for installation tests
MOCK_HOME="$TEST_TEMP_DIR/mock_home"
MOCK_DOTFILES="$TEST_TEMP_DIR/mock_dotfiles"

# =============================================================================
# Test Setup and Teardown
# =============================================================================

setup_integration_test() {
    test_init "Full Installation Integration Test"

    # Create mock home directory (don't mock system commands -- let install.sh use real tools)
    MOCK_HOME="$TEST_TEMP_DIR/mock_home"
    MOCK_DOTFILES="$TEST_TEMP_DIR/mock_dotfiles"
    mkdir -p "$MOCK_HOME"

    # Save real HOME, set mock
    REAL_HOME="$HOME"
    export HOME="$MOCK_HOME"

    # Create mock dotfiles directory with real files
    mkdir -p "$MOCK_DOTFILES"/{bin,lib/cli,config,scripts,tests}
    cp "$DOTFILES_DIR/install.sh" "$MOCK_DOTFILES/"
    cp -r "$DOTFILES_DIR/config" "$MOCK_DOTFILES/"
    cp -r "$DOTFILES_DIR/lib" "$MOCK_DOTFILES/"
    cp -rP "$DOTFILES_DIR/bin" "$MOCK_DOTFILES/" 2>/dev/null || true

    chmod +x "$MOCK_DOTFILES/install.sh"
    find "$MOCK_DOTFILES/bin" -maxdepth 1 -type f -exec chmod +x {} \; 2>/dev/null || true

    # Set DOTFILES_DIR for the mock environment
    export DOTFILES_DIR="$MOCK_DOTFILES"

    log_verbose "Integration test environment set up at $MOCK_DOTFILES"
}

teardown_integration_test() {
    export HOME="$REAL_HOME"
    export DOTFILES_DIR="$REAL_HOME/dotfiles"
    test_cleanup
}

# =============================================================================
# Installation Test Functions
# =============================================================================

test_minimal_installation() {
    log_info "Testing minimal profile installation"
    
    cd "$MOCK_DOTFILES"
    
    # Test minimal installation
    assert_time_limit "./install.sh install minimal --dry-run" "$INSTALL_TIMEOUT" \
        "Minimal installation dry-run should complete within ${INSTALL_TIMEOUT}s"
    
    # Verify expected tools would be installed
    assert_output_contains "./install.sh install minimal --dry-run" "Installing group: essential" \
        "Should attempt to install essential group"
        
    assert_output_contains "./install.sh install minimal --dry-run" "zsh" \
        "Should include zsh in minimal installation"
}

test_standard_installation() {
    log_info "Testing standard profile installation"
    
    cd "$MOCK_DOTFILES"
    
    # Test standard installation (dry run)
    assert_time_limit "./install.sh install standard --dry-run" "$INSTALL_TIMEOUT" \
        "Standard installation dry-run should complete within ${INSTALL_TIMEOUT}s"
    
    # Verify expected groups
    assert_output_contains "./install.sh install standard --dry-run" "Installing group: essential" \
        "Should install essential group"
        
    assert_output_contains "./install.sh install standard --dry-run" "Installing group: modern_cli" \
        "Should install modern_cli group"
        
    assert_output_contains "./install.sh install standard --dry-run" "Installing group: development" \
        "Should install development group"
}

test_full_installation() {
    log_info "Testing full profile installation"
    
    cd "$MOCK_DOTFILES"
    
    # Test full installation (dry run)
    assert_time_limit "./install.sh install full --dry-run" "$INSTALL_TIMEOUT" \
        "Full installation dry-run should complete within ${INSTALL_TIMEOUT}s"
    
    # Should include AI tools and optional components
    assert_output_contains "./install.sh install full --dry-run" "ai_tools" \
        "Should include AI tools in full installation"
}

test_cross_platform_compatibility() {
    log_info "Testing cross-platform installation compatibility"

    cd "$MOCK_DOTFILES"

    # Test that dry-run works on current platform
    assert_command_success "./install.sh install minimal --dry-run" \
        "Should work on current platform"
}

test_yaml_parsing_robustness() {
    log_info "Testing YAML parsing robustness"
    
    cd "$MOCK_DOTFILES"
    
    # Test that YAML parsing works (either PyYAML or sed fallback)
    assert_command_success "./install.sh install minimal --dry-run" \
        "Should parse tools.yaml successfully"
}

test_tool_verification() {
    log_info "Testing tool verification during installation"

    cd "$MOCK_DOTFILES"

    # Dry run should list tools it would install/verify
    assert_command_success "./install.sh install minimal --dry-run" \
        "Should verify tool installations"

    # Dry run output should mention DRY RUN
    assert_output_contains "./install.sh install minimal --dry-run" "DRY RUN" \
        "Should indicate dry run mode"
}

test_configuration_linking() {
    log_info "Testing configuration file linking"
    
    cd "$MOCK_DOTFILES"
    
    # Run installation that includes linking
    assert_command_success "./install.sh link --dry-run" \
        "Configuration linking should work"
    
    # Dry run should show linking actions
    assert_output_contains "./install.sh link --dry-run" "Would link" \
        "Should handle configuration file linking"
}

test_health_check_integration() {
    log_info "Testing integrated health check"
    
    cd "$MOCK_DOTFILES"
    
    # Should include health check (uses real bin/dot from mock_dotfiles)
    assert_command_success "./install.sh install minimal --dry-run" \
        "Should include health check"
}

test_performance_optimization() {
    log_info "Testing performance optimization during installation"
    
    cd "$MOCK_DOTFILES"
    
    # Installation should complete within reasonable time
    assert_time_limit "./install.sh install standard --dry-run" "$INSTALL_TIMEOUT" \
        "Installation should be reasonably fast"
    
    # Should not have excessive tool checking
    local start_time end_time
    start_time=$(date +%s)
    ./install.sh install minimal --dry-run >/dev/null 2>&1
    end_time=$(date +%s)
    
    local duration=$((end_time - start_time))
    assert_true "[[ $duration -lt 30 ]]" \
        "Dry run installation should complete in under 30 seconds"
}

# =============================================================================
# DOT CLI Integration Tests
# =============================================================================

test_dot_cli_integration() {
    log_info "Testing DOT CLI integration after installation"
    
    # Set up environment for DOT CLI
    export DOTFILES_DIR="$MOCK_DOTFILES"
    export PATH="$MOCK_DOTFILES/bin:$PATH"
    
    cd "$MOCK_DOTFILES"
    
    # Test DOT CLI basic functionality
    assert_command_success "./bin/dot --help" \
        "DOT CLI should display help"
    
    assert_output_contains "DOTFILES_DIR=$MOCK_DOTFILES ./bin/dot --help" "setup" \
        "DOT CLI help should contain main commands"
}

test_shell_configuration_integration() {
    log_info "Testing shell configuration integration"
    
    cd "$MOCK_DOTFILES"
    
    # Test shell configuration components
    assert_file_exists "config/zsh/core.zsh" \
        "Core zsh configuration should exist"
    
    assert_file_exists "config/zsh/history-enhanced.zsh" \
        "Enhanced history configuration should exist"
    
    # Should handle shell configuration without errors
    assert_command_success "source config/zsh/core.zsh" \
        "Core zsh configuration should load without errors"
}

# =============================================================================
# Test Runner
# =============================================================================

run_integration_tests() {
    setup_integration_test
    
    # Run installation tests
    run_test "test_minimal_installation" "Minimal Installation"
    run_test "test_standard_installation" "Standard Installation" 
    run_test "test_full_installation" "Full Installation"
    run_test "test_cross_platform_compatibility" "Cross-Platform Compatibility"
    run_test "test_yaml_parsing_robustness" "YAML Parsing Robustness"
    run_test "test_tool_verification" "Tool Verification"
    run_test "test_configuration_linking" "Configuration Linking"
    run_test "test_health_check_integration" "Health Check Integration"
    run_test "test_performance_optimization" "Performance Optimization"
    
    # Run CLI integration tests
    run_test "test_dot_cli_integration" "DOT CLI Integration"
    run_test "test_shell_configuration_integration" "Shell Configuration Integration"
    
    teardown_integration_test
    
    # Return test results
    test_summary
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_integration_tests
fi