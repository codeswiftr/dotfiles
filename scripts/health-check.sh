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

OUTPUT_JSON=false

for arg in "$@"; do
    case "$arg" in
        --json)
            OUTPUT_JSON=true
            shift
            ;;
    esac
done

echo "🔍 Dotfiles Health Check"
echo "========================"
echo ""

echo "📦 Core Tools:"
OS_NAME="$(uname -s)"
print_info "OS: $OS_NAME"
print_info "Shell: $SHELL"
tools=(starship zoxide eza bat rg fd fzf mise git nvim tmux)
declare -A TOOL_STATUS
for t in "${tools[@]}"; do
    if check_command "$t"; then
        TOOL_STATUS[$t]="ok"
    else
        TOOL_STATUS[$t]="missing"
    fi
done

echo ""
echo "🧰 Package Managers:"
if [[ "$OS_NAME" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew (brew) is installed"
    else
        print_warning "Homebrew (brew) not found"
    fi
fi

echo ""
echo "🐍 Python Environment:"
py_tools=(python3 uv ruff)
for pt in "${py_tools[@]}"; do
    check_command "$pt" || true
done

echo ""
echo "📦 Node.js Environment:"
check_command "node" || true
check_command "npm" || true
check_optional_command "bun" || true

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

declare -A CONFIG_STATUS
for config in "${configs[@]}"; do
    if [[ -f "$config" ]]; then
        print_success "$(basename "$config") exists"
        CONFIG_STATUS["$(basename "$config")"]="ok"
    else
        print_error "$(basename "$config") is missing"
        CONFIG_STATUS["$(basename "$config")"]="missing"
    fi
done

if [[ "$OUTPUT_JSON" == true ]]; then
    # Compact JSON summary for agents/CI
    printf '{"os":"%s","shell":"%s","tools":{' "$OS_NAME" "$SHELL"
    first=1
    for k in "${!TOOL_STATUS[@]}"; do
        [[ $first -eq 1 ]] && first=0 || printf ','
        printf '"%s":"%s"' "$k" "${TOOL_STATUS[$k]}"
    done
    printf '},"configs":{'
    first=1
    for k in "${!CONFIG_STATUS[@]}"; do
        [[ $first -eq 1 ]] && first=0 || printf ','
        printf '"%s":"%s"' "$k" "${CONFIG_STATUS[$k]}"
    done
    printf '}}\n'
else
    echo ""
    echo "✨ Health check complete!"
    echo ""
    echo "💡 Tips:"
    echo "  • Run 'nvim +checkhealth' for detailed Neovim diagnostics"
    echo "  • Use 'df-update' to check for dotfiles updates"
    echo "  • Install missing optional tools with your package manager"
fi