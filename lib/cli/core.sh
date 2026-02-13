#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Core Commands
# Setup, check, update, and health management
# ============================================================================

# Fallback printing functions when not sourced through testing module
if ! command -v print_info >/dev/null 2>&1; then
    BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
    print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
    print_success() { echo -e "${GREEN}✅ $1${NC}"; }
    print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
    print_error() { echo -e "${RED}❌ $1${NC}"; }
fi

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
    
    # Symbols for output (fallback-safe if not sourced via testing module)
    local ROCKET_ICON=${ROCKET:-"🚀"}
    print_info "${ROCKET_ICON} Starting idempotent environment setup..."
    
    # Check if already setup
    local test_mode="${DOT_TEST_MODE:-false}"
    local always_install_test="${DOT_TEST_ALWAYS_INSTALL:-false}"
    if [[ "$force" != "true" ]] && dot_check --quiet; then
        if [[ "$test_mode" == "true" && "$always_install_test" == "true" ]]; then
            : # proceed to installer for test coverage
        else
            print_success "Environment already configured. Use --force to reinstall."
            return 0
        fi
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
    local test_mode="${DOT_TEST_MODE:-false}"
    local gear_icon="${GEAR:-"⚙️"}"
    local rocket_icon="${ROCKET:-"🚀"}"

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
        print_info "${gear_icon} Running comprehensive health check..."
    fi
    
    local exit_code=0
    
    # Check if running from correct dotfiles directory (skip in test mode)
    if [[ "$test_mode" != "true" ]]; then
        if [[ ! -f "$DOTFILES_DIR/bin/dot" ]]; then
            [[ "$quiet" != "true" ]] && print_error "Dotfiles directory not found or incorrect: $DOTFILES_DIR"
            exit_code=1
        fi
    fi
    
    # Check essential tools
    local essential_tools=("zsh" "git" "nvim" "tmux" "starship" "eza" "bat" "rg" "fd" "fzf")
    local missing_tools=()

    # Helper to check command with Ubuntu/Debian alternative names
    check_tool_available() {
        local tool="$1"
        case "$tool" in
            bat)  command -v bat &>/dev/null || command -v batcat &>/dev/null ;;
            fd)   command -v fd &>/dev/null || command -v fdfind &>/dev/null ;;
            *)    command -v "$tool" &>/dev/null ;;
        esac
    }

    for tool in "${essential_tools[@]}"; do
        if ! check_tool_available "$tool"; then
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
    if [[ "$test_mode" != "true" ]]; then
        if [[ "$SHELL" != *"zsh" ]]; then
            [[ "$quiet" != "true" ]] && print_warning "Default shell is not zsh"
            exit_code=1
        fi
    fi
    
    # Check dotfiles symlinks
    local config_files=("$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.config/nvim")
    if [[ "$test_mode" != "true" ]]; then
        for config in "${config_files[@]}"; do
            if [[ ! -L "$config" ]]; then
                [[ "$quiet" != "true" ]] && print_warning "Config not symlinked: $config"
                exit_code=1
            fi
        done
    fi
    
    # Check tmux configuration for conflicts
    if command -v tmux >/dev/null 2>&1; then
        local tmux_issues=0
        
        # Check if tmux config is valid
        if ! tmux -f ~/.tmux.conf list-keys >/dev/null 2>&1; then
            [[ "$quiet" != "true" ]] && print_error "Tmux configuration has syntax errors"
            exit_code=1
            tmux_issues=1
        fi
        
        # Check for keybinding conflicts (only if config is valid)
        # Look for direct bindings to c or d that launch claude/docker (not menu items)
        if [[ $tmux_issues -eq 0 ]]; then
            # Check if c key directly launches claude (not new-window)
            local c_binding=$(tmux list-keys 2>/dev/null | rg "bind-key.*-T prefix[[:space:]]+c[[:space:]]" | head -1 || true)
            local d_binding=$(tmux list-keys 2>/dev/null | rg "bind-key.*-T prefix[[:space:]]+d[[:space:]]" | head -1 || true)
            
            local has_c_conflict=false
            local has_d_conflict=false
            
            # Check if c binding launches claude instead of new-window
            if [[ -n "$c_binding" ]] && echo "$c_binding" | rg -q "claude" && ! echo "$c_binding" | rg -q "new-window"; then
                has_c_conflict=true
            fi
            
            # Check if d binding launches docker instead of detach
            if [[ -n "$d_binding" ]] && echo "$d_binding" | rg -q "docker" && ! echo "$d_binding" | rg -q "detach"; then
                has_d_conflict=true
            fi
            
            if [[ "$has_c_conflict" == "true" ]] || [[ "$has_d_conflict" == "true" ]]; then
                [[ "$quiet" != "true" ]] && print_warning "Tmux keybinding conflicts detected (run 'dot update' to fix)"
                exit_code=1
            fi
        fi
        
        if [[ "$quiet" != "true" ]] && [[ $tmux_issues -eq 0 ]]; then
            # Check configuration type by looking for markers in config
            local tmux_conf="$HOME/dotfiles/config/tmux/tmux.conf"
            if grep -q "STREAMLINED" "$tmux_conf" 2>/dev/null; then
                print_success "Using streamlined tmux config (~25 essential bindings)"
            elif grep -q "ULTIMATE Tmux Configuration" ~/.tmux.conf 2>/dev/null; then
                print_success "Using ultimate tmux config"
            fi
        fi
    fi
    
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
            print_success "All systems operational! ${rocket_icon}"
        else
            print_error "Issues detected. Run 'dot setup' to fix."
        fi
    fi
    
    return $exit_code
}

# Update command - update entire system
dot_update() {
    local auto_confirm=false
    local rocket_icon="${ROCKET:-"🚀"}"
    
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
    
    print_info "${rocket_icon} Updating development environment..."
    
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
    
    # Pull latest changes (detect default branch)
    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@') || default_branch="main"
    if git pull origin "$default_branch"; then
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
        print_info "Checking and fixing tmux configuration..."
        
        # Check for critical keybinding conflicts
        local conflicts_found=false
        
        # Check if 'c' is bound to claude instead of new-window
        if tmux list-keys | rg -q "prefix.*c.*claude"; then
            print_warning "Detected tmux keybinding conflicts (c→claude)"
            conflicts_found=true
        fi
        
        # Check if 'd' is bound to docker instead of detach
        if tmux list-keys | rg -q "prefix.*d.*docker"; then
            print_warning "Detected tmux keybinding conflicts (d→docker)"
            conflicts_found=true
        fi
        
        # Auto-fix conflicts if detected OR ensure ultimate config is active
        if [[ "$conflicts_found" == "true" ]] || [[ ! -f ~/.tmux.conf ]] || ! grep -q "ULTIMATE Tmux Configuration" ~/.tmux.conf; then
            print_info "Applying ultimate tmux configuration..."
            if [[ -f "$DOTFILES_DIR/.tmux-ultimate.conf" ]]; then
                cp "$DOTFILES_DIR/.tmux-ultimate.conf" ~/.tmux.conf
                print_success "Applied ultimate tmux configuration with perfect copy/paste"
            elif [[ -f "$DOTFILES_DIR/scripts/tmux-fix-complete.sh" ]]; then
                bash "$DOTFILES_DIR/scripts/tmux-fix-complete.sh" --yes 2>/dev/null || {
                    print_warning "Automatic fix failed, using fixed config directly"
                    if [[ -f "$DOTFILES_DIR/.tmux-fixed.conf" ]]; then
                        cp "$DOTFILES_DIR/.tmux-fixed.conf" ~/.tmux.conf
                        print_success "Applied fixed tmux configuration"
                    fi
                }
            fi
        fi
        
        # Reload configuration
        print_info "Reloading tmux configuration..."
        tmux source-file ~/.tmux.conf 2>/dev/null || {
            print_warning "Config reload failed, restarting tmux recommended"
        }
        tmux display-message "Tmux configuration reloaded and fixed!" 2>/dev/null || true
        print_success "Tmux configuration reloaded and verified"
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
    
    # Update Neovim plugins with version compatibility check
    print_info "📦 Updating Neovim plugins..."
    local nvim_version=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "0.0.0")
    if [[ -n "$nvim_version" ]]; then
        print_info "  Neovim version: $nvim_version"
        
        # Check if nvim meets minimum requirements for latest plugins
        if printf '%s\n' "0.10.4" "$nvim_version" | sort -V -C; then
            print_info "  Updating plugins via lazy.nvim..."
            nvim --headless -c 'Lazy! sync' -c 'qa' 2>/dev/null && print_success "  Plugins updated" || print_warning "  Plugin update had issues"
        else
            print_warning "  Neovim $nvim_version is older than 0.10.4"
            print_info "  Some plugins may not update to latest versions"
            print_info "  Consider upgrading Neovim for full plugin support"
            
            # Still try to update plugins, lazy.nvim will handle compatibility
            nvim --headless -c 'Lazy! sync' -c 'qa' 2>/dev/null && print_success "  Compatible plugins updated" || print_warning "  Some plugins may require nvim 0.10.4+"
        fi
    fi

    # Update AI coding tools
    print_info "🤖 Updating AI coding tools..."
    local ai_updated=()

    # npm-based tools (codex, gemini, pi, kilo)
    if command -v npm &>/dev/null; then
        local npm_tools=("@openai/codex" "@google/gemini-cli" "@anthropic/claude-code" "@mariozechner/pi-coding-agent" "@kilocode/cli")
        for tool in "${npm_tools[@]}"; do
            if npm list -g "$tool" &>/dev/null; then
                print_info "  Updating $tool..."
                npm update -g "$tool" 2>/dev/null && ai_updated+=("$tool")
            fi
        done
    fi

    # uv-based tools (aider, kimi)
    if command -v uv &>/dev/null; then
        if uv tool list 2>/dev/null | grep -q "aider\|kimi"; then
            print_info "  Updating uv tools (aider, kimi)..."
            uv tool upgrade --all 2>/dev/null && ai_updated+=("uv-tools")
        fi
    fi

    # Cursor Agent (cursor_cli)
    if command -v agent &>/dev/null || [[ -d "$HOME/.cursor-agent" ]]; then
        print_info "  Updating Cursor CLI (agent)..."
        curl -fsSL https://cursor.com/install 2>/dev/null | bash &>/dev/null && ai_updated+=("cursor-cli")
    fi

    # Amp
    if command -v amp &>/dev/null; then
        print_info "  Updating Amp..."
        curl -fsSL https://ampcode.com/install.sh 2>/dev/null | bash &>/dev/null && ai_updated+=("amp")
    fi

    # OpenCode
    if command -v opencode &>/dev/null && command -v brew &>/dev/null; then
        print_info "  Updating OpenCode..."
        brew upgrade opencode 2>/dev/null && ai_updated+=("opencode")
    fi

    # Claude Code
    if command -v claude &>/dev/null; then
        print_info "  Updating Claude Code..."
        if command -v brew &>/dev/null && brew list --cask claude-code &>/dev/null 2>&1; then
            brew upgrade --cask claude-code 2>/dev/null && ai_updated+=("claude-code")
        else
            # Fallback to reinstall via curl
            curl -fsSL https://claude.ai/install.sh 2>/dev/null | bash &>/dev/null && ai_updated+=("claude-code")
        fi
    fi

    if [[ ${#ai_updated[@]} -gt 0 ]]; then
        print_success "Updated AI tools: ${ai_updated[*]}"
    else
        print_info "  All AI tools already up to date"
    fi

    print_success "Environment update completed!"
    
    # Show summary of what was updated/fixed
    print_info "🎯 What was updated:"
    print_info "  • Repository pulled from remote"
    print_info "  • Configurations reloaded automatically"
    if [[ "$conflicts_found" == "true" ]]; then
        print_info "  • Tmux keybinding conflicts resolved"
    fi
    if [[ ${#ai_updated[@]} -gt 0 ]]; then
        print_info "  • AI tools: ${ai_updated[*]}"
    fi
    print_info "  • All running applications updated"
    
    print_info ""
    print_success "✨ Everything is ready to use immediately!"
    print_info "💡 Try these commands:"
    print_info "   tmux               # Start with fixed keybindings"
    print_info "   nvim               # Progressive editor (press <Space>?)"
    print_info "   dot check          # Verify everything is working"
    print_info "   perf-status        # Check shell performance"
}

# Reload command - refresh key configurations without restarting shell
dot_reload() {
    local reload_icon="${ROCKET:-"🚀"}"

    print_info "${reload_icon} Reloading key configurations..."

    # Reload tmux configuration when available
    if command -v tmux >/dev/null 2>&1; then
        tmux source-file ~/.tmux.conf 2>/dev/null || true
    fi

    # Ask Neovim instances to reload via nvr when present
    if command -v nvr >/dev/null 2>&1; then
        nvr --remote-send ':source $MYVIMRC<CR>' >/dev/null 2>&1 || true
    fi

    print_success "Configuration reload triggered"
}

# Version command - display CLI version information
dot_version() {
    local version="${DOT_VERSION:-}"

    if [[ -z "$version" ]] && [[ -f "$DOTFILES_DIR/VERSION" ]]; then
        version=$(<"$DOTFILES_DIR/VERSION")
    fi

    if [[ -z "$version" ]]; then
        version="0.0.0"
    fi

    echo "$version"
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
