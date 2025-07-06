#!/usr/bin/env bash

# ============================================================================
# Modern Dotfiles Setup Script - 2025 Edition
# One-command installation for the complete development environment
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
SUCCESS="✅"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"
AI="🤖"
PYTHON="🐍"
NODE="📦"

# Script configuration
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$HOME/dotfiles-install.log"

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "${CYAN}${GEAR} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
}

print_info() {
    echo -e "${YELLOW}${INFO} $1${NC}"
}

log_and_run() {
    echo "Running: $*" >> "$LOG_FILE"
    "$@" >> "$LOG_FILE" 2>&1
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Prerequisites Check
# ============================================================================

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS. Please check the manual installation steps for your OS."
        exit 1
    fi
    
    # Check for required commands
    local missing_deps=()
    
    if ! check_command "git"; then
        missing_deps+=("git")
    fi
    
    if ! check_command "curl"; then
        missing_deps+=("curl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install them first using: xcode-select --install"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# ============================================================================
# Backup Existing Configuration
# ============================================================================

backup_existing_config() {
    print_header "Backing Up Existing Configuration"
    
    mkdir -p "$BACKUP_DIR"
    
    local files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.vimrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [[ -e "$file" ]]; then
            print_step "Backing up $file"
            cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    print_success "Backup created at $BACKUP_DIR"
}

# ============================================================================
# Install Homebrew and Dependencies
# ============================================================================

install_homebrew() {
    print_header "Installing Homebrew and Dependencies"
    
    if ! check_command "brew"; then
        print_step "Installing Homebrew"
        log_and_run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_step "Homebrew already installed, updating"
        log_and_run brew update
    fi
    
    print_success "Homebrew ready"
}

install_modern_tools() {
    print_header "Installing Modern CLI Tools"
    
    local tools=(
        "starship"          # Modern shell prompt
        "zoxide"            # Smart cd replacement
        "eza"               # Modern ls replacement
        "bat"               # Modern cat replacement
        "ripgrep"           # Fast grep replacement
        "fd"                # Modern find replacement
        "fzf"               # Fuzzy finder
        "mise"              # Version manager
        "git-delta"         # Better git diffs
        "atuin"             # Better shell history
        "neovim"            # Modern vim
        "tmux"              # Terminal multiplexer
        "jq"                # JSON processor
        "tree"              # Directory tree viewer
    )
    
    print_step "Installing CLI tools: ${tools[*]}"
    for tool in "${tools[@]}"; do
        if ! check_command "$tool"; then
            print_step "Installing $tool"
            log_and_run brew install "$tool"
        else
            print_step "$tool already installed"
        fi
    done
    
    print_success "All CLI tools installed"
}

# ============================================================================
# Setup Python Environment
# ============================================================================

setup_python_environment() {
    print_header "${PYTHON} Setting Up Python Environment"
    
    # Install Python via mise
    print_step "Installing Python 3.12 via mise"
    log_and_run mise install python@3.12
    log_and_run mise use -g python@3.12
    
    # Install uv (modern Python package manager)
    if ! check_command "uv"; then
        print_step "Installing uv (Python package manager)"
        log_and_run curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    
    # Install Python development tools
    print_step "Installing Python development tools"
    local python_tools=(
        "ruff"              # Fast linter/formatter
        "aider-chat"        # AI coding assistant
        "shell-gpt"         # AI terminal assistant
    )
    
    for tool in "${python_tools[@]}"; do
        print_step "Installing $tool"
        log_and_run ~/.local/bin/uv tool install "$tool" || true
    done
    
    print_success "Python environment configured"
}

# ============================================================================
# Setup Node.js Environment
# ============================================================================

setup_nodejs_environment() {
    print_header "${NODE} Setting Up Node.js Environment"
    
    # Install Node.js via mise
    print_step "Installing Node.js LTS via mise"
    log_and_run mise install node@lts
    log_and_run mise use -g node@lts
    
    # Install Bun (modern JavaScript runtime)
    if ! check_command "bun"; then
        print_step "Installing Bun"
        log_and_run curl -fsSL https://bun.sh/install | bash
    fi
    
    print_success "Node.js environment configured"
}

# ============================================================================
# Setup Neovim
# ============================================================================

setup_neovim() {
    print_header "Setting Up Neovim"
    
    # Create Neovim config directory
    mkdir -p "$HOME/.config/nvim"
    
    # Link our modern Neovim configuration
    print_step "Installing Neovim configuration"
    if [[ -f "$DOTFILES_DIR/.config/nvim/init.lua" ]]; then
        ln -sf "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    else
        # Copy our configuration to the config directory
        cp "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua" 2>/dev/null || true
    fi
    
    print_success "Neovim configuration installed"
}

# ============================================================================
# Setup Tmux
# ============================================================================

setup_tmux() {
    print_header "Setting Up Tmux"
    
    # Link tmux configuration
    print_step "Installing tmux configuration"
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    
    # Install TPM (Tmux Plugin Manager)
    print_step "Installing Tmux Plugin Manager"
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        log_and_run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    
    # Create tmux scripts directory
    mkdir -p "$HOME/.config/tmux/scripts"
    ln -sf "$DOTFILES_DIR/.config/tmux/scripts/tmux-sessionizer" "$HOME/.config/tmux/scripts/tmux-sessionizer"
    chmod +x "$HOME/.config/tmux/scripts/tmux-sessionizer"
    
    print_success "Tmux configuration installed"
}

# ============================================================================
# Setup Shell Configuration
# ============================================================================

setup_shell_config() {
    print_header "Setting Up Shell Configuration"
    
    # Link zsh configuration
    print_step "Installing ZSH configuration"
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    
    # Setup starship configuration
    print_step "Setting up Starship prompt"
    mkdir -p "$HOME/.config"
    if [[ ! -f "$HOME/.config/starship.toml" ]]; then
        cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship configuration
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$nodejs\
$character"""

[directory]
style = "blue"

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vicmd_symbol = "[❮](green)"

[git_branch]
format = "[$branch]($style)"
style = "bright-black"

[git_status]
format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
style = "cyan"

[python]
symbol = "🐍 "
format = '[$symbol$pyenv_prefix$version]($style) '

[nodejs]
symbol = "📦 "
format = '[$symbol$version]($style) '
EOF
    fi
    
    print_success "Shell configuration installed"
}

# ============================================================================
# Setup Git Configuration
# ============================================================================

setup_git_config() {
    print_header "Setting Up Git Configuration"
    
    # Backup existing git config
    if [[ -f "$HOME/.gitconfig" ]]; then
        cp "$HOME/.gitconfig" "$BACKUP_DIR/.gitconfig.backup" 2>/dev/null || true
    fi
    
    # Check if user has git configured
    if ! git config --global user.name >/dev/null 2>&1; then
        print_step "Git user not configured. Please enter your details:"
        read -p "Enter your name: " git_name
        read -p "Enter your email: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
    fi
    
    # Apply our enhanced git configuration
    print_step "Applying enhanced git configuration"
    
    # Core settings
    git config --global core.editor "nvim"
    git config --global core.pager "delta"
    git config --global core.autocrlf "input"
    git config --global core.preloadindex "true"
    git config --global core.untrackedCache "true"
    
    # Delta configuration
    git config --global interactive.diffFilter "delta --color-only --features=interactive"
    git config --global delta.navigate "true"
    git config --global delta.light "false"
    git config --global delta.side-by-side "true"
    git config --global delta.line-numbers "true"
    git config --global delta.syntax-theme "gruvbox-dark"
    git config --global delta.features "decorations"
    
    # Push/pull settings
    git config --global push.default "simple"
    git config --global push.autoSetupRemote "true"
    git config --global pull.rebase "true"
    git config --global rebase.autoStash "true"
    
    # Branch settings
    git config --global init.defaultBranch "main"
    git config --global branch.sort "-committerdate"
    
    # Useful aliases
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.s "status --short"
    git config --global alias.c "commit -m"
    git config --global alias.ca "commit -am"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.undo "reset HEAD~1 --mixed"
    
    print_success "Git configuration enhanced"
}

# ============================================================================
# Install Plugins and Final Setup
# ============================================================================

install_plugins() {
    print_header "Installing Plugins and Final Setup"
    
    # Install tmux plugins
    print_step "Installing tmux plugins"
    if [[ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
        log_and_run "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    fi
    
    # Setup Neovim plugins (they'll auto-install on first run)
    print_step "Neovim plugins will auto-install on first launch"
    
    # Setup atuin (shell history)
    if check_command "atuin"; then
        print_step "Setting up Atuin"
        log_and_run atuin import auto || true
    fi
    
    # Setup mise plugins
    print_step "Setting up mise"
    log_and_run mise trust || true
    
    print_success "Plugins installation completed"
}

# ============================================================================
# Post-Installation Verification
# ============================================================================

verify_installation() {
    print_header "Verifying Installation"
    
    local verification_tests=(
        "starship --version:Starship prompt"
        "zoxide --version:Zoxide navigation"
        "eza --version:Eza file listing"
        "bat --version:Bat file viewer"
        "rg --version:Ripgrep search"
        "fd --version:Fd file finder"
        "fzf --version:FZF fuzzy finder"
        "mise --version:Mise version manager"
        "delta --version:Git delta"
        "nvim --version:Neovim editor"
        "tmux -V:Tmux multiplexer"
    )
    
    local failed_tests=()
    
    for test in "${verification_tests[@]}"; do
        local cmd="${test%%:*}"
        local name="${test##*:}"
        
        if eval "$cmd" >/dev/null 2>&1; then
            print_success "$name is working"
        else
            print_error "$name failed verification"
            failed_tests+=("$name")
        fi
    done
    
    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        print_success "All verification tests passed!"
    else
        print_error "Some tools failed verification: ${failed_tests[*]}"
        print_info "Check the log file at $LOG_FILE for details"
    fi
}

# ============================================================================
# Final Instructions
# ============================================================================

show_final_instructions() {
    print_header "${ROCKET} Installation Complete!"
    
    echo -e "${GREEN}"
    cat << 'EOF'
🎉 Your modern development environment is ready!

📋 Next Steps:
1. Restart your terminal or run: source ~/.zshrc
2. Launch Neovim to install plugins: nvim
3. Test tmux with AI session: tm (then Prefix+A)
4. Try AI functions: claude-context "help me code"

🚀 Quick Start Commands:
- proj             # Switch projects with fzf
- tm               # Smart tmux sessions
- cc "question"    # Quick Claude query
- gg "question"    # Quick Gemini query
- ai-analyze overview  # Analyze current project
- explain file.py  # Explain code with AI

📚 Documentation:
- AI Workflow Guide: ~/dotfiles/AI_WORKFLOW_GUIDE.md
- Backup location: BACKUP_DIR
- Installation log: LOG_FILE

⚡ Productivity Features:
- Modern shell with starship prompt
- AI-assisted development with Claude & Gemini
- Smart navigation with zoxide and fzf
- Enhanced git workflow with delta
- Tmux sessions optimized for AI development
- Neovim with LSP and GitHub Copilot ready

🤖 AI Integration Ready:
Your terminal now seamlessly integrates Claude Code CLI 
and Gemini CLI for AI-assisted development!

Happy coding! 🚀
EOF
    echo -e "${NC}"
}

# ============================================================================
# Error Handling
# ============================================================================

cleanup_on_error() {
    print_error "Installation failed! Check the log file at $LOG_FILE"
    print_info "Your original configuration is backed up at $BACKUP_DIR"
    exit 1
}

trap cleanup_on_error ERR

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           🚀 Modern Dotfiles Setup - 2025 Edition            ║
║                                                              ║
║     Complete development environment with AI integration     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Initialize log file
    echo "Modern Dotfiles Installation - $(date)" > "$LOG_FILE"
    
    # Run installation steps
    check_prerequisites
    backup_existing_config
    install_homebrew
    install_modern_tools
    setup_python_environment
    setup_nodejs_environment
    setup_neovim
    setup_tmux
    setup_shell_config
    setup_git_config
    install_plugins
    verify_installation
    show_final_instructions
    
    # Final success message
    print_success "Installation completed successfully!"
    print_info "Backup: $BACKUP_DIR"
    print_info "Log: $LOG_FILE"
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi