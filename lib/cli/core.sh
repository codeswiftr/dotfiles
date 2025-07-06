#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Core Commands
# Setup, check, update, and health management
# ============================================================================

# Setup command - idempotent environment setup
dot_setup() {
    local force=false
    local verbose=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                show_setup_help
                return 0
                ;;
            *)
                print_error "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    print_info "${ROCKET} Starting idempotent environment setup..."
    
    # Check if already setup
    if [[ "$force" != "true" ]] && dot_check --quiet; then
        print_success "Environment already configured. Use --force to reinstall."
        return 0
    fi
    
    # Run main installer
    print_info "Running main installer..."
    if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
        cd "$DOTFILES_DIR"
        bash install.sh
    else
        print_error "Main installer not found at $DOTFILES_DIR/install.sh"
        return 1
    fi
    
    # Verify installation
    if dot_check --quiet; then
        print_success "Environment setup completed successfully!"
        print_info "Run 'dot check' for detailed status"
    else
        print_error "Setup completed but verification failed"
        print_info "Run 'dot check' to see issues"
        return 1
    fi
}

# Check command - comprehensive health validation
dot_check() {
    local quiet=false
    local detailed=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet)
                quiet=true
                shift
                ;;
            --detailed)
                detailed=true
                shift
                ;;
            -h|--help)
                show_check_help
                return 0
                ;;
            *)
                print_error "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    if [[ "$quiet" != "true" ]]; then
        print_info "${GEAR} Running comprehensive health check..."
    fi
    
    local exit_code=0
    
    # Check if running from correct dotfiles directory
    if [[ ! -f "$DOTFILES_DIR/bin/dot" ]]; then
        [[ "$quiet" != "true" ]] && print_error "Dotfiles directory not found or incorrect: $DOTFILES_DIR"
        exit_code=1
    fi
    
    # Check essential tools
    local essential_tools=("zsh" "git" "nvim" "tmux" "starship" "eza" "bat" "rg" "fd" "fzf")
    local missing_tools=()
    
    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
            exit_code=1
        fi
    done
    
    if [[ "$quiet" != "true" ]]; then
        if [[ ${#missing_tools[@]} -eq 0 ]]; then
            print_success "All essential tools installed"
        else
            print_error "Missing tools: ${missing_tools[*]}"
        fi
    fi
    
    # Check shell configuration
    if [[ "$SHELL" != *"zsh" ]]; then
        [[ "$quiet" != "true" ]] && print_warning "Default shell is not zsh"
        exit_code=1
    fi
    
    # Check dotfiles symlinks
    local config_files=("$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.config/nvim/init.lua")
    for config in "${config_files[@]}"; do
        if [[ ! -L "$config" ]]; then
            [[ "$quiet" != "true" ]] && print_warning "Config not symlinked: $config"
            exit_code=1
        fi
    done
    
    # Call existing health check if available
    if command -v df-health &> /dev/null; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running extended health check..."
            df-health
        else
            df-health &> /dev/null || exit_code=1
        fi
    fi
    
    # Performance check
    if command -v perf-benchmark-startup &> /dev/null && [[ "$detailed" == "true" ]]; then
        print_info "Performance status:"
        perf-benchmark-startup
    fi
    
    # AI security check
    if command -v ai-security-status &> /dev/null && [[ "$detailed" == "true" ]]; then
        print_info "AI security status:"
        ai-security-status
    fi
    
    # Testing status
    if command -v testing-status &> /dev/null && [[ "$detailed" == "true" ]]; then
        print_info "Testing framework status:"
        testing-status
    fi
    
    if [[ "$quiet" != "true" ]]; then
        if [[ $exit_code -eq 0 ]]; then
            print_success "All systems operational! ${ROCKET}"
        else
            print_error "Issues detected. Run 'dot setup' to fix."
        fi
    fi
    
    return $exit_code
}

# Update command - update entire system
dot_update() {
    local auto_confirm=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --yes)
                auto_confirm=true
                shift
                ;;
            -h|--help)
                show_update_help
                return 0
                ;;
            *)
                print_error "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    print_info "${ROCKET} Updating development environment..."
    
    # Update git repository
    print_info "Updating dotfiles repository..."
    cd "$DOTFILES_DIR"
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "Uncommitted changes detected in dotfiles"
        if [[ "$auto_confirm" != "true" ]]; then
            echo -n "Continue with update? [y/N]: "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_info "Update cancelled"
                return 0
            fi
        fi
    fi
    
    # Pull latest changes
    if git pull origin master; then
        print_success "Repository updated"
    else
        print_error "Failed to update repository"
        return 1
    fi
    
    # Run setup to apply changes
    print_info "Applying configuration changes..."
    dot_setup --force
    
    # Reload configurations
    print_info "Reloading configurations..."
    
    # Reload tmux configuration if tmux is running
    if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
        print_info "Reloading tmux configuration..."
        tmux source-file ~/.tmux.conf
        tmux display-message "Tmux configuration reloaded!"
        print_success "Tmux configuration reloaded"
    fi
    
    # Reload Neovim configuration for all running instances
    if command -v nvim >/dev/null 2>&1; then
        print_info "Reloading Neovim configurations..."
        # Send reload command to all nvim instances via nvr if available
        if command -v nvr >/dev/null 2>&1; then
            for server in /tmp/nvim*/0; do
                if [[ -S "$server" ]]; then
                    nvr --servername "$server" --remote-send ':source $MYVIMRC<CR>' 2>/dev/null || true
                fi
            done
            print_success "Neovim configurations reloaded"
        else
            print_info "Install 'neovim-remote' (nvr) for automatic Neovim config reload"
        fi
    fi
    
    # Update tools via existing update mechanism
    if command -v df-update &> /dev/null; then
        print_info "Updating system packages and tools..."
        df-update --auto
    fi
    
    print_success "Environment update completed!"
    print_success "All configurations reloaded automatically"
    print_info "Shell restart recommended for complete environment refresh"
}

# Help functions
show_setup_help() {
    cat << 'EOF'
dot setup - Idempotent environment setup

USAGE:
    dot setup [options]

OPTIONS:
    --force      Force reinstallation even if already setup
    --verbose    Enable verbose output
    -h, --help   Show this help message

DESCRIPTION:
    Performs a complete, idempotent setup of the development environment.
    Can be run safely multiple times. Installs all tools, creates symlinks,
    and configures the entire system.

EXAMPLES:
    dot setup              # Initial setup or repair
    dot setup --force      # Force complete reinstallation
EOF
}

show_check_help() {
    cat << 'EOF'
dot check - Comprehensive health validation

USAGE:
    dot check [options]

OPTIONS:
    --quiet      Suppress output, return only exit code
    --detailed   Include performance and security checks
    -h, --help   Show this help message

DESCRIPTION:
    Validates that all components of the development environment
    are properly installed and configured. Returns 0 if healthy,
    non-zero if issues are detected.

EXAMPLES:
    dot check              # Basic health check
    dot check --detailed   # Comprehensive validation
    dot check --quiet      # Silent check for scripts
EOF
}

show_update_help() {
    cat << 'EOF'
dot update - Update entire system

USAGE:
    dot update [options]

OPTIONS:
    --yes        Auto-confirm all prompts
    -h, --help   Show this help message

DESCRIPTION:
    Updates the dotfiles repository, applies configuration changes,
    and updates all system packages and tools.

EXAMPLES:
    dot update             # Interactive update
    dot update --yes       # Automatic update
EOF
}