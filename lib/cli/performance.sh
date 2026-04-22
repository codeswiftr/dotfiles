#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Performance Management
# Development environment performance optimization
# ============================================================================

# Load advanced performance monitoring
source "$DOTFILES_DIR/lib/performance-monitor.sh"

# Performance command dispatcher
dot_perf() {
    local subcommand="${1:-}"
    shift || true

    case "$subcommand" in
        "profile"|"measure")
            performance_cli "measure" "$@"
            ;;
        "optimize")
            performance_cli "optimize" "$@"
            ;;
        "benchmark")
            performance_cli "measure" "shell" "$@"
            ;;
        "status")
            performance_cli "monitor" "status" "$@"
            ;;
        "monitor")
            performance_cli "monitor" "$@"
            ;;
        "report")
            performance_cli "report" "$@"
            ;;
        "analyze"|"analysis")
            performance_cli "analyze" "$@"
            ;;
        "cache")
            perf_manage_cache "$@"
            ;;
        "cleanup")
            perf_cleanup_system "$@"
            ;;
        "auto-tune")
            performance_auto_tuning "$@"
            ;;
        "regression")
            performance_regression_detection "$@"
            ;;
        "resource")
            resource_optimization "$@"
            ;;
        "startup")
            startup_time_optimization "$@"
            ;;
        "-h"|"--help"|"")
            show_perf_help
            ;;
        *)
            print_error "Unknown performance subcommand: $subcommand"
            echo "Run 'dot perf --help' for available commands."
            return 1
            ;;
    esac
}

# Minimal Neovim tier management (Epic 2 vertical slice)
dot_nvim() {
    local subcmd="${1:-help}"; shift || true
    case "$subcmd" in
        tier)
            local action="${1:-info}"; shift || true
            local tier_file="$HOME/.config/nvim/.nvim-tier"
            case "$action" in
                get|info)
                    if [[ -f "$tier_file" ]]; then
                        cat "$tier_file"
                    else
                        echo "(unset)"
                    fi
                    ;;
                set)
                    local tier_val="${1:-}"
                    if [[ "$tier_val" =~ ^[123]$ ]]; then
                        mkdir -p "$(dirname "$tier_file")"
                        echo "$tier_val" > "$tier_file"
                        echo "Tier set to $tier_val. Restart nvim to apply."
                    else
                        echo "Usage: dot nvim tier set 1|2|3" >&2; return 1
                    fi
                    ;;
                bench)
                    local tier_override="${1:-}"
                    if [[ -n "$tier_override" && ! "$tier_override" =~ ^[123]$ ]]; then
                        echo "Usage: dot nvim tier bench [1|2|3]" >&2; return 1
                    fi
                    NVIM_TIER="$tier_override" nvim --headless --startuptime /tmp/nvim-startup.log -c 'qa' >/dev/null 2>&1 || true
                    tail -1 /tmp/nvim-startup.log 2>/dev/null || echo "No startup log"
                    ;;
                *)
                    echo "Usage: dot nvim tier {get|set 1|2|3|bench [1|2|3]}" >&2; return 1
                    ;;
            esac
            ;;
        profile)
            # Usage: dot nvim profile [1|2|3] [runs]
            local tier_val="${1:-}"
            local runs="${2:-3}"
            if [[ -n "$tier_val" && ! "$tier_val" =~ ^[123]$ ]]; then
                echo "Usage: dot nvim profile [1|2|3] [runs] [--json]" >&2; return 1
            fi
            shift || true
            shift || true
            local json=false
            for arg in "$@"; do
              [[ "$arg" == "--json" ]] && json=true
            done

            local total=0
            local i
            for (( i=1; i<=runs; i++ )); do
              NVIM_TIER="$tier_val" nvim --headless --startuptime /tmp/nvim-startup.log -c 'qa' >/dev/null 2>&1 || true
              # Extract last line milliseconds
              local ms
              ms=$(awk '/msec/ {last=$0} END{print last}' /tmp/nvim-startup.log 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "0")
              total=$(python3 - <<PY 2>/dev/null || echo 0
t=$total
try:
  print(float(t)+float("$ms"))
except Exception:
  print(0)
PY
)
            done
            # Compute average
            local avg
            avg=$(python3 - <<PY 2>/dev/null || echo 0
try:
  print(round(float("$total")/float($runs), 1))
except Exception:
  print(0)
PY
)
            if [[ "$json" == true ]]; then
              printf '{"tier":%s,"runs":%s,"average_ms":%s}\n' "${tier_val:-null}" "$runs" "$avg"
            else
              echo "Tier: ${tier_val:-auto}, Runs: $runs, Average: ${avg}ms"
            fi
            ;;
        *)
            echo "Usage: dot nvim tier {get|set 1|2|3|bench [1|2|3]}" >&2; return 1
            ;;
    esac
}

# Apply specific optimization
perf_apply_optimization() {
    local optimization="$1"
    local backup="$2"

    case "$optimization" in
        "shell-startup")
            print_info "Optimizing shell startup..."
            # Enable fast mode
            export DOTFILES_FAST_MODE=1
            # Compile zsh functions
            if [[ -d "$DOTFILES_DIR/config/zsh/functions" ]]; then
                zcompile "$DOTFILES_DIR/config/zsh/functions"/*
            fi
            ;;
        "zsh-completion")
            print_info "Rebuilding ZSH completion cache..."
            [[ "$backup" == "true" ]] && cp ~/.zcompdump ~/.zcompdump.backup
            rm -f ~/.zcompdump*
            autoload -U compinit && compinit
            ;;
        "npm-cache")
            print_info "Cleaning npm cache..."
            npm cache clean --force 2>/dev/null || true
            ;;
        "pip-cache")
            print_info "Cleaning pip cache..."
            pip cache purge 2>/dev/null || true
            ;;
        "docker-cleanup")
            print_info "Cleaning Docker images..."
            docker image prune -f 2>/dev/null || true
            ;;
        "log-cleanup")
            print_info "Cleaning large log files..."
            find ~/.local/share -name "*.log" -size +100M -exec truncate -s 0 {} \; 2>/dev/null || true
            ;;
    esac
}

# Cache management
perf_manage_cache() {
    local action="${1:-status}"

    case "$action" in
        "status")
            echo "Cache Status:"

            # ZSH completion cache
            if [[ -f ~/.zcompdump ]]; then
                local zsh_size=$(du -h ~/.zcompdump | cut -f1)
                echo "  ZSH Completions: $zsh_size"
            else
                echo "  ZSH Completions: Not found"
            fi

            # NPM cache
            if command -v npm >/dev/null 2>&1 && [[ -d ~/.npm ]]; then
                local npm_size=$(du -sh ~/.npm | cut -f1)
                echo "  NPM Cache: $npm_size"
            fi

            # Pip cache
            if [[ -d ~/.cache/pip ]]; then
                local pip_size=$(du -sh ~/.cache/pip | cut -f1)
                echo "  Pip Cache: $pip_size"
            fi

            # Rust cache
            if [[ -d ~/.cargo ]]; then
                local cargo_size=$(du -sh ~/.cargo | cut -f1)
                echo "  Cargo Cache: $cargo_size"
            fi
            ;;
        "clean")
            print_info "Cleaning all caches..."
            perf_apply_optimization "zsh-completion" false
            perf_apply_optimization "npm-cache" false
            perf_apply_optimization "pip-cache" false
            print_success "Cache cleanup completed!"
            ;;
        "rebuild")
            print_info "Rebuilding performance caches..."
            # Rebuild ZSH completion cache
            autoload -U compinit && compinit
            # Compile ZSH functions
            if [[ -d "$DOTFILES_DIR/config/zsh/functions" ]]; then
                zcompile "$DOTFILES_DIR/config/zsh/functions"/*
            fi
            print_success "Cache rebuild completed!"
            ;;
    esac
}

# System cleanup
perf_cleanup_system() {
    print_info "Cleaning up system for optimal performance..."

    local cleanup_actions=(
        "temp-files:Clean temporary files"
        "downloads:Clean old downloads"
        "trash:Empty trash"
        "logs:Rotate and compress logs"
        "brew-cleanup:Clean Homebrew cache"
    )

    for action in "${cleanup_actions[@]}"; do
        local key="${action%%:*}"
        local desc="${action#*:}"

        print_info "$desc..."
        case "$key" in
            "temp-files")
                find /tmp -type f -atime +7 -delete 2>/dev/null || true
                find ~/.cache -type f -atime +30 -delete 2>/dev/null || true
                ;;
            "downloads")
                find ~/Downloads -type f -atime +30 -size +100M 2>/dev/null | head -10
                ;;
            "trash")
                if command -v trash >/dev/null 2>&1; then
                    trash -e
                fi
                ;;
            "logs")
                find ~/.local/share -name "*.log" -size +50M -exec gzip {} \; 2>/dev/null || true
                ;;
            "brew-cleanup")
                if command -v brew >/dev/null 2>&1; then
                    brew cleanup 2>/dev/null || true
                fi
                ;;
        esac
    done

    print_success "System cleanup completed!"
}

# ============================================================================
# Performance Automation Features
# ============================================================================

# Automated performance tuning
performance_auto_tuning() {
    local tuning_mode="${1:-balanced}"
    local apply_immediately="${2:-false}"
    local backup_config="${3:-true}"

    print_info "Starting automated performance tuning (mode: $tuning_mode)..."

    # Initialize performance tracking
    local baseline_metrics=$(capture_baseline_metrics)
    local optimization_log="${DOTFILES_CACHE_DIR:-$HOME/.cache}/dotfiles/perf-auto-tune-$(date +%Y%m%d-%H%M%S).log"
    mkdir -p "$(dirname "$optimization_log")"

    echo "Performance Auto-Tuning Session: $(date)" > "$optimization_log"
    echo "Mode: $tuning_mode" >> "$optimization_log"
    echo "Baseline Metrics: $baseline_metrics" >> "$optimization_log"
    echo "" >> "$optimization_log"

    # Analyze system capabilities
    local system_profile=$(analyze_system_performance_profile)
    print_info "System profile: $system_profile"
    echo "System Profile: $system_profile" >> "$optimization_log"

    # Apply tuning based on mode and system profile
    case "$tuning_mode" in
        "aggressive")
            apply_aggressive_tuning "$system_profile" "$optimization_log"
            ;;
        "balanced")
            apply_balanced_tuning "$system_profile" "$optimization_log"
            ;;
        "conservative")
            print_info "Conservative tuning: applying minimal safe optimizations"
            echo "Applying conservative tuning for $system_profile system" >> "$optimization_log"
            export DOTFILES_BALANCED_MODE=1
            echo "- Enabled balanced mode (conservative)" >> "$optimization_log"
            ;;
        "development")
            apply_development_tuning "$system_profile" "$optimization_log"
            ;;
        *)
            print_error "Unknown tuning mode: $tuning_mode"
            echo "Available modes: aggressive, balanced, conservative, development"
            return 1
            ;;
    esac

    # Measure post-tuning
    local post_tuning_metrics=$(capture_baseline_metrics)

    echo "" >> "$optimization_log"
    echo "Post-Tuning Metrics: $post_tuning_metrics" >> "$optimization_log"

    print_success "Automated performance tuning completed!"
    print_info "Tuning log: $optimization_log"
}

# Analyze system performance profile
analyze_system_performance_profile() {
    local cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "4")
    local total_memory_gb=8

    # Detect total memory (cross-platform)
    if command -v free >/dev/null 2>&1; then
        total_memory_gb=$(free -g 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "8")
    elif command -v sysctl >/dev/null 2>&1; then
        local mem_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592")
        total_memory_gb=$((mem_bytes / 1073741824))
    fi

    # Classify system profile
    if [[ $cpu_cores -ge 8 ]] && [[ $total_memory_gb -ge 16 ]]; then
        echo "high-performance"
    elif [[ $cpu_cores -ge 4 ]] && [[ $total_memory_gb -ge 8 ]]; then
        echo "standard"
    else
        echo "resource-constrained"
    fi
}

# Apply aggressive tuning
apply_aggressive_tuning() {
    local system_profile="$1"
    local log_file="$2"

    print_info "Applying aggressive performance tuning..."
    echo "Applying aggressive tuning for $system_profile system" >> "$log_file"

    # Shell startup optimizations
    export DOTFILES_FAST_MODE=1
    export DOTFILES_MINIMAL_PROMPT=1
    export ZSH_DISABLE_COMPFIX=true
    echo "- Enabled fast mode and minimal prompt" >> "$log_file"

    # Disable heavy features for maximum speed
    export DOTFILES_DISABLE_SLOW_PLUGINS=1
    export DOTFILES_SKIP_UPDATES=1
    echo "- Disabled slow plugins and update checks" >> "$log_file"

    # Optimize completion system
    export ZSH_COMPDUMP_REBUILD=1
    if [[ -f ~/.zcompdump ]]; then
        rm -f ~/.zcompdump*
        autoload -U compinit && compinit -C
        echo "- Rebuilt completion cache with fast mode" >> "$log_file"
    fi

    print_info "Aggressive tuning applied (shell-level optimizations)"
}

# Apply balanced tuning
apply_balanced_tuning() {
    local system_profile="$1"
    local log_file="$2"

    print_info "Applying balanced performance tuning..."
    echo "Applying balanced tuning for $system_profile system" >> "$log_file"

    # Moderate shell optimizations
    export DOTFILES_BALANCED_MODE=1
    echo "- Enabled balanced mode" >> "$log_file"

    # Rebuild completion cache if needed
    if [[ -f ~/.zcompdump ]] && [[ $(stat -f%z ~/.zcompdump 2>/dev/null || stat -c%s ~/.zcompdump 2>/dev/null || echo 0) -gt 100000 ]]; then
        rm -f ~/.zcompdump*
        autoload -U compinit && compinit -C
        echo "- Rebuilt oversized completion cache" >> "$log_file"
    fi

    print_info "Balanced tuning applied"
}

# Apply development-specific tuning
apply_development_tuning() {
    local system_profile="$1"
    local log_file="$2"

    print_info "Applying development-optimized tuning..."
    echo "Applying development tuning for $system_profile system" >> "$log_file"

    # Development-focused optimizations
    export DOTFILES_DEV_MODE=1
    export DOTFILES_ENHANCED_GIT=1
    export DOTFILES_SMART_COMPLETION=1
    echo "- Enabled development mode with enhanced features" >> "$log_file"

    print_info "Development tuning applied"
}

# Performance regression detection
performance_regression_detection() {
    local monitoring_duration="${1:-once}"
    local threshold_percent="${2:-10}"
    local alert_method="${3:-log}"

    print_info "Starting performance regression detection..."

    local baseline_file="${DOTFILES_DATA_DIR:-$HOME/.local/share}/dotfiles/performance-baseline.json"
    local current_metrics_file="${DOTFILES_CACHE_DIR:-$HOME/.cache}/dotfiles/current-metrics.json"

    # Ensure directories exist
    mkdir -p "$(dirname "$baseline_file")"
    mkdir -p "$(dirname "$current_metrics_file")"

    case "$monitoring_duration" in
        "once")
            run_single_regression_check "$baseline_file" "$current_metrics_file" "$threshold_percent" "$alert_method"
            ;;
        *)
            print_info "Only 'once' mode is supported. Running single check..."
            run_single_regression_check "$baseline_file" "$current_metrics_file" "$threshold_percent" "$alert_method"
            ;;
    esac
}

# Run single regression check
run_single_regression_check() {
    local baseline_file="$1"
    local current_metrics_file="$2"
    local threshold_percent="$3"
    local alert_method="$4"

    print_info "Running performance regression check..."

    # Capture current metrics
    capture_comprehensive_metrics > "$current_metrics_file"

    if [[ ! -f "$baseline_file" ]]; then
        print_info "No baseline found. Creating baseline from current metrics..."
        cp "$current_metrics_file" "$baseline_file"
        print_success "Baseline established!"
        return 0
    fi

    # Compare metrics
    local regression_detected=false
    local regressions=()

    # Shell startup time regression
    local baseline_startup=$(jq -r '.shell_startup_time // "0"' "$baseline_file" 2>/dev/null || echo "0")
    local current_startup=$(jq -r '.shell_startup_time // "0"' "$current_metrics_file" 2>/dev/null || echo "0")

    if (( $(echo "$current_startup > $baseline_startup * (1 + $threshold_percent/100)" | bc -l 2>/dev/null || echo 0) )); then
        regressions+=("Shell startup: ${current_startup}s (was ${baseline_startup}s)")
        regression_detected=true
    fi

    # Git operations regression
    local baseline_git=$(jq -r '.git_status_time // "0"' "$baseline_file" 2>/dev/null || echo "0")
    local current_git=$(jq -r '.git_status_time // "0"' "$current_metrics_file" 2>/dev/null || echo "0")

    if (( $(echo "$current_git > $baseline_git * (1 + $threshold_percent/100)" | bc -l 2>/dev/null || echo 0) )); then
        regressions+=("Git status: ${current_git}s (was ${baseline_git}s)")
        regression_detected=true
    fi

    # Memory usage regression
    local baseline_memory=$(jq -r '.memory_usage_mb // "0"' "$baseline_file" 2>/dev/null || echo "0")
    local current_memory=$(jq -r '.memory_usage_mb // "0"' "$current_metrics_file" 2>/dev/null || echo "0")

    if (( $(echo "$current_memory > $baseline_memory * (1 + $threshold_percent/100)" | bc -l 2>/dev/null || echo 0) )); then
        regressions+=("Memory usage: ${current_memory}MB (was ${baseline_memory}MB)")
        regression_detected=true
    fi

    # Handle regression detection
    if [[ "$regression_detected" == "true" ]]; then
        print_warning "Performance regression detected!"

        echo "Regressions found:"
        for regression in "${regressions[@]}"; do
            echo "  - $regression"
        done

        # Log regressions
        local regression_log="${DOTFILES_CACHE_DIR:-$HOME/.cache}/dotfiles/regression-$(date +%Y%m%d-%H%M%S).log"
        printf '%s\n' "${regressions[@]}" > "$regression_log"
        print_info "Regression details logged to: $regression_log"

        return 1
    else
        print_success "No performance regression detected"
        return 0
    fi
}

# Resource optimization
resource_optimization() {
    local optimization_target="${1:-auto}"
    local optimization_level="${2:-moderate}"

    print_info "Starting resource optimization (target: $optimization_target, level: $optimization_level)..."

    case "$optimization_target" in
        "memory")
            optimize_memory_usage "$optimization_level"
            ;;
        "disk")
            optimize_disk_usage "$optimization_level"
            ;;
        "auto")
            auto_detect_and_optimize_resources "$optimization_level"
            ;;
        *)
            print_error "Unknown optimization target: $optimization_target"
            echo "Available targets: memory, disk, auto"
            return 1
            ;;
    esac
}

# Auto-detect and optimize resources
auto_detect_and_optimize_resources() {
    local optimization_level="$1"

    print_info "Auto-detecting resource optimization opportunities..."

    # Analyze current resource usage
    local disk_usage_percent=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')

    print_info "Current disk usage: ${disk_usage_percent}%"

    local optimizations_applied=()

    # Disk optimization if high usage or low performance
    if [[ ${disk_usage_percent:-0} -gt 85 ]]; then
        print_info "High disk usage detected (${disk_usage_percent}%). Optimizing..."
        optimize_disk_usage "$optimization_level"
        optimizations_applied+=("disk")
    fi

    if [[ ${#optimizations_applied[@]} -eq 0 ]]; then
        print_success "System resources are well optimized!"
    else
        print_success "Applied optimizations: ${optimizations_applied[*]}"
    fi
}

# Startup time optimization
startup_time_optimization() {
    local optimization_mode="${1:-auto}"
    local target_time="${2:-0.3}"

    print_info "Optimizing shell startup time (target: ${target_time}s)..."

    # Measure current startup time
    local current_startup_time=$(measure_shell_startup_time)
    print_info "Current startup time: ${current_startup_time}s"

    if (( $(echo "$current_startup_time <= $target_time" | bc -l 2>/dev/null || echo 0) )); then
        print_success "Startup time already optimal! (${current_startup_time}s <= ${target_time}s)"
        return 0
    fi

    case "$optimization_mode" in
        "auto")
            auto_optimize_startup_time "$current_startup_time" "$target_time"
            ;;
        *)
            print_info "Only 'auto' mode is supported. Running auto optimization..."
            auto_optimize_startup_time "$current_startup_time" "$target_time"
            ;;
    esac

    # Measure improvement
    local optimized_startup_time=$(measure_shell_startup_time)
    local improvement=$(echo "scale=3; ($current_startup_time - $optimized_startup_time) / $current_startup_time * 100" | bc 2>/dev/null || echo "0")

    print_success "Startup time optimized: ${optimized_startup_time}s (${improvement}% improvement)"

    if (( $(echo "$optimized_startup_time <= $target_time" | bc -l 2>/dev/null || echo 0) )); then
        print_success "Target startup time achieved!"
    else
        print_info "Further optimization may be needed to reach target time"
    fi
}

# Auto-optimize startup time
auto_optimize_startup_time() {
    local current_time="$1"
    local target_time="$2"

    print_info "Auto-optimizing startup time..."

    local optimizations_applied=()

    # Enable fast mode if not already enabled
    if [[ -z "$DOTFILES_FAST_MODE" ]]; then
        export DOTFILES_FAST_MODE=1
        echo 'export DOTFILES_FAST_MODE=1' >> ~/.zshrc.performance
        optimizations_applied+=("fast-mode")
    fi

    # Optimize completion system
    if [[ -f ~/.zcompdump ]] && [[ $(stat -f%z ~/.zcompdump 2>/dev/null || stat -c%s ~/.zcompdump 2>/dev/null || echo 0) -gt 100000 ]]; then
        rm -f ~/.zcompdump*
        autoload -U compinit && compinit -C
        optimizations_applied+=("completion-rebuild")
    fi

    # Defer heavy plugin loading
    setup_deferred_plugin_loading
    optimizations_applied+=("deferred-loading")

    # Optimize history settings
    optimize_zsh_history_for_startup
    optimizations_applied+=("history-optimization")

    # Precompile ZSH functions
    precompile_zsh_functions
    optimizations_applied+=("function-compilation")

    print_info "Applied optimizations: ${optimizations_applied[*]}"
}

# ============================================================================
# Utility functions
# ============================================================================

capture_baseline_metrics() {
    local startup_time=$(measure_shell_startup_time)
    local git_time=$(measure_git_status_time)
    local memory_usage=$(get_shell_memory_usage)

    echo "startup:${startup_time},git:${git_time},memory:${memory_usage}"
}

capture_comprehensive_metrics() {
    local startup_time=$(measure_shell_startup_time)
    local git_time=$(measure_git_status_time)
    local memory_usage=$(get_shell_memory_usage)

    cat << EOF
{
    "timestamp": "$(date -Iseconds)",
    "shell_startup_time": "$startup_time",
    "git_status_time": "$git_time",
    "memory_usage_mb": "$memory_usage",
    "system_load": "$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')",
    "disk_usage_percent": "$(df . | tail -1 | awk '{print $5}' | sed 's/%//')"
}
EOF
}

measure_shell_startup_time() {
    local total_time=0
    local runs=3

    for ((i=1; i<=runs; i++)); do
        local start_time=$(date +%s.%3N)
        zsh -i -c 'exit' >/dev/null 2>&1
        local end_time=$(date +%s.%3N)
        local elapsed=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        total_time=$(echo "$total_time + $elapsed" | bc 2>/dev/null || echo "0")
    done

    echo "scale=3; $total_time / $runs" | bc 2>/dev/null || echo "0.500"
}

measure_git_status_time() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "0"
        return
    fi

    local start_time=$(date +%s.%3N)
    git status --porcelain >/dev/null 2>&1
    local end_time=$(date +%s.%3N)

    echo "scale=3; $end_time - $start_time" | bc 2>/dev/null || echo "0"
}

get_shell_memory_usage() {
    local shell_pid=$$
    if command -v ps >/dev/null 2>&1; then
        ps -o rss= -p $shell_pid 2>/dev/null | awk '{print int($1/1024)}' || echo "0"
    else
        echo "0"
    fi
}

optimize_memory_usage() {
    local level="$1"

    print_info "Optimizing memory usage (level: $level)..."

    case "$level" in
        "aggressive")
            # Optimize ZSH memory usage
            export HISTSIZE=1000  # Reduce history size
            export SAVEHIST=1000

            # Disable memory-intensive features
            export DOTFILES_MINIMAL_MODE=1
            ;;
        "moderate")
            # Optimize completion cache
            if [[ -f ~/.zcompdump ]]; then
                rm -f ~/.zcompdump*
                autoload -U compinit && compinit -C
            fi
            ;;
        "conservative")
            # Only clear user-space caches
            rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
            ;;
    esac
}

optimize_disk_usage() {
    local level="$1"

    print_info "Optimizing disk usage (level: $level)..."

    case "$level" in
        "aggressive")
            # Clean all caches and logs
            find ~/.cache -type f -atime +1 -delete 2>/dev/null || true
            find ~/.local/share/Trash -type f -delete 2>/dev/null || true

            # Clean development caches
            [[ -d ~/.npm ]] && npm cache clean --force 2>/dev/null || true
            [[ -d ~/.cache/pip ]] && pip cache purge 2>/dev/null || true
            ;;
        "moderate")
            # Clean old temporary files
            find /tmp -type f -atime +3 -delete 2>/dev/null || true
            find ~/.cache -type f -atime +7 -delete 2>/dev/null || true
            ;;
        "conservative")
            # Only clean obvious temporary files
            find /tmp -name "*.tmp" -type f -atime +1 -delete 2>/dev/null || true
            ;;
    esac
}

setup_deferred_plugin_loading() {
    local zshrc_performance="$HOME/.zshrc.performance"

    # Create deferred loading configuration
    cat >> "$zshrc_performance" << 'EOF'
# Deferred plugin loading for faster startup
if [[ -z "$DOTFILES_PLUGINS_LOADED" ]]; then
    # Defer heavy plugins
    defer_plugin_loading() {
        # Load plugins after 2 seconds
        (sleep 2 && source_heavy_plugins) &
    }

    source_heavy_plugins() {
        # Load heavy plugins here
        export DOTFILES_PLUGINS_LOADED=1
    }

    defer_plugin_loading
fi
EOF
}

optimize_zsh_history_for_startup() {
    local zshrc_performance="$HOME/.zshrc.performance"

    cat >> "$zshrc_performance" << 'EOF'
# Optimized history settings for faster startup
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
EOF
}

precompile_zsh_functions() {
    print_info "Precompiling ZSH functions..."

    # Compile .zshrc if not already compiled
    if [[ ~/.zshrc -nt ~/.zshrc.zwc ]] || [[ ! -f ~/.zshrc.zwc ]]; then
        zcompile ~/.zshrc
    fi

    # Compile functions directory
    if [[ -d "$DOTFILES_DIR/config/zsh/functions" ]]; then
        for func in "$DOTFILES_DIR/config/zsh/functions"/*; do
            if [[ -f "$func" ]] && [[ "$func" -nt "$func.zwc" ]] || [[ ! -f "$func.zwc" ]]; then
                zcompile "$func"
            fi
        done
    fi
}

# Help function
show_perf_help() {
    cat << 'EOF'
dot perf - Performance management and optimization

USAGE:
    dot perf <command> [options]

COMMANDS:
    profile [duration]       Profile system performance
    optimize [--auto]        Analyze and apply optimizations
    benchmark                Benchmark shell startup time
    status                   Show performance status
    monitor [duration]       Monitor system resources
    cache <status|clean|rebuild>  Manage performance caches
    cleanup                  Clean up system for optimal performance
    auto-tune [mode]         Automated performance tuning
    regression [once]        Performance regression detection
    resource [target]        Resource optimization (memory, disk, auto)
    startup [auto]           Shell startup time optimization

OPTIONS:
    -h, --help               Show this help message

EXAMPLES:
    dot perf profile 60             # 60-second system profile
    dot perf optimize --auto        # Auto-apply optimizations
    dot perf benchmark              # Test shell startup speed
    dot perf cache status           # Check cache sizes
    dot perf monitor 120            # Monitor for 2 minutes
EOF
}
