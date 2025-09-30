#!/usr/bin/env bash
# =============================================================================
# Mock Helpers - External Dependency Mocking
# Provides mocking capabilities for external commands and services
# =============================================================================

set -euo pipefail

# Mock configuration
MOCK_DIR="${MOCK_DIR:-$TEST_TEMP_DIR/mocks}"
MOCK_LOG="${MOCK_LOG:-$TEST_TEMP_DIR/mock.log}"

# =============================================================================
# Mock Infrastructure
# =============================================================================

# Initialize mock system
mock_init() {
    mkdir -p "$MOCK_DIR"
    export PATH="$MOCK_DIR:$PATH"
    hash -r 2>/dev/null || true

    # Clear mock log
    > "$MOCK_LOG"

    log_verbose "Mock system initialized at $MOCK_DIR"
}

# Clean up mock system
mock_cleanup() {
    if [[ -d "$MOCK_DIR" ]]; then
        rm -rf "$MOCK_DIR"
    fi
    
    if [[ -f "$MOCK_LOG" ]]; then
        rm -f "$MOCK_LOG"
    fi
}

# Create a mock command
create_mock() {
    local command_name="$1"
    local mock_behavior="${2:-success}"
    local return_code="${3:-0}"
    local output="${4:-}"
    
    local mock_script="$MOCK_DIR/$command_name"
    
    cat > "$mock_script" << EOF
#!/bin/sh
# Mock for: $command_name
# Behavior: $mock_behavior

# Log the call
echo "\$(date '+%Y-%m-%d %H:%M:%S') - $command_name called with args: \$*" >> "$MOCK_LOG"

case "$mock_behavior" in
    "success")
        if [ -n "$output" ]; then
            echo "$output"
        fi
        exit $return_code
        ;;
    "failure")
        if [ -n "$output" ]; then
            echo "$output" >&2
        fi
        exit $return_code
        ;;
    "interactive")
        # For commands that might need interactive responses
        if [ -n "$output" ]; then
            echo "$output"
        fi
        exit $return_code
        ;;
    *)
        echo "Unknown mock behavior: $mock_behavior" >&2
        exit 1
        ;;
esac
EOF
    
    chmod +x "$mock_script"
    log_verbose "Created mock for '$command_name' with behavior '$mock_behavior'"
}

# Verify a command was called
assert_mock_called() {
    local command_name="$1"
    local expected_calls="${2:-1}"
    local message="${3:-Mock '$command_name' should have been called $expected_calls times}"
    
    local actual_calls
    actual_calls=$(grep -c "^.* - $command_name called" "$MOCK_LOG" 2>/dev/null || echo "0")
    
    assert_equals "$expected_calls" "$actual_calls" "$message"
}

# Verify a command was called with specific arguments
assert_mock_called_with() {
    local command_name="$1"
    local expected_args="$2"
    local message="${3:-Mock '$command_name' should have been called with args: $expected_args}"
    
    if grep -q "^.* - $command_name called with args: $expected_args" "$MOCK_LOG" 2>/dev/null; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Mock log contents:"
        cat "$MOCK_LOG" >&2 || true
        return 1
    fi
}

# Verify a command was never called
assert_mock_not_called() {
    local command_name="$1"
    local message="${2:-Mock '$command_name' should not have been called}"
    
    if ! grep -q "^.* - $command_name called" "$MOCK_LOG" 2>/dev/null; then
        ((TEST_PASS_COUNT++))
        log_success "$message"
        return 0
    else
        ((TEST_FAIL_COUNT++))
        log_error "$message"
        log_error "Mock was called but should not have been"
        return 1
    fi
}

# =============================================================================
# Common System Command Mocks
# =============================================================================

# Mock git command
mock_git() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    case "$behavior" in
        "clean_repo")
            create_mock "git" "success" "0" "nothing to commit, working tree clean"
            ;;
        "dirty_repo")
            create_mock "git" "success" "0" "Changes not staged for commit:"
            ;;
        "version")
            create_mock "git" "success" "0" "${output:-git version 2.34.1}"
            ;;
        *)
            create_mock "git" "$behavior" "0" "$output"
            ;;
    esac
}

# Mock package managers
mock_brew() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    case "$behavior" in
        "installed")
            create_mock "brew" "success" "0" "${output:-/opt/homebrew/bin/brew}"
            ;;
        "not_installed")
            create_mock "brew" "failure" "1" "command not found: brew"
            ;;
        "list")
            create_mock "brew" "success" "0" "${output:-starship\nzoxide\neza\nbat\nripgrep}"
            ;;
        *)
            create_mock "brew" "$behavior" "0" "$output"
            ;;
    esac
}

mock_apt() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    create_mock "apt" "$behavior" "0" "$output"
    create_mock "apt-get" "$behavior" "0" "$output"
}

mock_pacman() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    create_mock "pacman" "$behavior" "0" "$output"
}

# Mock version managers
mock_mise() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    case "$behavior" in
        "version")
            create_mock "mise" "success" "0" "${output:-mise 2024.1.0}"
            ;;
        "list")
            create_mock "mise" "success" "0" "${output:-python@3.11.0\nnode@20.0.0}"
            ;;
        *)
            create_mock "mise" "$behavior" "0" "$output"
            ;;
    esac
}

# Mock Python and related tools
mock_python() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    case "$behavior" in
        "version")
            create_mock "python3" "success" "0" "${output:-Python 3.11.0}"
            ;;
        "import_yaml_success")
            create_mock "python3" "success" "0" ""
            ;;
        "import_yaml_fail")
            create_mock "python3" "failure" "1" "ModuleNotFoundError: No module named 'yaml'"
            ;;
        *)
            create_mock "python3" "$behavior" "0" "$output"
            ;;
    esac
    
    # Also mock python for compatibility
    create_mock "python" "$behavior" "0" "$output"
}

mock_pip() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    create_mock "pip3" "$behavior" "0" "$output"
    create_mock "pip" "$behavior" "0" "$output"
}

# Mock shell and system commands
mock_which() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    create_mock "which" "$behavior" "0" "$output"
}

mock_command() {
    local command_name="$1"
    local behavior="${2:-success}"
    local output="${3:-}"
    
    create_mock "command" "$behavior" "0" "$output"
}

# Mock filesystem operations
mock_ls() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    create_mock "ls" "$behavior" "0" "$output"
}

mock_find() {
    local behavior="${1:-success}"
    local output="${2:-}"
    
    create_mock "find" "$behavior" "0" "$output"
}

# =============================================================================
# DOT CLI Specific Mocks
# =============================================================================

# Mock external tools used by DOT CLI
mock_dotfiles_tools() {
    # Mock all common tools as installed and working
    mock_git "version"
    mock_brew "installed"
    mock_mise "version"
    mock_python "version"
    # Ensure installer invocations are captured without executing real bash
    create_mock "bash" "success" "0" ""
    
    # Mock command existence checks
    create_mock "command" "success" "0" ""
    create_mock "which" "success" "0" "/usr/local/bin/mock"
}

# Mock installation dependencies
mock_installation_deps() {
    mock_brew "installed"
    mock_python "import_yaml_success"
    mock_git "clean_repo"
    
    # Mock successful installations
    create_mock "curl" "success" "0" ""
    create_mock "wget" "success" "0" ""
}

# Mock system detection
mock_system_detection() {
    local os_type="${1:-macos}"
    
    case "$os_type" in
        "macos")
            create_mock "uname" "success" "0" "Darwin"
            mock_brew "installed"
            ;;
        "ubuntu")
            create_mock "uname" "success" "0" "Linux"
            mock_apt "success"
            # Mock os-release file
            create_temp_file "etc/os-release" "ID=ubuntu"
            ;;
        "arch")
            create_mock "uname" "success" "0" "Linux"
            mock_pacman "success"
            create_temp_file "etc/os-release" "ID=arch"
            ;;
    esac
}

# =============================================================================
# Mock Validation Helpers
# =============================================================================

# Get all mock calls for debugging
get_mock_calls() {
    if [[ -f "$MOCK_LOG" ]]; then
        cat "$MOCK_LOG"
    else
        echo "No mock calls recorded"
    fi
}

# Reset mock call log
reset_mock_calls() {
    > "$MOCK_LOG"
    log_verbose "Mock call log reset"
}
