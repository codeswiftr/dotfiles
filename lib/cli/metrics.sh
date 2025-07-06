#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Metrics Management
# Metrics collection and analytics command interface
# ============================================================================

# Load metrics system
source "$DOTFILES_DIR/lib/metrics.sh"

# Metrics command dispatcher
dot_metrics() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        "init"|"initialize"|"setup")
            metrics_cli "init" "$@"
            ;;
        "collect"|"gather")
            metrics_cli "collect" "$@"
            ;;
        "daemon"|"service")
            metrics_cli "daemon" "$@"
            ;;
        "report"|"generate")
            metrics_cli "report" "$@"
            ;;
        "dashboard"|"show"|"view")
            metrics_cli "dashboard" "$@"
            ;;
        "export"|"backup")
            metrics_cli "export" "$@"
            ;;
        "clean"|"cleanup"|"purge")
            metrics_cli "clean" "$@"
            ;;
        "status"|"info")
            show_metrics_status
            ;;
        "config"|"configure")
            configure_metrics_system "$@"
            ;;
        "doctor"|"health")
            metrics_system_doctor
            ;;
        "test"|"benchmark")
            run_metrics_tests "$@"
            ;;
        "-h"|"--help"|"help"|"")
            show_metrics_help
            ;;
        *)
            print_error "Unknown metrics subcommand: $subcommand"
            echo "Run 'dot metrics --help' for available commands."
            return 1
            ;;
    esac
}

# Show metrics system status
show_metrics_status() {
    echo "📊 Metrics System Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # System information
    echo "Data Directory: $METRICS_DIR"
    echo "Config Directory: $METRICS_CONFIG_DIR"
    echo "Data File: $METRICS_DATA_FILE"
    echo ""
    
    # Check if system is initialized
    if [[ -f "$METRICS_DATA_FILE" ]]; then
        echo "Status: ✅ Initialized"
    else
        echo "Status: ❌ Not initialized"
        echo "Run 'dot metrics init' to initialize the metrics system"
        return 1
    fi
    
    # Collection status
    if command -v jq >/dev/null 2>&1 && [[ -f "$METRICS_CONFIG_FILE" ]]; then
        local collection_enabled=$(jq -r '.collection.enabled' "$METRICS_CONFIG_FILE" 2>/dev/null || echo "unknown")
        local collection_interval=$(jq -r '.collection.interval' "$METRICS_CONFIG_FILE" 2>/dev/null || echo "unknown")
        local retention_days=$(jq -r '.collection.retention_days' "$METRICS_CONFIG_FILE" 2>/dev/null || echo "unknown")
        
        echo "Collection Settings:"
        echo "  Enabled: $collection_enabled"
        echo "  Interval: ${collection_interval}s"
        echo "  Retention: $retention_days days"
        echo ""
    fi
    
    # Daemon status
    local pid_file="$METRICS_DIR/daemon.pid"
    if [[ -f "$pid_file" ]] && ps -p "$(cat "$pid_file")" >/dev/null 2>&1; then
        echo "Daemon Status: ✅ Running (PID: $(cat "$pid_file"))"
    else
        echo "Daemon Status: ❌ Not running"
    fi
    
    # Data statistics
    if command -v jq >/dev/null 2>&1 && [[ -f "$METRICS_DATA_FILE" ]]; then
        local total_commands=$(jq '.statistics.total_commands' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)
        local total_errors=$(jq '.statistics.total_errors' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)
        local last_collection=$(jq -r '.statistics.last_collection' "$METRICS_DATA_FILE" 2>/dev/null || echo "never")
        
        echo ""
        echo "Data Statistics:"
        echo "  Total Commands: $total_commands"
        echo "  Total Errors: $total_errors"
        echo "  Last Collection: $last_collection"
        
        # Data size
        if [[ -d "$METRICS_DIR" ]]; then
            local data_size=$(du -sh "$METRICS_DIR" 2>/dev/null | cut -f1 || echo "unknown")
            echo "  Storage Usage: $data_size"
        fi
    fi
    
    # Category status
    echo ""
    echo "Collection Categories:"
    if command -v jq >/dev/null 2>&1 && [[ -f "$METRICS_CONFIG_FILE" ]]; then
        local categories=("system" "commands" "performance" "usage")
        for category in "${categories[@]}"; do
            local enabled=$(jq -r ".categories.$category.enabled" "$METRICS_CONFIG_FILE" 2>/dev/null || echo "unknown")
            local count=$(jq ".metrics.$category | length" "$METRICS_DATA_FILE" 2>/dev/null || echo 0)
            echo "  $category: $enabled ($count records)"
        done
    fi
    
    # Health check
    echo ""
    echo "Health Check:"
    
    # Check required directories
    if [[ -d "$METRICS_DIR" ]]; then
        echo "  ✅ Data directory exists"
    else
        echo "  ❌ Data directory missing"
    fi
    
    if [[ -d "$METRICS_CONFIG_DIR" ]]; then
        echo "  ✅ Config directory exists"
    else
        echo "  ❌ Config directory missing"
    fi
    
    # Check permissions
    if [[ -w "$METRICS_DIR" ]]; then
        echo "  ✅ Data directory writable"
    else
        echo "  ❌ Data directory not writable"
    fi
    
    # Check required tools
    local required_tools=("jq" "awk" "ps")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ❌ $tool not found"
        fi
    done
}

# Configure metrics system
configure_metrics_system() {
    local setting="${1:-}"
    local value="${2:-}"
    
    if [[ -z "$setting" ]]; then
        show_metrics_config
        return
    fi
    
    echo "⚙️  Configuring metrics system: $setting"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq required for configuration management"
        return 1
    fi
    
    if [[ ! -f "$METRICS_CONFIG_FILE" ]]; then
        echo "❌ Metrics system not initialized"
        return 1
    fi
    
    case "$setting" in
        "collection")
            configure_collection_settings "$value" "$3"
            ;;
        "retention")
            configure_retention_settings "$value"
            ;;
        "categories")
            configure_category_settings "$value" "$3"
            ;;
        "privacy")
            configure_privacy_settings "$value" "$3"
            ;;
        "reporting")
            configure_reporting_settings "$value" "$3"
            ;;
        *)
            echo "❌ Unknown setting: $setting"
            echo "Available settings: collection, retention, categories, privacy, reporting"
            ;;
    esac
}

# Show metrics configuration
show_metrics_config() {
    echo "⚙️  Metrics System Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq required to display configuration"
        return 1
    fi
    
    if [[ ! -f "$METRICS_CONFIG_FILE" ]]; then
        echo "❌ Metrics system not initialized"
        return 1
    fi
    
    echo "Collection Settings:"
    local enabled=$(jq -r '.collection.enabled' "$METRICS_CONFIG_FILE")
    local interval=$(jq -r '.collection.interval' "$METRICS_CONFIG_FILE")
    local retention=$(jq -r '.collection.retention_days' "$METRICS_CONFIG_FILE")
    echo "  Enabled: $enabled"
    echo "  Interval: ${interval}s"
    echo "  Retention: $retention days"
    echo ""
    
    echo "Category Settings:"
    local categories=("system" "commands" "performance" "usage")
    for category in "${categories[@]}"; do
        local cat_enabled=$(jq -r ".categories.$category.enabled" "$METRICS_CONFIG_FILE")
        echo "  $category: $cat_enabled"
    done
    echo ""
    
    echo "Privacy Settings:"
    local collect_personal=$(jq -r '.privacy.collect_personal_data' "$METRICS_CONFIG_FILE")
    local anonymize_paths=$(jq -r '.privacy.anonymize_paths' "$METRICS_CONFIG_FILE")
    echo "  Collect personal data: $collect_personal"
    echo "  Anonymize paths: $anonymize_paths"
    echo ""
    
    echo "Reporting Settings:"
    local daily_summary=$(jq -r '.reporting.daily_summary' "$METRICS_CONFIG_FILE")
    local weekly_report=$(jq -r '.reporting.weekly_report' "$METRICS_CONFIG_FILE")
    local export_format=$(jq -r '.reporting.export_format' "$METRICS_CONFIG_FILE")
    echo "  Daily summary: $daily_summary"
    echo "  Weekly report: $weekly_report"
    echo "  Export format: $export_format"
}

# Configure collection settings
configure_collection_settings() {
    local property="$1"
    local value="$2"
    
    case "$property" in
        "enabled")
            if [[ "$value" =~ ^(true|false|on|off|yes|no)$ ]]; then
                local bool_value
                case "$value" in
                    true|on|yes) bool_value="true" ;;
                    false|off|no) bool_value="false" ;;
                esac
                
                jq ".collection.enabled = $bool_value" "$METRICS_CONFIG_FILE" > "${METRICS_CONFIG_FILE}.tmp"
                mv "${METRICS_CONFIG_FILE}.tmp" "$METRICS_CONFIG_FILE"
                echo "✅ Collection enabled set to: $bool_value"
            else
                echo "❌ Invalid value: $value"
                echo "Valid options: true, false, on, off, yes, no"
            fi
            ;;
        "interval")
            if [[ "$value" =~ ^[0-9]+$ ]]; then
                jq ".collection.interval = $value" "$METRICS_CONFIG_FILE" > "${METRICS_CONFIG_FILE}.tmp"
                mv "${METRICS_CONFIG_FILE}.tmp" "$METRICS_CONFIG_FILE"
                echo "✅ Collection interval set to: ${value}s"
            else
                echo "❌ Invalid interval: $value"
                echo "Must be a number in seconds"
            fi
            ;;
        "retention")
            if [[ "$value" =~ ^[0-9]+$ ]]; then
                jq ".collection.retention_days = $value" "$METRICS_CONFIG_FILE" > "${METRICS_CONFIG_FILE}.tmp"
                mv "${METRICS_CONFIG_FILE}.tmp" "$METRICS_CONFIG_FILE"
                echo "✅ Retention period set to: $value days"
            else
                echo "❌ Invalid retention period: $value"
                echo "Must be a number in days"
            fi
            ;;
        *)
            echo "❌ Unknown collection property: $property"
            echo "Valid properties: enabled, interval, retention"
            ;;
    esac
}

# Configure category settings
configure_category_settings() {
    local category="$1"
    local enabled="$2"
    
    if [[ ! "$category" =~ ^(system|commands|performance|usage)$ ]]; then
        echo "❌ Invalid category: $category"
        echo "Valid categories: system, commands, performance, usage"
        return 1
    fi
    
    if [[ "$enabled" =~ ^(true|false|on|off|yes|no)$ ]]; then
        local bool_value
        case "$enabled" in
            true|on|yes) bool_value="true" ;;
            false|off|no) bool_value="false" ;;
        esac
        
        jq ".categories.$category.enabled = $bool_value" "$METRICS_CONFIG_FILE" > "${METRICS_CONFIG_FILE}.tmp"
        mv "${METRICS_CONFIG_FILE}.tmp" "$METRICS_CONFIG_FILE"
        echo "✅ Category $category enabled set to: $bool_value"
    else
        echo "❌ Invalid value: $enabled"
        echo "Valid options: true, false, on, off, yes, no"
    fi
}

# Metrics system doctor
metrics_system_doctor() {
    echo "🏥 Metrics System Doctor"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running comprehensive metrics system health check..."
    echo ""
    
    local issues=0
    
    # Check system requirements
    echo "🔍 Checking system requirements..."
    
    # Check required tools
    local required_tools=("jq" "awk" "ps" "date")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ❌ $tool not found"
            ((issues++))
        fi
    done
    
    # Check optional tools
    echo ""
    echo "🔍 Checking optional tools..."
    local optional_tools=("top" "free" "vm_stat" "df" "uptime")
    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✅ $tool available"
        else
            echo "  ⚠️  $tool not found (limited functionality)"
        fi
    done
    
    # Check directory structure
    echo ""
    echo "🔍 Checking directory structure..."
    local required_dirs=("$METRICS_DIR" "$METRICS_CONFIG_DIR" "$METRICS_HISTORY_DIR" "$METRICS_REPORTS_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "  ✅ $(basename "$dir"): $dir"
        else
            echo "  ❌ Missing directory: $dir"
            ((issues++))
        fi
    done
    
    # Check permissions
    echo ""
    echo "🔍 Checking permissions..."
    if [[ -w "$METRICS_DIR" ]]; then
        echo "  ✅ Data directory writable"
    else
        echo "  ❌ Data directory not writable"
        ((issues++))
    fi
    
    if [[ -w "$METRICS_CONFIG_DIR" ]]; then
        echo "  ✅ Config directory writable"
    else
        echo "  ❌ Config directory not writable"
        ((issues++))
    fi
    
    # Check configuration files
    echo ""
    echo "🔍 Checking configuration files..."
    if [[ -f "$METRICS_CONFIG_FILE" ]]; then
        echo "  ✅ Config file exists"
        
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$METRICS_CONFIG_FILE" >/dev/null 2>&1; then
                echo "  ✅ Config format valid"
            else
                echo "  ❌ Config format invalid"
                ((issues++))
            fi
        fi
    else
        echo "  ❌ Config file missing"
        ((issues++))
    fi
    
    if [[ -f "$METRICS_DATA_FILE" ]]; then
        echo "  ✅ Data file exists"
        
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$METRICS_DATA_FILE" >/dev/null 2>&1; then
                echo "  ✅ Data format valid"
            else
                echo "  ❌ Data format invalid"
                ((issues++))
            fi
        fi
    else
        echo "  ❌ Data file missing"
        ((issues++))
    fi
    
    # Check disk space
    echo ""
    echo "🔍 Checking disk space..."
    if [[ -d "$METRICS_DIR" ]]; then
        local available_space=$(df "$METRICS_DIR" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
        local available_mb=$((available_space / 1024))
        
        if [[ $available_mb -gt 100 ]]; then
            echo "  ✅ Sufficient disk space: ${available_mb}MB available"
        else
            echo "  ⚠️  Low disk space: ${available_mb}MB available"
        fi
    fi
    
    # Check daemon status
    echo ""
    echo "🔍 Checking daemon status..."
    local pid_file="$METRICS_DIR/daemon.pid"
    if [[ -f "$pid_file" ]]; then
        local daemon_pid=$(cat "$pid_file")
        if ps -p "$daemon_pid" >/dev/null 2>&1; then
            echo "  ✅ Daemon running (PID: $daemon_pid)"
        else
            echo "  ⚠️  Daemon PID file exists but process not running"
            rm -f "$pid_file"
        fi
    else
        echo "  ℹ️  Daemon not running"
    fi
    
    # Test data collection
    echo ""
    echo "🔍 Testing data collection..."
    if collect_system_metrics >/dev/null 2>&1; then
        echo "  ✅ System metrics collection works"
    else
        echo "  ❌ System metrics collection failed"
        ((issues++))
    fi
    
    # Summary
    echo ""
    echo "📋 Health Check Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Metrics system is healthy!"
        echo ""
        echo "🎯 Recommendations:"
        echo "  • Start metrics collection: dot metrics daemon start"
        echo "  • Generate your first report: dot metrics report"
        echo "  • View dashboard: dot metrics dashboard"
    else
        echo "❌ Found $issues issues that need attention"
        echo ""
        echo "🔧 Recommendations:"
        if [[ ! -f "$METRICS_DATA_FILE" ]]; then
            echo "  • Initialize metrics system: dot metrics init"
        fi
        if [[ ! -d "$METRICS_DIR" ]]; then
            echo "  • Create data directory: mkdir -p $METRICS_DIR"
        fi
        echo "  • Install missing required tools"
        echo "  • Fix permission issues if any"
        echo "  • Check available disk space"
    fi
}

# Run metrics tests
run_metrics_tests() {
    local test_type="${1:-basic}"
    
    echo "🧪 Running metrics system tests..."
    
    case "$test_type" in
        "basic")
            run_basic_metrics_tests
            ;;
        "collection")
            run_collection_tests
            ;;
        "performance")
            run_performance_tests
            ;;
        "all")
            run_basic_metrics_tests
            run_collection_tests
            run_performance_tests
            ;;
        *)
            echo "❌ Unknown test type: $test_type"
            echo "Available tests: basic, collection, performance, all"
            return 1
            ;;
    esac
}

# Run basic metrics tests
run_basic_metrics_tests() {
    echo "🔍 Running basic functionality tests..."
    
    local tests_passed=0
    local tests_total=5
    
    # Test 1: System initialization
    echo "  Test 1: System initialization"
    if init_metrics_system >/dev/null 2>&1; then
        echo "    ✅ PASSED"
        ((tests_passed++))
    else
        echo "    ❌ FAILED"
    fi
    
    # Test 2: Configuration loading
    echo "  Test 2: Configuration loading"
    if [[ -f "$METRICS_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1 && jq empty "$METRICS_CONFIG_FILE" >/dev/null 2>&1; then
        echo "    ✅ PASSED"
        ((tests_passed++))
    else
        echo "    ❌ FAILED"
    fi
    
    # Test 3: Data file creation
    echo "  Test 3: Data file creation"
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1 && jq empty "$METRICS_DATA_FILE" >/dev/null 2>&1; then
        echo "    ✅ PASSED"
        ((tests_passed++))
    else
        echo "    ❌ FAILED"
    fi
    
    # Test 4: System metrics collection
    echo "  Test 4: System metrics collection"
    if collect_system_metrics >/dev/null 2>&1; then
        echo "    ✅ PASSED"
        ((tests_passed++))
    else
        echo "    ❌ FAILED"
    fi
    
    # Test 5: Report generation
    echo "  Test 5: Report generation"
    local test_report="/tmp/test-metrics-report.json"
    if generate_metrics_report "daily" "$test_report" >/dev/null 2>&1 && [[ -f "$test_report" ]]; then
        echo "    ✅ PASSED"
        ((tests_passed++))
        rm -f "$test_report"
    else
        echo "    ❌ FAILED"
    fi
    
    echo ""
    echo "Basic tests result: $tests_passed/$tests_total passed"
}

# Run collection tests
run_collection_tests() {
    echo "🔍 Running collection tests..."
    
    # Test command metrics collection
    echo "  Test: Command metrics collection"
    if collect_command_metrics "test-command" "1000" "0" >/dev/null 2>&1; then
        echo "    ✅ PASSED"
    else
        echo "    ❌ FAILED"
    fi
    
    # Test performance metrics collection
    echo "  Test: Performance metrics collection"
    if collect_performance_metrics "test-operation" "1000" "2000" >/dev/null 2>&1; then
        echo "    ✅ PASSED"
    else
        echo "    ❌ FAILED"
    fi
    
    # Test usage metrics collection
    echo "  Test: Usage metrics collection"
    if collect_usage_metrics "test-feature" "test-action" "{}" >/dev/null 2>&1; then
        echo "    ✅ PASSED"
    else
        echo "    ❌ FAILED"
    fi
}

# Run performance tests
run_performance_tests() {
    echo "🔍 Running performance tests..."
    
    # Test collection speed
    echo "  Test: Collection speed"
    local start_time=$(date +%s%N)
    for i in {1..10}; do
        collect_system_metrics >/dev/null 2>&1
    done
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000))
    
    echo "    10 collections in ${duration}ms"
    if [[ $duration -lt 10000 ]]; then
        echo "    ✅ PASSED (< 10s)"
    else
        echo "    ⚠️  SLOW (> 10s)"
    fi
}

# Export functions
export -f dot_metrics show_metrics_status configure_metrics_system
export -f metrics_system_doctor run_metrics_tests