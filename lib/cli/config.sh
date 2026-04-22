#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Configuration Management
# Backup, restore, validation, and editing of dotfiles configuration
# ============================================================================

dot_config() {
    local subcommand="${1:-}"
    shift || true

    case "$subcommand" in
        "theme")     config_manage_theme "$@" ;;
        "edit")      config_edit_files "$@" ;;
        "backup")    config_backup "$@" ;;
        "restore")   config_restore "$@" ;;
        "validate")  config_validate ;;
        "reset")     config_reset "$@" ;;
        "-h"|"--help"|"") show_config_help ;;
        *)
            print_error "Unknown config subcommand: $subcommand"
            echo "Run 'dot config --help' for available commands."
            return 1
            ;;
    esac
}

# ============================================================================
# Theme Management
# ============================================================================

config_manage_theme() {
    local action="${1:-current}"

    case "$action" in
        "list")    config_list_themes ;;
        "current") config_current_theme ;;
        *)
            print_error "Unknown theme action: $action"
            echo "Available actions: list, current"
            return 1
            ;;
    esac
}

config_list_themes() {
    echo "Available Themes:"
    echo "  catppuccin     - Catppuccin Mocha (active)"
    echo ""
    echo "Theme is configured via starship.toml, tmux.conf, and nvim config."
    echo "Edit these directly with 'dot config edit'."
}

config_current_theme() {
    local current_theme="catppuccin"
    if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
        grep -q "catppuccin" "$DOTFILES_DIR/config/starship.toml" && current_theme="catppuccin"
    fi
    echo "Current Theme: $current_theme"
}

# ============================================================================
# Configuration File Editing
# ============================================================================

config_edit_files() {
    local file="${1:-}"

    if [[ -z "$file" ]]; then
        echo "Configuration Files:"
        echo ""
        echo "1) .zshrc - Shell configuration"
        echo "2) .tmux.conf - Tmux configuration"
        echo "3) config/nvim/init.lua - Neovim configuration"
        echo "4) config/starship.toml - Prompt configuration"
        echo "5) .gitconfig - Git configuration"
        echo ""
        echo -n "Select file to edit [1-5]: "
        read -r choice

        case "$choice" in
            1) file=".zshrc" ;;
            2) file=".tmux.conf" ;;
            3) file="config/nvim/init.lua" ;;
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

# ============================================================================
# Backup and Restore
# ============================================================================

config_backup() {
    local backup_name="${1:-backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_dir="$HOME/.config/dotfiles/backups"

    mkdir -p "$backup_dir"
    local backup_path="$backup_dir/$backup_name.tar.gz"

    print_info "Creating configuration backup..."

    cd "$DOTFILES_DIR"
    tar -czf "$backup_path" \
        .zshrc \
        .tmux.conf \
        .gitconfig \
        config/ \
        2>/dev/null || true

    print_success "Backup created: $backup_path"
    echo "Restore with: dot config restore $backup_name"
}

config_restore() {
    local backup_name="$1"
    local backup_dir="$HOME/.config/dotfiles/backups"

    if [[ -z "$backup_name" ]]; then
        echo "Available Backups:"
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
    [[ "$response" =~ ^[Yy]$ ]] || return 0

    print_info "Restoring configuration from backup..."

    cd "$DOTFILES_DIR"
    tar -xzf "$backup_path"

    print_success "Configuration restored from: $backup_name"
    print_info "Restart your shell to apply changes"
}

# ============================================================================
# Validation and Reset
# ============================================================================

config_validate() {
    print_info "Validating configuration files..."

    local errors=0

    local essential_files=(".zshrc" ".tmux.conf" "config/nvim/init.lua" "config/starship.toml")
    for file in "${essential_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            print_success "$file exists"
        else
            print_error "$file missing"
            ((errors++))
        fi
    done

    if command -v zsh >/dev/null 2>&1; then
        if zsh -n "$DOTFILES_DIR/.zshrc" 2>/dev/null; then
            print_success ".zshrc syntax valid"
        else
            print_error ".zshrc syntax error"
            ((errors++))
        fi
    fi

    local symlinks=(
        "$HOME/.zshrc:$DOTFILES_DIR/.zshrc"
        "$HOME/.tmux.conf:$DOTFILES_DIR/.tmux.conf"
        "$HOME/.config/nvim:$DOTFILES_DIR/config/nvim"
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

config_reset() {
    local component="${1:-all}"

    print_warning "This will reset configuration to defaults!"
    echo -n "Continue? [y/N]: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] || return 0

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
            git checkout HEAD -- config/nvim/
            ;;
        *)
            print_error "Unknown component: $component"
            echo "Available components: all, zsh, nvim"
            return 1
            ;;
    esac

    print_success "Configuration reset completed!"
}

# ============================================================================
# Help
# ============================================================================

show_config_help() {
    cat << 'EOF'
dot config - Configuration management

USAGE:
    dot config <command> [options]

COMMANDS:
    theme list|current       Show available/current theme
    edit [file]              Edit configuration files interactively
    backup [name]            Backup current configuration
    restore [name]           Restore from backup
    validate                 Validate configuration files and symlinks
    reset [component]        Reset to default (all|zsh|nvim)

EXAMPLES:
    dot config edit                     # Interactive file picker
    dot config edit .zshrc              # Edit shell config directly
    dot config backup my-config         # Create named backup
    dot config validate                 # Check configuration health
    dot config reset nvim               # Reset Neovim to defaults
    dot config theme current            # Show active theme
EOF
}
