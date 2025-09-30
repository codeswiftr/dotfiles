#!/usr/bin/env bash
# Test: Neovim Keymap Regression Tests
# Purpose: Verify critical keybindings are properly configured after migration
# Epic 5/9: Neovim Migration Remediation

set -euo pipefail

# Get script directory and source testing framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../utils/test_framework.sh
source "$DOTFILES_ROOT/tests/utils/test_framework.sh"

TEST_NAME="Neovim Keymap Regression Tests"
NVIM_CONFIG="$DOTFILES_ROOT/config/nvim"

# ============================================================================
# Helper Functions
# ============================================================================

# Check if a keybinding exists in the keymaps file
check_keymap_exists() {
    local key="$1"
    local description="$2"
    local file="$NVIM_CONFIG/lua/core/keymaps-unified.lua"

    if grep -q "\"$key\"" "$file"; then
        test_pass "Keybinding exists: $key ($description)"
        return 0
    else
        test_fail "Keybinding missing: $key ($description)"
        return 1
    fi
}

# Check if a pattern exists in the keymaps file
check_keymap_pattern() {
    local pattern="$1"
    local description="$2"
    local file="$NVIM_CONFIG/lua/core/keymaps-unified.lua"

    if grep -q "$pattern" "$file"; then
        test_pass "Pattern found: $description"
        return 0
    else
        test_fail "Pattern not found: $description"
        return 1
    fi
}

# Verify Neovim config structure
check_nvim_structure() {
    local path="$1"
    local description="$2"

    if [[ -f "$NVIM_CONFIG/$path" ]] || [[ -d "$NVIM_CONFIG/$path" ]]; then
        test_pass "Config exists: $description"
        return 0
    else
        test_fail "Config missing: $description"
        return 1
    fi
}

# ============================================================================
# Test: Git Merge Conflict Resolution Keybindings (CRITICAL)
# ============================================================================

test_git_merge_keybindings() {
    test_description "Git Merge Conflict Resolution Keybindings"

    check_keymap_pattern "diffget //3" "Git merge: get from right (theirs) - <leader>gh"
    check_keymap_pattern "diffget //2" "Git merge: get from left (ours) - <leader>gu"

    # Verify the leader keys are properly mapped
    check_keymap_exists "<leader>gh" "Git merge right (theirs)"
    check_keymap_exists "<leader>gu" "Git merge left (ours)"
}

# ============================================================================
# Test: Legacy Git Workflow Keybindings
# ============================================================================

test_git_workflow_keybindings() {
    test_description "Legacy Git Workflow Keybindings"

    check_keymap_exists "<leader>gs" "Git status (legacy)"
    check_keymap_exists "<leader>ga" "Git fetch all"
    check_keymap_exists "<leader>gb" "Git branches"
    check_keymap_exists "<leader>gc" "Git commit"
    check_keymap_exists "<leader>gp" "Git push"
    check_keymap_exists "<leader>gl" "Git log"
    check_keymap_exists "<leader>gd" "Git diff"

    # Verify correct commands are used
    check_keymap_pattern "Git fetch --all" "Git fetch all command"
    check_keymap_pattern "GBranches\\|Git branch" "Git branches command"
}

# ============================================================================
# Test: Window Management Keybindings
# ============================================================================

test_window_management() {
    test_description "Window Management Keybindings"

    check_keymap_exists "<leader>m" "Window maximize toggle"
    check_keymap_pattern "vim.t.maximized" "Window maximizer implementation"
    check_keymap_pattern "wincmd" "Window commands for maximize"
}

# ============================================================================
# Test: File Navigation Keybindings
# ============================================================================

test_file_navigation() {
    test_description "File Navigation Keybindings"

    check_keymap_exists "<leader>t" "Reveal file in tree"
    check_keymap_exists "<leader>e" "Toggle file explorer"
    check_keymap_pattern "NvimTreeFindFile" "NvimTree reveal file command"
    check_keymap_pattern "NvimTreeToggle" "NvimTree toggle command"
}

# ============================================================================
# Test: Split Navigation (Preserved from Legacy)
# ============================================================================

test_split_navigation() {
    test_description "Split Navigation Keybindings"

    check_keymap_exists "sh" "Navigate to left split"
    check_keymap_exists "sj" "Navigate to bottom split"
    check_keymap_exists "sk" "Navigate to top split"
    check_keymap_exists "sl" "Navigate to right split"
    check_keymap_exists "sv" "Split vertically"
    check_keymap_exists "ss" "Split horizontally"
}

# ============================================================================
# Test: Essential Editor Keybindings
# ============================================================================

test_essential_keybindings() {
    test_description "Essential Editor Keybindings"

    check_keymap_exists "<leader>w" "Save file"
    check_keymap_exists "<leader>q" "Quit"
    check_keymap_exists "<leader>ff" "Find files"
    check_keymap_exists "<leader>fg" "Live grep"
    check_keymap_exists "<leader>fb" "Buffer list"
}

# ============================================================================
# Test: Neovim Configuration Structure
# ============================================================================

test_config_structure() {
    test_description "Neovim Configuration Structure"

    check_nvim_structure "init.lua" "Main init.lua"
    check_nvim_structure "lua/core/keymaps-unified.lua" "Unified keymaps"
    check_nvim_structure "lua/core/tier-manager.lua" "Tier manager"
    check_nvim_structure "lua/tiers/tier1.lua" "Tier 1 config"
    check_nvim_structure "lua/tiers/tier2.lua" "Tier 2 config"
}

# ============================================================================
# Test: Auto-open Tree on Directory
# ============================================================================

test_auto_open_tree() {
    test_description "Auto-open Tree on Directory"

    local tier2_file="$NVIM_CONFIG/lua/tiers/tier2.lua"

    if grep -q "VimEnter" "$tier2_file" && \
       grep -q "isdirectory" "$tier2_file" && \
       grep -q "tree.open()" "$tier2_file"; then
        test_pass "Auto-open tree autocmd configured"
    else
        test_fail "Auto-open tree autocmd missing or incomplete"
    fi
}

# ============================================================================
# Test: Breaking Changes Documentation
# ============================================================================

test_breaking_changes_doc() {
    test_description "Breaking Changes Documentation"

    if [[ -f "$DOTFILES_ROOT/BREAKING_CHANGES.md" ]]; then
        test_pass "BREAKING_CHANGES.md exists"

        # Verify key sections are documented
        local doc="$DOTFILES_ROOT/BREAKING_CHANGES.md"

        if grep -q "Git Workflow" "$doc"; then
            test_pass "Git workflow changes documented"
        else
            test_fail "Git workflow section missing"
        fi

        if grep -q "<leader>gh" "$doc" && grep -q "<leader>gu" "$doc"; then
            test_pass "Merge conflict keybindings documented"
        else
            test_fail "Merge conflict keybindings not documented"
        fi

        if grep -q "Migration Timeline" "$doc"; then
            test_pass "Migration timeline documented"
        else
            test_fail "Migration timeline missing"
        fi
    else
        test_fail "BREAKING_CHANGES.md does not exist"
    fi
}

# ============================================================================
# Main Test Runner
# ============================================================================

main() {
    test_init "$TEST_NAME"

    # Verify Neovim config exists
    if [[ ! -d "$NVIM_CONFIG" ]]; then
        test_fail "Neovim config directory not found: $NVIM_CONFIG"
        test_suite_end
        exit 1
    fi

    # Run all test groups
    test_git_merge_keybindings
    test_git_workflow_keybindings
    test_window_management
    test_file_navigation
    test_split_navigation
    test_essential_keybindings
    test_config_structure
    test_auto_open_tree
    test_breaking_changes_doc

    test_suite_end
}

main "$@"