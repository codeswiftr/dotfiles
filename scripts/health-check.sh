#!/usr/bin/env bash

# ============================================================================
# Dotfiles Health Check Script
# Verifies that all tools and formatters are properly installed
# ============================================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Emojis
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"

print_success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

check_optional_command() {
    if command -v "$1" >/dev/null 2>&1; then
        print_success "$1 is installed (optional)"
        return 0
    else
        print_warning "$1 is not installed (optional)"
        return 1
    fi
}

echo "🔍 Dotfiles Health Check"
echo "========================"
echo ""

echo "📦 Core Tools:"
print_info "OS: $(uname -s)"
print_info "Shell: $SHELL"
check_command "starship"
check_command "zoxide" 
check_command "eza"
check_command "bat"
check_command "rg"
check_command "fd"
check_command "fzf"
check_command "mise"
check_command "git"
check_command "nvim"
check_command "tmux"

echo ""
echo "🧰 Package Managers:"
if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew (brew) is installed"
    else
        print_warning "Homebrew (brew) not found"
    fi
fi

echo ""
echo "🐍 Python Environment:"
check_command "python3"
check_command "uv"
check_command "ruff"

echo ""
echo "📦 Node.js Environment:"
check_command "node"
check_command "npm"
check_optional_command "bun"

echo ""
echo "🎨 Code Formatters:"
check_command "prettier"
check_command "stylua"
check_optional_command "swift-format"

echo ""
echo "🤖 AI Tools:"
check_optional_command "claude"
check_optional_command "gemini"
check_optional_command "aider"

echo ""
echo "🔌 Neovim Providers:"
if python3 -c "import pynvim" 2>/dev/null; then
    print_success "Python neovim package is installed"
else
    print_error "Python neovim package is missing (run: pip install pynvim)"
fi

if npm list -g neovim >/dev/null 2>&1; then
    print_success "Node.js neovim package is installed"
else
    print_error "Node.js neovim package is missing (run: npm install -g neovim)"
fi

echo ""
echo "📁 Configuration Files:"
configs=(
    "$HOME/.zshrc"
    "$HOME/.config/nvim/init.lua"
    "$HOME/.tmux.conf"
    "$HOME/.config/starship.toml"
)

for config in "${configs[@]}"; do
    if [[ -f "$config" ]]; then
        print_success "$(basename "$config") exists"
    else
        print_error "$(basename "$config") is missing"
    fi
done

echo ""
echo "✨ Health check complete!"
echo ""
echo "💡 Tips:"
echo "  • Run 'nvim +checkhealth' for detailed Neovim diagnostics"
echo "  • Use 'df-update' to check for dotfiles updates"
echo "  • Install missing optional tools with your package manager"