#!/usr/bin/env bash
# ============================================================================
# Neovim Testing Helper Functions
# Common utilities for testing Neovim configurations
# ============================================================================

# Mock Neovim environment for testing
setup_mock_nvim_env() {
    export NVIM_TEST_MODE=1
    export XDG_CONFIG_HOME="/tmp/nvim_test_config"
    export XDG_DATA_HOME="/tmp/nvim_test_data"
}

# Clean up mock environment
cleanup_mock_nvim_env() {
    unset NVIM_TEST_MODE
    unset XDG_CONFIG_HOME
    unset XDG_DATA_HOME
    rm -rf "/tmp/nvim_test_config" "/tmp/nvim_test_data"
}

# Validate Lua syntax for Neovim config files
validate_lua_syntax() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "ERROR: File $file does not exist"
        return 1
    fi
    
    # Prefer luac if available
    if command -v luac >/dev/null 2>&1; then
        if ! luac -p "$file" 2>/dev/null; then
            echo "ERROR: Syntax error in $file"
            luac -p "$file" 2>&1
            return 1
        fi
        return 0
    fi
    
    # Fallback to lua interpreter with loadfile
    if ! lua -e "assert(loadfile(arg[1]))" "$file" 2>/dev/null; then
        echo "ERROR: Syntax error in $file"
        lua -e "assert(loadfile(arg[1]))" "$file" 2>&1
        return 1
    fi
    
    return 0
}

# Extract keybindings from Lua file
extract_keybindings() {
    local file="$1"
    grep -E 'keymap\(' "$file" | sed -E 's/.*keymap\([^"]*"([^"]*)"[^"]*"([^"]*)".*desc.*=.*"([^"]*)".*/\1 -> \2 (\3)/'
}

# Count leader key usage
count_leader_usage() {
    local file="$1"
    grep -c '<leader>' "$file" 2>/dev/null || echo 0
}

# Count control key usage
count_ctrl_usage() {
    local file="$1" 
    grep -c '<C-' "$file" 2>/dev/null || echo 0
}

# Check if binding pattern exists
binding_exists() {
    local file="$1"
    local pattern="$2"
    
    grep -q "$pattern" "$file" 2>/dev/null
}