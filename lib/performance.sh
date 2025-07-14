#!/usr/bin/env bash
# ============================================================================
# Performance Optimization Functions
# Improves shell startup time and runtime performance
# ============================================================================

# Enable performance timing
DOTFILES_PERF_TIMING=${DOTFILES_PERF_TIMING:-false}

# Performance timing function
perf_time() {
    if [[ "$DOTFILES_PERF_TIMING" == "true" ]]; then
        echo "⏱️  $1: $(date +%s.%3N)" >&2
    fi
}

# Cached completion initialization
init_completions_cached() {
    perf_time "Starting completions init"
    
    # Cache completions for faster startup
    local zcompdump_file="${ZDOTDIR:-$HOME}/.zcompdump"
    
    # Only regenerate if needed
    if [[ ! -s "$zcompdump_file" || "$zcompdump_file" -ot ~/.zshrc ]]; then
        perf_time "Regenerating completions cache"
        autoload -U compinit
        compinit
        # Compile the cache for faster loading
        [[ -s "$zcompdump_file" && (! -s "${zcompdump_file}.zwc" || "$zcompdump_file" -nt "${zcompdump_file}.zwc") ]] && zcompile "$zcompdump_file"
    else
        perf_time "Loading cached completions"
        autoload -U compinit
        compinit -C  # Skip security check for cached completions
    fi
    
    perf_time "Completions init done"
}

# Lazy load functions to improve startup time
lazy_load() {
    local cmd="$1"
    local load_func="$2"
    
    # Create a wrapper function that loads the real command on first use
    eval "$cmd() {
        unfunction $cmd
        $load_func
        $cmd \"\$@\"
    }"
}

# Initialize tools asynchronously where possible
async_init_tools() {
    perf_time "Starting async tool init"
    
    # Background initialization for non-critical tools
    {
        # Atuin history
        if command -v atuin >/dev/null 2>&1; then
            eval "$(atuin init zsh)" 2>/dev/null
        fi
        
        # Version update check (low priority)
        if [[ -f "$DOTFILES_DIR/lib/version.sh" ]]; then
            source "$DOTFILES_DIR/lib/version.sh"
            auto_update_check 2>/dev/null &
        fi
    } &
    
    perf_time "Async init started"
}

# Fast tool initialization
fast_init_tools() {
    perf_time "Starting fast tool init"
    
    # Critical tools that need immediate availability
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi
    
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi
    
    perf_time "Fast tool init done"
}

# Optimized mise initialization
init_mise_fast() {
    perf_time "Starting mise init"
    
    if command -v mise >/dev/null 2>&1; then
        # Use mise's built-in fast initialization
        eval "$(mise activate zsh)"
    fi
    
    perf_time "Mise init done"
}

# Performance monitoring commands
perf_enable_timing() {
    export DOTFILES_PERF_TIMING=true
    echo "✅ Performance timing enabled. Restart shell to see timings."
}

perf_disable_timing() {
    export DOTFILES_PERF_TIMING=false
    echo "✅ Performance timing disabled."
}

perf_benchmark_startup() {
    echo "🚀 Benchmarking shell startup time..."
    echo "Running 5 shell startup tests..."
    
    # Check if bc is available for arithmetic calculations
    if ! command -v bc &> /dev/null; then
        echo "⚠️  Warning: 'bc' command not found. Install with: brew install bc"
        echo "📊 Performing simplified startup benchmark..."
        
        # Fallback to shell arithmetic (less precise)
        local total_time=0
        for i in {1..5}; do
            local start_time=$(date +%s)
            zsh -i -c exit 2>/dev/null
            local end_time=$(date +%s)
            local elapsed=$((end_time - start_time))
            echo "Test $i: ${elapsed}s"
            total_time=$((total_time + elapsed))
        done
        
        local avg_time=$((total_time / 5))
        echo "📊 Average startup time: ${avg_time}s (approximate)"
        
        if (( avg_time > 1 )); then
            echo "⚠️  Startup time is slow (>1s). Consider optimizations."
        else
            echo "✅ Startup time looks good (<1s)."
        fi
        return
    fi
    
    # Use bc for precise calculations
    local total_time=0
    for i in {1..5}; do
        local start_time=$(date +%s.%3N)
        zsh -i -c exit 2>/dev/null
        local end_time=$(date +%s.%3N)
        local elapsed=$(echo "$end_time - $start_time" | bc)
        echo "Test $i: ${elapsed}s"
        total_time=$(echo "$total_time + $elapsed" | bc)
    done
    
    local avg_time=$(echo "scale=3; $total_time / 5" | bc)
    echo "📊 Average startup time: ${avg_time}s"
    
    if (( $(echo "$avg_time > 1.0" | bc -l) )); then
        echo "⚠️  Startup time is slow (>1s). Consider optimizations."
    elif (( $(echo "$avg_time > 0.5" | bc -l) )); then
        echo "⚡ Startup time is acceptable (0.5-1.0s)."
    else
        echo "🚀 Startup time is fast (<0.5s)!"
    fi
}

perf_profile_startup() {
    echo "🔍 Profiling shell startup with detailed timing..."
    DOTFILES_PERF_TIMING=true zsh -i -c exit
}

perf_status() {
    echo "📊 Performance Status:"
    echo "  Timing Enabled: $DOTFILES_PERF_TIMING"
    echo "  Completion Cache: $([ -f ~/.zcompdump.zwc ] && echo "✅ Compiled" || echo "❌ Not compiled")"
    echo "  ZSH Version: $ZSH_VERSION"
    
    # Check if running in performance mode
    if [[ -n "$DOTFILES_FAST_MODE" ]]; then
        echo "  Fast Mode: ✅ Enabled"
    else
        echo "  Fast Mode: ❌ Disabled (export DOTFILES_FAST_MODE=1 to enable)"
    fi
}

# Fast mode - minimal initialization
enable_fast_mode() {
    export DOTFILES_FAST_MODE=1
    echo "🚀 Fast mode enabled. Some features may be disabled for speed."
    echo "   Restart your shell to take effect."
}

disable_fast_mode() {
    unset DOTFILES_FAST_MODE
    echo "🔄 Fast mode disabled. Full feature set restored."
    echo "   Restart your shell to take effect."
}