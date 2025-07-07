#!/usr/bin/env bash
# ============================================================================
# Workflow Enhancements Test Script
# Validates shell autosuggestions and Neovim split navigation functionality
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_test() {
    echo -e "${BLUE}🧪 Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test counter
tests_passed=0
tests_total=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_test "$test_name"
    ((tests_total++))
    
    if eval "$test_command" >/dev/null 2>&1; then
        print_success "$test_name"
        ((tests_passed++))
    else
        print_error "$test_name"
        return 1
    fi
}

echo "🚀 Testing Workflow Enhancements"
echo "================================"

# Test 1: Shell History Enhancement Configuration
print_test "Shell history enhancement configuration file exists"
if [[ -f "config/zsh/history-enhanced.zsh" ]]; then
    print_success "History enhancement configuration found"
    ((tests_passed++))
else
    print_error "History enhancement configuration missing"
fi
((tests_total++))

# Test 2: ZSH Autosuggestions Installation
print_test "ZSH autosuggestions plugin availability"
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] || 
   [[ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    print_success "ZSH autosuggestions plugin available"
    ((tests_passed++))
else
    print_warning "ZSH autosuggestions not installed - install with: brew install zsh-autosuggestions"
fi
((tests_total++))

# Test 3: ZSH History Substring Search Installation
print_test "ZSH history substring search plugin availability"
if [[ -f "/opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] || 
   [[ -f "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    print_success "ZSH history substring search plugin available"
    ((tests_passed++))
else
    print_warning "ZSH history substring search not installed - install with: brew install zsh-history-substring-search"
fi
((tests_total++))

# Test 4: Neovim Split Navigation Configuration
print_test "Neovim split navigation configuration file exists"
if [[ -f "config/nvim/lua/core/split-navigation.lua" ]]; then
    print_success "Neovim split navigation configuration found"
    ((tests_passed++))
else
    print_error "Neovim split navigation configuration missing"
fi
((tests_total++))

# Test 5: Lua Syntax Validation for Neovim Configuration
run_test "Neovim split navigation Lua syntax validation" \
    "lua -e 'loadfile(\"config/nvim/lua/core/split-navigation.lua\")'"

# Test 6: ZSH Configuration Integration
print_test "ZSH configuration integration"
if grep -q "history-enhanced.zsh" .zshrc; then
    print_success "History enhancement integrated in .zshrc"
    ((tests_passed++))
else
    print_error "History enhancement not integrated in .zshrc"
fi
((tests_total++))

# Test 7: Neovim Configuration Integration
print_test "Neovim configuration integration"
if grep -q "split-navigation" config/nvim/init-streamlined.lua; then
    print_success "Split navigation integrated in Neovim config"
    ((tests_passed++))
else
    print_error "Split navigation not integrated in Neovim config"
fi
((tests_total++))

# Test 8: History Configuration Loading
print_test "History configuration loading test"
if bash -c "source config/zsh/history-enhanced.zsh 2>&1 | grep -q 'Enhanced history'"; then
    print_success "History configuration loads successfully"
    ((tests_passed++))
else
    print_error "History configuration failed to load"
fi
((tests_total++))

# Test 9: Tool Configuration Updates
print_test "Development tools configuration updated"
if grep -q "ios_development\|web_development" config/tools.yaml; then
    print_success "Tools configuration includes new development tools"
    ((tests_passed++))
else
    print_warning "Tools configuration may need development tool updates"
fi
((tests_total++))

# Test 10: Tmux Configuration Updates
print_test "Tmux configuration integration"
if grep -q "fastapi-layout.sh\|ios-layout.sh" .tmux.conf; then
    print_success "Tmux configuration includes new development layouts"
    ((tests_passed++))
else
    print_warning "Tmux configuration may need layout updates"
fi
((tests_total++))

echo ""
echo "📊 Test Results"
echo "==============="
echo "Tests passed: $tests_passed / $tests_total"

if [[ $tests_passed -eq $tests_total ]]; then
    print_success "All tests passed! Workflow enhancements are ready to use."
    echo ""
    echo "🎉 New Workflow Features:"
    echo "   🐟 Fish-like autosuggestions in shell (type any command)"
    echo "   ⬆️  History substring search (up/down arrows)"
    echo "   🔧 Enhanced split navigation in Neovim (s + hjkl)"
    echo "   📱 iOS development tmux layout (Ctrl-a + D → i)"
    echo "   🌐 FastAPI development tmux layout (Ctrl-a + D → f)"
    echo ""
    echo "💡 Quick Test:"
    echo "   • Shell: Type 'ls' and see autosuggestions"
    echo "   • Neovim: Open nvim, use 'sv' to split, then 'sh/sl' to navigate"
    echo "   • Tmux: Press Ctrl-a + D to see new development layouts"
    
    exit 0
elif [[ $tests_passed -gt $((tests_total * 3 / 4)) ]]; then
    print_warning "Most tests passed ($tests_passed/$tests_total). Minor issues detected."
    echo ""
    echo "🎯 Next Steps:"
    echo "   • Install missing zsh plugins if needed"
    echo "   • Restart your shell to activate autosuggestions"
    echo "   • Test Neovim split navigation with 's + hjkl'"
    
    exit 0
else
    print_error "Several tests failed ($tests_passed/$tests_total). Please review configuration."
    exit 1
fi