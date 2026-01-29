#!/usr/bin/env bash
# =============================================================================
# Unified Setup Script
# One-command setup for new machines
# Usage: ./scripts/setup.sh [profile]
# Profiles: minimal, standard (default), full, ai-dev
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_step() { echo -e "${CYAN}▶  $1${NC}"; }

# Profile definitions
PROFILE="${1:-standard}"

echo ""
echo "======================================"
echo "🚀 Dotfiles Setup - Profile: $PROFILE"
echo "======================================"
echo ""

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)
            if [[ -f /etc/arch-release ]]; then
                echo "arch"
            elif [[ -f /etc/debian_version ]]; then
                echo "debian"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

OS=$(detect_os)
log_info "Detected OS: $OS"

# =============================================================================
# Step 1: Install package manager packages
# =============================================================================
install_packages() {
    log_step "Installing system packages..."
    
    case "$OS" in
        macos)
            # Install Homebrew if needed
            if ! command -v brew &>/dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add to PATH for Apple Silicon
                if [[ -f /opt/homebrew/bin/brew ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi
            
            # Install from Brewfile
            if [[ -f "$DOTFILES_DIR/config/platform/Brewfile" ]]; then
                log_info "Installing packages from Brewfile..."
                brew bundle --file="$DOTFILES_DIR/config/platform/Brewfile" || true
            fi
            ;;
            
        arch)
            log_info "Installing packages from pacman.txt..."
            if [[ -f "$DOTFILES_DIR/config/platform/pacman.txt" ]]; then
                # Filter comments and empty lines
                grep -v '^#' "$DOTFILES_DIR/config/platform/pacman.txt" | grep -v '^$' | \
                    xargs sudo pacman -S --noconfirm --needed || true
            fi
            ;;
            
        debian)
            log_info "Installing packages from apt.txt..."
            sudo apt update
            if [[ -f "$DOTFILES_DIR/config/platform/apt.txt" ]]; then
                grep -v '^#' "$DOTFILES_DIR/config/platform/apt.txt" | grep -v '^$' | \
                    xargs sudo apt install -y || true
            fi
            ;;
    esac
    
    log_success "System packages installed"
}

# =============================================================================
# Step 2: Install modern CLI tools (cross-platform)
# =============================================================================
install_modern_tools() {
    log_step "Installing modern CLI tools..."
    
    # Starship prompt
    if ! command -v starship &>/dev/null; then
        log_info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Zoxide (smart cd)
    if ! command -v zoxide &>/dev/null; then
        log_info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    # Mise (version manager)
    if ! command -v mise &>/dev/null; then
        log_info "Installing mise..."
        curl https://mise.run | sh
    fi
    
    # UV (Python package manager)
    if ! command -v uv &>/dev/null; then
        log_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    
    # Bun (JavaScript runtime)
    if ! command -v bun &>/dev/null; then
        log_info "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # Atuin (shell history) - optional
    if [[ "$PROFILE" == "full" ]] || [[ "$PROFILE" == "ai-dev" ]]; then
        if ! command -v atuin &>/dev/null; then
            log_info "Installing atuin..."
            curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || true
        fi
    fi
    
    log_success "Modern CLI tools installed"
}

# =============================================================================
# Step 3: Create symlinks
# =============================================================================
create_symlinks() {
    log_step "Creating symlinks..."
    
    # Backup existing files
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Files to symlink
    local files=(
        ".zshrc"
        ".tmux.conf"
        ".gitconfig"
        ".vimrc"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
            mv "$HOME/$file" "$backup_dir/" 2>/dev/null || true
        fi
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
        log_info "Linked: $file"
    done
    
    # Config directory symlinks
    mkdir -p "$HOME/.config"
    
    # Neovim
    if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$backup_dir/" 2>/dev/null || true
    fi
    ln -sf "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    log_info "Linked: .config/nvim"
    
    # Starship
    ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
    log_info "Linked: .config/starship.toml"
    
    # Add dotfiles bin to PATH check
    if ! grep -q 'dotfiles/bin' "$HOME/.zshrc.local" 2>/dev/null; then
        echo 'export PATH="$HOME/dotfiles/bin:$PATH"' >> "$HOME/.zshrc.local"
    fi
    
    log_success "Symlinks created"
}

# =============================================================================
# Step 4: Install AI tools (for ai-dev and full profiles)
# =============================================================================
install_ai_tools() {
    if [[ "$PROFILE" != "ai-dev" ]] && [[ "$PROFILE" != "full" ]]; then
        return
    fi
    
    log_step "Installing AI coding tools..."
    
    # Claude Code
    if ! command -v claude &>/dev/null; then
        case "$OS" in
            macos) brew install --cask claude 2>/dev/null || true ;;
            *) curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null || true ;;
        esac
    fi
    
    # Aider
    if ! command -v aider &>/dev/null; then
        if command -v uv &>/dev/null; then
            uv tool install aider-chat || true
        fi
    fi
    
    # OpenCode
    if ! command -v opencode &>/dev/null; then
        case "$OS" in
            macos) brew install anomalyco/tap/opencode 2>/dev/null || true ;;
            *) curl -fsSL https://opencode.ai/install | bash 2>/dev/null || true ;;
        esac
    fi
    
    log_success "AI tools installed"
}

# =============================================================================
# Step 5: Set Zsh as default shell
# =============================================================================
set_default_shell() {
    log_step "Setting Zsh as default shell..."
    
    if [[ "$SHELL" != *"zsh"* ]]; then
        local zsh_path=$(command -v zsh)
        if [[ -n "$zsh_path" ]]; then
            # Add to /etc/shells if needed
            if ! grep -q "$zsh_path" /etc/shells; then
                echo "$zsh_path" | sudo tee -a /etc/shells
            fi
            chsh -s "$zsh_path" || log_info "Run manually: chsh -s $zsh_path"
        fi
    fi
    
    log_success "Default shell configured"
}

# =============================================================================
# Step 6: Final setup
# =============================================================================
final_setup() {
    log_step "Running final setup..."
    
    # Initialize mise if available
    if command -v mise &>/dev/null; then
        mise install 2>/dev/null || true
    fi
    
    # Install Neovim plugins
    if command -v nvim &>/dev/null; then
        log_info "Installing Neovim plugins (this may take a moment)..."
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    fi
    
    # Create local config files if they don't exist
    touch "$HOME/.zshrc.local" 2>/dev/null || true
    touch "$HOME/.gitconfig.local" 2>/dev/null || true
    
    log_success "Final setup complete"
}

# =============================================================================
# Main
# =============================================================================
main() {
    case "$PROFILE" in
        minimal)
            create_symlinks
            set_default_shell
            ;;
        standard)
            install_packages
            install_modern_tools
            create_symlinks
            set_default_shell
            final_setup
            ;;
        full|ai-dev)
            install_packages
            install_modern_tools
            create_symlinks
            install_ai_tools
            set_default_shell
            final_setup
            ;;
        *)
            log_error "Unknown profile: $PROFILE"
            echo "Available profiles: minimal, standard, full, ai-dev"
            exit 1
            ;;
    esac
    
    echo ""
    echo "======================================"
    log_success "Setup complete!"
    echo "======================================"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Configure git: git config --global user.name 'Your Name'"
    echo "  3. Configure git: git config --global user.email 'you@example.com'"
    echo ""
    echo "Commands available:"
    echo "  dot check     - Verify installation"
    echo "  dot update    - Update dotfiles"
    echo "  ai --list     - List installed AI agents"
    echo ""
}

main
