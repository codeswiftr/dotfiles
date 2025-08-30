#!/usr/bin/env bash
# ============================================================================
# Metrics Dashboard Visualization
# Interactive terminal dashboard for metrics monitoring
# ============================================================================

# Load metrics system
source "${DOTFILES_DIR}/lib/metrics.sh"

# Dashboard configuration
DASHBOARD_REFRESH_INTERVAL="${DASHBOARD_REFRESH_INTERVAL:-2}"
DASHBOARD_AUTO_REFRESH="${DASHBOARD_AUTO_REFRESH:-true}"
DASHBOARD_THEME="${DASHBOARD_THEME:-default}"

# Colors and symbols
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[0;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [CYAN]='\033[0;36m'
    [WHITE]='\033[0;37m'
    [BOLD]='\033[1m'
    [DIM]='\033[2m'
    [RESET]='\033[0m'
)

declare -A SYMBOLS=(
    [CHECK]="✅"
    [CROSS]="❌"
    [WARNING]="⚠️"
    [INFO]="ℹ️"
    [ARROW_UP]="↗"
    [ARROW_DOWN]="↘"
    [ARROW_RIGHT]="→"
    [METER]="█"
    [DOT]="•"
    [SPARK]="▁▂▃▄▅▆▇█"
)

# Dashboard state
DASHBOARD_RUNNING=false
DASHBOARD_LAST_UPDATE=""

# Main dashboard function
show_interactive_dashboard() {
    local mode="${1:-live}"
    
    case "$mode" in
        "live"|"interactive")
            show_live_dashboard
            ;;
        "static"|"once")
            show_static_dashboard
            ;;
        "compact")
            show_compact_dashboard
            ;;
        "detailed")
            show_detailed_dashboard
            ;;
        *)
            echo "❌ Unknown dashboard mode: $mode"
            echo "Available modes: live, static, compact, detailed"
            return 1
            ;;
    esac
}

# Live dashboard with auto-refresh
show_live_dashboard() {
    echo "📊 Starting Live Metrics Dashboard"
    echo "Press 'q' to quit, 'r' to refresh, 'h' for help"
    echo ""
    
    DASHBOARD_RUNNING=true
    
    # Trap signals
    trap cleanup_dashboard INT TERM
    
    while [[ "$DASHBOARD_RUNNING" == "true" ]]; do
        clear
        render_dashboard_header
        render_system_overview
        render_performance_metrics
        render_command_statistics
        render_dashboard_footer
        
        # Handle user input
        if read -t "$DASHBOARD_REFRESH_INTERVAL" -n 1 key; then
            handle_dashboard_input "$key"
        fi
    done
}

# Static dashboard (one-time render)
show_static_dashboard() {
    render_dashboard_header
    render_system_overview
    render_performance_metrics
    render_command_statistics
    render_usage_analytics
    render_health_status
    render_dashboard_footer
}

# Compact dashboard
show_compact_dashboard() {
    echo "📊 Metrics Overview"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # System metrics in one line
    local latest_system=$(get_latest_system_metrics)
    if [[ "$latest_system" != "null" ]]; then
        local cpu=$(echo "$latest_system" | jq -r '.cpu_usage // "N/A"')
        local memory=$(echo "$latest_system" | jq -r '.memory_usage // "N/A"')
        local disk=$(echo "$latest_system" | jq -r '.disk_usage // "N/A"')
        local load=$(echo "$latest_system" | jq -r '.load_average // "N/A"')
        
        printf "System: CPU %s%% | Memory %s%% | Disk %s%% | Load %s\n" \
            "$cpu" "$memory" "$disk" "$load"
    else
        echo "System: No data available"
    fi
    
    # Command statistics
    local total_commands=$(get_total_commands)
    local total_errors=$(get_total_errors)
    local success_rate=$(calculate_success_rate "$total_commands" "$total_errors")
    
    printf "Commands: %d total | %d errors | %.1f%% success rate\n" \
        "$total_commands" "$total_errors" "$success_rate"
    
    # Collection status
    local daemon_status=$(get_daemon_status)
    local last_collection=$(get_last_collection_time)
    
    printf "Collection: %s | Last: %s\n" "$daemon_status" "$last_collection"
}

# Detailed dashboard
show_detailed_dashboard() {
    render_dashboard_header
    echo ""
    
    # Extended system metrics
    render_extended_system_metrics
    echo ""
    
    # Detailed performance analysis
    render_detailed_performance_metrics
    echo ""
    
    # Command analysis
    render_detailed_command_analysis
    echo ""
    
    # Usage patterns
    render_usage_patterns
    echo ""
    
    # Trends and insights
    render_trends_and_insights
    echo ""
    
    render_dashboard_footer
}

# Render dashboard header
render_dashboard_header() {
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${COLORS[BOLD]}📊 Dotfiles Metrics Dashboard${COLORS[RESET]}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Updated: $current_time | Auto-refresh: ${DASHBOARD_AUTO_REFRESH}"
    echo ""
}

# Render system overview
render_system_overview() {
    echo -e "${COLORS[BOLD]}🖥️  System Overview${COLORS[RESET]}"
    echo "────────────────────────────────────────"
    
    local latest_system=$(get_latest_system_metrics)
    
    if [[ "$latest_system" != "null" && "$latest_system" != "" ]]; then
        local cpu=$(echo "$latest_system" | jq -r '.cpu_usage // "0"')
        local memory=$(echo "$latest_system" | jq -r '.memory_usage // "0"')
        local disk=$(echo "$latest_system" | jq -r '.disk_usage // "0"')
        local load=$(echo "$latest_system" | jq -r '.load_average // "0"')
        local processes=$(echo "$latest_system" | jq -r '.process_count // "0"')
        
        # CPU usage with bar
        printf "CPU Usage:    %3s%% %s\n" "$cpu" "$(render_progress_bar "$cpu" 100)"
        
        # Memory usage with bar
        printf "Memory Usage: %3s%% %s\n" "$memory" "$(render_progress_bar "$memory" 100)"
        
        # Disk usage with bar
        printf "Disk Usage:   %3s%% %s\n" "$disk" "$(render_progress_bar "$disk" 100)"
        
        # Load average and processes
        printf "Load Average: %s\n" "$load"
        printf "Processes:    %s\n" "$processes"
        
        # System health indicator
        local health_color="${COLORS[GREEN]}"
        local health_status="Healthy"
        
        if [[ $(echo "$cpu > 80" | bc -l 2>/dev/null || echo 0) -eq 1 ]] || \
           [[ $(echo "$memory > 85" | bc -l 2>/dev/null || echo 0) -eq 1 ]] || \
           [[ $(echo "$disk > 90" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
            health_color="${COLORS[RED]}"
            health_status="Critical"
        elif [[ $(echo "$cpu > 60" | bc -l 2>/dev/null || echo 0) -eq 1 ]] || \
             [[ $(echo "$memory > 70" | bc -l 2>/dev/null || echo 0) -eq 1 ]] || \
             [[ $(echo "$disk > 80" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
            health_color="${COLORS[YELLOW]}"
            health_status="Warning"
        fi
        
        printf "Health:       %s%s%s\n" "$health_color" "$health_status" "${COLORS[RESET]}"
    else
        echo "No system metrics available"
        echo "Run 'dot metrics collect' to gather data"
    fi
    
    echo ""
}

# Render performance metrics
render_performance_metrics() {
    echo -e "${COLORS[BOLD]}⚡ Performance Metrics${COLORS[RESET]}"
    echo "────────────────────────────────────────"
    
    # Shell startup time
    local startup_time=$(get_shell_startup_time)
    if [[ "$startup_time" != "null" && "$startup_time" != "" ]]; then
        local rating=$(get_performance_rating "$startup_time")
        printf "Shell Startup: %4sms (%s)\n" "$startup_time" "$rating"
    else
        echo "Shell Startup: Not measured"
    fi
    
    # Command response times
    local avg_command_time=$(get_average_command_time)
    if [[ "$avg_command_time" != "null" && "$avg_command_time" != "" ]]; then
        printf "Avg Command:   %4sms\n" "$avg_command_time"
    else
        echo "Avg Command:   Not available"
    fi
    
    # System responsiveness
    local fs_response=$(get_filesystem_response_time)
    if [[ "$fs_response" != "null" && "$fs_response" != "" ]]; then
        printf "Filesystem:    %4sms\n" "$fs_response"
    else
        echo "Filesystem:    Not measured"
    fi
    
    echo ""
}

# Render command statistics
render_command_statistics() {
    echo -e "${COLORS[BOLD]}📈 Command Statistics${COLORS[RESET]}"
    echo "────────────────────────────────────────"
    
    local total_commands=$(get_total_commands)
    local total_errors=$(get_total_errors)
    local success_rate=$(calculate_success_rate "$total_commands" "$total_errors")
    
    printf "Total Commands: %d\n" "$total_commands"
    printf "Total Errors:   %d\n" "$total_errors"
    printf "Success Rate:   %.1f%%\n" "$success_rate"
    
    echo ""
    echo "Top Commands:"
    
    # Get top 5 commands
    local top_commands=$(get_top_commands 5)
    if [[ "$top_commands" != "null" && "$top_commands" != "" ]]; then
        echo "$top_commands" | jq -r '.[] | "  \(.command | .[0:20]): \(.count)"' 2>/dev/null || echo "  No data available"
    else
        echo "  No data available"
    fi
    
    echo ""
}

# Render usage analytics
render_usage_analytics() {
    echo -e "${COLORS[BOLD]}📊 Usage Analytics${COLORS[RESET]}"
    echo "────────────────────────────────────────"
    
    local usage_data=$(get_usage_analytics)
    if [[ "$usage_data" != "null" && "$usage_data" != "" ]]; then
        echo "$usage_data" | jq -r '.[] | "  \(.feature): \(.usage_count) uses"' 2>/dev/null || echo "  No usage data available"
    else
        echo "  No usage data available"
    fi
    
    echo ""
}

# Render health status
render_health_status() {
    echo -e "${COLORS[BOLD]}🏥 System Health${COLORS[RESET]}"
    echo "────────────────────────────────────────"
    
    local health_data=$(get_dotfiles_health)
    if [[ "$health_data" != "null" && "$health_data" != "" ]]; then
        local healthy=$(echo "$health_data" | jq -r '.healthy')
        local issues=$(echo "$health_data" | jq -r '.issues[]?' 2>/dev/null)
        
        if [[ "$healthy" == "true" ]]; then
            echo -e "  ${COLORS[GREEN]}${SYMBOLS[CHECK]} All systems healthy${COLORS[RESET]}"
        else
            echo -e "  ${COLORS[RED]}${SYMBOLS[CROSS]} Issues detected${COLORS[RESET]}"
            if [[ -n "$issues" ]]; then
                echo "$issues" | while read -r issue; do
                    echo "    • $issue"
                done
            fi
        fi
    else
        echo "  Health status not available"
    fi
    
    echo ""
}

# Render dashboard footer
render_dashboard_footer() {
    local data_size=$(get_metrics_data_size)
    local collection_status=$(get_collection_status)
    local daemon_status=$(get_daemon_status)
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "Collection: %s | Daemon: %s | Data: %s\n" \
        "$collection_status" "$daemon_status" "$data_size"
}

# Render progress bar
render_progress_bar() {
    local value="$1"
    local max_value="$2"
    local bar_length=20
    
    if [[ -z "$value" || "$value" == "null" || "$value" == "N/A" ]]; then
        printf "%-${bar_length}s" "No data"
        return
    fi
    
    # Calculate filled portion
    local filled_length=$(echo "scale=0; ($value * $bar_length) / $max_value" | bc -l 2>/dev/null || echo "0")
    
    # Choose color based on value
    local color="${COLORS[GREEN]}"
    if [[ $(echo "$value > 80" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        color="${COLORS[RED]}"
    elif [[ $(echo "$value > 60" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        color="${COLORS[YELLOW]}"
    fi
    
    # Render bar
    printf "%s" "$color"
    for ((i=0; i<filled_length; i++)); do
        printf "${SYMBOLS[METER]}"
    done
    printf "%s" "${COLORS[RESET]}"
    
    for ((i=filled_length; i<bar_length; i++)); do
        printf "░"
    done
}

# Handle dashboard input
handle_dashboard_input() {
    local key="$1"
    
    case "$key" in
        "q"|"Q")
            DASHBOARD_RUNNING=false
            ;;
        "r"|"R")
            # Force refresh
            ;;
        "h"|"H")
            show_dashboard_help
            read -p "Press Enter to continue..." -r
            ;;
        "c"|"C")
            show_compact_dashboard
            read -p "Press Enter to continue..." -r
            ;;
        "d"|"D")
            show_detailed_dashboard
            read -p "Press Enter to continue..." -r
            ;;
        "p"|"P")
            toggle_auto_refresh
            ;;
        *)
            # Unknown key, ignore
            ;;
    esac
}

# Show dashboard help
show_dashboard_help() {
    clear
    echo "📊 Dashboard Help"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Keyboard Controls:"
    echo "  q/Q - Quit dashboard"
    echo "  r/R - Force refresh"
    echo "  h/H - Show this help"
    echo "  c/C - Show compact view"
    echo "  d/D - Show detailed view"
    echo "  p/P - Toggle auto-refresh"
    echo ""
    echo "Dashboard automatically refreshes every ${DASHBOARD_REFRESH_INTERVAL} seconds"
    echo ""
}

# Toggle auto-refresh
toggle_auto_refresh() {
    if [[ "$DASHBOARD_AUTO_REFRESH" == "true" ]]; then
        DASHBOARD_AUTO_REFRESH="false"
    else
        DASHBOARD_AUTO_REFRESH="true"
    fi
}

# Cleanup dashboard
cleanup_dashboard() {
    DASHBOARD_RUNNING=false
    echo ""
    echo "Dashboard stopped."
    exit 0
}

# Helper functions for data retrieval

get_latest_system_metrics() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.metrics.system[-1] // null' "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_total_commands() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.statistics.total_commands // 0' "$METRICS_DATA_FILE" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

get_total_errors() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.statistics.total_errors // 0' "$METRICS_DATA_FILE" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

calculate_success_rate() {
    local total="$1"
    local errors="$2"
    
    if [[ "$total" -gt 0 ]]; then
        echo "scale=1; (($total - $errors) * 100) / $total" | bc -l 2>/dev/null || echo "0.0"
    else
        echo "0.0"
    fi
}

get_top_commands() {
    local limit="${1:-5}"
    
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq ".metrics.commands | group_by(.command) | map({command: .[0].command, count: length}) | sort_by(.count) | reverse | .[:$limit]" \
            "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_usage_analytics() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.metrics.usage | group_by(.feature) | map({feature: .[0].feature, usage_count: length}) | sort_by(.usage_count) | reverse | .[:5]' \
            "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_dotfiles_health() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.performance.dotfiles_health // null' "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_shell_startup_time() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.performance.shell_startup.average_startup_ms // null' "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_performance_rating() {
    local time="$1"
    
    if [[ $(echo "$time > 500" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        echo "Needs Improvement"
    elif [[ $(echo "$time > 350" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        echo "Acceptable"
    elif [[ $(echo "$time > 200" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        echo "Good"
    else
        echo "Excellent"
    fi
}

get_average_command_time() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.metrics.commands | if length > 0 then (map(.duration) | add) / length else null end' \
            "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_filesystem_response_time() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq '.performance.system_responsiveness.filesystem_response_ms // null' "$METRICS_DATA_FILE" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

get_daemon_status() {
    local pid_file="$METRICS_DIR/daemon.pid"
    if [[ -f "$pid_file" ]] && ps -p "$(cat "$pid_file")" >/dev/null 2>&1; then
        echo "Running"
    else
        echo "Stopped"
    fi
}

get_collection_status() {
    if [[ -f "$METRICS_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
        local enabled=$(jq -r '.collection.enabled // false' "$METRICS_CONFIG_FILE" 2>/dev/null)
        if [[ "$enabled" == "true" ]]; then
            echo "Enabled"
        else
            echo "Disabled"
        fi
    else
        echo "Unknown"
    fi
}

get_last_collection_time() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        local last_time=$(jq -r '.statistics.last_collection // null' "$METRICS_DATA_FILE" 2>/dev/null)
        if [[ "$last_time" != "null" && "$last_time" != "" ]]; then
            # Convert to relative time
            date -d "$last_time" 2>/dev/null || echo "$last_time"
        else
            echo "Never"
        fi
    else
        echo "Never"
    fi
}

get_metrics_data_size() {
    if [[ -d "$METRICS_DIR" ]]; then
        du -sh "$METRICS_DIR" 2>/dev/null | cut -f1 || echo "Unknown"
    else
        echo "N/A"
    fi
}

# Main entry point
main() {
    local command="${1:-live}"
    show_interactive_dashboard "$command"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi