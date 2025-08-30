#!/usr/bin/env bash
# ============================================================================
# Metrics Data Export and Integration API
# REST-like API for metrics data export and external integrations
# ============================================================================

# Load metrics system
source "${DOTFILES_DIR}/lib/metrics.sh"

# API configuration
API_VERSION="v1"
API_BASE_PATH="/api/$API_VERSION"
API_PORT="${METRICS_API_PORT:-8080}"
API_HOST="${METRICS_API_HOST:-127.0.0.1}"
API_AUTH_TOKEN="${METRICS_API_TOKEN:-}"
API_LOG_FILE="${METRICS_DIR}/api.log"

# Export formats
SUPPORTED_FORMATS=("json" "csv" "xml" "yaml" "prometheus" "influxdb" "grafana")

# Start metrics API server
start_api_server() {
    echo "🚀 Starting Metrics API server..."
    
    local port="${1:-$API_PORT}"
    local host="${2:-$API_HOST}"
    
    # Check if port is available
    if netstat -ln 2>/dev/null | grep -q ":${port} "; then
        echo "❌ Port $port is already in use"
        return 1
    fi
    
    echo "📡 Starting server on $host:$port"
    echo "🔗 API endpoints available at http://$host:$port$API_BASE_PATH"
    
    # Simple HTTP server using netcat or socat
    if command -v socat >/dev/null 2>&1; then
        start_socat_server "$host" "$port"
    elif command -v nc >/dev/null 2>&1; then
        start_netcat_server "$host" "$port"
    else
        echo "❌ Neither socat nor netcat available for HTTP server"
        echo "Please install socat or netcat to run the API server"
        return 1
    fi
}

# Start server with socat
start_socat_server() {
    local host="$1"
    local port="$2"
    
    while true; do
        echo "$(date): API server listening on $host:$port" >> "$API_LOG_FILE"
        socat TCP-LISTEN:"$port",bind="$host",fork,reuseaddr EXEC:"$0 handle_request"
    done
}

# Start server with netcat
start_netcat_server() {
    local host="$1"
    local port="$2"
    
    while true; do
        echo "$(date): API server listening on $host:$port" >> "$API_LOG_FILE"
        nc -l "$host" "$port" -c "$0 handle_request"
    done
}

# Handle HTTP request
handle_request() {
    local request_line
    local method path version
    local content_length=0
    local auth_header=""
    local accept_header="application/json"
    
    # Read request line
    read -r request_line
    read method path version <<< "$request_line"
    
    # Read headers
    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')
        [[ -z "$line" ]] && break
        
        if [[ "$line" =~ ^Content-Length:\ (.+)$ ]]; then
            content_length="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Authorization:\ (.+)$ ]]; then
            auth_header="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Accept:\ (.+)$ ]]; then
            accept_header="${BASH_REMATCH[1]}"
        fi
    done
    
    # Log request
    echo "$(date): $method $path" >> "$API_LOG_FILE"
    
    # Authentication check
    if [[ -n "$API_AUTH_TOKEN" ]] && [[ "$auth_header" != "Bearer $API_AUTH_TOKEN" ]]; then
        send_response "401" "Unauthorized" "application/json" '{"error": "Invalid or missing authentication token"}'
        return
    fi
    
    # Route request
    route_request "$method" "$path" "$accept_header"
}

# Route API requests
route_request() {
    local method="$1"
    local path="$2"
    local accept="$3"
    
    # Remove API base path
    path="${path#$API_BASE_PATH}"
    
    case "$method $path" in
        "GET /")
            api_root "$accept"
            ;;
        "GET /health")
            api_health "$accept"
            ;;
        "GET /metrics")
            api_metrics_list "$accept"
            ;;
        "GET /metrics/system")
            api_system_metrics "$accept"
            ;;
        "GET /metrics/commands")
            api_command_metrics "$accept"
            ;;
        "GET /metrics/performance")
            api_performance_metrics "$accept"
            ;;
        "GET /metrics/usage")
            api_usage_metrics "$accept"
            ;;
        "GET /export/"*)
            handle_export_request "$path" "$accept"
            ;;
        "GET /integrations/"*)
            handle_integration_request "$path" "$accept"
            ;;
        "POST /collect")
            api_collect_metrics "$accept"
            ;;
        "GET /reports")
            api_reports_list "$accept"
            ;;
        "GET /reports/"*)
            handle_report_request "$path" "$accept"
            ;;
        *)
            send_response "404" "Not Found" "application/json" '{"error": "Endpoint not found"}'
            ;;
    esac
}

# API root endpoint
api_root() {
    local accept="$1"
    local response='{
  "name": "Dotfiles Metrics API",
  "version": "'$API_VERSION'",
  "endpoints": {
    "health": "/health",
    "metrics": "/metrics",
    "system": "/metrics/system",
    "commands": "/metrics/commands", 
    "performance": "/metrics/performance",
    "usage": "/metrics/usage",
    "export": "/export/{format}",
    "integrations": "/integrations/{service}",
    "collect": "/collect",
    "reports": "/reports"
  },
  "supported_formats": ["json", "csv", "xml", "yaml", "prometheus"],
  "documentation": "https://docs.dotfiles.dev/metrics/api"
}'
    
    send_response "200" "OK" "application/json" "$response"
}

# Health check endpoint
api_health() {
    local accept="$1"
    local health_status="healthy"
    local issues=0
    
    # Check system health
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        health_status="unhealthy"
        ((issues++))
    fi
    
    if [[ ! -d "$METRICS_DIR" ]]; then
        health_status="unhealthy"
        ((issues++))
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        health_status="degraded"
        ((issues++))
    fi
    
    local response='{
  "status": "'$health_status'",
  "timestamp": "'$(date -Iseconds)'",
  "checks": {
    "data_file": '$(test -f "$METRICS_DATA_FILE" && echo "true" || echo "false")',
    "data_directory": '$(test -d "$METRICS_DIR" && echo "true" || echo "false")',
    "jq_available": '$(command -v jq >/dev/null && echo "true" || echo "false")'
  },
  "issues": '$issues'
}'
    
    if [[ "$health_status" == "healthy" ]]; then
        send_response "200" "OK" "application/json" "$response"
    else
        send_response "503" "Service Unavailable" "application/json" "$response"
    fi
}

# List available metrics
api_metrics_list() {
    local accept="$1"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        send_response "404" "Not Found" "application/json" '{"error": "No metrics data available"}'
        return
    fi
    
    local response='{
  "categories": {
    "system": {
      "count": '$(jq '.metrics.system | length' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)',
      "last_updated": '$(jq '.metrics.system[-1].timestamp // null' "$METRICS_DATA_FILE" 2>/dev/null || echo null)'
    },
    "commands": {
      "count": '$(jq '.metrics.commands | length' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)',
      "last_updated": '$(jq '.metrics.commands[-1].timestamp // null' "$METRICS_DATA_FILE" 2>/dev/null || echo null)'
    },
    "performance": {
      "count": '$(jq '.metrics.performance | length' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)',
      "last_updated": '$(jq '.metrics.performance[-1].timestamp // null' "$METRICS_DATA_FILE" 2>/dev/null || echo null)'
    },
    "usage": {
      "count": '$(jq '.metrics.usage | length' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)',
      "last_updated": '$(jq '.metrics.usage[-1].timestamp // null' "$METRICS_DATA_FILE" 2>/dev/null || echo null)'
    }
  },
  "total_records": '$(jq '.metrics | [.system, .commands, .performance, .usage] | map(length) | add' "$METRICS_DATA_FILE" 2>/dev/null || echo 0)',
  "collection_enabled": '$(jq '.collection.enabled // false' "$METRICS_CONFIG_FILE" 2>/dev/null || echo false)'
}'
    
    send_response "200" "OK" "application/json" "$response"
}

# Get system metrics
api_system_metrics() {
    local accept="$1"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        send_response "404" "Not Found" "application/json" '{"error": "No metrics data available"}'
        return
    fi
    
    local system_metrics=$(jq '.metrics.system' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    send_response "200" "OK" "application/json" "$system_metrics"
}

# Get command metrics
api_command_metrics() {
    local accept="$1"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        send_response "404" "Not Found" "application/json" '{"error": "No metrics data available"}'
        return
    fi
    
    local command_metrics=$(jq '.metrics.commands' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    send_response "200" "OK" "application/json" "$command_metrics"
}

# Get performance metrics
api_performance_metrics() {
    local accept="$1"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        send_response "404" "Not Found" "application/json" '{"error": "No metrics data available"}'
        return
    fi
    
    local performance_metrics=$(jq '.metrics.performance' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    send_response "200" "OK" "application/json" "$performance_metrics"
}

# Get usage metrics  
api_usage_metrics() {
    local accept="$1"
    
    if [[ ! -f "$METRICS_DATA_FILE" ]]; then
        send_response "404" "Not Found" "application/json" '{"error": "No metrics data available"}'
        return
    fi
    
    local usage_metrics=$(jq '.metrics.usage' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
    send_response "200" "OK" "application/json" "$usage_metrics"
}

# Handle export requests
handle_export_request() {
    local path="$1"
    local accept="$2"
    
    # Parse export format from path
    local format="${path#/export/}"
    format="${format%%/*}"
    
    if [[ -z "$format" ]]; then
        send_response "400" "Bad Request" "application/json" '{"error": "Export format required"}'
        return
    fi
    
    # Validate format
    if [[ ! " ${SUPPORTED_FORMATS[*]} " =~ " $format " ]]; then
        send_response "400" "Bad Request" "application/json" '{"error": "Unsupported format: '$format'"}'
        return
    fi
    
    case "$format" in
        "json")
            export_json
            ;;
        "csv")
            export_csv
            ;;
        "xml")
            export_xml
            ;;
        "yaml")
            export_yaml
            ;;
        "prometheus")
            export_prometheus
            ;;
        "influxdb")
            export_influxdb
            ;;
        "grafana")
            export_grafana
            ;;
    esac
}

# Export to JSON format
export_json() {
    if [[ -f "$METRICS_DATA_FILE" ]]; then
        local data=$(cat "$METRICS_DATA_FILE")
        send_response "200" "OK" "application/json" "$data"
    else
        send_response "404" "Not Found" "application/json" '{"error": "No data to export"}'
    fi
}

# Export to CSV format
export_csv() {
    local csv_data="timestamp,category,metric_name,value,metadata\n"
    
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        # System metrics to CSV
        jq -r '.metrics.system[]? | [.timestamp, "system", "cpu_usage", .cpu_usage, ""] | @csv' "$METRICS_DATA_FILE" 2>/dev/null | while read -r line; do
            csv_data+="$line\n"
        done
        
        # Command metrics to CSV  
        jq -r '.metrics.commands[]? | [.timestamp, "command", .command, .duration, .exit_code] | @csv' "$METRICS_DATA_FILE" 2>/dev/null | while read -r line; do
            csv_data+="$line\n"
        done
        
        send_response "200" "OK" "text/csv" "$csv_data"
    else
        send_response "404" "Not Found" "text/csv" "No data to export"
    fi
}

# Export to Prometheus format
export_prometheus() {
    local prometheus_data=""
    
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        # System metrics
        local latest_system=$(jq '.metrics.system[-1]' "$METRICS_DATA_FILE" 2>/dev/null)
        if [[ "$latest_system" != "null" ]]; then
            local cpu=$(echo "$latest_system" | jq -r '.cpu_usage // 0')
            local memory=$(echo "$latest_system" | jq -r '.memory_usage // 0')
            local disk=$(echo "$latest_system" | jq -r '.disk_usage // 0')
            
            prometheus_data+="# HELP dotfiles_cpu_usage CPU usage percentage\n"
            prometheus_data+="# TYPE dotfiles_cpu_usage gauge\n"
            prometheus_data+="dotfiles_cpu_usage $cpu\n\n"
            
            prometheus_data+="# HELP dotfiles_memory_usage Memory usage percentage\n"
            prometheus_data+="# TYPE dotfiles_memory_usage gauge\n"
            prometheus_data+="dotfiles_memory_usage $memory\n\n"
            
            prometheus_data+="# HELP dotfiles_disk_usage Disk usage percentage\n"
            prometheus_data+="# TYPE dotfiles_disk_usage gauge\n"
            prometheus_data+="dotfiles_disk_usage $disk\n\n"
        fi
        
        # Command statistics
        local total_commands=$(jq '.statistics.total_commands // 0' "$METRICS_DATA_FILE")
        local total_errors=$(jq '.statistics.total_errors // 0' "$METRICS_DATA_FILE")
        
        prometheus_data+="# HELP dotfiles_commands_total Total commands executed\n"
        prometheus_data+="# TYPE dotfiles_commands_total counter\n"
        prometheus_data+="dotfiles_commands_total $total_commands\n\n"
        
        prometheus_data+="# HELP dotfiles_errors_total Total command errors\n"
        prometheus_data+="# TYPE dotfiles_errors_total counter\n"
        prometheus_data+="dotfiles_errors_total $total_errors\n\n"
        
        send_response "200" "OK" "text/plain" "$prometheus_data"
    else
        send_response "404" "Not Found" "text/plain" "No data to export"
    fi
}

# Export to InfluxDB line protocol
export_influxdb() {
    local influx_data=""
    
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        # System metrics
        jq -r '.metrics.system[]? | "dotfiles_system,host=" + (.hostname // "localhost") + " cpu_usage=" + (.cpu_usage | tostring) + ",memory_usage=" + (.memory_usage | tostring) + ",disk_usage=" + (.disk_usage | tostring) + " " + (.timestamp | fromdateiso8601 | tostring) + "000000000"' "$METRICS_DATA_FILE" 2>/dev/null | while read -r line; do
            influx_data+="$line\n"
        done
        
        send_response "200" "OK" "text/plain" "$influx_data"
    else
        send_response "404" "Not Found" "text/plain" "No data to export"
    fi
}

# Export to Grafana datasource format
export_grafana() {
    local grafana_data='{
  "datasource": "dotfiles-metrics",
  "targets": [
    {
      "target": "dotfiles.system.cpu_usage",
      "datapoints": ['
    
    if [[ -f "$METRICS_DATA_FILE" ]] && command -v jq >/dev/null 2>&1; then
        local datapoints=$(jq '[.metrics.system[]? | [(.cpu_usage | tonumber), (.timestamp | fromdateiso8601 | . * 1000)]]' "$METRICS_DATA_FILE" 2>/dev/null || echo "[]")
        grafana_data+="$datapoints"
    else
        grafana_data+="[]"
    fi
    
    grafana_data+='
      ]
    }
  ]
}'
    
    send_response "200" "OK" "application/json" "$grafana_data"
}

# Trigger metrics collection
api_collect_metrics() {
    local accept="$1"
    
    echo "📊 Collecting metrics via API request..." >> "$API_LOG_FILE"
    
    if collect_system_metrics >/dev/null 2>&1; then
        local response='{"status": "success", "message": "Metrics collected successfully", "timestamp": "'$(date -Iseconds)'"}'
        send_response "200" "OK" "application/json" "$response"
    else
        local response='{"status": "error", "message": "Failed to collect metrics", "timestamp": "'$(date -Iseconds)'"}'
        send_response "500" "Internal Server Error" "application/json" "$response"
    fi
}

# Send HTTP response
send_response() {
    local status_code="$1"
    local status_text="$2"
    local content_type="$3"
    local body="$4"
    
    local content_length=${#body}
    
    cat << EOF
HTTP/1.1 $status_code $status_text
Content-Type: $content_type
Content-Length: $content_length
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Cache-Control: no-cache
Connection: close

$body
EOF
}

# Export metrics to external services
export_to_service() {
    local service="$1"
    local config_file="${METRICS_CONFIG_DIR}/integrations.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Integration config not found: $config_file"
        return 1
    fi
    
    echo "📤 Exporting metrics to $service..."
    
    case "$service" in
        "prometheus")
            export_to_prometheus "$config_file"
            ;;
        "influxdb")
            export_to_influxdb "$config_file"
            ;;
        "grafana")
            export_to_grafana "$config_file"
            ;;
        "datadog")
            export_to_datadog "$config_file"
            ;;
        "newrelic")
            export_to_newrelic "$config_file"
            ;;
        "elasticsearch")
            export_to_elasticsearch "$config_file"
            ;;
        *)
            echo "❌ Unsupported service: $service"
            return 1
            ;;
    esac
}

# Export to Prometheus pushgateway
export_to_prometheus() {
    local config_file="$1"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq required for Prometheus export"
        return 1
    fi
    
    local prometheus_config=$(jq '.prometheus' "$config_file" 2>/dev/null)
    if [[ "$prometheus_config" == "null" ]]; then
        echo "❌ Prometheus configuration not found"
        return 1
    fi
    
    local pushgateway_url=$(echo "$prometheus_config" | jq -r '.pushgateway_url')
    local job_name=$(echo "$prometheus_config" | jq -r '.job_name // "dotfiles"')
    
    if [[ "$pushgateway_url" == "null" ]]; then
        echo "❌ Prometheus pushgateway URL not configured"
        return 1
    fi
    
    # Generate Prometheus format
    local metrics_data=$(export_prometheus)
    
    # Push to gateway
    if command -v curl >/dev/null 2>&1; then
        echo "$metrics_data" | curl -X POST "$pushgateway_url/metrics/job/$job_name" \
            --data-binary @- \
            --header "Content-Type: text/plain"
        echo "✅ Metrics pushed to Prometheus"
    else
        echo "❌ curl required for Prometheus export"
        return 1
    fi
}

# Export to InfluxDB
export_to_influxdb() {
    local config_file="$1"
    
    local influxdb_config=$(jq '.influxdb' "$config_file" 2>/dev/null)
    if [[ "$influxdb_config" == "null" ]]; then
        echo "❌ InfluxDB configuration not found"
        return 1
    fi
    
    local url=$(echo "$influxdb_config" | jq -r '.url')
    local database=$(echo "$influxdb_config" | jq -r '.database')
    local username=$(echo "$influxdb_config" | jq -r '.username // ""')
    local password=$(echo "$influxdb_config" | jq -r '.password // ""')
    
    # Generate InfluxDB format
    local metrics_data=$(export_influxdb)
    
    # Construct URL
    local write_url="$url/write?db=$database"
    if [[ -n "$username" ]]; then
        write_url+="&u=$username&p=$password"
    fi
    
    # Send to InfluxDB
    if command -v curl >/dev/null 2>&1; then
        echo "$metrics_data" | curl -X POST "$write_url" \
            --data-binary @-
        echo "✅ Metrics sent to InfluxDB"
    else
        echo "❌ curl required for InfluxDB export"
        return 1
    fi
}

# Create sample integration configuration
create_integration_config() {
    local config_file="${METRICS_CONFIG_DIR}/integrations.json"
    
    echo "📝 Creating sample integration configuration..."
    
    cat > "$config_file" << 'EOF'
{
  "prometheus": {
    "enabled": false,
    "pushgateway_url": "http://localhost:9091",
    "job_name": "dotfiles",
    "push_interval": 60
  },
  "influxdb": {
    "enabled": false,
    "url": "http://localhost:8086",
    "database": "dotfiles",
    "username": "",
    "password": "",
    "retention_policy": "default"
  },
  "grafana": {
    "enabled": false,
    "url": "http://localhost:3000",
    "api_key": "",
    "dashboard_id": "dotfiles-metrics"
  },
  "datadog": {
    "enabled": false,
    "api_key": "",
    "app_key": "",
    "site": "datadoghq.com"
  },
  "elasticsearch": {
    "enabled": false,
    "url": "http://localhost:9200",
    "index": "dotfiles-metrics",
    "username": "",
    "password": ""
  }
}
EOF
    
    echo "✅ Integration configuration created: $config_file"
    echo "Edit the file to configure your monitoring services"
}

# API CLI interface
api_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "start"|"serve")
            start_api_server "$@"
            ;;
        "export")
            local format="${1:-json}"
            local output_file="${2:-}"
            export_metrics "$format" "$output_file"
            ;;
        "integration")
            local service="${1:-}"
            if [[ -n "$service" ]]; then
                export_to_service "$service"
            else
                echo "❌ Service required"
                echo "Available services: prometheus, influxdb, grafana, datadog, elasticsearch"
            fi
            ;;
        "config")
            create_integration_config
            ;;
        "test")
            test_api_endpoints
            ;;
        "help"|"")
            show_api_help
            ;;
        "handle_request")
            # Internal command for request handling
            handle_request
            ;;
        *)
            echo "❌ Unknown API command: $command"
            echo "Run 'dot metrics api help' for available commands"
            return 1
            ;;
    esac
}

# Test API endpoints
test_api_endpoints() {
    echo "🧪 Testing API endpoints..."
    
    local base_url="http://127.0.0.1:8080$API_BASE_PATH"
    
    if ! command -v curl >/dev/null 2>&1; then
        echo "❌ curl required for testing"
        return 1
    fi
    
    # Test endpoints
    local endpoints=("/" "/health" "/metrics" "/metrics/system")
    
    for endpoint in "${endpoints[@]}"; do
        echo "Testing $endpoint..."
        local response=$(curl -s -w "%{http_code}" "$base_url$endpoint" || echo "connection_failed")
        
        if [[ "$response" =~ connection_failed ]]; then
            echo "  ❌ Connection failed (is server running?)"
        elif [[ "$response" =~ 200$ ]]; then
            echo "  ✅ OK"
        else
            echo "  ⚠️  Response: $response"
        fi
    done
}

# Show API help
show_api_help() {
    cat << 'EOF'
🔌 Metrics Data Export and Integration API

USAGE:
    dot metrics api <command> [options]

COMMANDS:
    start [port] [host]    Start HTTP API server
    export [format] [file] Export metrics data
    integration <service>  Export to external service
    config                 Create integration config template
    test                   Test API endpoints
    help                   Show this help

API ENDPOINTS:
    GET  /                 API root and documentation
    GET  /health           Health check
    GET  /metrics          List available metrics
    GET  /metrics/system   System metrics
    GET  /metrics/commands Command metrics
    GET  /export/{format}  Export in specified format
    POST /collect          Trigger metrics collection

EXPORT FORMATS:
    json, csv, xml, yaml, prometheus, influxdb, grafana

INTEGRATIONS:
    prometheus, influxdb, grafana, datadog, elasticsearch

EXAMPLES:
    # Start API server
    dot metrics api start 8080 127.0.0.1
    
    # Export data
    dot metrics api export json metrics.json
    dot metrics api export prometheus
    
    # Test endpoints
    curl http://127.0.0.1:8080/api/v1/health
    curl http://127.0.0.1:8080/api/v1/metrics/system
    
    # Setup integrations
    dot metrics api config
    dot metrics api integration prometheus

AUTHENTICATION:
    Set METRICS_API_TOKEN environment variable to require
    Bearer token authentication for API access.

For more information: https://docs.dotfiles.dev/metrics/api
EOF
}

# Export functions
export -f start_api_server export_to_service api_cli

# Main entry point
main() {
    api_cli "$@"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi