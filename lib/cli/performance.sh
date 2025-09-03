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

# System performance profiling
perf_profile_system() {
    local duration="${1:-30}"
    local output_format="${2:-summary}"
    
    print_info "${GEAR} Profiling system performance for ${duration}s..."
    
    # Create temporary files for data collection
    local temp_dir=$(mktemp -d)
    local cpu_log="$temp_dir/cpu.log"
    local memory_log="$temp_dir/memory.log"
    local disk_log="$temp_dir/disk.log"
    
    # Start background monitoring
    {
        for ((i=0; i<duration; i++)); do
            # CPU usage
            if command -v top >/dev/null 2>&1; then
                top -l 1 -n 0 | grep "CPU usage" >> "$cpu_log" 2>/dev/null || true
            fi
            
            # Memory usage
            if command -v vm_stat >/dev/null 2>&1; then
                vm_stat | head -4 >> "$memory_log" 2>/dev/null || true
            fi
            
            # Disk I/O (macOS)
            if command -v iostat >/dev/null 2>&1; then
                iostat -d 1 1 | tail -1 >> "$disk_log" 2>/dev/null || true
            fi
            
            sleep 1
        done
    } &
    
    local monitor_pid=$!
    
    # Profile shell startup during monitoring
    print_info "Benchmarking shell startup..."
    local startup_times=()
    for i in {1..5}; do
        local start_time=$(date +%s.%3N)
        zsh -i -c exit 2>/dev/null
        local end_time=$(date +%s.%3N)
        local elapsed=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        startup_times+=("$elapsed")
        echo "  Startup test $i: ${elapsed}s"
    done
    
    # Wait for monitoring to complete
    wait $monitor_pid
    
    # Analyze results
    case "$output_format" in
        "summary")
            perf_show_summary "$cpu_log" "$memory_log" "$disk_log" "${startup_times[@]}"
            ;;
        "detailed")
            perf_show_detailed "$cpu_log" "$memory_log" "$disk_log" "${startup_times[@]}"
            ;;
        "json")
            perf_show_json "$cpu_log" "$memory_log" "$disk_log" "${startup_times[@]}"
            ;;
    esac
    
    # Cleanup
    rm -rf "$temp_dir"
}

# System optimization
perf_optimize_system() {
    local auto_apply=false
    local backup=true
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                auto_apply=true
                shift
                ;;
            --no-backup)
                backup=false
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    print_info "${GEAR} Analyzing system for optimization opportunities..."
    
    local optimizations=()
    
    # Check shell startup performance
    local avg_startup=$(perf_get_average_startup_time)
    if (( $(echo "$avg_startup > 0.5" | bc -l 2>/dev/null || echo 0) )); then
        optimizations+=("shell-startup:Optimize shell startup time (${avg_startup}s)")
    fi
    
    # Check for large completion cache
    if [[ -f ~/.zcompdump ]] && [[ $(stat -f%z ~/.zcompdump 2>/dev/null || echo 0) -gt 100000 ]]; then
        optimizations+=("zsh-completion:Rebuild ZSH completion cache")
    fi
    
    # Check for old npm cache
    if command -v npm >/dev/null 2>&1; then
        local npm_cache_size=$(du -sk ~/.npm 2>/dev/null | cut -f1)
        if [[ ${npm_cache_size:-0} -gt 1000000 ]]; then  # > 1GB
            optimizations+=("npm-cache:Clean npm cache (${npm_cache_size}KB)")
        fi
    fi
    
    # Check for old Python cache
    if [[ -d ~/.cache/pip ]]; then
        local pip_cache_size=$(du -sk ~/.cache/pip 2>/dev/null | cut -f1)
        if [[ ${pip_cache_size:-0} -gt 500000 ]]; then  # > 500MB
            optimizations+=("pip-cache:Clean pip cache (${pip_cache_size}KB)")
        fi
    fi
    
    # Check Docker cleanup
    if command -v docker >/dev/null 2>&1; then
        local docker_images=$(docker images -q 2>/dev/null | wc -l | tr -d ' ')
        if [[ ${docker_images:-0} -gt 20 ]]; then
            optimizations+=("docker-cleanup:Clean Docker images (${docker_images} images)")
        fi
    fi
    
    # Check for large log files
    local large_logs=$(find /var/log ~/.local/share -name "*.log" -size +100M 2>/dev/null | head -5)
    if [[ -n "$large_logs" ]]; then
        optimizations+=("log-cleanup:Clean large log files")
    fi
    
    # Display optimization opportunities
    if [[ ${#optimizations[@]} -eq 0 ]]; then
        print_success "System is already optimized! 🚀"
        return 0
    fi
    
    echo ""
    echo "🔧 Optimization Opportunities:"
    local index=1
    for opt in "${optimizations[@]}"; do
        local key="${opt%%:*}"
        local desc="${opt#*:}"
        echo "  $index) $desc"
        ((index++))
    done
    echo ""
    
    if [[ "$auto_apply" == "true" ]]; then
        print_info "Auto-applying all optimizations..."
        for opt in "${optimizations[@]}"; do
            local key="${opt%%:*}"
            perf_apply_optimization "$key" "$backup"
        done
    else
        echo -n "Apply all optimizations? [y/N]: "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            for opt in "${optimizations[@]}"; do
                local key="${opt%%:*}"
                perf_apply_optimization "$key" "$backup"
            done
        else
            echo "Select optimizations to apply (comma-separated numbers, or 'all'):"
            echo -n "Choice: "
            read -r choice
            
            if [[ "$choice" == "all" ]]; then
                for opt in "${optimizations[@]}"; do
                    local key="${opt%%:*}"
                    perf_apply_optimization "$key" "$backup"
                done
            else
                IFS=',' read -ra CHOICES <<< "$choice"
                for num in "${CHOICES[@]}"; do
                    num=$(echo "$num" | tr -d ' ')
                    if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -le ${#optimizations[@]} ]]; then
                        local opt="${optimizations[$((num-1))]}"
                        local key="${opt%%:*}"
                        perf_apply_optimization "$key" "$backup"
                    fi
                done
            fi
        fi
    fi
    
    print_success "Optimization completed!"
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

# Performance monitoring
perf_monitor_resources() {
    local duration="${1:-60}"
    local interval="${2:-5}"
    
    print_info "${GEAR} Monitoring system resources for ${duration}s..."
    
    echo "Time,CPU%,Memory%,Disk%"
    
    for ((i=0; i<=duration; i+=interval)); do
        local timestamp=$(date +%H:%M:%S)
        
        # CPU usage (simplified)
        local cpu_usage="0"
        if command -v top >/dev/null 2>&1; then
            cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' 2>/dev/null || echo "0")
        fi
        
        # Memory usage
        local memory_usage="0"
        if command -v vm_stat >/dev/null 2>&1; then
            local pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
            local pages_total=$(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/4096}')
            if [[ -n "$pages_free" && -n "$pages_total" && "$pages_total" -gt 0 ]]; then
                memory_usage=$(echo "scale=1; (1 - $pages_free / $pages_total) * 100" | bc 2>/dev/null || echo "0")
            fi
        fi
        
        # Disk usage
        local disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
        
        echo "$timestamp,$cpu_usage,$memory_usage,$disk_usage"
        
        if [[ $i -lt $duration ]]; then
            sleep "$interval"
        fi
    done
}

# Cache management
perf_manage_cache() {
    local action="${1:-status}"
    
    case "$action" in
        "status")
            echo "📊 Cache Status:"
            
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
    print_info "${GEAR} Cleaning up system for optimal performance..."
    
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

# Utility functions
perf_get_average_startup_time() {
    local total=0
    local count=3
    
    for i in $(seq 1 $count); do
        local start_time=$(date +%s.%3N)
        zsh -i -c exit 2>/dev/null
        local end_time=$(date +%s.%3N)
        local elapsed=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        total=$(echo "$total + $elapsed" | bc 2>/dev/null || echo "0")
    done
    
    echo "scale=3; $total / $count" | bc 2>/dev/null || echo "0"
}

perf_show_summary() {
    local cpu_log="$1"
    local memory_log="$2" 
    local disk_log="$3"
    shift 3
    local startup_times=("$@")
    
    echo ""
    echo "📊 Performance Summary:"
    echo ""
    
    # Startup time analysis
    if [[ ${#startup_times[@]} -gt 0 ]]; then
        local total=0
        for time in "${startup_times[@]}"; do
            total=$(echo "$total + $time" | bc 2>/dev/null || echo "0")
        done
        local avg=$(echo "scale=3; $total / ${#startup_times[@]}" | bc 2>/dev/null || echo "0")
        
        echo "Shell Startup:"
        echo "  Average: ${avg}s"
        if (( $(echo "$avg > 1.0" | bc -l 2>/dev/null || echo 0) )); then
            echo "  Status: ⚠️  Slow (consider optimization)"
        elif (( $(echo "$avg > 0.5" | bc -l 2>/dev/null || echo 0) )); then
            echo "  Status: 🟡 Acceptable"
        else
            echo "  Status: ✅ Fast"
        fi
    fi
    
    echo ""
    echo "Recommendations:"
    
    if [[ -f ~/.zcompdump ]] && [[ $(stat -f%z ~/.zcompdump 2>/dev/null || echo 0) -gt 100000 ]]; then
        echo "  • Rebuild ZSH completion cache"
    fi
    
    if [[ -z "$DOTFILES_FAST_MODE" ]]; then
        echo "  • Enable fast mode: export DOTFILES_FAST_MODE=1"
    fi
    
    echo "  • Run 'dot perf optimize' for automated improvements"
}

# ============================================================================
# Epic 7.4: Performance Automation Features
# Automated performance optimization and regression detection
# ============================================================================

# Automated performance tuning
performance_auto_tuning() {
    local tuning_mode="${1:-balanced}"
    local apply_immediately="${2:-false}"
    local backup_config="${3:-true}"
    
    print_info "⚡ Starting automated performance tuning (mode: $tuning_mode)..."
    
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
            apply_conservative_tuning "$system_profile" "$optimization_log"
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
    
    # Measure improvement
    local post_tuning_metrics=$(capture_baseline_metrics)
    local improvement=$(calculate_performance_improvement "$baseline_metrics" "$post_tuning_metrics")
    
    echo "" >> "$optimization_log"
    echo "Post-Tuning Metrics: $post_tuning_metrics" >> "$optimization_log"
    echo "Improvement: $improvement" >> "$optimization_log"
    
    # Apply changes immediately if requested
    if [[ "$apply_immediately" == "true" ]]; then
        apply_tuning_changes_immediately "$optimization_log"
    fi
    
    print_success "Automated performance tuning completed!"
    print_info "Performance improvement: $improvement"
    print_info "Tuning log: $optimization_log"
    
    # Schedule follow-up optimization if significant improvement detected
    if (( $(echo "$improvement > 20" | bc -l 2>/dev/null || echo 0) )); then
        schedule_follow_up_optimization "$tuning_mode"
    fi
}

# Analyze system performance profile
analyze_system_performance_profile() {
    local cpu_cores=$(nproc 2>/dev/null || echo "4")
    local total_memory_gb=$(free -g 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "8")
    local disk_type="unknown"
    local power_profile="unknown"
    
    # Detect SSD vs HDD
    if [[ -f "/sys/block/sda/queue/rotational" ]]; then
        if [[ "$(cat /sys/block/sda/queue/rotational)" == "0" ]]; then
            disk_type="ssd"
        else
            disk_type="hdd"
        fi
    fi
    
    # Detect power profile (laptop vs desktop)
    if [[ -d "/sys/class/power_supply" ]]; then
        if find /sys/class/power_supply -name "BAT*" | grep -q .; then
            power_profile="laptop"
        else
            power_profile="desktop"
        fi
    fi
    
    # Classify system profile
    if [[ $cpu_cores -ge 8 ]] && [[ $total_memory_gb -ge 16 ]] && [[ "$disk_type" == "ssd" ]]; then
        echo "high-performance"
    elif [[ $cpu_cores -ge 4 ]] && [[ $total_memory_gb -ge 8 ]]; then
        echo "standard"
    elif [[ "$power_profile" == "laptop" ]]; then
        echo "mobile"
    else
        echo "resource-constrained"
    fi
}

# Apply aggressive tuning
apply_aggressive_tuning() {
    local system_profile="$1"
    local log_file="$2"
    
    print_info "🚀 Applying aggressive performance tuning..."
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
    
    # System-level optimizations
    case "$system_profile" in
        "high-performance")
            # Enable performance governor if available
            if [[ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]]; then
                echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
                echo "- Set CPU governor to performance" >> "$log_file"
            fi
            
            # Optimize I/O scheduler for SSDs
            for disk in /sys/block/sd*/queue/scheduler; do
                if [[ -f "$disk" ]]; then
                    echo "noop" | sudo tee "$disk" >/dev/null 2>&1 || true
                fi
            done
            echo "- Optimized I/O scheduler for SSDs" >> "$log_file"
            ;;
    esac
    
    # Development tool optimizations
    optimize_development_tools_aggressive "$log_file"
}

# Apply balanced tuning
apply_balanced_tuning() {
    local system_profile="$1"
    local log_file="$2"
    
    print_info "⚖️ Applying balanced performance tuning..."
    echo "Applying balanced tuning for $system_profile system" >> "$log_file"
    
    # Moderate shell optimizations
    export DOTFILES_BALANCED_MODE=1
    echo "- Enabled balanced mode" >> "$log_file"
    
    # Selective feature optimization
    optimize_completion_cache "$log_file"
    optimize_history_management "$log_file"
    optimize_plugin_loading "$log_file"
    
    # System optimizations based on profile
    case "$system_profile" in
        "high-performance"|"standard")
            # Moderate performance optimizations
            optimize_file_system_cache "$log_file"
            optimize_network_stack "$log_file"
            ;;
        "mobile")
            # Battery-aware optimizations
            apply_battery_conscious_tuning "$log_file"
            ;;
        "resource-constrained")
            # Memory and CPU conscious optimizations
            apply_resource_conscious_tuning "$log_file"
            ;;
    esac
    
    # Development tool moderate optimizations
    optimize_development_tools_balanced "$log_file"
}

# Apply development-specific tuning
apply_development_tuning() {
    local system_profile="$1"
    local log_file="$2"
    
    print_info "💻 Applying development-optimized tuning..."
    echo "Applying development tuning for $system_profile system" >> "$log_file"
    
    # Development-focused optimizations
    export DOTFILES_DEV_MODE=1
    export DOTFILES_ENHANCED_GIT=1
    export DOTFILES_SMART_COMPLETION=1
    echo "- Enabled development mode with enhanced features" >> "$log_file"
    
    # Tool-specific optimizations
    optimize_git_performance "$log_file"
    optimize_editor_performance "$log_file"
    optimize_build_tools "$log_file"
    
    # Development environment optimizations
    optimize_development_workflow "$log_file"
    setup_development_monitoring "$log_file"
}

# Performance regression detection
performance_regression_detection() {
    local monitoring_duration="${1:-continuous}"
    local threshold_percent="${2:-10}"
    local alert_method="${3:-log}"
    
    print_info "📊 Starting performance regression detection..."
    
    local baseline_file="${DOTFILES_DATA_DIR:-$HOME/.local/share}/dotfiles/performance-baseline.json"
    local current_metrics_file="${DOTFILES_CACHE_DIR:-$HOME/.cache}/dotfiles/current-metrics.json"
    
    # Ensure directories exist
    mkdir -p "$(dirname "$baseline_file")"
    mkdir -p "$(dirname "$current_metrics_file")"
    
    case "$monitoring_duration" in
        "once")
            run_single_regression_check "$baseline_file" "$current_metrics_file" "$threshold_percent" "$alert_method"
            ;;
        "continuous")
            start_continuous_regression_monitoring "$baseline_file" "$current_metrics_file" "$threshold_percent" "$alert_method"
            ;;
        "schedule")
            setup_scheduled_regression_checks "$baseline_file" "$current_metrics_file" "$threshold_percent" "$alert_method"
            ;;
        "report")
            generate_regression_report "$baseline_file" "$current_metrics_file"
            ;;
        *)
            print_error "Unknown monitoring duration: $monitoring_duration"
            echo "Available options: once, continuous, schedule, report"
            return 1
            ;;
    esac
}

# Run single regression check
run_single_regression_check() {
    local baseline_file="$1"
    local current_metrics_file="$2"
    local threshold_percent="$3"
    local alert_method="$4"
    
    print_info "🔍 Running performance regression check..."
    
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
        print_warning "⚠️ Performance regression detected!"
        
        echo "Regressions found:"
        for regression in "${regressions[@]}"; do
            echo "  - $regression"
        done
        
        # Alert based on method
        case "$alert_method" in
            "log")
                log_regression_alert "${regressions[@]}"
                ;;
            "notification")
                send_regression_notification "${regressions[@]}"
                ;;
            "email")
                send_regression_email "${regressions[@]}"
                ;;
        esac
        
        # Suggest automatic fixes
        suggest_regression_fixes "${regressions[@]}"
        
        return 1
    else
        print_success "✅ No performance regression detected"
        return 0
    fi
}

# Resource optimization
resource_optimization() {
    local optimization_target="${1:-auto}"
    local optimization_level="${2:-moderate}"
    
    print_info "🎯 Starting resource optimization (target: $optimization_target, level: $optimization_level)..."
    
    case "$optimization_target" in
        "memory")
            optimize_memory_usage "$optimization_level"
            ;;
        "cpu")
            optimize_cpu_usage "$optimization_level"
            ;;
        "disk")
            optimize_disk_usage "$optimization_level"
            ;;
        "network")
            optimize_network_usage "$optimization_level"
            ;;
        "battery")
            optimize_battery_usage "$optimization_level"
            ;;
        "auto")
            auto_detect_and_optimize_resources "$optimization_level"
            ;;
        *)
            print_error "Unknown optimization target: $optimization_target"
            echo "Available targets: memory, cpu, disk, network, battery, auto"
            return 1
            ;;
    esac
}

# Auto-detect and optimize resources
auto_detect_and_optimize_resources() {
    local optimization_level="$1"
    
    print_info "🔍 Auto-detecting resource optimization opportunities..."
    
    # Analyze current resource usage
    local memory_usage_percent=$(free | awk 'FNR==2{printf "%.0f", $3/$2*100}')
    local cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local disk_usage_percent=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')
    
    print_info "Current usage - Memory: ${memory_usage_percent}%, Disk: ${disk_usage_percent}%"
    
    local optimizations_applied=()
    
    # Memory optimization if high usage
    if [[ $memory_usage_percent -gt 80 ]]; then
        print_info "High memory usage detected (${memory_usage_percent}%). Optimizing..."
        optimize_memory_usage "$optimization_level"
        optimizations_applied+=("memory")
    fi
    
    # Disk optimization if high usage or low performance
    if [[ $disk_usage_percent -gt 85 ]]; then
        print_info "High disk usage detected (${disk_usage_percent}%). Optimizing..."
        optimize_disk_usage "$optimization_level"
        optimizations_applied+=("disk")
    fi
    
    # CPU optimization based on load
    if (( $(echo "$cpu_load > $(nproc)" | bc -l 2>/dev/null || echo 0) )); then
        print_info "High CPU load detected ($cpu_load). Optimizing..."
        optimize_cpu_usage "$optimization_level"
        optimizations_applied+=("cpu")
    fi
    
    # Battery optimization for laptops
    if [[ -d "/sys/class/power_supply" ]] && find /sys/class/power_supply -name "BAT*" | grep -q .; then
        local battery_level=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 || echo "100")
        if [[ $battery_level -lt 30 ]]; then
            print_info "Low battery detected (${battery_level}%). Applying power optimizations..."
            optimize_battery_usage "$optimization_level"
            optimizations_applied+=("battery")
        fi
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
    
    print_info "⚡ Optimizing shell startup time (target: ${target_time}s)..."
    
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
        "aggressive")
            aggressive_startup_optimization "$current_startup_time" "$target_time"
            ;;
        "safe")
            safe_startup_optimization "$current_startup_time" "$target_time"
            ;;
        "analyze")
            analyze_startup_bottlenecks "$current_startup_time"
            ;;
        *)
            print_error "Unknown optimization mode: $optimization_mode"
            echo "Available modes: auto, aggressive, safe, analyze"
            return 1
            ;;
    esac
    
    # Measure improvement
    local optimized_startup_time=$(measure_shell_startup_time)
    local improvement=$(echo "scale=3; ($current_startup_time - $optimized_startup_time) / $current_startup_time * 100" | bc 2>/dev/null || echo "0")
    
    print_success "Startup time optimized: ${optimized_startup_time}s (${improvement}% improvement)"
    
    if (( $(echo "$optimized_startup_time <= $target_time" | bc -l 2>/dev/null || echo 0) )); then
        print_success "🎯 Target startup time achieved!"
    else
        print_info "Further optimization may be needed to reach target time"
    fi
}

# Auto-optimize startup time
auto_optimize_startup_time() {
    local current_time="$1"
    local target_time="$2"
    
    print_info "🔧 Auto-optimizing startup time..."
    
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

# Utility functions
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
    local completion_time=$(measure_completion_time)
    
    cat << EOF
{
    "timestamp": "$(date -Iseconds)",
    "shell_startup_time": "$startup_time",
    "git_status_time": "$git_time",
    "memory_usage_mb": "$memory_usage",
    "completion_time": "$completion_time",
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
    
    print_info "🧠 Optimizing memory usage (level: $level)..."
    
    case "$level" in
        "aggressive")
            # Clear all caches
            sudo sync && sudo sysctl -w vm.drop_caches=3 2>/dev/null || true
            
            # Optimize ZSH memory usage
            export HISTSIZE=1000  # Reduce history size
            export SAVEHIST=1000
            
            # Disable memory-intensive features
            export DOTFILES_MINIMAL_MODE=1
            ;;
        "moderate")
            # Clear page cache
            sudo sync && sudo sysctl -w vm.drop_caches=1 2>/dev/null || true
            
            # Optimize completion cache
            if [[ -f ~/.zcompdump ]]; then
                rm -f ~/.zcompdump*
                autoload -U compinit && compinit -C
            fi
            ;;
        "conservative")
            # Only clear user-space caches
            rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
            rm -rf ~/.cache/mesa_shader_cache/* 2>/dev/null || true
            ;;
    esac
}

optimize_disk_usage() {
    local level="$1"
    
    print_info "💾 Optimizing disk usage (level: $level)..."
    
    case "$level" in
        "aggressive")
            # Clean all caches and logs
            find ~/.cache -type f -atime +1 -delete 2>/dev/null || true
            find ~/.local/share/Trash -type f -delete 2>/dev/null || true
            
            # Clean development caches
            [[ -d ~/.npm ]] && npm cache clean --force 2>/dev/null || true
            [[ -d ~/.cache/pip ]] && pip cache purge 2>/dev/null || true
            [[ -d ~/.cargo ]] && cargo clean 2>/dev/null || true
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
    profile [duration]       Profile system performance (default: 30s)
    optimize [--auto]        Analyze and apply optimizations
    benchmark                Benchmark shell startup time
    status                   Show performance status
    monitor [duration]       Monitor system resources
    cache <status|clean|rebuild>  Manage performance caches
    cleanup                  Clean up system for optimal performance
    auto-tune [mode]         Automated performance tuning
    regression [duration]    Performance regression detection
    resource [target]        Resource optimization
    startup [mode]           Shell startup time optimization

OPTIONS:
    --auto                   Auto-apply optimizations without prompts
    --no-backup              Skip creating backups during optimization
    --format <type>          Output format (summary|detailed|json)
    -h, --help               Show this help message

PERFORMANCE AREAS:
    Shell Startup            ZSH initialization and plugin loading
    Completion Cache         Command completion performance
    Package Caches           npm, pip, cargo cache management
    System Cleanup           Temporary files and disk usage
    Resource Monitoring      CPU, memory, and disk usage

OPTIMIZATION TARGETS:
    < 100ms                  Excellent shell startup time
    < 500ms                  Good shell startup time  
    < 1000ms                 Acceptable shell startup time
    > 1000ms                 Needs optimization

EXAMPLES:
    dot perf profile 60             # 60-second system profile
    dot perf optimize --auto        # Auto-apply optimizations
    dot perf benchmark              # Test shell startup speed
    dot perf cache status           # Check cache sizes
    dot perf monitor 120            # Monitor for 2 minutes
EOF
}