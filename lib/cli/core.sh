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
    local machine=false
    local test_mode="${DOT_TEST_MODE:-false}"
    local gear_icon="${GEAR:-"⚙️"}"
    local rocket_icon="${ROCKET:-"🚀"}"

    local fix=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet) quiet=true; shift ;;
            --detailed) detailed=true; shift ;;
            --machine|-m|--json) machine=true; quiet=true; shift ;;
            --fix) fix=true; shift ;;
            -h|--help) show_check_help; return 0 ;;
            *) print_error "Unknown option: $1"; return 1 ;;
        esac
    done
    
    # Machine-readable output (JSON)
    if [[ "$machine" == "true" ]]; then
        local json_output='{'
        json_output+='"status":"checking",'
        json_output+='"tools":{},'
        json_output+='"issues":[],'
        json_output+='"configs":{},'
        json_output+='"tmux":{},'
        json_output+='"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"'
        json_output+='}'
        
        # Parse and check tools
        local tools_status='{'
        local essential_tools=("zsh" "git" "nvim" "tmux" "starship" "eza" "bat" "rg" "fd" "fzf")
        local first=true
        
        for tool in "${essential_tools[@]}"; do
            local tool_name="$tool"
            local tool_version="unknown"
            local tool_ok=false
            
            case "$tool" in
                bat)  command -v bat &>/dev/null || command -v batcat &>/dev/null && tool_ok=true ;;
                fd)   command -v fd &>/dev/null || command -v fdfind &>/dev/null && tool_ok=true ;;
                *)    command -v "$tool" &>/dev/null && tool_ok=true ;;
            esac
            
            # Get version if available
            if [[ "$tool_ok" == "true" ]]; then
                case "$tool" in
                    zsh) tool_version=$(zsh --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown") ;;
                    git) tool_version=$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown") ;;
                    nvim) tool_version=$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown") ;;
                    tmux) tool_version=$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "unknown") ;;
                    *) tool_version=$(eval "$tool" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown") ;;
                esac
            fi
            
            [[ "$first" == "true" ]] || tools_status+=','
            first=false
            tools_status+="\"$tool\":{\"ok\":$tool_ok,\"version\":\"$tool_version\"}"
        done
        tools_status+='}'
        
        # Check configs
        local configs_status='{'
        configs_status+="\"zsh\":$([[ -L \"$HOME/.zshrc\" ]] && echo true || echo false),"
        configs_status+="\"tmux\":$([[ -L \"$HOME/.tmux.conf\" ]] && echo true || echo false),"
        configs_status+="\"nvim\":$([[ -L \"$HOME/.config/nvim\" ]] && echo true || echo false)"
        configs_status+='}'
        
        # Check tmux
        local tmux_status="{}"
        if command -v tmux &>/dev/null; then
            tmux_status='{'
            tmux_status+="\"installed\":true,"
            tmux_status+="\"version\":\"$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo unknown)\","
            tmux_status+="\"config_valid\":$(tmux -f ~/.tmux.conf list-keys &>/dev/null && echo true || echo false)"
            tmux_status+='}'
        fi
        
        # Build final JSON
        local final_json='{'
        final_json+='"status":"ok",'
        final_json+='"tools":'$tools_status','
        final_json+='"configs":'$configs_status','
        final_json+='"tmux":'$tmux_status','
        final_json+='"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"'
        final_json+='}'
        
        echo "$final_json"
        return 0
    fi
    
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

# Show changelog after pulling new commits
_show_update_changelog() {
    local old_head="$1"
    local new_head
    new_head=$(git rev-parse HEAD)

    # Nothing new
    [[ "$old_head" == "$new_head" ]] && return 0

    local commits
    commits=$(git log --oneline "$old_head..$new_head" 2>/dev/null)
    [[ -z "$commits" ]] && return 0

    # Count by type
    local feat_count=0 fix_count=0 chore_count=0 other_count=0
    while IFS= read -r line; do
        local subject="${line#* }"
        case "$subject" in
            feat*)  ((feat_count++)) ;;
            fix*)   ((fix_count++)) ;;
            chore*) ((chore_count++)) ;;
            *)      ((other_count++)) ;;
        esac
    done <<< "$commits"

    local total=$((feat_count + fix_count + chore_count + other_count))

    echo ""
    print_info "📋 What's new:"

    # Show feat commits with usage hints
    while IFS= read -r line; do
        local subject="${line#* }"
        case "$subject" in
            feat*)
                echo "  $subject"
                # Extract subcommand hint from feat(cli) commits
                if [[ "$subject" =~ feat\(cli\):.*\`dot\ ([a-z]+) ]]; then
                    local cmd="${BASH_REMATCH[1]}"
                    echo "    → Try: dot $cmd --help"
                elif [[ "$subject" =~ feat\(cli\):.*\`dot\ ([a-z]+\ [a-z]+) ]]; then
                    local cmd="${BASH_REMATCH[1]}"
                    echo "    → Try: dot $cmd --help"
                fi
                ;;
        esac
    done <<< "$commits"

    # Show fix commits
    while IFS= read -r line; do
        local subject="${line#* }"
        case "$subject" in
            fix*) echo "  $subject" ;;
        esac
    done <<< "$commits"

    # Build summary line
    local parts=()
    [[ $feat_count -gt 0 ]] && parts+=("feat: $feat_count")
    [[ $fix_count -gt 0 ]] && parts+=("fix: $fix_count")
    [[ $chore_count -gt 0 ]] && parts+=("chore: $chore_count")
    [[ $other_count -gt 0 ]] && parts+=("other: $other_count")

    local summary
    summary=$(IFS=', '; echo "${parts[*]}")

    echo ""
    print_info "  $total commits pulled ($summary)"
}

# Update command - update entire system
dot_update() {
    local auto_confirm=false
    local machine=false
    local reload_shell=false
    local update_scope="all"  # all | self | tools | per-tool
    local -a tool_targets=()

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --yes) auto_confirm=true; shift ;;
            --machine|-m) machine=true; shift ;;
            --self) update_scope="self"; shift ;;
            --tools) update_scope="tools"; shift ;;
            --reload) reload_shell=true; shift ;;
            -h|--help) show_update_help; return 0 ;;
            -*) print_error "Unknown option: $1"; return 1 ;;
            *) tool_targets+=("$1"); shift ;;
        esac
    done

    # Per-tool update (fast path): dot update claude codex gemini
    if [[ ${#tool_targets[@]} -gt 0 ]]; then
        local failed=0
        for tool in "${tool_targets[@]}"; do
            _update_tool "$tool" || ((failed++))
        done
        [[ "$reload_shell" == "true" ]] && exec zsh
        return $failed
    fi

    print_info "Updating development environment..."

    # --- Step 1: Pull dotfiles repo (unless --tools only) ---
    if [[ "$update_scope" != "tools" ]]; then
        _update_repo "$auto_confirm" || return 1
    fi

    # --- Step 2: Relink dotfiles (unless --tools only) ---
    if [[ "$update_scope" != "tools" ]]; then
        print_info "Relinking configurations..."
        if [[ -x "$DOTFILES_DIR/install.sh" ]]; then
            bash "$DOTFILES_DIR/install.sh" link 2>/dev/null || print_warning "Relinking had issues"
        fi
    fi

    # --- Step 3: Upgrade tools (unless --self only) ---
    if [[ "$update_scope" != "self" ]]; then
        _update_package_managers
        _update_nvim_plugins
        _update_tpm_plugins
    fi

    # --- Step 4: Reload running services ---
    _reload_running_services

    # Machine-readable output
    if [[ "$machine" == "true" ]]; then
        echo '{"status":"completed","timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'
        return 0
    fi

    print_success "Update completed!"
    if [[ "$reload_shell" == "true" ]]; then
        exec zsh
    else
        print_info "Run 'exec zsh' or 'dot update --reload' to reload shell"
    fi
}

# Pull dotfiles repository
_update_repo() {
    local auto_confirm="${1:-false}"

    print_info "Updating dotfiles repository..."
    cd "$DOTFILES_DIR"

    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "Uncommitted changes detected in dotfiles"
        if [[ "$auto_confirm" != "true" ]]; then
            echo -n "Continue with update? [y/N]: "
            read -r response
            [[ "$response" =~ ^[Yy]$ ]] || { print_info "Update cancelled"; return 1; }
        fi
    fi

    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@') || default_branch="main"
    local old_head=$(git rev-parse HEAD)

    if git pull origin "$default_branch"; then
        print_success "Repository updated"
        _show_update_changelog "$old_head"
    else
        print_error "Failed to update repository"
        return 1
    fi
}

# Upgrade all package managers (one unified pass, no duplicates)
_update_package_managers() {
    print_info "Upgrading installed tools..."

    # Homebrew (handles brew-installed tools including neovim, opencode, etc.)
    if command -v brew &>/dev/null; then
        print_info "  Homebrew..."
        brew upgrade 2>/dev/null && print_success "  Homebrew upgraded" || true
    fi

    # npm global packages (all npm-managed tools in one pass)
    if command -v npm &>/dev/null; then
        print_info "  npm globals..."
        npm update -g 2>/dev/null && print_success "  npm globals upgraded" || true
    fi

    # uv-managed tools (aider, kimi, repomix, etc.)
    if command -v uv &>/dev/null; then
        print_info "  uv tools..."
        uv tool upgrade --all 2>/dev/null && print_success "  uv tools upgraded" || true
    fi

    # mise-managed runtimes
    if command -v mise &>/dev/null; then
        print_info "  mise runtimes..."
        mise upgrade 2>/dev/null && print_success "  mise upgraded" || true
    fi
}

# Update Neovim plugins
_update_nvim_plugins() {
    if command -v nvim >/dev/null 2>&1; then
        print_info "Updating Neovim plugins..."
        nvim --headless -c 'Lazy! sync' -c 'qa' 2>/dev/null \
            && print_success "  Plugins updated" \
            || print_warning "  Plugin update had issues"
    fi
}

# Update tmux plugins via TPM
_update_tpm_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]] && [[ -x "$tpm_dir/bin/update_plugins" ]]; then
        if tmux list-sessions >/dev/null 2>&1; then
            print_info "Updating tmux plugins..."
            tmux run-shell "$tpm_dir/bin/update_plugins all" 2>/dev/null \
                && print_success "  Tmux plugins updated" || true
        fi
    elif [[ ! -d "$tpm_dir" ]]; then
        print_info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir" 2>/dev/null \
            && print_success "  TPM installed" \
            || print_warning "  Failed to install TPM"
    fi
}

# Per-tool update: dot update claude / dot update codex / etc.
_update_tool() {
    local tool="$1"
    print_info "Updating $tool..."
    case "$tool" in
        claude|claude_code|claude-code)
            _try_brew_cask "claude-code" || _try_npm "@anthropic-ai/claude-code" ;;
        codex)
            _try_brew_cask "codex" || _try_npm "@openai/codex" ;;
        gemini|gemini_cli|gemini-cli)
            _try_npm "@google/gemini-cli" ;;
        amp)
            _try_brew "amp" || { print_warning "Reinstall: curl -fsSL https://ampcode.com/install.sh | bash"; return 1; } ;;
        aider)
            _try_uv "aider-chat" ;;
        kimi)
            _try_uv "kimi-cli" ;;
        opencode)
            _try_brew "opencode" ;;
        cursor|cursor_cli)
            print_info "Cursor updates via its own auto-updater" ;;
        pi)
            _try_npm "@mariozechner/pi-coding-agent" ;;
        kilo)
            _try_npm "@nicepkg/kilo" ;;
        factory|droid)
            _try_brew_cask "droid" ;;
        # Package manager bulk upgrades
        brew|homebrew)
            command -v brew &>/dev/null && brew upgrade 2>/dev/null || return 1 ;;
        npm)
            command -v npm &>/dev/null && npm update -g 2>/dev/null || return 1 ;;
        uv)
            command -v uv &>/dev/null && uv tool upgrade --all 2>/dev/null || return 1 ;;
        mise)
            command -v mise &>/dev/null && mise upgrade 2>/dev/null || return 1 ;;
        nvim|neovim)
            _update_nvim_plugins ;;
        tmux)
            _update_tpm_plugins ;;
        *)
            print_error "Unknown tool: $tool"
            echo "Tools: claude, codex, gemini, amp, aider, kimi, opencode, cursor, pi, kilo, factory"
            echo "Managers: brew, npm, uv, mise, nvim, tmux"
            return 1 ;;
    esac
    local rc=$?
    [[ $rc -eq 0 ]] && print_success "$tool updated" || print_warning "$tool update had issues"
    return $rc
}

_try_brew_cask() { command -v brew &>/dev/null && brew upgrade --cask "$1" 2>/dev/null; }
_try_brew()      { command -v brew &>/dev/null && brew upgrade "$1" 2>/dev/null; }
_try_npm()       { command -v npm &>/dev/null && npm update -g "$1" 2>/dev/null; }
_try_uv()        { command -v uv &>/dev/null && uv tool upgrade "$1" 2>/dev/null; }

# Reload running tmux and nvim
_reload_running_services() {
    # Tmux
    if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
        print_success "Tmux config reloaded"
    fi

    # Neovim (via nvr if available)
    if command -v nvr >/dev/null 2>&1; then
        for server in /tmp/nvim*/0; do
            [[ -S "$server" ]] && nvr --servername "$server" --remote-send ':source $MYVIMRC<CR>' 2>/dev/null || true
        done
    fi
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
dot update - Update development environment

USAGE:
    dot update [options] [tool...]

OPTIONS:
    --self       Pull dotfiles + relink only (no tool upgrades)
    --tools      Upgrade tools only (no git pull)
    --reload     Auto-reload shell after update (exec zsh)
    --yes        Auto-confirm all prompts
    -m, --machine  JSON output
    -h, --help   Show this help message

TOOLS (per-tool fast update):
    claude, codex, gemini, amp, aider, kimi, opencode, cursor, pi, kilo, factory
    brew, npm, uv, mise, nvim, tmux

EXAMPLES:
    dot update             # Full update (pull + tools + reload)
    dot update claude      # Update only Claude Code (~2s)
    dot update claude codex gemini  # Update multiple tools
    dot update --self      # Just pull dotfiles and relink
    dot update --tools     # Just upgrade brew/npm/uv/mise
    dot update --reload    # Full update + auto-reload shell
EOF
}

# Check managed file drift - detect symlinks that have been replaced or removed
check_managed_file_drift() {
    local dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
    local drift_count=0

    # Build the list of managed symlinks.
    # Each entry is "target|expected_source_relative" where the source is
    # relative to $dotfiles_dir.  For .tmux.conf and .gitconfig the installer
    # supports fallback paths, so we check both.
    local -a targets=()
    local -a expected_sources=()

    targets+=("$HOME/.zshrc");              expected_sources+=(".zshrc")
    targets+=("$HOME/.zshenv");             expected_sources+=("config/zsh/.zshenv")
    targets+=("$HOME/.zprofile");           expected_sources+=("config/zsh/.zprofile")
    targets+=("$HOME/.tmux.conf");          expected_sources+=(".tmux.conf")
    targets+=("$HOME/.gitconfig");          expected_sources+=(".gitconfig")
    targets+=("$HOME/.config/nvim");        expected_sources+=("config/nvim")
    targets+=("$HOME/.config/git/hooks");   expected_sources+=("hooks")

    echo ""
    print_info "Managed file drift check:"

    for i in "${!targets[@]}"; do
        local target="${targets[$i]}"
        local expected="${expected_sources[$i]}"
        local display_target="${target/#$HOME/~}"

        if [[ ! -e "$target" && ! -L "$target" ]]; then
            # File/directory does not exist at all
            echo "  ✗ $display_target missing"
            ((drift_count++))
            continue
        fi

        if [[ -L "$target" ]]; then
            # It is a symlink - resolve where it points
            local actual_target
            actual_target=$(readlink "$target")

            # Check against each acceptable source (pipe-separated)
            local matched=false
            IFS='|' read -ra candidates <<< "$expected"
            for candidate in "${candidates[@]}"; do
                local full_candidate="$dotfiles_dir/$candidate"
                if [[ "$actual_target" == "$full_candidate" ]]; then
                    matched=true
                    local display_source="dotfiles/$candidate"
                    echo "  ✓ $display_target → $display_source"
                    break
                fi
            done

            if [[ "$matched" == "false" ]]; then
                echo "  ✗ $display_target → $actual_target (expected dotfiles)"
                ((drift_count++))
            fi
        else
            # It exists but is a regular file/directory, not a symlink
            echo "  ✗ $display_target is a regular file (not managed symlink) — drift risk"
            ((drift_count++))
        fi
    done

    return $drift_count
}

# Doctor command - diagnose and fix common issues
dot_doctor() {
    local machine=false
    local fix_mode=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)
                fix_mode=true
                shift
                ;;
            --machine|-m)
                machine=true
                shift
                ;;
            -h|--help)
                echo "dot doctor - Diagnose and fix common issues"
                echo ""
                echo "USAGE:"
                echo "    dot doctor [options]"
                echo ""
                echo "OPTIONS:"
                echo "    --fix      Auto-fix detected issues"
                echo "    --machine  Output JSON for scripting"
                echo "    -h, --help Show this help"
                echo ""
                echo "Checks:"
                echo "  • Shell configuration"
                echo "  • Git configuration"
                echo "  • SSH keys"
                echo "  • Tool installations"
                echo "  • Common path issues"
                echo "  • Managed file drift (symlinks vs repo)"
                return 0
                ;;
            *)
                print_error "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    local issues=()
    local fixes=()
    local critical=0
    local warnings=0
    
    print_info "🔍 Running diagnostics..."
    
    # Check 1: Shell is zsh
    if [[ "$SHELL" != *"zsh" ]]; then
        issues+=("Shell is not zsh (current: $SHELL)")
        ((critical++))
        if [[ "$fix_mode" == "true" ]]; then
            if chsh -s $(which zsh) 2>/dev/null; then
                fixes+=("Changed default shell to zsh")
            fi
        fi
    fi
    
    # Check 2: Dotfiles symlinks
    if [[ ! -L "$HOME/.zshrc" ]]; then
        issues+=(".zshrc not symlinked to dotfiles")
        ((critical++))
        if [[ "$fix_mode" == "true" ]]; then
            if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
                mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)" 2>/dev/null
                ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
                fixes+=("Linked .zshrc to dotfiles")
            fi
        fi
    fi
    
    # Check 3: Git user config
    if ! git config --global user.name &>/dev/null || ! git config --global user.email &>/dev/null; then
        issues+=("Git user.name or user.email not set")
        ((warnings++))
    fi
    
    # Check 4: SSH keys
    if [[ ! -d "$HOME/.ssh" ]] || [[ -z "$(ls -A $HOME/.ssh/id_* 2>/dev/null)" ]]; then
        issues+=("No SSH keys found")
        ((warnings++))
    fi
    
    # Check 5: TPM installed (if tmux is used)
    if command -v tmux &>/dev/null && [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        issues+=("TPM (Tmux Plugin Manager) not installed")
        ((warnings++))
        if [[ "$fix_mode" == "true" ]]; then
            git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null
            fixes+=("Installed TPM")
        fi
    fi
    
    # Check 6: Neovim health
    if command -v nvim &>/dev/null; then
        local nvim_version=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
        if printf '%s\n' "0.10.0" "$nvim_version" | sort -V -C; then
            : # nvim >= 0.10.0, good
        else
            issues+=("Neovim $nvim_version is older than 0.10.0 (recommended)")
            ((warnings++))
        fi
    fi
    
    # Check 7: PATH contains common bin directories
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        issues+=("~/.local/bin not in PATH")
        ((warnings++))
    fi

    # Check 8: Managed file drift
    check_managed_file_drift
    local drift_count=$?
    if [[ $drift_count -gt 0 ]]; then
        issues+=("$drift_count managed file(s) have drifted from dotfiles")
        ((warnings += drift_count))
    fi

    # Machine-readable output
    if [[ "$machine" == "true" ]]; then
        local json_output='{'
        json_output+='"status":"'$((${#issues[@]} == 0 ? "ok" : "issues"))'",'
        json_output+='"critical":'$critical','
        json_output+='"warnings":'$warnings','
        json_output+='"issues":['
        local first=true
        for issue in "${issues[@]}"; do
            [[ "$first" == "true" ]] || json_output+=','
            first=false
            json_output+="\"${issue//\"/\\\"}\""
        done
        json_output+='],'
        json_output+='"fixes_applied":['
        first=true
        for fix in "${fixes[@]}"; do
            [[ "$first" == "true" ]] || json_output+=','
            first=false
            json_output+="\"${fix//\"/\\\"}\""
        done
        json_output+=']}'
        echo "$json_output"
        return 0
    fi
    
    # Human-readable output
    echo ""
    if [[ ${#issues[@]} -eq 0 ]]; then
        print_success "All checks passed! No issues found."
    else
        print_warning "Found ${#issues[@]} issues ($critical critical, $warnings warnings):"
        echo ""
        for issue in "${issues[@]}"; do
            echo "  • $issue"
        done
        echo ""
        
        if [[ ${#fixes[@]} -gt 0 ]]; then
            print_success "Applied ${#fixes[@]} fixes:"
            for fix in "${fixes[@]}"; do
                echo "  ✓ $fix"
            done
        fi
        
        if [[ "$fix_mode" != "true" && $critical -gt 0 ]]; then
            print_info "Run 'dot doctor --fix' to auto-fix issues"
        fi
        
        return 1
    fi
}
