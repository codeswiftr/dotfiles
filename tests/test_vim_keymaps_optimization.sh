#!/usr/bin/env bash
# ============================================================================
# Test Suite: Vim Keymaps Optimization
# Tests the optimized key binding system for usability and consistency
# ============================================================================

source "$(dirname "$0")/utils/test_framework.sh"
source "$(dirname "$0")/utils/nvim_test_helpers.sh"

# Test configuration
TEST_NAME="Vim Keymaps Optimization"
NVIM_CONFIG_PATH="/Users/bogdan/dotfiles/config/nvim"
OPTIMIZED_KEYMAPS_PATH="$NVIM_CONFIG_PATH/lua/core/keymaps-optimized.lua"

# ============================================================================
# Test Setup and Teardown
# ============================================================================

setup_test_environment() {
    # Create temporary nvim config for testing
    export TEST_NVIM_CONFIG_DIR="/tmp/nvim_test_config"
    rm -rf "$TEST_NVIM_CONFIG_DIR"
    mkdir -p "$TEST_NVIM_CONFIG_DIR/lua/core"
    
    # Copy optimized keymaps for testing
    cp "$OPTIMIZED_KEYMAPS_PATH" "$TEST_NVIM_CONFIG_DIR/lua/core/"
    
    # Create minimal init.lua for testing
    cat > "$TEST_NVIM_CONFIG_DIR/init.lua" << 'EOF'
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("core.keymaps-optimized")
EOF
}

cleanup_test_environment() {
    rm -rf "$TEST_NVIM_CONFIG_DIR"
}

# ============================================================================
# Core Functionality Tests
# ============================================================================

test_optimized_keymaps_file_syntax() {
    test_description "Optimized keymaps file has valid Lua syntax"
    
    if lua -c "$OPTIMIZED_KEYMAPS_PATH" 2>/dev/null; then
        test_pass "Syntax is valid"
    else
        test_fail "Syntax errors found in optimized keymaps"
        lua -c "$OPTIMIZED_KEYMAPS_PATH" 2>&1
    fi
}

test_tier_1_instant_access_bindings() {
    test_description "Tier 1 instant access bindings are properly defined"
    
    local required_bindings=(
        "C-p.*find_files"
        "C-s.*save"
        "C-f.*current_buffer_fuzzy_find"
        "C-g.*live_grep"
    )
    
    local missing_bindings=()
    for binding in "${required_bindings[@]}"; do
        if ! grep -q "$binding" "$OPTIMIZED_KEYMAPS_PATH"; then
            missing_bindings+=("$binding")
        fi
    done
    
    if [[ ${#missing_bindings[@]} -eq 0 ]]; then
        test_pass "All Tier 1 instant access bindings present"
    else
        test_fail "Missing Tier 1 bindings: ${missing_bindings[*]}"
    fi
}

test_tier_2_daily_operations_bindings() {
    test_description "Tier 2 daily operations use single letter after leader"
    
    local daily_operations=(
        "<leader>e.*explorer"
        "<leader>b.*buffers"
        "<leader>g.*Git"
        "<leader>t.*terminal"
        "<leader>r.*run"
    )
    
    local missing_operations=()
    for operation in "${daily_operations[@]}"; do
        if ! grep -q "$operation" "$OPTIMIZED_KEYMAPS_PATH"; then
            missing_operations+=("$operation")
        fi
    done
    
    if [[ ${#missing_operations[@]} -eq 0 ]]; then
        test_pass "All Tier 2 daily operations present"
    else
        test_fail "Missing Tier 2 operations: ${missing_operations[*]}"
    fi
}

test_code_navigation_consistency() {
    test_description "Code navigation uses consistent 'g' prefix pattern"
    
    local nav_bindings=(
        'gd.*definition'
        'gr.*references'
        'gi.*implementation'
        'gt.*type_definition'
    )
    
    local consistent=true
    for binding in "${nav_bindings[@]}"; do
        if ! grep -q "$binding" "$OPTIMIZED_KEYMAPS_PATH"; then
            consistent=false
            break
        fi
    done
    
    if [[ "$consistent" == "true" ]]; then
        test_pass "Code navigation bindings follow consistent pattern"
    else
        test_fail "Code navigation bindings are inconsistent"
    fi
}

test_code_actions_consistency() {
    test_description "Code actions use consistent '<leader>c' prefix pattern"
    
    local code_actions=(
        '<leader>ca.*code.*action'
        '<leader>cf.*format'
        '<leader>cr.*rename'
        '<leader>cd.*documentation'
    )
    
    local consistent=true
    for action in "${code_actions[@]}"; do
        if ! grep -q "$action" "$OPTIMIZED_KEYMAPS_PATH"; then
            consistent=false
            break
        fi
    done
    
    if [[ "$consistent" == "true" ]]; then
        test_pass "Code action bindings follow consistent pattern"
    else
        test_fail "Code action bindings are inconsistent"
    fi
}

test_git_operations_logical_grouping() {
    test_description "Git operations are logically grouped under <leader>g prefix"
    
    local git_ops=(
        '<leader>g".*Git'        # Main git status
        '<leader>ga.*stage'      # Add/stage
        '<leader>gc.*commit'     # Commit
        '<leader>gp.*push'       # Push
        '<leader>gl.*log'        # Log
        '<leader>gb.*blame'      # Blame
    )
    
    local grouped_correctly=true
    for op in "${git_ops[@]}"; do
        if ! grep -q "$op" "$OPTIMIZED_KEYMAPS_PATH"; then
            grouped_correctly=false
            break
        fi
    done
    
    if [[ "$grouped_correctly" == "true" ]]; then
        test_pass "Git operations properly grouped under <leader>g"
    else
        test_fail "Git operations grouping is inconsistent"
    fi
}

# ============================================================================
# Usability and Ergonomics Tests
# ============================================================================

test_no_duplicate_exit_methods() {
    test_description "Only one consistent method to exit insert mode"
    
    local jk_count=$(grep -c '"jk"' "$OPTIMIZED_KEYMAPS_PATH")
    local jj_count=$(grep -c '"jj"' "$OPTIMIZED_KEYMAPS_PATH")
    
    if [[ $jk_count -eq 1 && $jj_count -eq 0 ]]; then
        test_pass "Single consistent exit method (jk only)"
    elif [[ $jk_count -eq 0 && $jj_count -eq 1 ]]; then
        test_pass "Single consistent exit method (jj only)"
    else
        test_fail "Multiple exit methods found: jk($jk_count), jj($jj_count)"
    fi
}

test_leader_key_usage_optimization() {
    test_description "Leader key usage is optimized (not overloaded)"
    
    local leader_count=$(grep -c '<leader>' "$OPTIMIZED_KEYMAPS_PATH")
    local ctrl_count=$(grep -c '<C-' "$OPTIMIZED_KEYMAPS_PATH")
    
    # Optimized design should have more direct Ctrl bindings for frequent actions
    if [[ $ctrl_count -ge 6 && $leader_count -le 25 ]]; then
        test_pass "Leader key usage optimized (Ctrl: $ctrl_count, Leader: $leader_count)"
    else
        test_fail "Leader key overloaded (Ctrl: $ctrl_count, Leader: $leader_count)"
    fi
}

test_visual_mode_optimizations() {
    test_description "Visual mode has proper text manipulation optimizations"
    
    local visual_optimizations=(
        'keymap("v".*"<".*"<gv"'    # Maintain selection when indenting left
        'keymap("v".*">".*">gv"'    # Maintain selection when indenting right
        'keymap("v".*"J".*":m"'     # Move text blocks down
        'keymap("v".*"K".*":m"'     # Move text blocks up
        'keymap("v".*"p".*"_dP"'    # Better paste (preserve clipboard)
    )
    
    local optimizations_present=0
    for optimization in "${visual_optimizations[@]}"; do
        if grep -q "$optimization" "$OPTIMIZED_KEYMAPS_PATH"; then
            ((optimizations_present++))
        fi
    done
    
    if [[ $optimizations_present -eq 5 ]]; then
        test_pass "All visual mode optimizations present"
    else
        test_fail "Missing visual mode optimizations: $((5 - optimizations_present))/5"
    fi
}

# ============================================================================
# Modern Enhancement Tests
# ============================================================================

test_os_native_integration() {
    test_description "OS-native shortcuts are integrated where beneficial"
    
    local native_shortcuts=(
        'C-p'   # Universal find files (VS Code, Atom, etc.)
        'C-s'   # Universal save (OS-native)
        'C-f'   # Universal find in file (OS-native)
    )
    
    local native_count=0
    for shortcut in "${native_shortcuts[@]}"; do
        if grep -q "$shortcut" "$OPTIMIZED_KEYMAPS_PATH"; then
            ((native_count++))
        fi
    done
    
    if [[ $native_count -eq 3 ]]; then
        test_pass "OS-native shortcuts properly integrated"
    else
        test_fail "Missing OS-native shortcuts: $((3 - native_count))/3"
    fi
}

test_context_aware_functionality() {
    test_description "Context-aware commands are implemented"
    
    # Check for context-aware run command
    if grep -q "filetype.*python\|filetype.*javascript\|filetype.*rust" "$OPTIMIZED_KEYMAPS_PATH"; then
        test_pass "Context-aware run command implemented"
    else
        test_fail "Context-aware functionality missing"
    fi
}

test_progressive_disclosure() {
    test_description "Help system provides progressive disclosure"
    
    local help_features=(
        '<leader>\?.*WhichKey'      # Show all keybindings
        '<leader>h.*function'       # Custom help with tiered information
        'desc.*=.*'                 # Descriptive text for all bindings
    )
    
    local help_count=0
    for feature in "${help_features[@]}"; do
        if grep -q "$feature" "$OPTIMIZED_KEYMAPS_PATH"; then
            ((help_count++))
        fi
    done
    
    if [[ $help_count -eq 3 ]]; then
        test_pass "Progressive disclosure help system present"
    else
        test_fail "Incomplete help system: $help_count/3 features"
    fi
}

# ============================================================================
# Performance and Safety Tests
# ============================================================================

test_emergency_commands_safety() {
    test_description "Emergency commands have appropriate safety measures"
    
    local safe_commands=(
        '<leader>Q.*qa!'           # Force quit (explicit)
        '<leader>q.*confirm'       # Safe quit (with confirmation)
        '<leader>W.*wa'            # Save all (safe)
    )
    
    local safety_count=0
    for command in "${safe_commands[@]}"; do
        if grep -q "$command" "$OPTIMIZED_KEYMAPS_PATH"; then
            ((safety_count++))
        fi
    done
    
    if [[ $safety_count -eq 3 ]]; then
        test_pass "Emergency commands have proper safety measures"
    else
        test_fail "Missing safety measures: $((3 - safety_count))/3"
    fi
}

test_command_line_efficiency() {
    test_description "Command line navigation is optimized"
    
    local cmdline_optimizations=(
        'keymap("c".*"<C-h>".*"<Left>"'
        'keymap("c".*"<C-l>".*"<Right>"'
        'keymap("c".*"<C-a>".*"<Home>"'
        'keymap("c".*"<C-e>".*"<End>"'
    )
    
    local cmdline_count=0
    for optimization in "${cmdline_optimizations[@]}"; do
        if grep -q "$optimization" "$OPTIMIZED_KEYMAPS_PATH"; then
            ((cmdline_count++))
        fi
    done
    
    if [[ $cmdline_count -eq 4 ]]; then
        test_pass "Command line navigation optimized"
    else
        test_fail "Missing command line optimizations: $((4 - cmdline_count))/4"
    fi
}

# ============================================================================
# Integration Tests
# ============================================================================

test_nvim_config_integration() {
    test_description "Optimized keymaps integrate properly with existing config"
    
    # Test if the optimized keymaps can be loaded without errors
    if command -v nvim >/dev/null 2>&1; then
        # Create test init file that loads optimized keymaps
        local test_init="/tmp/test_nvim_init.lua"
        cat > "$test_init" << 'EOF'
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Mock telescope commands to avoid plugin dependency errors
vim.cmd = function(cmd) 
    if cmd:match("Telescope") then
        print("Mock telescope command: " .. cmd)
    else
        vim.api.nvim_cmd({cmd = cmd, args = {}}, {})
    end
end

dofile("/Users/bogdan/dotfiles/config/nvim/lua/core/keymaps-optimized.lua")
EOF
        
        if nvim --headless -u "$test_init" -c "qall!" 2>/dev/null; then
            test_pass "Optimized keymaps load without errors"
        else
            test_fail "Optimized keymaps have loading errors"
        fi
        
        rm -f "$test_init"
    else
        test_skip "Neovim not available for integration test"
    fi
}

# ============================================================================
# Main Test Runner
# ============================================================================

run_vim_keymaps_optimization_tests() {
    test_suite_start "$TEST_NAME"
    
    # Setup
    setup_test_environment
    
    # Core functionality tests
    test_optimized_keymaps_file_syntax
    test_tier_1_instant_access_bindings
    test_tier_2_daily_operations_bindings
    test_code_navigation_consistency
    test_code_actions_consistency
    test_git_operations_logical_grouping
    
    # Usability tests
    test_no_duplicate_exit_methods
    test_leader_key_usage_optimization
    test_visual_mode_optimizations
    
    # Modern enhancement tests
    test_os_native_integration
    test_context_aware_functionality
    test_progressive_disclosure
    
    # Performance and safety tests
    test_emergency_commands_safety
    test_command_line_efficiency
    
    # Integration tests
    test_nvim_config_integration
    
    # Cleanup
    cleanup_test_environment
    
    test_suite_end
}

# Run tests if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_vim_keymaps_optimization_tests
fi