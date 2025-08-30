#!/usr/bin/env bash
# ============================================================================
# Automated Metrics Reporting and Alerting System
# Generates scheduled reports and sends alerts for system issues
# ============================================================================

# Load metrics system
source "${DOTFILES_DIR}/lib/metrics.sh"

# Reporting configuration
REPORTER_CONFIG_FILE="${METRICS_CONFIG_DIR}/reporter.json"
REPORTER_STATE_FILE="${METRICS_DIR}/reporter-state.json"
REPORTS_OUTPUT_DIR="${METRICS_REPORTS_DIR}/automated"

# Alert thresholds (can be overridden in config)
DEFAULT_ALERT_THRESHOLDS='{
  "cpu_usage": 85,
  "memory_usage": 90,
  "disk_usage": 95,
  "error_rate": 10,
  "shell_startup_time": 1000,
  "command_failure_streak": 5
}'

# Initialize reporter system
init_reporter() {
    echo "🚀 Initializing metrics reporter system..."
    
    # Create output directory
    mkdir -p "$REPORTS_OUTPUT_DIR"
    
    # Create default reporter configuration
    if [[ ! -f "$REPORTER_CONFIG_FILE" ]]; then
        create_default_reporter_config
    fi
    
    # Create state file
    if [[ ! -f "$REPORTER_STATE_FILE" ]]; then
        echo '{}' > "$REPORTER_STATE_FILE"
    fi
    
    echo "✅ Reporter system initialized"
}

# Create default reporter configuration
create_default_reporter_config() {
    cat > "$REPORTER_CONFIG_FILE" << 'EOF'
{
  "reports": {
    "daily_summary": {
      "enabled": true,
      "time": "09:00",
      "format": "text",
      "email": false
    },
    "weekly_report": {
      "enabled": true,
      "day": "monday",
      "time": "09:00", 
      "format": "html",
      "email": false
    },
    "monthly_report": {
      "enabled": true,
      "day": 1,
      "time": "09:00",
      "format": "html", 
      "email": false
    }
  },
  "alerts": {
    "enabled": true,
    "channels": {
      "desktop": true,
      "log": true,
      "email": false,
      "webhook": false
    },
    "thresholds": {
      "cpu_usage": 85,
      "memory_usage": 90,
      "disk_usage": 95,
      "error_rate": 10,
      "shell_startup_time": 1000,
      "command_failure_streak": 5
    },
    "cooldown_minutes": 30
  },
  "email": {
    "smtp_host": "",
    "smtp_port": 587,
    "smtp_user": "",
    "smtp_password": "",
    "from": "dotfiles@localhost",
    "to": []
  },
  "webhook": {
    "url": "",
    "headers": {
      "Content-Type": "application/json"
    }
  }
}
EOF
    
    echo "📝 Created default reporter configuration: $REPORTER_CONFIG_FILE"
}

# Generate automated report
generate_automated_report() {
    local report_type="${1:-daily}"
    local force="${2:-false}"
    
    echo "📊 Generating $report_type report..."
    
    # Check if report should be generated
    if [[ "$force" != "true" ]] && ! should_generate_report "$report_type"; then
        echo "ℹ️  Report not due yet"
        return 0
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="$REPORTS_OUTPUT_DIR/${report_type}_${timestamp}.html"
    
    case "$report_type" in
        "daily")
            generate_daily_report "$output_file"
            ;;
        "weekly")
            generate_weekly_report "$output_file"
            ;;
        "monthly")
            generate_monthly_report "$output_file"
            ;;
        *)
            echo "❌ Unknown report type: $report_type"
            return 1
            ;;
    esac
    
    # Update state
    update_report_state "$report_type"
    
    # Send notification
    send_report_notification "$report_type" "$output_file"
    
    echo "✅ Report generated: $output_file"
}

# Check if report should be generated
should_generate_report() {
    local report_type="$1"
    
    if ! command -v jq >/dev/null 2>&1; then
        return 0  # Generate if jq not available
    fi
    
    local last_generated=$(jq -r ".reports.${report_type}.last_generated // null" "$REPORTER_STATE_FILE" 2>/dev/null || echo "null")
    
    if [[ "$last_generated" == "null" ]]; then
        return 0  # First time
    fi
    
    local current_date=$(date +%s)
    local last_date=$(date -d "$last_generated" +%s 2>/dev/null || echo "0")
    
    case "$report_type" in
        "daily")
            # Generate if more than 20 hours ago
            [[ $((current_date - last_date)) -gt 72000 ]]
            ;;
        "weekly")
            # Generate if more than 6 days ago
            [[ $((current_date - last_date)) -gt 518400 ]]
            ;;
        "monthly")
            # Generate if more than 25 days ago
            [[ $((current_date - last_date)) -gt 2160000 ]]
            ;;
        *)
            return 0
            ;;
    esac
}

# Generate daily report
generate_daily_report() {
    local output_file="$1"
    
    # Get yesterday's data
    local yesterday=$(date -d "1 day ago" +%Y-%m-%d)
    local report_data=$(generate_metrics_report "daily" "/tmp/daily_metrics.json")
    
    # Generate HTML report
    cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Daily Dotfiles Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; color: #333; }
        .header { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .metric-card { background: white; border: 1px solid #e9ecef; border-radius: 8px; padding: 15px; margin: 10px 0; }
        .metric-value { font-size: 24px; font-weight: bold; color: #28a745; }
        .metric-label { color: #6c757d; font-size: 14px; }
        .alert-high { color: #dc3545; }
        .alert-medium { color: #ffc107; }
        .chart-container { width: 100%; height: 200px; background: #f8f9fa; border-radius: 4px; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #e9ecef; color: #6c757d; font-size: 12px; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid #e9ecef; }
        th { background: #f8f9fa; font-weight: 600; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 Daily Dotfiles Report</h1>
        <p>Report generated: $(date)</p>
        <p>Data period: $(date -d "1 day ago" +%Y-%m-%d)</p>
    </div>

    <h2>System Performance</h2>
EOF
    
    # Add system metrics
    local latest_system=$(get_latest_system_metrics)
    if [[ "$latest_system" != "null" ]]; then
        local cpu=$(echo "$latest_system" | jq -r '.cpu_usage // "N/A"')
        local memory=$(echo "$latest_system" | jq -r '.memory_usage // "N/A"')
        local disk=$(echo "$latest_system" | jq -r '.disk_usage // "N/A"')
        
        cat >> "$output_file" << EOF
    <div class="metric-card">
        <div class="metric-value">$cpu%</div>
        <div class="metric-label">Average CPU Usage</div>
    </div>
    <div class="metric-card">
        <div class="metric-value">$memory%</div>
        <div class="metric-label">Average Memory Usage</div>
    </div>
    <div class="metric-card">
        <div class="metric-value">$disk%</div>
        <div class="metric-label">Disk Usage</div>
    </div>
EOF
    fi
    
    # Add command statistics
    cat >> "$output_file" << 'EOF'
    <h2>Command Statistics</h2>
    <table>
        <thead>
            <tr>
                <th>Command</th>
                <th>Count</th>
                <th>Avg Duration</th>
                <th>Success Rate</th>
            </tr>
        </thead>
        <tbody>
EOF
    
    # Add top commands
    local command_stats=$(generate_command_statistics)
    if [[ "$command_stats" != "null" && "$command_stats" != "" ]]; then
        echo "$command_stats" | jq -r '.[:10][] | "<tr><td>\(.command[0:30])</td><td>\(.count)</td><td>\(.avg_duration)ms</td><td>\(.success_rate)%</td></tr>"' >> "$output_file" 2>/dev/null || true
    fi
    
    cat >> "$output_file" << 'EOF'
        </tbody>
    </table>

    <div class="footer">
        <p>Generated by Dotfiles Metrics Reporter</p>
        <p>To disable these reports, run: dot metrics config reporting daily false</p>
    </div>
</body>
</html>
EOF
}

# Generate weekly report
generate_weekly_report() {
    local output_file="$1"
    
    echo "📊 Generating comprehensive weekly report..."
    
    # Get week's data
    local week_start=$(date -d "1 week ago" +%Y-%m-%d)
    local week_end=$(date +%Y-%m-%d)
    
    # Generate comprehensive HTML report with trends
    cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Weekly Dotfiles Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; color: #333; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px; }
        .metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background: white; border: 1px solid #e9ecef; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric-value { font-size: 32px; font-weight: bold; color: #28a745; margin-bottom: 5px; }
        .metric-label { color: #6c757d; font-size: 14px; }
        .trend-up { color: #28a745; }
        .trend-down { color: #dc3545; }
        .section { margin: 30px 0; }
        .chart-placeholder { background: #f8f9fa; height: 200px; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #6c757d; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e9ecef; }
        th { background: #f8f9fa; font-weight: 600; }
        .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #e9ecef; color: #6c757d; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>📈 Weekly Dotfiles Performance Report</h1>
        <p>Week ending: $(date)</p>
        <p>Analysis period: $week_start to $week_end</p>
    </div>
EOF
    
    # Add weekly metrics
    local total_commands=$(get_total_commands)
    local total_errors=$(get_total_errors)
    local success_rate=$(calculate_success_rate "$total_commands" "$total_errors")
    
    cat >> "$output_file" << EOF
    <div class="metric-grid">
        <div class="metric-card">
            <div class="metric-value">$total_commands</div>
            <div class="metric-label">Total Commands This Week</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">$success_rate%</div>
            <div class="metric-label">Success Rate</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">$(get_shell_startup_time)</div>
            <div class="metric-label">Avg Shell Startup (ms)</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">$(get_metrics_data_size)</div>
            <div class="metric-label">Data Storage Used</div>
        </div>
    </div>

    <div class="section">
        <h2>🎯 Key Insights</h2>
        <ul>
            <li>Most active day: $(get_most_active_day)</li>
            <li>Peak usage time: $(get_peak_usage_time)</li>
            <li>Most used command: $(get_most_used_command)</li>
            <li>Performance trend: $(get_performance_trend)</li>
        </ul>
    </div>

    <div class="section">
        <h2>📊 Command Analysis</h2>
        <table>
            <thead>
                <tr>
                    <th>Command</th>
                    <th>Weekly Usage</th>
                    <th>Avg Duration</th>
                    <th>Success Rate</th>
                    <th>Trend</th>
                </tr>
            </thead>
            <tbody>
EOF
    
    # Add command analysis
    local command_stats=$(generate_command_statistics)
    if [[ "$command_stats" != "null" && "$command_stats" != "" ]]; then
        echo "$command_stats" | jq -r '.[:15][] | "<tr><td>\(.command[0:25])</td><td>\(.count)</td><td>\(.avg_duration)ms</td><td>\(.success_rate)%</td><td>📈</td></tr>"' >> "$output_file" 2>/dev/null || true
    fi
    
    cat >> "$output_file" << 'EOF'
            </tbody>
        </table>
    </div>

    <div class="section">
        <h2>🔧 Recommendations</h2>
        <div id="recommendations">
            <!-- Dynamic recommendations will be added here -->
        </div>
    </div>

    <div class="footer">
        <p>Generated by Dotfiles Metrics Reporter</p>
        <p>For detailed analysis, run: dot metrics dashboard</p>
    </div>
</body>
</html>
EOF
}

# Generate monthly report
generate_monthly_report() {
    local output_file="$1"
    
    echo "📊 Generating comprehensive monthly report..."
    
    # Similar structure to weekly but with monthly data
    # This would include trend analysis, performance comparisons, etc.
    cp "$output_file" "${output_file}.template" # Placeholder for now
    sed 's/Weekly/Monthly/g' "${output_file}.template" > "$output_file"
    rm "${output_file}.template"
}

# Check system health and send alerts
check_system_health() {
    echo "🏥 Checking system health for alerts..."
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  jq not available, skipping health checks"
        return 1
    fi
    
    # Load alert configuration
    local alert_config=$(jq '.alerts' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_ALERT_THRESHOLDS")
    local alerts_enabled=$(echo "$alert_config" | jq -r '.enabled // true')
    
    if [[ "$alerts_enabled" != "true" ]]; then
        echo "ℹ️  Alerts disabled, skipping"
        return 0
    fi
    
    local alerts_triggered=()
    
    # Check system metrics
    local latest_system=$(get_latest_system_metrics)
    if [[ "$latest_system" != "null" ]]; then
        check_cpu_alert "$latest_system" alerts_triggered
        check_memory_alert "$latest_system" alerts_triggered  
        check_disk_alert "$latest_system" alerts_triggered
    fi
    
    # Check command metrics
    check_error_rate_alert alerts_triggered
    check_performance_alert alerts_triggered
    
    # Send alerts if any triggered
    if [[ ${#alerts_triggered[@]} -gt 0 ]]; then
        send_alerts "${alerts_triggered[@]}"
    else
        echo "✅ All systems healthy"
    fi
}

# Check CPU usage alert
check_cpu_alert() {
    local system_data="$1"
    local -n alerts_ref=$2
    
    local cpu_usage=$(echo "$system_data" | jq -r '.cpu_usage // "0"')
    local cpu_threshold=$(jq -r '.alerts.thresholds.cpu_usage // 85' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "85")
    
    if [[ $(echo "$cpu_usage > $cpu_threshold" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        alerts_ref+=("cpu_high:CPU usage at ${cpu_usage}% (threshold: ${cpu_threshold}%)")
    fi
}

# Check memory usage alert
check_memory_alert() {
    local system_data="$1"
    local -n alerts_ref=$2
    
    local memory_usage=$(echo "$system_data" | jq -r '.memory_usage // "0"')
    local memory_threshold=$(jq -r '.alerts.thresholds.memory_usage // 90' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "90")
    
    if [[ $(echo "$memory_usage > $memory_threshold" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        alerts_ref+=("memory_high:Memory usage at ${memory_usage}% (threshold: ${memory_threshold}%)")
    fi
}

# Check disk usage alert
check_disk_alert() {
    local system_data="$1"
    local -n alerts_ref=$2
    
    local disk_usage=$(echo "$system_data" | jq -r '.disk_usage // "0"')
    local disk_threshold=$(jq -r '.alerts.thresholds.disk_usage // 95' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "95")
    
    if [[ $(echo "$disk_usage > $disk_threshold" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        alerts_ref+=("disk_high:Disk usage at ${disk_usage}% (threshold: ${disk_threshold}%)")
    fi
}

# Check error rate alert
check_error_rate_alert() {
    local -n alerts_ref=$1
    
    local total_commands=$(get_total_commands)
    local total_errors=$(get_total_errors)
    
    if [[ $total_commands -gt 0 ]]; then
        local error_rate=$(echo "scale=1; ($total_errors * 100) / $total_commands" | bc -l 2>/dev/null || echo "0")
        local error_threshold=$(jq -r '.alerts.thresholds.error_rate // 10' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "10")
        
        if [[ $(echo "$error_rate > $error_threshold" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
            alerts_ref+=("error_rate_high:Command error rate at ${error_rate}% (threshold: ${error_threshold}%)")
        fi
    fi
}

# Check performance alert
check_performance_alert() {
    local -n alerts_ref=$1
    
    local startup_time=$(get_shell_startup_time)
    if [[ "$startup_time" != "null" ]]; then
        local startup_threshold=$(jq -r '.alerts.thresholds.shell_startup_time // 1000' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "1000")
        
        if [[ $(echo "$startup_time > $startup_threshold" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
            alerts_ref+=("performance_slow:Shell startup time ${startup_time}ms (threshold: ${startup_threshold}ms)")
        fi
    fi
}

# Send alerts
send_alerts() {
    local alerts=("$@")
    
    echo "🚨 Sending ${#alerts[@]} alerts..."
    
    # Check cooldown
    if is_alert_in_cooldown; then
        echo "ℹ️  Alert cooldown active, skipping notifications"
        return 0
    fi
    
    local alert_config=$(jq '.alerts.channels' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo '{"desktop": true, "log": true}')
    
    # Desktop notification
    if [[ $(echo "$alert_config" | jq -r '.desktop // true') == "true" ]]; then
        send_desktop_alert "${alerts[@]}"
    fi
    
    # Log alert
    if [[ $(echo "$alert_config" | jq -r '.log // true') == "true" ]]; then
        send_log_alert "${alerts[@]}"
    fi
    
    # Email alert
    if [[ $(echo "$alert_config" | jq -r '.email // false') == "true" ]]; then
        send_email_alert "${alerts[@]}"
    fi
    
    # Webhook alert
    if [[ $(echo "$alert_config" | jq -r '.webhook // false') == "true" ]]; then
        send_webhook_alert "${alerts[@]}"
    fi
    
    # Update alert state
    update_alert_state
}

# Send desktop notification
send_desktop_alert() {
    local alerts=("$@")
    
    local title="Dotfiles System Alert"
    local message="⚠️ ${#alerts[@]} system issues detected"
    
    # Try different notification methods
    if command -v osascript >/dev/null 2>&1; then
        # macOS notification
        osascript -e "display notification \"$message\" with title \"$title\""
    elif command -v notify-send >/dev/null 2>&1; then
        # Linux notification
        notify-send "$title" "$message"
    else
        echo "🔔 Desktop notification: $title - $message"
    fi
}

# Send log alert
send_log_alert() {
    local alerts=("$@")
    
    local log_file="$METRICS_DIR/alerts.log"
    local timestamp=$(date)
    
    echo "[$timestamp] ALERT: ${#alerts[@]} issues detected" >> "$log_file"
    for alert in "${alerts[@]}"; do
        echo "[$timestamp] - $alert" >> "$log_file"
    done
    echo "[$timestamp] ---" >> "$log_file"
}

# Check if alert is in cooldown
is_alert_in_cooldown() {
    if ! command -v jq >/dev/null 2>&1; then
        return 1
    fi
    
    local last_alert=$(jq -r '.alerts.last_sent // null' "$REPORTER_STATE_FILE" 2>/dev/null || echo "null")
    local cooldown_minutes=$(jq -r '.alerts.cooldown_minutes // 30' "$REPORTER_CONFIG_FILE" 2>/dev/null || echo "30")
    
    if [[ "$last_alert" == "null" ]]; then
        return 1
    fi
    
    local current_time=$(date +%s)
    local last_alert_time=$(date -d "$last_alert" +%s 2>/dev/null || echo "0")
    local cooldown_seconds=$((cooldown_minutes * 60))
    
    [[ $((current_time - last_alert_time)) -lt $cooldown_seconds ]]
}

# Update alert state
update_alert_state() {
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".alerts.last_sent = \"$(date -Iseconds)\"" "$REPORTER_STATE_FILE" > "$temp_file"
        mv "$temp_file" "$REPORTER_STATE_FILE"
    fi
}

# Update report state
update_report_state() {
    local report_type="$1"
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".reports.${report_type}.last_generated = \"$(date -Iseconds)\"" "$REPORTER_STATE_FILE" > "$temp_file"
        mv "$temp_file" "$REPORTER_STATE_FILE"
    fi
}

# Send report notification
send_report_notification() {
    local report_type="$1"
    local report_file="$2"
    
    local title="Dotfiles $report_type Report Ready"
    local message="Report generated: $(basename "$report_file")"
    
    # Desktop notification
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$message\" with title \"$title\""
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message"
    fi
}

# Helper functions for report data
get_most_active_day() {
    echo "$(date -d "2 days ago" +%A)"  # Placeholder
}

get_peak_usage_time() {
    echo "14:00-15:00"  # Placeholder
}

get_most_used_command() {
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        local top_command=$(jq -r '.metrics.commands | group_by(.command) | map({command: .[0].command, count: length}) | sort_by(.count) | reverse | .[0].command // "N/A"' "$METRICS_DATA_FILE" 2>/dev/null || echo "N/A")
        echo "$top_command"
    else
        echo "N/A"
    fi
}

get_performance_trend() {
    echo "Stable"  # Placeholder - would compare with previous periods
}

# Main CLI interface
reporter_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "init"|"initialize")
            init_reporter
            ;;
        "report")
            local type="${1:-daily}"
            local force="${2:-false}"
            generate_automated_report "$type" "$force"
            ;;
        "alerts"|"check")
            check_system_health
            ;;
        "schedule")
            setup_reporting_schedule "$@"
            ;;
        "config")
            configure_reporter "$@"
            ;;
        "status")
            show_reporter_status
            ;;
        "test")
            test_reporter_system "$@"
            ;;
        "help"|"")
            show_reporter_help
            ;;
        *)
            echo "❌ Unknown reporter command: $command"
            echo "Run 'dot metrics reporter help' for available commands"
            return 1
            ;;
    esac
}

# Show reporter help
show_reporter_help() {
    cat << 'EOF'
📊 Automated Metrics Reporting and Alerting

USAGE:
    dot metrics reporter <command> [options]

COMMANDS:
    init                Initialize reporter system
    report [type]       Generate report (daily, weekly, monthly)
    alerts             Check system health and send alerts
    schedule           Setup automated reporting schedule
    config [setting]   Configure reporter settings
    status             Show reporter status
    test               Test reporter functionality
    help               Show this help

EXAMPLES:
    # Setup
    dot metrics reporter init
    
    # Generate reports
    dot metrics reporter report daily
    dot metrics reporter report weekly --force
    
    # Check for alerts
    dot metrics reporter alerts
    
    # Configure
    dot metrics reporter config alerts enabled true
    dot metrics reporter config reports daily_summary enabled true

CONFIGURATION:
    Config file: ~/.config/dotfiles/metrics/reporter.json
    Reports: ~/.local/share/dotfiles/metrics/reports/automated/

For more information: https://docs.dotfiles.dev/metrics/reporting
EOF
}

# Main entry point for reporter
main() {
    reporter_cli "$@"
}

# Export functions
export -f init_reporter generate_automated_report check_system_health reporter_cli

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi