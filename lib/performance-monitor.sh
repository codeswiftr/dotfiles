#!/usr/bin/env bash
# =============================================================================
# Performance Monitoring and Optimization System
# Advanced performance tracking, analysis, and optimization for dotfiles
# =============================================================================

# Performance monitoring configuration
PERF_CONFIG_DIR="$HOME/.config/dotfiles/performance"
PERF_DATA_DIR="$HOME/.local/share/dotfiles/performance"
PERF_CACHE_DIR="$HOME/.cache/dotfiles/performance"
PERF_LOG_FILE="$PERF_DATA_DIR/performance.log"
PERF_METRICS_FILE="$PERF_DATA_DIR/metrics.json"

# Performance thresholds (milliseconds)
SHELL_STARTUP_THRESHOLD=2000
COMMAND_RESPONSE_THRESHOLD=1000
GIT_OPERATION_THRESHOLD=5000
FILE_OPERATION_THRESHOLD=500

# Initialize performance monitoring
init_performance_monitoring() {
    mkdir -p "$PERF_CONFIG_DIR" "$PERF_DATA_DIR" "$PERF_CACHE_DIR"
    
    # Create default config if it doesn't exist
    if [[ ! -f "$PERF_CONFIG_DIR/config.yaml" ]]; then
        create_performance_config
    fi
    
    # Initialize metrics file
    if [[ ! -f "$PERF_METRICS_FILE" ]]; then
        echo '{"startup_times":[],"command_times":{},"optimization_history":[]}' > "$PERF_METRICS_FILE"
    fi
}

# Create performance configuration
create_performance_config() {
    cat > "$PERF_CONFIG_DIR/config.yaml" << EOF
# Performance Monitoring Configuration
monitoring:
  enabled: true
  log_level: "info"
  collect_metrics: true
  
thresholds:
  shell_startup: 2000  # ms
  command_response: 1000  # ms
  git_operations: 5000  # ms
  file_operations: 500  # ms
  
optimization:
  auto_optimize: false
  backup_before_optimize: true
  optimization_interval: 7  # days
  
alerts:
  enabled: true
  threshold_exceeded_count: 3
  email_notifications: false
  
collection:
  history_retention: 30  # days
  metrics_interval: 60  # seconds
  detailed_profiling: false
EOF
}

# Performance logging
perf_log() {
    local level="$1"
    local operation="$2"
    local duration="$3"
    local details="$4"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $operation: ${duration}ms ${details:-}" >> "$PERF_LOG_FILE"
}

# Measure command execution time
measure_command() {
    local command="$1"
    shift
    local args=("$@")
    
    local start_time=$(date +%s%N)
    "$command" "${args[@]}"
    local exit_code=$?
    local end_time=$(date +%s%N)
    
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    perf_log "INFO" "command:$command" "$duration" "exit_code:$exit_code"
    
    # Check against threshold
    if [[ $duration -gt $COMMAND_RESPONSE_THRESHOLD ]]; then
        perf_log "WARN" "slow_command:$command" "$duration" "threshold_exceeded"
    fi
    
    return $exit_code
}

# Shell startup time measurement
measure_shell_startup() {
    local shell="${1:-zsh}"
    local iterations="${2:-5}"
    local total_time=0
    
    echo "🔍 Measuring $shell startup time ($iterations iterations)..."
    
    for i in $(seq 1 "$iterations"); do
        local start_time=$(date +%s%N)
        $shell -i -c exit 2>/dev/null
        local end_time=$(date +%s%N)
        
        local iteration_time=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + iteration_time))
        
        echo "  Iteration $i: ${iteration_time}ms"
    done
    
    local avg_time=$((total_time / iterations))
    echo "  Average: ${avg_time}ms"
    
    # Log result
    perf_log "INFO" "shell_startup:$shell" "$avg_time" "iterations:$iterations"
    
    # Update metrics
    update_startup_metrics "$shell" "$avg_time"
    
    # Check threshold
    if [[ $avg_time -gt $SHELL_STARTUP_THRESHOLD ]]; then
        echo "  ⚠️ Warning: Startup time exceeds threshold (${SHELL_STARTUP_THRESHOLD}ms)"
        perf_log "WARN" "slow_startup:$shell" "$avg_time" "threshold_exceeded"
        suggest_startup_optimizations "$shell" "$avg_time"
    else
        echo "  ✅ Startup time is within acceptable range"
    fi
    
    return 0
}

# Update startup metrics in JSON
update_startup_metrics() {
    local shell="$1"
    local time="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Use Python to update JSON (fallback to basic append if not available)
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json
import sys
from datetime import datetime

try:
    with open('$PERF_METRICS_FILE', 'r') as f:
        data = json.load(f)
except:
    data = {'startup_times': [], 'command_times': {}, 'optimization_history': []}

data['startup_times'].append({
    'shell': '$shell',
    'time': $time,
    'timestamp': '$timestamp'
})

# Keep only last 100 entries
data['startup_times'] = data['startup_times'][-100:]

with open('$PERF_METRICS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    else
        # Fallback: append to log
        echo "startup,$shell,$time,$timestamp" >> "$PERF_DATA_DIR/startup_times.csv"
    fi
}

# Suggest startup optimizations
suggest_startup_optimizations() {
    local shell="$1"
    local time="$2"
    
    echo "🔧 Startup Optimization Suggestions:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # General optimizations
    echo "1. Profile your shell configuration:"
    echo "   zsh: zsh -i -c 'zprof'"
    echo "   bash: bash --debugger"
    
    echo "2. Check for slow plugins/modules:"
    echo "   • Review Oh My Zsh plugins"
    echo "   • Disable unused completions"
    echo "   • Lazy-load heavy tools"
    
    echo "3. Optimize PATH variable:"
    echo "   • Remove duplicate entries"
    echo "   • Put most-used paths first"
    echo "   • Avoid scanning large directories"
    
    echo "4. Cache completion data:"
    echo "   • Enable zsh completion cache"
    echo "   • Pre-compile zsh functions"
    
    echo "5. Defer expensive operations:"
    echo "   • Use async loading for tools"
    echo "   • Initialize tools on first use"
    
    # Specific suggestions based on time
    if [[ $time -gt 5000 ]]; then
        echo "6. Critical performance issues detected:"
        echo "   • Consider switching to a faster shell"
        echo "   • Profile and remove major bottlenecks"
        echo "   • Use minimal shell configuration"
    elif [[ $time -gt 3000 ]]; then
        echo "6. Moderate performance issues:"
        echo "   • Audit installed plugins"
        echo "   • Optimize heavy completions"
        echo "   • Consider using Starship prompt"
    fi
}

# System performance analysis
analyze_system_performance() {
    echo "📊 System Performance Analysis"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # CPU information
    echo "🖥️ CPU Information:"
    if [[ "$PLATFORM_OS" == "macos" ]]; then
        sysctl -n machdep.cpu.brand_string
        echo "Cores: $(sysctl -n hw.ncpu)"
    elif [[ "$PLATFORM_OS" == "linux" ]]; then
        grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
        echo "Cores: $(nproc)"
    fi
    
    # Memory information
    echo -e "\n💾 Memory Information:"
    if [[ "$PLATFORM_OS" == "macos" ]]; then
        local total_memory=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
        echo "Total: ${total_memory}GB"
        vm_stat | head -5
    elif [[ "$PLATFORM_OS" == "linux" ]]; then
        free -h | head -2
    fi
    
    # Disk performance
    echo -e "\n💿 Disk Information:"
    df -h | head -5
    
    # Load average
    echo -e "\n⚡ System Load:"
    if command -v uptime >/dev/null 2>&1; then
        uptime
    fi
    
    # Shell performance
    echo -e "\n🐚 Shell Performance:"
    measure_shell_startup "$SHELL" 3
    
    # Tool responsiveness
    echo -e "\n🔧 Tool Responsiveness:"
    test_tool_performance
}

# Test tool performance
test_tool_performance() {
    local tools=("git" "ls" "grep" "find" "cat")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo -n "  $tool: "
            local start_time=$(date +%s%N)
            case "$tool" in
                "git")
                    git --version >/dev/null 2>&1
                    ;;
                "ls")
                    ls /usr/bin >/dev/null 2>&1
                    ;;
                "grep")
                    echo "test" | grep "test" >/dev/null 2>&1
                    ;;
                "find")
                    find /tmp -maxdepth 1 -name ".*" >/dev/null 2>&1
                    ;;
                "cat")
                    cat /etc/passwd >/dev/null 2>&1
                    ;;
            esac
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            echo "${duration}ms"
            
            perf_log "INFO" "tool_test:$tool" "$duration"
        fi
    done
}

# Performance optimization
optimize_performance() {
    local optimization_type="${1:-auto}"
    
    echo "🚀 Performance Optimization"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case "$optimization_type" in
        "shell")
            optimize_shell_performance
            ;;
        "tools")
            optimize_tool_performance
            ;;
        "system")
            optimize_system_performance
            ;;
        "auto"|*)
            echo "Running automatic optimization..."
            optimize_shell_performance
            optimize_tool_performance
            optimize_path_performance
            ;;
    esac
    
    # Log optimization
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    perf_log "INFO" "optimization:$optimization_type" "0" "completed:$timestamp"
}

# Shell performance optimization
optimize_shell_performance() {
    echo "🐚 Optimizing shell performance..."
    
    # Compile zsh functions
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "  Compiling zsh functions..."
        for file in ~/.zsh/**/*.zsh(N); do
            if [[ ! -f "${file}.zwc" ]] || [[ "$file" -nt "${file}.zwc" ]]; then
                zcompile "$file" 2>/dev/null && echo "    Compiled: $(basename "$file")"
            fi
        done
        
        # Rebuild completion cache
        echo "  Rebuilding completion cache..."
        rm -f ~/.zcompdump*
        autoload -Uz compinit && compinit -u
    fi
    
    # Optimize PATH
    echo "  Optimizing PATH variable..."
    optimize_path_performance
    
    echo "  ✅ Shell optimization complete"
}

# Tool performance optimization
optimize_tool_performance() {
    echo "🔧 Optimizing tool performance..."
    
    # Git optimization
    if command -v git >/dev/null 2>&1; then
        echo "  Optimizing Git..."
        git config --global core.preloadindex true
        git config --global core.fscache true
        git config --global gc.auto 256
    fi
    
    # Homebrew optimization (macOS)
    if command -v brew >/dev/null 2>&1; then
        echo "  Optimizing Homebrew..."
        export HOMEBREW_NO_AUTO_UPDATE=1
        export HOMEBREW_NO_ANALYTICS=1
    fi
    
    # Python optimization
    if command -v python3 >/dev/null 2>&1; then
        echo "  Optimizing Python..."
        export PYTHONDONTWRITEBYTECODE=1
        export PYTHONUNBUFFERED=1
    fi
    
    echo "  ✅ Tool optimization complete"
}

# PATH optimization
optimize_path_performance() {
    echo "  Analyzing PATH variable..."
    
    # Count PATH entries
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    echo "    Current PATH entries: $path_count"
    
    # Check for duplicates
    local unique_paths=$(echo "$PATH" | tr ':' '\n' | sort -u | wc -l)
    local duplicates=$((path_count - unique_paths))
    
    if [[ $duplicates -gt 0 ]]; then
        echo "    ⚠️ Found $duplicates duplicate PATH entries"
        echo "    Consider cleaning up PATH in your shell configuration"
    else
        echo "    ✅ No duplicate PATH entries found"
    fi
    
    # Check for non-existent directories
    local missing_paths=0
    while IFS=: read -r path_entry; do
        if [[ -n "$path_entry" ]] && [[ ! -d "$path_entry" ]]; then
            ((missing_paths++))
            echo "    ⚠️ Non-existent PATH: $path_entry"
        fi
    done <<< "$PATH"
    
    if [[ $missing_paths -gt 0 ]]; then
        echo "    Found $missing_paths non-existent PATH entries"
    else
        echo "    ✅ All PATH entries exist"
    fi
}

# System optimization
optimize_system_performance() {
    echo "💻 Optimizing system performance..."
    
    case "$PLATFORM_OS" in
        "macos")
            optimize_macos_performance
            ;;
        "linux")
            optimize_linux_performance
            ;;
    esac
    
    echo "  ✅ System optimization complete"
}

# macOS-specific optimizations
optimize_macos_performance() {
    echo "  Applying macOS optimizations..."
    
    # Disable animations for faster UI
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
    
    # Faster key repeat
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10
    
    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
    
    echo "    ✅ macOS optimizations applied (restart may be required)"
}

# Linux-specific optimizations
optimize_linux_performance() {
    echo "  Applying Linux optimizations..."
    
    # Optimize swap usage
    if [[ -w /proc/sys/vm/swappiness ]]; then
        echo 10 | sudo tee /proc/sys/vm/swappiness >/dev/null
        echo "    Set swappiness to 10"
    fi
    
    # Clear system caches
    if command -v sync >/dev/null 2>&1; then
        sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
        echo "    Cleared system caches"
    fi
    
    echo "    ✅ Linux optimizations applied"
}

# Performance monitoring daemon
start_performance_monitoring() {
    echo "📊 Starting performance monitoring..."
    
    local monitor_script="$PERF_DATA_DIR/monitor.sh"
    
    cat > "$monitor_script" << 'EOF'
#!/bin/bash
# Performance monitoring daemon

PERF_DATA_DIR="$HOME/.local/share/dotfiles/performance"
PERF_METRICS_FILE="$PERF_DATA_DIR/metrics.json"

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Collect system metrics
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        memory_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    fi
    
    # Log metrics
    echo "[$timestamp] CPU: ${cpu_usage}%, Memory: ${memory_usage}%" >> "$PERF_DATA_DIR/system_metrics.log"
    
    sleep 60
done
EOF
    
    chmod +x "$monitor_script"
    
    # Start monitoring in background
    nohup "$monitor_script" >/dev/null 2>&1 &
    local monitor_pid=$!
    echo "$monitor_pid" > "$PERF_DATA_DIR/monitor.pid"
    
    echo "  ✅ Performance monitoring started (PID: $monitor_pid)"
}

# Stop performance monitoring
stop_performance_monitoring() {
    local pid_file="$PERF_DATA_DIR/monitor.pid"
    
    if [[ -f "$pid_file" ]]; then
        local monitor_pid=$(cat "$pid_file")
        if kill -0 "$monitor_pid" 2>/dev/null; then
            kill "$monitor_pid"
            rm -f "$pid_file"
            echo "✅ Performance monitoring stopped"
        else
            echo "⚠️ Monitor process not running"
            rm -f "$pid_file"
        fi
    else
        echo "⚠️ No monitor PID file found"
    fi
}

# Performance report generation
generate_performance_report() {
    local output_file="${1:-$PERF_DATA_DIR/performance_report.md}"
    
    echo "📋 Generating performance report..."
    
    cat > "$output_file" << EOF
# Performance Report

**Generated:** $(date)
**System:** $PLATFORM_OS ($PLATFORM_ARCH)
**Shell:** $SHELL

## Summary

This report contains performance analysis and recommendations for your dotfiles environment.

## Shell Startup Performance

EOF
    
    # Add startup time analysis
    if [[ -f "$PERF_DATA_DIR/startup_times.csv" ]]; then
        echo "Recent startup times:" >> "$output_file"
        tail -10 "$PERF_DATA_DIR/startup_times.csv" | while IFS=, read -r type shell time timestamp; do
            echo "- $shell: ${time}ms ($timestamp)" >> "$output_file"
        done
        echo "" >> "$output_file"
    fi
    
    # Add system metrics
    cat >> "$output_file" << EOF
## System Performance

$(analyze_system_performance 2>&1 | head -20)

## Optimization History

EOF
    
    # Add recent optimizations
    grep "optimization" "$PERF_LOG_FILE" 2>/dev/null | tail -5 >> "$output_file" || echo "No optimization history found" >> "$output_file"
    
    cat >> "$output_file" << EOF

## Recommendations

1. **Shell Optimization**: Regularly profile and optimize shell startup
2. **Tool Management**: Keep tools updated and remove unused ones
3. **System Maintenance**: Regular cleanup and optimization
4. **Monitoring**: Continue performance monitoring for trends

## Next Steps

- Run \`dot perf optimize\` to apply automatic optimizations
- Monitor startup times with \`dot perf monitor\`
- Review PATH and shell configuration regularly

---
*Generated by Dotfiles Performance Monitor*
EOF
    
    echo "✅ Performance report generated: $output_file"
}

# Performance CLI interface
performance_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "measure"|"test")
            local target="${1:-shell}"
            case "$target" in
                "shell")
                    measure_shell_startup "$SHELL" "${2:-5}"
                    ;;
                "startup")
                    measure_shell_startup "$SHELL" "${2:-5}"
                    ;;
                "tools")
                    test_tool_performance
                    ;;
                "system")
                    analyze_system_performance
                    ;;
                *)
                    echo "Usage: performance measure {shell|startup|tools|system}"
                    ;;
            esac
            ;;
        "optimize")
            optimize_performance "$@"
            ;;
        "monitor")
            local action="${1:-start}"
            case "$action" in
                "start")
                    start_performance_monitoring
                    ;;
                "stop")
                    stop_performance_monitoring
                    ;;
                "status")
                    if [[ -f "$PERF_DATA_DIR/monitor.pid" ]]; then
                        local pid=$(cat "$PERF_DATA_DIR/monitor.pid")
                        if kill -0 "$pid" 2>/dev/null; then
                            echo "✅ Performance monitoring running (PID: $pid)"
                        else
                            echo "❌ Monitor process not running"
                        fi
                    else
                        echo "❌ Performance monitoring not started"
                    fi
                    ;;
                *)
                    echo "Usage: performance monitor {start|stop|status}"
                    ;;
            esac
            ;;
        "report")
            generate_performance_report "$@"
            ;;
        "analyze"|"analysis")
            analyze_system_performance
            ;;
        "init")
            init_performance_monitoring
            echo "✅ Performance monitoring initialized"
            ;;
        "help"|*)
            cat << 'EOF'
🚀 Performance Monitoring System

USAGE:
    performance <command> [options]

COMMANDS:
    measure <target>     Measure performance metrics
      shell [iterations] Measure shell startup time
      startup [iter]     Alias for shell measurement  
      tools              Test tool responsiveness
      system             Full system analysis
      
    optimize [type]      Apply performance optimizations
      shell              Optimize shell configuration
      tools              Optimize development tools
      system             Optimize system settings
      auto               Apply all optimizations (default)
      
    monitor <action>     Performance monitoring daemon
      start              Start continuous monitoring
      stop               Stop monitoring daemon
      status             Check monitoring status
      
    report [file]        Generate performance report
    analyze              Analyze current system performance
    init                 Initialize monitoring system

EXAMPLES:
    performance measure shell 10    # Measure startup 10 times
    performance optimize auto       # Auto-optimize everything
    performance monitor start       # Start monitoring
    performance report              # Generate report

EOF
            ;;
    esac
}

# Initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_performance_monitoring
fi

# Export functions
export -f measure_command measure_shell_startup analyze_system_performance
export -f optimize_performance performance_cli init_performance_monitoring