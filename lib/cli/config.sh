#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Configuration Management
# Interactive configuration and theme management
# ============================================================================

# Config command dispatcher
dot_config() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "theme")
            config_manage_theme "$@"
            ;;
        "tools")
            config_manage_tools "$@"
            ;;
        "security")
            config_manage_security "$@"
            ;;
        "edit")
            config_edit_files "$@"
            ;;
        "backup")
            config_backup "$@"
            ;;
        "restore")
            config_restore "$@"
            ;;
        "sync")
            config_sync "$@"
            ;;
        "validate")
            config_validate
            ;;
        "reset")
            config_reset "$@"
            ;;
        "-h"|"--help"|"")
            show_config_help
            ;;
        *)
            print_error "Unknown config subcommand: $subcommand"
            echo "Run 'dot config --help' for available commands."
            return 1
            ;;
    esac
}

# Theme management
config_manage_theme() {
    local action="${1:-select}"
    local theme="${2:-}"
    
    case "$action" in
        "select"|"set")
            config_select_theme "$theme"
            ;;
        "list")
            config_list_themes
            ;;
        "current")
            config_current_theme
            ;;
        "preview")
            config_preview_theme "$theme"
            ;;
        *)
            print_error "Unknown theme action: $action"
            echo "Available actions: select, list, current, preview"
            return 1
            ;;
    esac
}

# Select and apply theme
config_select_theme() {
    local theme="$1"
    
    # List available themes if none specified
    if [[ -z "$theme" ]]; then
        echo "🎨 Available Themes:"
        config_list_themes
        echo ""
        echo -n "Select theme: "
        read -r theme
    fi
    
    case "$theme" in
        "catppuccin"|"catppuccin-mocha")
            apply_catppuccin_theme
            ;;
        "nord")
            apply_nord_theme
            ;;
        "dracula")
            apply_dracula_theme
            ;;
        "gruvbox")
            apply_gruvbox_theme
            ;;
        "tokyo-night")
            apply_tokyo_night_theme
            ;;
        "rose-pine")
            apply_rose_pine_theme
            ;;
        *)
            print_error "Unknown theme: $theme"
            config_list_themes
            return 1
            ;;
    esac
    
    print_success "Theme '$theme' applied successfully!"
    print_info "Restart your terminal to see all changes"
}

# List available themes
config_list_themes() {
    echo "  catppuccin     - Catppuccin Mocha (current default)"
    echo "  nord           - Nord color scheme"
    echo "  dracula        - Dracula theme"
    echo "  gruvbox        - Gruvbox dark"
    echo "  tokyo-night    - Tokyo Night"
    echo "  rose-pine      - Rosé Pine"
}

# Show current theme
config_current_theme() {
    local current_theme="catppuccin"  # Default
    
    # Try to detect current theme from various config files
    if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
        if grep -q "catppuccin" "$DOTFILES_DIR/config/starship.toml"; then
            current_theme="catppuccin"
        elif grep -q "nord" "$DOTFILES_DIR/config/starship.toml"; then
            current_theme="nord"
        fi
    fi
    
    echo "🎨 Current Theme: $current_theme"
}

# Apply theme functions
apply_catppuccin_theme() {
    print_info "Applying Catppuccin theme..."
    
    # Update starship config
    if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
        # Ensure catppuccin palette is used
        if ! grep -q "palette = \"catppuccin_mocha\"" "$DOTFILES_DIR/config/starship.toml"; then
            echo "" >> "$DOTFILES_DIR/config/starship.toml"
            echo "palette = \"catppuccin_mocha\"" >> "$DOTFILES_DIR/config/starship.toml"
        fi
    fi
    
    # Update tmux theme
    create_catppuccin_tmux_config
    
    # Update terminal color scheme info
    echo "catppuccin" > "$HOME/.config/dotfiles/current_theme"
}

apply_nord_theme() {
    print_info "Applying Nord theme..."
    
    # Create Nord tmux config
    create_nord_tmux_config
    
    echo "nord" > "$HOME/.config/dotfiles/current_theme"
    print_info "Nord theme applied. Configure your terminal emulator manually for full effect."
}

# Tool configuration management
config_manage_tools() {
    local action="${1:-menu}"
    
    case "$action" in
        "menu")
            show_tools_config_menu
            ;;
        "ai")
            config_ai_tools
            ;;
        "editor")
            config_editor_settings
            ;;
        "terminal")
            config_terminal_settings
            ;;
        "git")
            config_git_settings
            ;;
        *)
            print_error "Unknown tools action: $action"
            return 1
            ;;
    esac
}

show_tools_config_menu() {
    echo "🛠️ Tool Configuration Menu:"
    echo ""
    echo "1) AI Integration (Claude, Gemini, Copilot)"
    echo "2) Editor Settings (Neovim, VSCode)"
    echo "3) Terminal Settings (ZSH, Starship)"
    echo "4) Git Configuration"
    echo "5) Return to main menu"
    echo ""
    echo -n "Select option [1-5]: "
    read -r choice
    
    case "$choice" in
        1) config_ai_tools ;;
        2) config_editor_settings ;;
        3) config_terminal_settings ;;
        4) config_git_settings ;;
        5) return 0 ;;
        *) print_error "Invalid choice" ;;
    esac
}

config_ai_tools() {
    echo "🤖 AI Integration Configuration:"
    echo ""
    echo "Current AI Provider: ${AI_PROVIDER:-claude}"
    echo ""
    echo "1) Set default AI provider"
    echo "2) Configure API keys"
    echo "3) Test AI connections"
    echo ""
    echo -n "Select option [1-3]: "
    read -r choice
    
    case "$choice" in
        1)
            echo "Available providers: claude, gemini, copilot"
            echo -n "Enter provider: "
            read -r provider
            echo "export AI_PROVIDER=$provider" >> "$HOME/.zshrc.local"
            print_success "AI provider set to: $provider"
            ;;
        2)
            print_info "Configure API keys according to each provider's documentation:"
            echo "  Claude: Set ANTHROPIC_API_KEY"
            echo "  Gemini: Use 'gcloud auth' or set GOOGLE_API_KEY"
            echo "  Copilot: Use 'gh auth login'"
            ;;
        3)
            dot ai status
            ;;
    esac
}

# Security configuration
config_manage_security() {
    local action="${1:-menu}"
    
    case "$action" in
        "menu")
            show_security_config_menu
            ;;
        "ssh")
            config_ssh_security
            ;;
        "gpg")
            config_gpg_security
            ;;
        "firewall")
            config_firewall_settings
            ;;
        *)
            print_error "Unknown security action: $action"
            return 1
            ;;
    esac
}

show_security_config_menu() {
    echo "🔒 Security Configuration Menu:"
    echo ""
    echo "1) SSH Key Management"
    echo "2) GPG Key Setup"
    echo "3) Firewall Configuration"
    echo "4) Security Audit"
    echo "5) Return to main menu"
    echo ""
    echo -n "Select option [1-5]: "
    read -r choice
    
    case "$choice" in
        1) config_ssh_security ;;
        2) config_gpg_security ;;
        3) config_firewall_settings ;;
        4) dot security scan ;;
        5) return 0 ;;
        *) print_error "Invalid choice" ;;
    esac
}

# Configuration file editing
config_edit_files() {
    local file="${1:-}"
    
    if [[ -z "$file" ]]; then
        echo "📝 Configuration Files:"
        echo ""
        echo "1) .zshrc - Shell configuration"
        echo "2) .tmux.conf - Tmux configuration"
        echo "3) init.lua - Neovim configuration"
        echo "4) starship.toml - Prompt configuration"
        echo "5) .gitconfig - Git configuration"
        echo ""
        echo -n "Select file to edit [1-5]: "
        read -r choice
        
        case "$choice" in
            1) file=".zshrc" ;;
            2) file=".tmux.conf" ;;
            3) file=".config/nvim/init.lua" ;;
            4) file="config/starship.toml" ;;
            5) file=".gitconfig" ;;
            *) print_error "Invalid choice" && return 1 ;;
        esac
    fi
    
    local full_path="$DOTFILES_DIR/$file"
    
    if [[ ! -f "$full_path" ]]; then
        print_error "Configuration file not found: $file"
        return 1
    fi
    
    print_info "Opening $file in editor..."
    
    if command -v nvim >/dev/null 2>&1; then
        nvim "$full_path"
    elif command -v code >/dev/null 2>&1; then
        code "$full_path"
    else
        "${EDITOR:-nano}" "$full_path"
    fi
}

# Configuration backup and restore
config_backup() {
    local backup_name="${1:-backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_dir="$HOME/.config/dotfiles/backups"
    
    mkdir -p "$backup_dir"
    local backup_path="$backup_dir/$backup_name.tar.gz"
    
    print_info "📦 Creating configuration backup..."
    
    cd "$DOTFILES_DIR"
    tar -czf "$backup_path" \
        .zshrc \
        .tmux.conf \
        .gitconfig \
        .config/ \
        config/ \
        2>/dev/null || true
    
    print_success "Backup created: $backup_path"
    echo "Restore with: dot config restore $backup_name"
}

config_restore() {
    local backup_name="$1"
    local backup_dir="$HOME/.config/dotfiles/backups"
    
    if [[ -z "$backup_name" ]]; then
        echo "📥 Available Backups:"
        ls -1 "$backup_dir"/*.tar.gz 2>/dev/null | sed 's|.*/||; s|\.tar\.gz||' || echo "No backups found"
        echo ""
        echo -n "Enter backup name: "
        read -r backup_name
    fi
    
    local backup_path="$backup_dir/$backup_name.tar.gz"
    
    if [[ ! -f "$backup_path" ]]; then
        print_error "Backup not found: $backup_name"
        return 1
    fi
    
    print_warning "This will overwrite current configuration!"
    echo -n "Continue? [y/N]: "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    print_info "📥 Restoring configuration from backup..."
    
    cd "$DOTFILES_DIR"
    tar -xzf "$backup_path"
    
    print_success "Configuration restored from: $backup_name"
    print_info "Restart your shell to apply changes"
}

# Configuration validation
config_validate() {
    print_info "🔍 Validating configuration files..."
    
    local errors=0
    
    # Check essential files
    local essential_files=(
        ".zshrc"
        ".tmux.conf" 
        ".config/nvim/init.lua"
        "config/starship.toml"
    )
    
    for file in "${essential_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            print_success "$file exists"
        else
            print_error "$file missing"
            ((errors++))
        fi
    done
    
    # Validate syntax where possible
    if command -v zsh >/dev/null 2>&1; then
        if zsh -n "$DOTFILES_DIR/.zshrc" 2>/dev/null; then
            print_success ".zshrc syntax valid"
        else
            print_error ".zshrc syntax error"
            ((errors++))
        fi
    fi
    
    if command -v nvim >/dev/null 2>&1; then
        if nvim --headless -c "luafile $DOTFILES_DIR/.config/nvim/init.lua" -c "qall" 2>/dev/null; then
            print_success "Neovim config valid"
        else
            print_error "Neovim config has errors"
            ((errors++))
        fi
    fi
    
    # Check symlinks
    local symlinks=(
        "$HOME/.zshrc:$DOTFILES_DIR/.zshrc"
        "$HOME/.tmux.conf:$DOTFILES_DIR/.tmux.conf"
        "$HOME/.config/nvim/init.lua:$DOTFILES_DIR/.config/nvim/init.lua"
    )
    
    for link_info in "${symlinks[@]}"; do
        local link="${link_info%%:*}"
        local target="${link_info#*:}"
        
        if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
            print_success "Symlink valid: $(basename "$link")"
        else
            print_warning "Symlink broken: $(basename "$link")"
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        print_success "All configuration files valid!"
    else
        print_error "Found $errors configuration errors"
    fi
    
    return $errors
}

# Configuration reset
config_reset() {
    local component="${1:-all}"
    
    print_warning "This will reset configuration to defaults!"
    echo -n "Continue? [y/N]: "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    case "$component" in
        "all")
            print_info "Resetting all configurations..."
            cd "$DOTFILES_DIR"
            git checkout HEAD -- .zshrc .tmux.conf .gitconfig config/
            ;;
        "zsh")
            print_info "Resetting ZSH configuration..."
            cd "$DOTFILES_DIR"
            git checkout HEAD -- .zshrc config/zsh/
            ;;
        "nvim")
            print_info "Resetting Neovim configuration..."
            cd "$DOTFILES_DIR"
            git checkout HEAD -- .config/nvim/
            ;;
        *)
            print_error "Unknown component: $component"
            echo "Available components: all, zsh, nvim"
            return 1
            ;;
    esac
    
    print_success "Configuration reset completed!"
}

# Utility functions
create_catppuccin_tmux_config() {
    # Ensure catppuccin theme configuration
    local tmux_config="$DOTFILES_DIR/.tmux.conf"
    
    if ! grep -q "catppuccin" "$tmux_config"; then
        echo "" >> "$tmux_config"
        echo "# Catppuccin theme" >> "$tmux_config"
        echo "set -g @plugin 'catppuccin/tmux'" >> "$tmux_config"
        echo "set -g @catppuccin_flavour 'mocha'" >> "$tmux_config"
    fi
}

# Help function
show_config_help() {
    cat << 'EOF'
dot config - Configuration management and customization

USAGE:
    dot config <command> [options]

COMMANDS:
    theme <action> [theme]       Manage color themes
    tools [component]            Configure development tools
    security [component]         Security configuration settings
    edit [file]                  Edit configuration files
    backup [name]                Backup current configuration
    restore [name]               Restore from backup
    sync                         Sync configuration changes
    validate                     Validate configuration files
    reset [component]            Reset to default configuration

THEME ACTIONS:
    select                       Choose and apply theme
    list                         List available themes
    current                      Show current theme
    preview                      Preview theme without applying

AVAILABLE THEMES:
    catppuccin                   Catppuccin Mocha (default)
    nord                         Nord color scheme
    dracula                      Dracula theme
    gruvbox                      Gruvbox dark
    tokyo-night                  Tokyo Night
    rose-pine                    Rosé Pine

TOOL COMPONENTS:
    ai                           AI integration settings
    editor                       Neovim and VSCode settings
    terminal                     ZSH and Starship settings
    git                          Git configuration

SECURITY COMPONENTS:
    ssh                          SSH key management
    gpg                          GPG key setup
    firewall                     Firewall configuration

CONFIGURATION FILES:
    .zshrc                       Shell configuration
    .tmux.conf                   Terminal multiplexer
    init.lua                     Neovim configuration
    starship.toml                Prompt configuration
    .gitconfig                   Git settings

OPTIONS:
    -h, --help                   Show this help message

EXAMPLES:
    dot config theme select catppuccin    # Apply catppuccin theme
    dot config edit .zshrc               # Edit shell config
    dot config backup my-config          # Create named backup
    dot config validate                  # Check configuration
    dot config tools ai                  # Configure AI tools

BACKUP MANAGEMENT:
    Backups are stored in ~/.config/dotfiles/backups/
    Format: backup-YYYYMMDD-HHMMSS.tar.gz
    Automatic backups created before major changes
EOF
}