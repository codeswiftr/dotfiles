#!/usr/bin/env bash
# =============================================================================
# Unit Tests for lib/cli/core.sh
# Tests core DOT CLI functionality: setup, check, update, reload
# =============================================================================

set -euo pipefail

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load test framework
source "$SCRIPT_DIR/../utils/test_framework.sh"
source "$SCRIPT_DIR/../utils/mock_helpers.sh"

# Load the module under test
source "$DOTFILES_DIR/lib/cli/core.sh"

# =============================================================================
# Test Setup and Teardown
# =============================================================================

setup_test() {
    test_init "CLI Core Functions"
    mock_init
    
    # Mock common dependencies
    mock_dotfiles_tools
    
    # Set up test environment variables
    export DOTFILES_DIR="$TEST_TEMP_DIR/dotfiles"
    export DOT_CLI_DIR="$DOTFILES_DIR/lib/cli"
    export DOT_TEST_MODE="true"
    export DOT_TEST_ALWAYS_INSTALL="true"
    
    # Create mock dotfiles structure
    mkdir -p "$DOTFILES_DIR"/{lib/cli,bin,config}
    create_temp_file "dotfiles/install.sh" "#!/bin/bash\necho 'Mock installer'"
    chmod +x "$TEST_TEMP_DIR/dotfiles/install.sh"
}

teardown_test() {
    mock_cleanup
    test_cleanup
}

# =============================================================================
# Test Functions
# =============================================================================

test_dot_setup_basic() {
    log_info "Testing basic dot_setup functionality"
    
    # Mock successful check to test --force behavior
    mock_git "clean_repo"
    
    # Test setup without force (should skip if already configured)
    assert_command_success "dot_setup" "dot_setup should succeed"
    
    # Verify installer was called
    assert_mock_called "bash" "1" "Installer should be called once"
    reset_mock_calls
}

test_dot_setup_force() {
    log_info "Testing dot_setup --force functionality"
    
    reset_mock_calls

    # Mock the installer
    create_mock "bash" "success" "0" "Installation complete"
    
    # Test setup with force flag
    assert_command_success "dot_setup --force" "dot_setup --force should succeed"
    
    # Verify installer was called even if system is already configured
    assert_mock_called "bash" "1" "Installer should be called with --force"
    reset_mock_calls
}

test_dot_setup_missing_installer() {
    log_info "Testing dot_setup with missing installer"
    
    # Remove the mock installer
    rm -f "$TEST_TEMP_DIR/dotfiles/install.sh"
    
    # Test setup should fail gracefully
    assert_command_failure "dot_setup --force" "dot_setup should fail without installer"
}

test_dot_check_basic() {
    log_info "Testing basic dot_check functionality"

    reset_mock_calls

    # Mock system tools as available
    create_mock "zsh" "success" "0" "zsh 5.8"
    create_mock "git" "success" "0" "git version 2.34.1"
    create_mock "nvim" "success" "0" "NVIM v0.8.0"
    create_mock "tmux" "success" "0" "tmux 3.3a"
    create_mock "starship" "success" "0" "starship 1.0.0"
    create_mock "eza" "success" "0" "eza 2024.1"
    create_mock "bat" "success" "0" "bat 0.24"
    create_mock "rg" "success" "0" "1"
    create_mock "fd" "success" "0" "fd 9.0"
    create_mock "fzf" "success" "0" "fzf 0.45"
    hash -r 2>/dev/null || true

    # Test health check and capture output for assertions
    local output status
    if output=$(dot_check 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_true "[[ $status -eq 0 ]]" "dot_check should exit successfully"
    assert_output_contains "echo '$output'" "All essential tools installed" "dot_check should report tools installed"
    assert_output_contains "echo '$output'" "All systems operational" "dot_check should report healthy status"
    assert_mock_called "tmux" "3" "tmux should be inspected"
    reset_mock_calls
}

test_dot_check_missing_tools() {
    log_info "Testing dot_check with missing tools"
    
    reset_mock_calls

    create_mock "git" "success" "0" "git version 2.34.1"

    local original_path="$PATH"
    local zsh_mock="$MOCK_DIR/zsh"
    local backup_zsh="$MOCK_DIR/zsh.bak"

    if [[ -f "$zsh_mock" ]]; then
        mv "$zsh_mock" "$backup_zsh"
    fi

    export PATH="$MOCK_DIR"
    hash -r 2>/dev/null || true

    local output status
    if output=$(dot_check 2>&1); then
        status=0
    else
        status=$?
    fi

    export PATH="$original_path"
    if [[ -f "$backup_zsh" ]]; then
        mv "$backup_zsh" "$zsh_mock"
    fi
    hash -r 2>/dev/null || true

    assert_true "[[ $status -ne 0 ]]" "dot_check should fail when zsh is missing"
    assert_output_contains "echo '$output'" "Missing tools" "dot_check should surface missing tools"
    assert_output_contains "echo '$output'" "zsh" "dot_check output should mention zsh"
    reset_mock_calls
}

test_dot_check_quiet_mode() {
    log_info "Testing dot_check --quiet functionality"
    
    # Mock tools as available
    create_mock "zsh" "success" "0" "zsh 5.8"
    create_mock "git" "success" "0" "git version 2.34.1"
    
    # Test quiet mode should produce minimal output
    local output
    output=$(dot_check --quiet 2>&1)
    
    # Quiet mode should have less verbose output
    assert_true "[[ ${#output} -lt 100 ]]" "Quiet mode should produce minimal output"
}

test_dot_update_basic() {
    log_info "Testing basic dot_update functionality"

    # Mock git operations for update
    reset_mock_calls
    mock_git "clean_repo"
    create_mock "git" "success" "0" "Already up to date."
    hash -r 2>/dev/null || true

    # Test update command
    assert_command_success "dot_update" "dot_update should succeed"

    local git_calls
    git_calls=$(grep -c " - git called" "$MOCK_LOG" 2>/dev/null || echo "0")
    assert_true "[[ $git_calls -ge 1 ]]" "git should be invoked during update"
    reset_mock_calls
}

test_dot_reload_basic() {
    log_info "Testing basic dot_reload functionality"
    
    # Mock shell reload operations
    create_mock "source" "success" "0" ""
    
    # Test reload command
    assert_command_success "dot_reload" "dot_reload should succeed"
}

test_dot_version() {
    log_info "Testing dot_version functionality"
    
    # Set version for testing
    export DOT_VERSION="1.0.0-test"
    
    # Test version command
    assert_output_contains "dot_version" "1.0.0-test" "Version should be displayed"
}

test_show_setup_help() {
    log_info "Testing setup help display"
    
    # Test help display
    assert_command_success "show_setup_help" "show_setup_help should succeed"
    
    # Should contain usage information
    assert_output_contains "show_setup_help" "setup" "Help should contain setup information"
}

test_error_handling() {
    log_info "Testing error handling in core functions"
    
    # Test with invalid directory
    export DOTFILES_DIR="/nonexistent/path"
    
    # Should handle missing dotfiles directory gracefully
    assert_command_failure "dot_setup --force" "Should fail with invalid DOTFILES_DIR"
    
    # Reset for other tests
    export DOTFILES_DIR="$TEST_TEMP_DIR/dotfiles"
}

test_environment_variables() {
    log_info "Testing environment variable handling"
    
    # Test with custom DOTFILES_DIR
    local custom_dir="$TEST_TEMP_DIR/custom_dotfiles"
    mkdir -p "$custom_dir"
    create_temp_file "custom_dotfiles/install.sh" "#!/bin/bash\necho 'Custom installer'"
    chmod +x "$custom_dir/install.sh"
    
    export DOTFILES_DIR="$custom_dir"
    
    # Should use custom directory
    assert_command_success "dot_setup --force" "Should work with custom DOTFILES_DIR"
}

test_performance_requirements() {
    log_info "Testing performance requirements for core functions"
    
    # Mock fast responses for all dependencies
    mock_dotfiles_tools
    
    # Test that core functions execute quickly
    assert_time_limit "dot_check --quiet" "2.0" "dot_check should execute within 2 seconds"
    assert_time_limit "dot_version" "0.1" "dot_version should execute within 100ms"
}

# =============================================================================
# Test Runner
# =============================================================================

run_all_tests() {
    setup_test
    
    # Run individual test functions
    run_test "test_dot_setup_basic" "DOT Setup - Basic functionality"
    run_test "test_dot_setup_force" "DOT Setup - Force flag"
    run_test "test_dot_setup_missing_installer" "DOT Setup - Missing installer"
    run_test "test_dot_check_basic" "DOT Check - Basic functionality"
    run_test "test_dot_check_missing_tools" "DOT Check - Missing tools"
    run_test "test_dot_check_quiet_mode" "DOT Check - Quiet mode"
    run_test "test_dot_update_basic" "DOT Update - Basic functionality"
    run_test "test_dot_reload_basic" "DOT Reload - Basic functionality"
    run_test "test_dot_version" "DOT Version - Display version"
    run_test "test_show_setup_help" "DOT Setup - Help display"
    run_test "test_error_handling" "Error Handling"
    run_test "test_environment_variables" "Environment Variables"
    run_test "test_performance_requirements" "Performance Requirements"
    
    teardown_test
    
    # Return test results
    test_summary
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
