# ============================================================================
# Performance Configuration Module
# High-performance shell startup and runtime optimizations
# ============================================================================

# ============================================================================
# Performance Flags and Environment
# ============================================================================

# Set performance mode based on system resources
if [[ -z "$DOTFILES_PERFORMANCE_MODE" ]]; then
    # Auto-detect performance mode based on system
    cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)
    available_memory=""
    
    # Get available memory in MB
    if command -v free >/dev/null 2>&1; then
        available_memory=$(free -m | awk '/^Mem:/{print $7}')
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        available_memory=$(( $(vm_stat | awk '/Pages free:/{print $3}' | tr -d '.') * 4096 / 1024 / 1024 ))
    else
        available_memory=2048  # Default assumption
    fi
    
    # Set performance mode based on resources
    if [[ -n "$available_memory" && $available_memory -lt 512 ]] || [[ $cpu_cores -lt 2 ]]; then
        export DOTFILES_PERFORMANCE_MODE="fast"
        export DOTFILES_FAST_MODE=1
    elif [[ -n "$available_memory" && $available_memory -gt 4096 ]] && [[ $cpu_cores -gt 4 ]]; then
        export DOTFILES_PERFORMANCE_MODE="full"
    else
        export DOTFILES_PERFORMANCE_MODE="balanced"
    fi
fi

# ============================================================================
# Advanced Timing and Profiling
# ============================================================================

# High-precision timing for performance analysis
if [[ "$DOTFILES_PERF_TIMING" == "true" ]]; then
    # Enable zsh profiling module
    zmodload zsh/datetime
    
    # Enhanced timing function with microsecond precision
    perf_time_enhanced() {
        if [[ "$DOTFILES_PERF_TIMING" == "true" ]]; then
            local current_time=$(printf "%.6f" $EPOCHREALTIME)
            echo "⏱️  $1: ${current_time}s" >&2
        fi
    }
    
    # Override standard perf_time
    alias perf_time='perf_time_enhanced'
fi

# ============================================================================
# Memory and Process Optimization
# ============================================================================

# Optimize shell memory usage based on performance mode
optimize_shell_memory_advanced() {
    case "$DOTFILES_PERFORMANCE_MODE" in
        "fast")
            # Minimal memory footprint
            export HISTSIZE=1000
            export SAVEHIST=1000
            export LISTMAX=50
            setopt NO_SHARE_HISTORY  # Reduce I/O
            ;;
        "balanced")
            # Balanced settings
            export HISTSIZE=5000
            export SAVEHIST=5000
            export LISTMAX=100
            ;;
        "full")
            # Full feature set
            export HISTSIZE=10000
            export SAVEHIST=10000
            export LISTMAX=200
            ;;
    esac
    
    # Common optimizations for all modes
    setopt HIST_REDUCE_BLANKS      # Remove unnecessary spaces
    setopt HIST_NO_STORE           # Don't store history commands
    setopt HIST_EXPIRE_DUPS_FIRST  # Expire duplicates first
    
    # Optimize for large directories
    setopt GLOB_DOTS
    setopt NO_NOMATCH
    setopt NUMERIC_GLOB_SORT
}

# ============================================================================
# Intelligent Caching System
# ============================================================================

# Cache frequently accessed data
setup_intelligent_caching() {
    local cache_dir="$HOME/.cache/dotfiles/zsh"
    mkdir -p "$cache_dir"
    
    # Cache system information
    if [[ ! -f "$cache_dir/system_info" ]] || [[ $(find "$cache_dir/system_info" -mtime +1 2>/dev/null) ]]; then
        {
            echo "OS: $OSTYPE"
            echo "CPU_CORES: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)"
            echo "SHELL_VERSION: $ZSH_VERSION"
            echo "TERM: $TERM"
        } > "$cache_dir/system_info"
    fi
    
    # Cache tool versions
    if [[ ! -f "$cache_dir/tool_versions" ]] || [[ $(find "$cache_dir/tool_versions" -mtime +7 2>/dev/null) ]]; then
        {
            command -v git >/dev/null && echo "GIT: $(git --version)"
            command -v node >/dev/null && echo "NODE: $(node --version)"
            command -v python3 >/dev/null && echo "PYTHON: $(python3 --version)"
            command -v nvim >/dev/null && echo "NVIM: $(nvim --version | head -1)"
        } > "$cache_dir/tool_versions" 2>/dev/null &
    fi
}

# ============================================================================
# Parallel Loading System
# ============================================================================

# Load multiple components in parallel
parallel_load() {
    local components=("$@")
    local pids=()
    
    # Start background processes
    for component in "${components[@]}"; do
        {
            case "$component" in
                "completions")
                    init_completions_smart 2>/dev/null
                    ;;
                "aliases")
                    setup_optimized_aliases 2>/dev/null
                    ;;
                "tools")
                    init_tools_prioritized 2>/dev/null
                    ;;
                "fzf")
                    init_fzf_optimized 2>/dev/null
                    ;;
                *)
                    eval "$component" 2>/dev/null
                    ;;
            esac
        } &
        pids+=($!)
    done
    
    # Wait for critical components
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# ============================================================================
# Performance Monitoring and Benchmarking
# ============================================================================

# Advanced startup benchmarking
benchmark_startup_advanced() {
    echo "🚀 Advanced Shell Startup Benchmark"
    echo "===================================="
    
    local test_count=10
    local times=()
    local total_time=0
    
    echo "Running $test_count startup tests..."
    
    for i in $(seq 1 $test_count); do
        local start_time=$(date +%s.%6N)
        zsh -i -c 'exit' 2>/dev/null
        local end_time=$(date +%s.%6N)
        local elapsed=$(echo "$end_time - $start_time" | bc -l)
        times+=($elapsed)
        total_time=$(echo "$total_time + $elapsed" | bc -l)
        printf "Test %2d: %6.3fs\n" "$i" "$elapsed"
    done
    
    # Calculate statistics
    local avg_time=$(echo "scale=3; $total_time / $test_count" | bc -l)
    local min_time=$(printf '%s\n' "${times[@]}" | sort -n | head -1)
    local max_time=$(printf '%s\n' "${times[@]}" | sort -n | tail -1)
    
    echo ""
    echo "📊 Results:"
    echo "   Average:  ${avg_time}s"
    echo "   Minimum:  ${min_time}s"
    echo "   Maximum:  ${max_time}s"
    echo "   Mode:     $DOTFILES_PERFORMANCE_MODE"
    
    # Performance assessment
    if (( $(echo "$avg_time < 0.3" | bc -l) )); then
        echo "   Rating:   🚀 Excellent (<0.3s)"
    elif (( $(echo "$avg_time < 0.5" | bc -l) )); then
        echo "   Rating:   ⚡ Very Good (0.3-0.5s)"
    elif (( $(echo "$avg_time < 1.0" | bc -l) )); then
        echo "   Rating:   ✅ Good (0.5-1.0s)"
    elif (( $(echo "$avg_time < 2.0" | bc -l) )); then
        echo "   Rating:   ⚠️  Acceptable (1.0-2.0s)"
    else
        echo "   Rating:   ❌ Needs Optimization (>2.0s)"
    fi
    
    echo ""
    echo "💡 Recommendations:"
    if (( $(echo "$avg_time > 1.0" | bc -l) )); then
        echo "   • Enable fast mode: export DOTFILES_FAST_MODE=1"
        echo "   • Compile completions: compile_all_completions"
        echo "   • Check for slow plugins with: profile_startup_detailed"
    fi
}

# Real-time performance monitoring
monitor_performance() {
    echo "📊 Performance Monitor (Press Ctrl+C to exit)"
    echo "============================================="
    
    while true; do
        local memory_mb=$(ps -o rss= -p $$ | awk '{print int($1/1024)}')
        local cpu_time=$(ps -o cputime= -p $$)
        local load_avg=$(uptime | awk -F'load averages?: ' '{print $2}' | awk '{print $1}' | tr -d ',')
        
        printf "\r🔄 Memory: %dMB | CPU Time: %s | Load: %s" "$memory_mb" "$cpu_time" "$load_avg"
        sleep 2
    done
}

# ============================================================================
# Performance Tuning Commands
# ============================================================================

# Quick performance optimization
quick_optimize() {
    echo "🚀 Quick Performance Optimization"
    echo "================================="
    
    # Compile completions
    compile_all_completions
    
    # Clean old cache files
    find "$HOME/.cache/dotfiles" -type f -mtime +30 -delete 2>/dev/null
    
    # Optimize history
    fc -W  # Write history
    fc -R  # Read history
    
    # Set optimal performance mode
    auto_optimize_for_system
    
    echo "✅ Quick optimization complete!"
    echo "💡 Restart your shell to see improvements"
}

# Performance status dashboard
performance_status() {
    echo "📊 Performance Status Dashboard"
    echo "==============================="
    echo ""
    
    # System info
    echo "🖥️  System:"
    echo "   OS: $OSTYPE"
    echo "   Shell: ZSH $ZSH_VERSION"
    echo "   Performance Mode: $DOTFILES_PERFORMANCE_MODE"
    echo "   Fast Mode: ${DOTFILES_FAST_MODE:-Off}"
    echo ""
    
    # Cache status
    echo "💾 Cache Status:"
    local cache_dir="$HOME/.cache/dotfiles"
    if [[ -d "$cache_dir" ]]; then
        local cache_size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1)
        local cache_files=$(find "$cache_dir" -type f | wc -l)
        echo "   Cache Size: $cache_size"
        echo "   Cache Files: $cache_files"
    else
        echo "   Cache: Not initialized"
    fi
    echo ""
    
    # Completion status
    echo "⚡ Completion Status:"
    local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -f "${zcompdump}.zwc" ]]; then
        echo "   Compiled: ✅ Yes"
        local comp_age=$(( ($(date +%s) - $(stat -f %m "${zcompdump}.zwc" 2>/dev/null || stat -c %Y "${zcompdump}.zwc" 2>/dev/null || echo 0)) / 86400 ))
        echo "   Age: $comp_age days"
    else
        echo "   Compiled: ❌ No (run 'compile_all_completions')"
    fi
    echo ""
    
    # Tool status
    echo "🔧 Tool Status:"
    local tools=("starship" "zoxide" "mise" "atuin" "fzf" "eza" "bat" "rg" "fd")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "   $tool: ✅ Available"
        else
            echo "   $tool: ❌ Not found"
        fi
    done
}

# ============================================================================
# Initialization
# ============================================================================

# Initialize performance optimizations
init_performance_system() {
    perf_time "Starting performance system init"
    
    # Set up memory optimizations
    optimize_shell_memory_advanced
    
    # Set up intelligent caching
    setup_intelligent_caching
    
    # Initialize based on performance mode
    case "$DOTFILES_PERFORMANCE_MODE" in
        "fast")
            # Minimal initialization for fast startup
            ;;
        "balanced"|"full")
            # Full initialization with optimizations
            init_performance_optimizations_advanced 2>/dev/null &
            ;;
    esac
    
    perf_time "Performance system init complete"
}

# ============================================================================
# Export Commands
# ============================================================================

# Performance command aliases
alias perf-bench='benchmark_startup_advanced'
alias perf-monitor='monitor_performance'
alias perf-quick='quick_optimize'
alias perf-status='performance_status'

# Initialize the performance system (if timing helper is available)
type perf_time >/dev/null 2>&1 || perf_time() { :; }
init_performance_system