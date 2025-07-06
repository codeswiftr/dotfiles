#!/usr/bin/env bash
# =============================================================================
# Metrics Collection and Analytics System
# Comprehensive system performance monitoring and usage analytics
# =============================================================================

# Metrics system configuration
METRICS_DIR="$HOME/.local/share/dotfiles/metrics"
METRICS_CONFIG_DIR="$HOME/.config/dotfiles/metrics"
METRICS_DATA_FILE="$METRICS_DIR/metrics.json"
METRICS_CONFIG_FILE="$METRICS_CONFIG_DIR/config.json"
METRICS_HISTORY_DIR="$METRICS_DIR/history"
METRICS_REPORTS_DIR="$METRICS_DIR/reports"

# Metrics collection settings
METRICS_COLLECTION_INTERVAL=300  # 5 minutes
METRICS_RETENTION_DAYS=30
METRICS_BATCH_SIZE=100

# Initialize metrics system
init_metrics_system() {
    mkdir -p "$METRICS_DIR" "$METRICS_CONFIG_DIR" "$METRICS_HISTORY_DIR" "$METRICS_REPORTS_DIR"
    
    # Create metrics data file if it doesn't exist
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        create_metrics_data_file
    fi
    
    # Create metrics configuration
    if [[ ! -f "$METRICS_CONFIG_FILE" ]]; then
        create_metrics_config
    fi
    
    # Setup metrics collection hooks
    setup_metrics_hooks
}

# Create metrics data file
create_metrics_data_file() {
    cat > "$METRICS_DATA_FILE" << EOF
{
  "version": "1.0",
  "created": "$(date -Iseconds)",
  "system_info": {
    "hostname": "$(hostname)",
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "shell": "$SHELL"
  },
  "metrics": {
    "system": [],
    "commands": [],
    "performance": [],
    "usage": [],
    "errors": []
  },
  "statistics": {
    "total_commands": 0,
    "total_errors": 0,
    "uptime_hours": 0,
    "last_collection": null
  }
}
EOF
}

# Create metrics configuration
create_metrics_config() {
    cat > "$METRICS_CONFIG_FILE" << EOF
{
  "collection": {
    "enabled": true,
    "interval": $METRICS_COLLECTION_INTERVAL,
    "auto_cleanup": true,
    "retention_days": $METRICS_RETENTION_DAYS
  },
  "categories": {
    "system": {
      "enabled": true,
      "metrics": ["cpu", "memory", "disk", "load", "processes"]
    },
    "commands": {
      "enabled": true,
      "track_frequency": true,
      "track_duration": true,
      "track_errors": true
    },
    "performance": {
      "enabled": true,
      "benchmark_commands": true,
      "track_startup_time": true,
      "profile_scripts": false
    },
    "usage": {
      "enabled": true,
      "track_features": true,
      "track_configurations": true,
      "anonymous": true
    }
  },
  "reporting": {
    "daily_summary": true,
    "weekly_report": true,
    "monthly_analytics": true,
    "export_format": "json"
  },
  "privacy": {
    "collect_personal_data": false,
    "anonymize_paths": true,
    "exclude_patterns": [
      "*/secrets/*",
      "*/private/*",
      "*.key",
      "*.pem"
    ]
  }
}
EOF
}

# Setup metrics hooks
setup_metrics_hooks() {
    # Create metrics collection hooks
    local hooks_dir="$DOTFILES_DIR/hooks"
    mkdir -p "$hooks_dir"
    
    # Command execution hook
    cat > "$hooks_dir/command_metrics.sh" << 'EOF'
#!/usr/bin/env bash
# Metrics collection hook for command execution

if [[ "${METRICS_ENABLED:-true}" == "true" ]]; then
    source "$DOTFILES_DIR/lib/metrics.sh"
    collect_command_metrics "$@"
fi
EOF
    
    chmod +x "$hooks_dir/command_metrics.sh"
}

# Collect system metrics
collect_system_metrics() {
    local timestamp=$(date -Iseconds)
    local metrics_data="{}"
    
    # CPU usage
    if command -v top >/dev/null 2>&1; then
        local cpu_usage=$(top -l 1 -s 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' 2>/dev/null || echo "0")
        metrics_data=$(echo "$metrics_data" | jq --arg cpu "$cpu_usage" '.cpu_usage = $cpu')
    fi
    
    # Memory usage
    if command -v free >/dev/null 2>&1; then
        local memory_info=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}' 2>/dev/null || echo "0")
        metrics_data=$(echo "$metrics_data" | jq --arg mem "$memory_info" '.memory_usage = $mem')
    elif command -v vm_stat >/dev/null 2>&1; then
        local memory_info=$(vm_stat | awk '/free/ {free=$3} /active/ {active=$3} /inactive/ {inactive=$3} /wired/ {wired=$3} END {total=free+active+inactive+wired; used=active+inactive+wired; printf "%.2f", used*100/total}' 2>/dev/null || echo "0")
        metrics_data=$(echo "$metrics_data" | jq --arg mem "$memory_info" '.memory_usage = $mem')
    fi
    
    # Disk usage
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
    metrics_data=$(echo "$metrics_data" | jq --arg disk "$disk_usage" '.disk_usage = $disk')
    
    # Load average
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//' 2>/dev/null || echo "0")
    metrics_data=$(echo "$metrics_data" | jq --arg load "$load_avg" '.load_average = $load')
    
    # Process count
    local process_count=$(ps aux | wc -l | tr -d ' ' 2>/dev/null || echo "0")
    metrics_data=$(echo "$metrics_data" | jq --arg procs "$process_count" '.process_count = $procs')
    
    # Add timestamp
    metrics_data=$(echo "$metrics_data" | jq --arg ts "$timestamp" '.timestamp = $ts')
    
    # Store metrics
    store_metrics "system" "$metrics_data"
}

# Collect command metrics
collect_command_metrics() {
    local command="$1"
    local duration="${2:-0}"
    local exit_code="${3:-0}"
    local timestamp=$(date -Iseconds)
    
    # Skip if metrics collection is disabled
    if [[ "${METRICS_ENABLED:-true}" != "true" ]]; then
        return
    fi
    
    # Skip sensitive commands
    if should_skip_command "$command"; then
        return
    fi
    
    # Create command metrics
    local metrics_data=$(cat << EOF
{
  "command": "$command",
  "duration": $duration,
  "exit_code": $exit_code,
  "timestamp": "$timestamp",
  "working_directory": "$(pwd | sed 's|'"$HOME"'|~|')",
  "shell": "$SHELL"
}
EOF
)
    
    # Store metrics
    store_metrics "commands" "$metrics_data"
    
    # Update statistics
    update_command_statistics "$command" "$exit_code"
}

# Check if command should be skipped
should_skip_command() {
    local command="$1"
    
    # Skip sensitive commands
    local skip_patterns=(
        "secret"
        "password"
        "token"
        "key"
        "ssh"
        "gpg"
        "sudo"
    )
    
    for pattern in "${skip_patterns[@]}"; do
        if [[ "$command" == *"$pattern"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Collect performance metrics
collect_performance_metrics() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    local timestamp=$(date -Iseconds)
    
    local duration=$((end_time - start_time))
    
    local metrics_data=$(cat << EOF
{
  "operation": "$operation",
  "duration": $duration,
  "timestamp": "$timestamp",
  "type": "performance"
}
EOF
)
    
    store_metrics "performance" "$metrics_data"
}

# Collect usage metrics
collect_usage_metrics() {
    local feature="$1"
    local action="$2"
    local metadata="${3:-{}}"
    local timestamp=$(date -Iseconds)
    
    local metrics_data=$(cat << EOF
{
  "feature": "$feature",
  "action": "$action",
  "metadata": $metadata,
  "timestamp": "$timestamp",
  "session_id": "${DOTFILES_SESSION_ID:-unknown}"
}
EOF
)
    
    store_metrics "usage" "$metrics_data"
}

# Store metrics data
store_metrics() {
    local category="$1"
    local data="$2"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        init_metrics_system
    fi
    
    # Add to metrics array
    local temp_file=$(mktemp)
    echo "$data" | jq -s ".[0]" | jq -c . > "$temp_file.data"
    jq ".metrics.$category += [$(cat "$temp_file.data")]" "$METRICS_DATA_FILE" > "$temp_file"
    mv "$temp_file" "$METRICS_DATA_FILE"
    rm -f "$temp_file.data"
    
    # Update last collection time
    local timestamp=$(date -Iseconds)
    jq ".statistics.last_collection = \"$timestamp\"" "$METRICS_DATA_FILE" > "$temp_file"
    mv "$temp_file" "$METRICS_DATA_FILE"
    
    # Archive old data if needed
    cleanup_old_metrics
}

# Update command statistics
update_command_statistics() {
    local command="$1"
    local exit_code="$2"
    
    local temp_file=$(mktemp)
    
    # Increment total commands
    jq '.statistics.total_commands += 1' "$METRICS_DATA_FILE" > "$temp_file"
    mv "$temp_file" "$METRICS_DATA_FILE"
    
    # Increment error count if command failed
    if [[ "$exit_code" -ne 0 ]]; then
        jq '.statistics.total_errors += 1' "$METRICS_DATA_FILE" > "$temp_file"
        mv "$temp_file" "$METRICS_DATA_FILE"
    fi
}

# Cleanup old metrics
cleanup_old_metrics() {
    local retention_days=$(jq -r '.collection.retention_days // 30' "$METRICS_CONFIG_FILE" 2>/dev/null || echo "30")
    local cutoff_date=$(date -d "$retention_days days ago" -Iseconds 2>/dev/null || date -v-"$retention_days"d -Iseconds)
    
    # Archive old metrics to history
    local archive_file="$METRICS_HISTORY_DIR/$(date +%Y%m%d).json"
    
    if [[ -f "$METRICS_DATA_FILE" ]]; then
        # Extract old metrics
        local old_metrics=$(jq --arg cutoff "$cutoff_date" '
          .metrics | to_entries | map(
            .value = (.value | map(select(.timestamp < $cutoff)))
          ) | from_entries
        ' "$METRICS_DATA_FILE" 2>/dev/null || echo "{}")
        
        # Save to archive if there's data
        if [[ "$(echo "$old_metrics" | jq '.system | length' 2>/dev/null || echo 0)" -gt 0 ]]; then
            echo "$old_metrics" > "$archive_file"
        fi
        
        # Remove old metrics from main file
        local temp_file=$(mktemp)
        jq --arg cutoff "$cutoff_date" '
          .metrics as $m |
          . + {"metrics": ($m | to_entries | map(
            .value = (.value | map(select(.timestamp >= $cutoff)))
          ) | from_entries)}
        ' "$METRICS_DATA_FILE" > "$temp_file" 2>/dev/null && mv "$temp_file" "$METRICS_DATA_FILE"
    fi
}

# Generate metrics report
generate_metrics_report() {
    local report_type="${1:-daily}"
    local output_file="${2:-$METRICS_REPORTS_DIR/report-$(date +%Y%m%d).json}"
    
    echo "📊 Generating $report_type metrics report..."
    
    local report_data="{}"
    
    # System metrics summary
    local system_metrics=$(jq '.metrics.system' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    report_data=$(echo "$report_data" | jq --argjson sys "$system_metrics" '.system_metrics = $sys')
    
    # Command statistics
    local command_stats=$(generate_command_statistics)
    report_data=$(echo "$report_data" | jq --argjson cmd "$command_stats" '.command_statistics = $cmd')
    
    # Performance analysis
    local performance_stats=$(generate_performance_analysis)
    report_data=$(echo "$report_data" | jq --argjson perf "$performance_stats" '.performance_analysis = $perf')
    
    # Usage analytics
    local usage_analytics=$(generate_usage_analytics)
    report_data=$(echo "$report_data" | jq --argjson usage "$usage_analytics" '.usage_analytics = $usage')
    
    # Add report metadata
    report_data=$(echo "$report_data" | jq --arg type "$report_type" --arg generated "$(date -Iseconds)" '
      .report_type = $type |
      .generated = $generated |
      .period = {
        "start": (.system_metrics[0].timestamp // null),
        "end": (.system_metrics[-1].timestamp // null)
      }
    ')
    
    # Save report
    echo "$report_data" > "$output_file"
    
    echo "✅ Report generated: $output_file"
}

# Generate command statistics
generate_command_statistics() {
    local commands_data=$(jq '.metrics.commands' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    
    echo "$commands_data" | jq '
      if length == 0 then [] else
        group_by(.command) | map({
          command: .[0].command,
          count: length,
          avg_duration: (if (map(.duration) | add) == 0 then 0 else (map(.duration) | add) / length end),
          success_rate: (if length == 0 then 0 else (map(select(.exit_code == 0)) | length) * 100 / length end),
          last_used: (map(.timestamp) | max)
        }) | sort_by(.count) | reverse
      end
    '
}

# Generate performance analysis
generate_performance_analysis() {
    local performance_data=$(jq '.metrics.performance' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    
    echo "$performance_data" | jq '
      if length == 0 then [] else
        group_by(.operation) | map({
          operation: .[0].operation,
          count: length,
          avg_duration: (if (map(.duration) | add) == 0 then 0 else (map(.duration) | add) / length end),
          min_duration: (map(.duration) | min),
          max_duration: (map(.duration) | max),
          total_time: (map(.duration) | add)
        }) | sort_by(.avg_duration) | reverse
      end
    '
}

# Generate usage analytics
generate_usage_analytics() {
    local usage_data=$(jq '.metrics.usage' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    
    echo "$usage_data" | jq '
      if length == 0 then [] else
        group_by(.feature) | map({
          feature: .[0].feature,
          usage_count: length,
          actions: (group_by(.action) | map({
            action: .[0].action,
            count: length
          })),
          last_used: (map(.timestamp) | max)
        }) | sort_by(.usage_count) | reverse
      end
    '
}

# Show metrics dashboard
show_metrics_dashboard() {
    echo "📊 Dotfiles Metrics Dashboard"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        echo "❌ No metrics data found"
        echo "Run 'dot metrics collect' to start collecting metrics"
        return 1
    fi
    
    # System status
    echo "🖥️  System Status"
    echo "────────────────"
    
    local latest_system=$(jq '.metrics.system[-1]' "$METRICS_DATA_FILE" 2>/dev/null)
    if [[ "$latest_system" != "null" ]]; then
        echo "CPU Usage: $(echo "$latest_system" | jq -r '.cpu_usage // "N/A"')%"
        echo "Memory Usage: $(echo "$latest_system" | jq -r '.memory_usage // "N/A"')%"
        echo "Disk Usage: $(echo "$latest_system" | jq -r '.disk_usage // "N/A"')%"
        echo "Load Average: $(echo "$latest_system" | jq -r '.load_average // "N/A"')"
    else
        echo "No system metrics available"
    fi
    
    echo ""
    
    # Command statistics
    echo "⚡ Command Statistics"
    echo "────────────────────"
    
    local total_commands=$(jq '.statistics.total_commands' "$METRICS_DATA_FILE" 2>/dev/null || echo "0")
    local total_errors=$(jq '.statistics.total_errors' "$METRICS_DATA_FILE" 2>/dev/null || echo "0")
    local success_rate=$(awk "BEGIN {printf \"%.1f\", (($total_commands - $total_errors) / $total_commands) * 100}" 2>/dev/null || echo "0")
    
    echo "Total Commands: $total_commands"
    echo "Total Errors: $total_errors"
    echo "Success Rate: $success_rate%"
    
    echo ""
    
    # Top commands
    echo "🔥 Top Commands"
    echo "───────────────"
    
    local top_commands=$(jq -r '.metrics.commands | group_by(.command) | map({command: .[0].command, count: length}) | sort_by(.count) | reverse | .[0:5] | .[] | "\(.command): \(.count)"' "$METRICS_DATA_FILE" 2>/dev/null || echo "No data")
    
    if [[ "$top_commands" != "No data" ]]; then
        echo "$top_commands"
    else
        echo "No command data available"
    fi
    
    echo ""
    
    # Data collection status
    echo "📅 Collection Status"
    echo "────────────────────"
    
    local last_collection=$(jq -r '.statistics.last_collection' "$METRICS_DATA_FILE" 2>/dev/null || echo "never")
    local collection_enabled=$(jq -r '.collection.enabled' "$METRICS_CONFIG_FILE" 2>/dev/null || echo "unknown")
    
    echo "Last Collection: $last_collection"
    echo "Collection Enabled: $collection_enabled"
    
    # Storage usage
    local metrics_size=$(du -sh "$METRICS_DIR" 2>/dev/null | cut -f1 || echo "unknown")
    echo "Storage Usage: $metrics_size"
}

# Start metrics collection daemon
start_metrics_daemon() {
    echo "🚀 Starting metrics collection daemon..."
    
    local interval=$(jq -r '.collection.interval // 300' "$METRICS_CONFIG_FILE" 2>/dev/null || echo "300")
    local pid_file="$METRICS_DIR/daemon.pid"
    
    # Check if daemon is already running
    if [[ -f "$pid_file" ]] && ps -p "$(cat "$pid_file")" >/dev/null 2>&1; then
        echo "❌ Metrics daemon is already running (PID: $(cat "$pid_file"))"
        return 1
    fi
    
    # Start daemon
    (
        while true; do
            collect_system_metrics
            sleep "$interval"
        done
    ) &
    
    local daemon_pid=$!
    echo "$daemon_pid" > "$pid_file"
    
    echo "✅ Metrics daemon started (PID: $daemon_pid)"
    echo "Collection interval: ${interval}s"
}

# Stop metrics collection daemon
stop_metrics_daemon() {
    echo "🛑 Stopping metrics collection daemon..."
    
    local pid_file="$METRICS_DIR/daemon.pid"
    
    if [[ -f "$pid_file" ]]; then
        local daemon_pid=$(cat "$pid_file")
        
        if ps -p "$daemon_pid" >/dev/null 2>&1; then
            kill "$daemon_pid"
            rm -f "$pid_file"
            echo "✅ Metrics daemon stopped"
        else
            echo "❌ Daemon not running"
            rm -f "$pid_file"
        fi
    else
        echo "❌ No daemon PID file found"
    fi
}

# Export metrics data
export_metrics() {
    local format="${1:-json}"
    local output_file="${2:-metrics-export-$(date +%Y%m%d).$format}"
    
    echo "📤 Exporting metrics data..."
    
    case "$format" in
        "json")
            cp "$METRICS_DATA_FILE" "$output_file"
            ;;
        "csv")
            export_metrics_csv "$output_file"
            ;;
        "html")
            export_metrics_html "$output_file"
            ;;
        *)
            echo "❌ Unsupported format: $format"
            echo "Supported formats: json, csv, html"
            return 1
            ;;
    esac
    
    echo "✅ Metrics exported to: $output_file"
}

# Export metrics to CSV
export_metrics_csv() {
    local output_file="$1"
    
    echo "timestamp,category,metric,value" > "$output_file"
    
    # System metrics
    jq -r '.metrics.system[] | [.timestamp, "system", "cpu_usage", .cpu_usage] | @csv' "$METRICS_DATA_FILE" >> "$output_file"
    jq -r '.metrics.system[] | [.timestamp, "system", "memory_usage", .memory_usage] | @csv' "$METRICS_DATA_FILE" >> "$output_file"
    jq -r '.metrics.system[] | [.timestamp, "system", "disk_usage", .disk_usage] | @csv' "$METRICS_DATA_FILE" >> "$output_file"
    
    # Command metrics
    jq -r '.metrics.commands[] | [.timestamp, "command", .command, .duration] | @csv' "$METRICS_DATA_FILE" >> "$output_file"
}

# Export metrics to HTML
export_metrics_html() {
    local output_file="$1"
    
    cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Dotfiles Metrics Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }
        .chart { width: 100%; height: 300px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Dotfiles Metrics Report</h1>
    <div id="metrics-data">
        <!-- Metrics data will be populated here -->
    </div>
    
    <script>
        // Add JavaScript for interactive charts
        const metricsData = EOF
    
    cat "$METRICS_DATA_FILE" >> "$output_file"
    
    cat >> "$output_file" << 'EOF'
    ;
    
    // Populate metrics dashboard
    console.log('Metrics data loaded:', metricsData);
    </script>
</body>
</html>
EOF
}

# Metrics CLI interface
metrics_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "init"|"initialize")
            init_metrics_system
            echo "✅ Metrics system initialized"
            ;;
        "collect")
            collect_system_metrics
            echo "✅ System metrics collected"
            ;;
        "daemon")
            local action="${1:-status}"
            case "$action" in
                "start") start_metrics_daemon ;;
                "stop") stop_metrics_daemon ;;
                "restart")
                    stop_metrics_daemon
                    sleep 2
                    start_metrics_daemon
                    ;;
                "status")
                    local pid_file="$METRICS_DIR/daemon.pid"
                    if [[ -f "$pid_file" ]] && ps -p "$(cat "$pid_file")" >/dev/null 2>&1; then
                        echo "✅ Metrics daemon is running (PID: $(cat "$pid_file"))"
                    else
                        echo "❌ Metrics daemon is not running"
                    fi
                    ;;
                *)
                    echo "Usage: dot metrics daemon <start|stop|restart|status>"
                    ;;
            esac
            ;;
        "report")
            generate_metrics_report "$@"
            ;;
        "dashboard"|"show")
            show_metrics_dashboard
            ;;
        "export")
            export_metrics "$@"
            ;;
        "clean"|"cleanup")
            cleanup_old_metrics
            echo "✅ Old metrics cleaned up"
            ;;
        "help"|"")
            show_metrics_help
            ;;
        *)
            echo "❌ Unknown metrics command: $command"
            echo "Run 'dot metrics help' for available commands"
            return 1
            ;;
    esac
}

# Show metrics help
show_metrics_help() {
    cat << 'EOF'
📊 Metrics Collection and Analytics System

USAGE:
    dot metrics <command> [options]

COMMANDS:
    init                Initialize metrics system
    collect             Collect current system metrics
    daemon <action>     Manage metrics collection daemon
      start               Start background collection
      stop                Stop background collection
      restart             Restart daemon
      status              Show daemon status
      
    report [type] [file]  Generate metrics report
      daily               Daily report (default)
      weekly              Weekly report
      monthly             Monthly report
      
    dashboard           Show metrics dashboard
    export [format] [file] Export metrics data
      json                JSON format (default)
      csv                 CSV format
      html                HTML report
      
    clean               Clean up old metrics data
    help                Show this help message

EXAMPLES:
    # Setup and start metrics collection
    dot metrics init
    dot metrics daemon start
    
    # View current metrics
    dot metrics dashboard
    
    # Generate reports
    dot metrics report daily
    dot metrics report weekly weekly-report.json
    
    # Export data
    dot metrics export csv metrics.csv
    dot metrics export html metrics.html
    
    # Maintenance
    dot metrics clean
    dot metrics daemon restart

CONFIGURATION:
    Config file: ~/.config/dotfiles/metrics/config.json
    Data directory: ~/.local/share/dotfiles/metrics
    
    Edit config to adjust collection intervals, retention policies,
    and privacy settings.

For more information: https://docs.dotfiles.dev/metrics
EOF
}

# Export functions
export -f init_metrics_system collect_system_metrics collect_command_metrics
export -f collect_performance_metrics collect_usage_metrics generate_metrics_report
export -f show_metrics_dashboard start_metrics_daemon stop_metrics_daemon
export -f export_metrics metrics_cli