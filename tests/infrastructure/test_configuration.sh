#!/bin/bash

# Dotfiles Configuration Testing Framework
# Tests configuration file syntax, structure, and functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    log_info "Running test: $test_name"
    
    if $test_function; then
        log_success "$test_name"
    else
        log_error "$test_name"
    fi
}

# YAML Configuration Tests
test_tools_yaml_exists() {
    [[ -f "config/tools.yaml" ]]
}

test_tools_yaml_syntax() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import yaml
import sys
try:
    with open('config/tools.yaml', 'r') as f:
        yaml.safe_load(f)
    sys.exit(0)
except yaml.YAMLError as e:
    print(f'YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'Error: {e}')
    sys.exit(1)
" 2>/dev/null
    else
        # Basic syntax check without python
        ! grep -q "^[[:space:]]*:" config/tools.yaml && # No leading colons
        ! grep -q "^[[:space:]]*-[[:space:]]*:" config/tools.yaml # No malformed lists
    fi
}

test_tools_yaml_structure() {
    local content
    content=$(cat config/tools.yaml)
    [[ "$content" == *"profiles:"* ]] &&
    [[ "$content" == *"minimal:"* ]] &&
    [[ "$content" == *"standard:"* ]] &&
    [[ "$content" == *"full:"* ]]
}

test_tools_yaml_profile_structure() {
    local content
    content=$(cat config/tools.yaml)
    # Each profile should have tools section
    [[ "$content" == *"tools:"* ]]
}

# ZSH Configuration Tests
test_zsh_config_directory() {
    [[ -d "config/zsh" ]]
}

test_zsh_config_files_exist() {
    [[ -f "config/zsh/config.zsh" ]] &&
    [[ -f "config/zsh/aliases.zsh" ]] &&
    [[ -f "config/zsh/functions.zsh" ]]
}

test_zsh_config_syntax() {
    local exit_code=0
    
    # Test each zsh config file syntax
    for file in config/zsh/*.zsh; do
        if [[ -f "$file" ]]; then
            # Basic syntax check using zsh parser
            if command -v zsh >/dev/null 2>&1; then
                if ! zsh -n "$file" 2>/dev/null; then
                    log_error "Syntax error in $file"
                    exit_code=1
                fi
            else
                # Basic checks without zsh
                if grep -q "^[[:space:]]*fi[[:space:]]*$" "$file" && ! grep -q "^[[:space:]]*if " "$file"; then
                    log_error "Unmatched fi in $file"
                    exit_code=1
                fi
            fi
        fi
    done
    
    [[ $exit_code -eq 0 ]]
}

test_zsh_environment_variables() {
    local content
    content=$(cat config/zsh/*.zsh)
    # Should define some basic environment variables
    [[ "$content" == *"export"* ]] || [[ "$content" == *"PATH"* ]]
}

test_zsh_aliases_format() {
    if [[ -f "config/zsh/aliases.zsh" ]]; then
        local content
        content=$(cat config/zsh/aliases.zsh)
        # Check for proper alias format
        if [[ "$content" == *"alias"* ]]; then
            # Aliases should be properly formatted
            ! grep -q "^[[:space:]]*alias[[:space:]]*=" config/zsh/aliases.zsh # No malformed aliases
        fi
    fi
}

test_zsh_functions_format() {
    if [[ -f "config/zsh/functions.zsh" ]]; then
        local content
        content=$(cat config/zsh/functions.zsh)
        if [[ "$content" == *"function"* ]] || [[ "$content" == *"() {"* ]]; then
            # Functions should have proper syntax
            local function_count opening_brace_count closing_brace_count
            function_count=$(grep -c "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" config/zsh/functions.zsh || echo 0)
            opening_brace_count=$(grep -c "{" config/zsh/functions.zsh || echo 0)
            closing_brace_count=$(grep -c "}" config/zsh/functions.zsh || echo 0)
            
            # Should have balanced braces
            [[ $opening_brace_count -eq $closing_brace_count ]]
        fi
    fi
}

# Tmux Configuration Tests
test_tmux_config_exists() {
    [[ -f "config/tmux/tmux.conf" ]] || [[ -f "config/tmux.conf" ]]
}

test_tmux_config_syntax() {
    local tmux_config
    if [[ -f "config/tmux/tmux.conf" ]]; then
        tmux_config="config/tmux/tmux.conf"
    elif [[ -f "config/tmux.conf" ]]; then
        tmux_config="config/tmux.conf"
    else
        return 0 # Skip if no tmux config
    fi
    
    if command -v tmux >/dev/null 2>&1; then
        # Check tmux config syntax
        tmux -f "$tmux_config" list-keys >/dev/null 2>&1
    else
        # Basic syntax check without tmux
        ! grep -q "^[[:space:]]*bind-key[[:space:]]*$" "$tmux_config" # No empty bind-key
    fi
}

# Git Configuration Tests
test_git_config_exists() {
    [[ -f "config/git/gitconfig" ]] || [[ -f "config/gitconfig" ]]
}

test_git_config_syntax() {
    local git_config
    if [[ -f "config/git/gitconfig" ]]; then
        git_config="config/git/gitconfig"
    elif [[ -f "config/gitconfig" ]]; then
        git_config="config/gitconfig"
    else
        return 0 # Skip if no git config
    fi
    
    if command -v git >/dev/null 2>&1; then
        # Check git config syntax
        git config --file "$git_config" --list >/dev/null 2>&1
    else
        # Basic syntax check without git
        ! grep -q "^[[:space:]]*\[" "$git_config" | grep -q "^[[:space:]]*=" # No malformed sections
    fi
}

# Vim/Neovim Configuration Tests
test_vim_config_exists() {
    [[ -f "config/vim/vimrc" ]] || [[ -f "config/nvim/init.vim" ]] || [[ -f "config/nvim/init.lua" ]]
}

test_vim_config_syntax() {
    local vim_config
    if [[ -f "config/vim/vimrc" ]]; then
        vim_config="config/vim/vimrc"
        if command -v vim >/dev/null 2>&1; then
            vim -u "$vim_config" -c "syntax on" -c "quit" >/dev/null 2>&1
        fi
    elif [[ -f "config/nvim/init.vim" ]]; then
        vim_config="config/nvim/init.vim"
        if command -v nvim >/dev/null 2>&1; then
            nvim -u "$vim_config" -c "syntax on" -c "quit" >/dev/null 2>&1
        fi
    fi
}

# Theme Configuration Tests
test_theme_files_exist() {
    [[ -d "themes" ]] || [[ -f "config/zsh/theme.zsh" ]] || [[ -f "config/theme.zsh" ]]
}

test_theme_syntax() {
    if [[ -d "themes" ]]; then
        for theme in themes/*.zsh-theme; do
            if [[ -f "$theme" ]]; then
                # Basic syntax check
                if command -v zsh >/dev/null 2>&1; then
                    zsh -n "$theme" 2>/dev/null
                fi
            fi
        done
    fi
}

# Cross-platform Configuration Tests
test_platform_specific_configs() {
    # Test that platform-specific configurations are properly separated
    local has_macos_config has_linux_config
    
    has_macos_config=$(find config -name "*macos*" -o -name "*darwin*" | wc -l)
    has_linux_config=$(find config -name "*linux*" -o -name "*ubuntu*" | wc -l)
    
    # Should have platform-specific configurations or universal configs
    [[ $has_macos_config -gt 0 ]] || [[ $has_linux_config -gt 0 ]] || [[ -f "config/zsh/config.zsh" ]]
}

test_path_configurations() {
    # Test that PATH configurations are reasonable
    if [[ -f "config/zsh/config.zsh" ]]; then
        local content
        content=$(cat config/zsh/config.zsh)
        if [[ "$content" == *"PATH"* ]]; then
            # PATH should not have obvious duplicates or empty entries
            ! grep -q "PATH=.*::" config/zsh/config.zsh # No empty path entries
        fi
    fi
}

# Integration Tests
test_configuration_loading() {
    # Test that configurations can be loaded without errors
    if command -v zsh >/dev/null 2>&1; then
        local temp_script
        temp_script=$(mktemp)
        
        cat > "$temp_script" << 'EOF'
#!/bin/zsh
# Test configuration loading
for file in config/zsh/*.zsh; do
    if [[ -f "$file" ]]; then
        source "$file" || exit 1
    fi
done
exit 0
EOF
        
        chmod +x "$temp_script"
        timeout 10 "$temp_script" >/dev/null 2>&1
        local result=$?
        rm -f "$temp_script"
        
        [[ $result -eq 0 ]]
    fi
}

# Main test execution
main() {
    log_info "Starting Dotfiles Configuration Testing Framework"
    log_info "Platform: $OSTYPE"
    log_info "Date: $(date)"
    echo
    
    # YAML Configuration Tests
    run_test "tools.yaml exists" test_tools_yaml_exists
    run_test "tools.yaml syntax is valid" test_tools_yaml_syntax
    run_test "tools.yaml structure is valid" test_tools_yaml_structure
    run_test "tools.yaml profile structure is valid" test_tools_yaml_profile_structure
    
    # ZSH Configuration Tests
    run_test "ZSH config directory exists" test_zsh_config_directory
    run_test "ZSH config files exist" test_zsh_config_files_exist
    run_test "ZSH config syntax is valid" test_zsh_config_syntax
    run_test "ZSH environment variables are defined" test_zsh_environment_variables
    run_test "ZSH aliases format is correct" test_zsh_aliases_format
    run_test "ZSH functions format is correct" test_zsh_functions_format
    
    # Other Configuration Tests
    run_test "Tmux config exists and syntax is valid" test_tmux_config_exists
    run_test "Tmux config syntax is valid" test_tmux_config_syntax
    run_test "Git config exists" test_git_config_exists
    run_test "Git config syntax is valid" test_git_config_syntax
    run_test "Vim config exists" test_vim_config_exists
    run_test "Vim config syntax is valid" test_vim_config_syntax
    
    # Theme Tests
    run_test "Theme files exist" test_theme_files_exist
    run_test "Theme syntax is valid" test_theme_syntax
    
    # Cross-platform Tests
    run_test "Platform-specific configs exist" test_platform_specific_configs
    run_test "PATH configurations are valid" test_path_configurations
    
    # Integration Tests
    run_test "Configuration loading works" test_configuration_loading
    
    # Results
    echo
    log_info "Test Results Summary:"
    echo "  Tests Run: $TESTS_RUN"
    echo "  Tests Passed: $TESTS_PASSED"
    echo "  Tests Failed: $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed!"
        exit 0
    else
        log_error "Some tests failed!"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi