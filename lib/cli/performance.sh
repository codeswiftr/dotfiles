#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Performance Management
# Development environment performance optimization
# ============================================================================

# Performance command dispatcher
dot_perf() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "profile")
            perf_profile_system "$@"
            ;;
        "optimize")
            perf_optimize_system "$@"
            ;;
        "benchmark")
            perf_benchmark_startup "$@"
            ;;
        "status")
            perf_status "$@"
            ;;
        "monitor")
            perf_monitor_resources "$@"
            ;;
        "cache")
            perf_manage_cache "$@"
            ;;
        "cleanup")
            perf_cleanup_system "$@"
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