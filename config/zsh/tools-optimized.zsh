# ============================================================================
# Optimized Tool Integration
# Advanced lazy loading and performance-optimized tool initialization
# ============================================================================

# Ensure perf_time is defined (no-op if not already loaded)
# This prevents "command not found" errors when performance.zsh is not sourced
if ! typeset -f perf_time > /dev/null 2>&1; then
    perf_time() { : ; }  # No-op function
fi

# Load advanced performance optimizations
if [[ -f "$DOTFILES_DIR/lib/performance-advanced.sh" ]]; then
    source "$DOTFILES_DIR/lib/performance-advanced.sh"
fi

# ============================================================================
# Smart Completion System with Caching
# ============================================================================

init_completions_smart() {
    perf_time "Starting smart completions init"
    
    local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    local completion_cache_dir="${ZDOTDIR:-$HOME}/.zsh_completion_cache"
    
    # Create completion cache directory
    [[ -d "$completion_cache_dir" ]] || /bin/mkdir -p "$completion_cache_dir"
    
    # Check if we need to rebuild completions
    local rebuild_needed=false
    
    # Rebuild if main dump doesn't exist or is old
    if [[ ! -f "$zcompdump" ]] || [[ ! -f "${zcompdump}.zwc" ]]; then
        rebuild_needed=true
    fi
    
    # Rebuild if any tool has been updated recently
    for tool in mise starship zoxide atuin; do
        if command -v "$tool" >/dev/null 2>&1; then
            local tool_path=$(command -v "$tool")
            if [[ "$tool_path" -nt "$zcompdump" ]]; then
                rebuild_needed=true
                break
            fi
        fi
    done
    
    if [[ "$rebuild_needed" == "true" ]]; then
        perf_time "Rebuilding completions cache"
        autoload -U compinit
        compinit -d "$zcompdump"
        compile_all_completions
    else
        perf_time "Loading cached completions"
        autoload -U compinit
        compinit -C -d "$zcompdump"
    fi
    
    perf_time "Smart completions init done"
}

# ============================================================================
# Lazy Loading for Heavy Tools
# ============================================================================

# Mise lazy loader
mise_lazy_loader() {
    if command -v mise >/dev/null 2>&1; then
        perf_time "Loading mise"
        eval "$(mise activate zsh)"
        eval "$(mise completion zsh)"
        perf_time "Mise loaded"
    fi
}

# Atuin lazy loader  
atuin_lazy_loader() {
    if command -v atuin >/dev/null 2>&1; then
        perf_time "Loading atuin"
        eval "$(atuin init zsh)"
        perf_time "Atuin loaded"
    fi
}

# Docker lazy loader
docker_lazy_loader() {
    if command -v docker >/dev/null 2>&1; then
        perf_time "Loading docker completions"
        if [[ -f /usr/local/share/zsh/site-functions/_docker ]]; then
            source /usr/local/share/zsh/site-functions/_docker
        fi
        perf_time "Docker completions loaded"
    fi
}

# Kubernetes lazy loader
kubectl_lazy_loader() {
    if command -v kubectl >/dev/null 2>&1; then
        perf_time "Loading kubectl completions"
        source <(kubectl completion zsh)
        alias k=kubectl
        perf_time "Kubectl completions loaded"
    fi
}

# ============================================================================
# Tool Priority System
# ============================================================================

# Initialize tools based on priority and usage patterns
init_tools_prioritized() {
    perf_time "Starting prioritized tool init"
    
    # PRIORITY 1: Essential tools (always load immediately)
    if [[ "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi
    
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi
    
    # PRIORITY 2: Frequently used tools (load in fast mode, lazy in full mode)
    if [[ "$DOTFILES_MODE" == "minimal" ]]; then
        # Minimal mode - load essential mise functionality only
        if command -v mise >/dev/null 2>&1; then
            eval "$(mise activate zsh --quiet)"
        fi
    else
        # Full mode - set up lazy loading
        if command -v mise >/dev/null 2>&1; then
            smart_lazy_load mise mise_lazy_loader
        fi
        
        if command -v atuin >/dev/null 2>&1; then
            smart_lazy_load atuin atuin_lazy_loader
        fi
    fi
    
    # PRIORITY 3: Development tools (always lazy load)
    if command -v docker >/dev/null 2>&1; then
        smart_lazy_load docker docker_lazy_loader
    fi
    
    if command -v kubectl >/dev/null 2>&1; then
        smart_lazy_load kubectl kubectl_lazy_loader
        smart_lazy_load k kubectl_lazy_loader
    fi
    
    perf_time "Prioritized tool init done"
}

# ----------------------------------------------------------------------------
# Optional Zsh plugins (fast, guarded sourcing)
# ----------------------------------------------------------------------------

fast_syntax_highlighting_loader() {
    # Prefer fast-syntax-highlighting if installed, else noop
    local candidates=(
        "$HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
        "/opt/homebrew/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
        "/usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
    )
    for f in "${candidates[@]}"; do
        if [[ -f "$f" ]]; then
            source "$f"
            return
        fi
    done
}

zsh_autocomplete_loader() {
    local candidates=(
        "/opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
        "/usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
        "$HOME/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
    )
    for f in "${candidates[@]}"; do
        if [[ -f "$f" ]]; then
            source "$f"
            return
        fi
    done
}

# ============================================================================
# FZF Optimization
# ============================================================================
# Note: FZF_DEFAULT_COMMAND and FZF_DEFAULT_OPTS are defined in defaults.zsh

init_fzf_optimized() {
    if command -v fzf >/dev/null 2>&1; then
        perf_time "Loading FZF"
        
        # Load key bindings if available
        if [[ -f "$HOME/.fzf.zsh" ]]; then
            source "$HOME/.fzf.zsh"
        elif [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
            source "/usr/share/fzf/key-bindings.zsh"
        elif [[ -f "/opt/homebrew/share/fzf/shell/key-bindings.zsh" ]]; then
            source "/opt/homebrew/share/fzf/shell/key-bindings.zsh"
        fi
        
        perf_time "FZF loaded"
    fi
}

# ============================================================================
# Conditional Tool Loading
# ============================================================================

# Load tools based on directory context
load_context_tools() {
    # Load project-specific tools based on files in current directory
    if [[ -f "package.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]]; then
        # Node.js project
        if command -v yarn >/dev/null 2>&1; then
            smart_lazy_load yarn "eval \"\$(yarn completion zsh)\""
        fi
        if command -v pnpm >/dev/null 2>&1; then
            smart_lazy_load pnpm "eval \"\$(pnpm completion zsh)\""
        fi
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        # Rust project
        if command -v cargo >/dev/null 2>&1; then
            smart_lazy_load cargo "source <(cargo completion zsh)"
        fi
    fi
    
    if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        # Python project
        if command -v poetry >/dev/null 2>&1; then
            smart_lazy_load poetry "eval \"\$(poetry completions zsh)\""
        fi
        if command -v pipenv >/dev/null 2>&1; then
            smart_lazy_load pipenv "eval \"\$(pipenv --completion)\""
        fi
    fi
    
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        # Docker project
        if command -v docker >/dev/null 2>&1; then
            docker_lazy_loader
        fi
        if command -v docker-compose >/dev/null 2>&1; then
            smart_lazy_load docker-compose "eval \"\$(docker-compose completion zsh)\""
        fi
    fi
    
    if [[ -f "kubernetes.yaml" ]] || [[ -f "k8s.yaml" ]] || [[ -d ".kubernetes" ]]; then
        # Kubernetes project
        if command -v kubectl >/dev/null 2>&1; then
            kubectl_lazy_loader
        fi
    fi
}

# ============================================================================
# Performance-Optimized Aliases
# ============================================================================

setup_optimized_aliases() {
    # Use fastest available tools
    if [[ -z "$DOTFILES_AGENT_SAFE" ]] && command -v eza >/dev/null 2>&1; then
        alias ls='eza --group-directories-first'
        alias ll='eza -l --group-directories-first --git'
        alias la='eza -la --group-directories-first --git'
        alias tree='eza --tree'
    fi
    
    if [[ -z "$DOTFILES_AGENT_SAFE" ]] && command -v bat >/dev/null 2>&1; then
        alias cat='bat --style=plain'
        alias less='bat'
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi
    
    if [[ -z "$DOTFILES_AGENT_SAFE" ]] && command -v rg >/dev/null 2>&1; then
        alias grep='rg'
    fi
    
    if [[ -z "$DOTFILES_AGENT_SAFE" ]] && command -v fd >/dev/null 2>&1; then
        alias find='fd'
    fi
    
    # Performance shortcuts
    alias reload='source ~/.zshrc'
    alias perf='perf_benchmark_startup'
    alias tools='command -v starship zoxide eza bat rg fd fzf mise atuin'
}

# ============================================================================
# Main Initialization Function
# ============================================================================

init_tools_optimized() {
    perf_time "Starting optimized tools initialization"
    
    # Initialize completions with smart caching
    init_completions_smart
    
    # Initialize tools with priority system
    init_tools_prioritized
    
    # Initialize FZF with optimizations
    init_fzf_optimized
    
    # Set up optimized aliases
    setup_optimized_aliases
    
    # Load context-specific tools (must run in current shell — `source` can't affect parent from subshell)
    load_context_tools 2>/dev/null || true

    # Load optional Zsh plugins (must run in current shell for syntax-highlighting/completions to activate)
    fast_syntax_highlighting_loader 2>/dev/null || true
    zsh_autocomplete_loader 2>/dev/null || true
    
    perf_time "Optimized tools initialization complete"
}

# ============================================================================
# Initialize
# ============================================================================

# Initialize optimized tools
init_tools_optimized
