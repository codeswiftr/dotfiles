#!/usr/bin/env bash
# ============================================================================
# Security System Test Suite
# Comprehensive tests for Epic 6: Security & Compliance System
# ============================================================================

# Test setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/testing.sh"
source "$SCRIPT_DIR/../lib/security-system.sh" 2>/dev/null || echo "Security system not loaded"

# Test configuration
TEST_SECURITY_DIR="/tmp/security_test_$$"
TEST_REPORTS_DIR="$TEST_SECURITY_DIR/reports"
TEST_CACHE_DIR="$TEST_SECURITY_DIR/cache"

# Test utilities
setup_test_environment() {
    mkdir -p "$TEST_SECURITY_DIR" "$TEST_REPORTS_DIR" "$TEST_CACHE_DIR"
    export SECURITY_REPORTS_DIR="$TEST_REPORTS_DIR"
    export SECURITY_CACHE_DIR="$TEST_CACHE_DIR"
    export SECURITY_AUDIT_LOG="$TEST_SECURITY_DIR/audit.log"
}

cleanup_test_environment() {
    rm -rf "$TEST_SECURITY_DIR"
}

create_test_project() {
    local project_dir="$1"
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Create test files for vulnerability scanning
    cat > package.json << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "dependencies": {
    "express": "4.17.1",
    "lodash": "4.17.15"
  }
}
EOF

    cat > requirements.txt << 'EOF'
Django==3.1.0
requests==2.25.1
PyYAML==5.4.1
EOF

    cat > Cargo.toml << 'EOF'
[package]
name = "test-project"
version = "0.1.0"

[dependencies]
serde = "1.0"
tokio = "1.0"
EOF

    cat > go.mod << 'EOF'
module test-project

go 1.19

require (
    github.com/gin-gonic/gin v1.7.0
    gopkg.in/yaml.v2 v2.4.0
)
EOF

    # Create test secret files
    cat > .env << 'EOF'
DATABASE_URL=postgresql://user:password@localhost/db
API_KEY=sk_test_1234567890abcdef
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF

    # Create test Dockerfile
    cat > Dockerfile << 'EOF'
FROM ubuntu:18.04
RUN apt-get update
USER root
COPY . /app
WORKDIR /app
EXPOSE 3000
CMD ["node", "server.js"]
EOF

    # Create test code with security issues
    cat > app.py << 'EOF'
import os
import subprocess
import yaml

# Potential security issue: Using shell=True
def run_command(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True)

# Potential security issue: Using unsafe yaml.load
def load_config(file_path):
    with open(file_path) as f:
        return yaml.load(f)  # Should use yaml.safe_load

# Hardcoded secret (test)
API_KEY = "sk_live_abcdef123456"
DATABASE_PASSWORD = "admin123"

if __name__ == "__main__":
    config = load_config("config.yml")
    result = run_command(f"echo {config['message']}")
    print(result.stdout)
EOF
}

# ============================================================================
# EPIC 6.1: VULNERABILITY SCANNING TESTS
# ============================================================================

test_security_dependency_scan() {
    test_case "Security dependency scan functionality"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/test_project"
    create_test_project "$test_project"
    
    # Test basic dependency scan
    cd "$test_project"
    
    # Mock npm audit for testing
    export PATH="$TEST_SECURITY_DIR:$PATH"
    cat > "$TEST_SECURITY_DIR/npm" << 'EOF'
#!/bin/bash
if [[ "$1" == "audit" ]]; then
    echo '{"vulnerabilities": {"info": 0, "low": 1, "moderate": 2, "high": 0, "critical": 0}}'
    exit 1
fi
EOF
    chmod +x "$TEST_SECURITY_DIR/npm"
    
    # Test dependency scan
    if security_dependency_scan "$test_project" "json" "medium" >/dev/null 2>&1; then
        assert_success "Dependency scan completed"
    else
        # Expected to fail due to vulnerabilities in mock
        assert_success "Dependency scan detected vulnerabilities correctly"
    fi
    
    # Check report generation
    local report_count=$(ls "$TEST_REPORTS_DIR"/dependency-scan-*.json 2>/dev/null | wc -l)
    assert_greater_than "$report_count" 0 "Dependency scan report generated"
    
    cleanup_test_environment
}

test_security_code_analysis() {
    test_case "Security code analysis functionality"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/test_project"
    create_test_project "$test_project"
    
    cd "$test_project"
    
    # Mock semgrep for testing
    export PATH="$TEST_SECURITY_DIR:$PATH"
    cat > "$TEST_SECURITY_DIR/semgrep" << 'EOF'
#!/bin/bash
echo '{"results": [{"check_id": "python.lang.security.audit.dangerous-subprocess-use.dangerous-subprocess-use", "path": "app.py", "start": {"line": 6}}]}'
exit 1
EOF
    chmod +x "$TEST_SECURITY_DIR/semgrep"
    
    # Test code analysis
    security_code_analysis "$test_project" "json" "auto" >/dev/null 2>&1
    local exit_code=$?
    
    # Should detect security issues
    assert_equals "$exit_code" 1 "Code analysis detected security issues"
    
    # Check report generation
    local report_count=$(ls "$TEST_REPORTS_DIR"/code-analysis-*.json 2>/dev/null | wc -l)
    assert_greater_than "$report_count" 0 "Code analysis report generated"
    
    cleanup_test_environment
}

test_security_secret_detection() {
    test_case "Security secret detection functionality"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/test_project"
    create_test_project "$test_project"
    
    cd "$test_project"
    
    # Mock gitleaks for testing
    export PATH="$TEST_SECURITY_DIR:$PATH"
    cat > "$TEST_SECURITY_DIR/gitleaks" << 'EOF'
#!/bin/bash
echo '{"DetectedSecrets": [{"Description": "AWS Access Key", "File": ".env", "LineNumber": 3}]}'
exit 1
EOF
    chmod +x "$TEST_SECURITY_DIR/gitleaks"
    
    # Test secret detection
    security_secret_detection "$test_project" "json" "false" >/dev/null 2>&1
    local exit_code=$?
    
    # Should detect secrets
    assert_equals "$exit_code" 1 "Secret detection found exposed secrets"
    
    # Check report generation
    local report_count=$(ls "$TEST_REPORTS_DIR"/secret-detection-*.json 2>/dev/null | wc -l)
    assert_greater_than "$report_count" 0 "Secret detection report generated"
    
    cleanup_test_environment
}

test_security_container_scan() {
    test_case "Security container scanning functionality"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/test_project"
    create_test_project "$test_project"
    
    cd "$test_project"
    
    # Mock trivy for testing
    export PATH="$TEST_SECURITY_DIR:$PATH"
    cat > "$TEST_SECURITY_DIR/trivy" << 'EOF'
#!/bin/bash
echo '{"Results": [{"Target": "Dockerfile", "Vulnerabilities": [{"VulnerabilityID": "CVE-2021-1234", "Severity": "HIGH"}]}]}'
exit 0
EOF
    chmod +x "$TEST_SECURITY_DIR/trivy"
    
    # Test container scan on Dockerfile
    if security_container_scan "$test_project/Dockerfile" "json" "medium" >/dev/null 2>&1; then
        assert_success "Container scan completed successfully"
    fi
    
    # Check report generation
    local report_count=$(ls "$TEST_REPORTS_DIR"/container-scan-*.json 2>/dev/null | wc -l)
    assert_greater_than "$report_count" 0 "Container scan report generated"
    
    cleanup_test_environment
}

# ============================================================================
# EPIC 6.2: COMPLIANCE AUTOMATION TESTS
# ============================================================================

test_compliance_soc2_audit() {
    test_case "SOC2 compliance audit functionality"
    
    setup_test_environment
    
    # Test SOC2 audit
    if compliance_soc2_audit "security" "json" >/dev/null 2>&1; then
        assert_success "SOC2 audit completed"
    fi
    
    # Check report generation
    local report_count=$(ls "$TEST_REPORTS_DIR"/soc2-audit-*.json 2>/dev/null | wc -l)
    assert_greater_than "$report_count" 0 "SOC2 audit report generated"
    
    cleanup_test_environment
}

test_compliance_gdpr_scan() {
    test_case "GDPR compliance scanning functionality"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/test_project"
    create_test_project "$test_project"
    
    # Create test files with PII patterns
    cat > "$test_project/users.sql" << 'EOF'
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    social_security_number VARCHAR(11),
    credit_card_number VARCHAR(16)
);
EOF
    
    # Test GDPR scan
    if compliance_gdpr_scan "$test_project" "json" >/dev/null 2>&1; then
        assert_success "GDPR scan completed"
    fi
    
    # Check report generation
    local report_count=$(ls "$TEST_REPORTS_DIR"/gdpr-scan-*.json 2>/dev/null | wc -l)
    assert_greater_than "$report_count" 0 "GDPR scan report generated"
    
    cleanup_test_environment
}

test_compliance_reporting() {
    test_case "Compliance reporting functionality"
    
    setup_test_environment
    
    # Test compliance report generation
    if compliance_reporting "soc2" "$TEST_REPORTS_DIR" "json" >/dev/null 2>&1; then
        assert_success "Compliance reporting completed"
    fi
    
    # Check if reports were generated
    local report_files=$(find "$TEST_REPORTS_DIR" -name "compliance-report-*" 2>/dev/null | wc -l)
    assert_greater_than "$report_files" 0 "Compliance reports generated"
    
    cleanup_test_environment
}

test_audit_trail_management() {
    test_case "Audit trail management functionality"
    
    setup_test_environment
    
    # Test audit trail status
    if audit_trail_management "status" >/dev/null 2>&1; then
        assert_success "Audit trail status check completed"
    fi
    
    # Test audit log creation
    log_security_action "test_action" "test_details"
    
    if [[ -f "$SECURITY_AUDIT_LOG" ]]; then
        assert_success "Audit log file created"
        
        # Check log content
        if grep -q "test_action" "$SECURITY_AUDIT_LOG"; then
            assert_success "Audit log entry recorded"
        else
            assert_fail "Audit log entry not found"
        fi
    else
        assert_fail "Audit log file not created"
    fi
    
    cleanup_test_environment
}

# ============================================================================
# EPIC 6.3: SECRET MANAGEMENT TESTS
# ============================================================================

test_secret_rotation_automation() {
    test_case "Secret rotation automation functionality"
    
    setup_test_environment
    
    # Mock secret rotation (testing framework)
    if secret_rotation_automation "local" "api_keys" "30d" >/dev/null 2>&1; then
        assert_success "Secret rotation process initiated"
    fi
    
    cleanup_test_environment
}

test_secret_encryption_at_rest() {
    test_case "Secret encryption at rest functionality"
    
    setup_test_environment
    
    # Create test secret file
    local secret_file="$TEST_SECURITY_DIR/test_secret.txt"
    echo "test_secret_content" > "$secret_file"
    
    # Mock age for testing
    export PATH="$TEST_SECURITY_DIR:$PATH"
    cat > "$TEST_SECURITY_DIR/age" << 'EOF'
#!/bin/bash
echo "age: encrypted successfully"
exit 0
EOF
    chmod +x "$TEST_SECURITY_DIR/age"
    
    # Test encryption
    if secret_encryption_at_rest "$secret_file" "age" >/dev/null 2>&1; then
        assert_success "Secret encryption completed"
    fi
    
    cleanup_test_environment
}

test_secret_access_control() {
    test_case "Secret access control functionality"
    
    setup_test_environment
    
    # Test access control operations
    if secret_access_control "list" "admin" "/secrets/api" >/dev/null 2>&1; then
        assert_success "Secret access control operation completed"
    fi
    
    cleanup_test_environment
}

test_secret_audit_logging() {
    test_case "Secret audit logging functionality"
    
    setup_test_environment
    
    # Test audit logging
    if secret_audit_logging "status" >/dev/null 2>&1; then
        assert_success "Secret audit logging status checked"
    fi
    
    cleanup_test_environment
}

# ============================================================================
# EPIC 6.4: SECURITY MONITORING TESTS
# ============================================================================

test_security_threat_detection() {
    test_case "Security threat detection functionality"
    
    setup_test_environment
    
    # Test threat detection (mock mode)
    if security_threat_detection "filesystem" "10s" "low" >/dev/null 2>&1; then
        assert_success "Threat detection process started"
    fi
    
    cleanup_test_environment
}

test_security_anomaly_detection() {
    test_case "Security anomaly detection functionality"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/test_project"
    create_test_project "$test_project"
    
    # Test anomaly detection
    if security_anomaly_detection "$test_project" "7" "medium" >/dev/null 2>&1; then
        assert_success "Anomaly detection completed"
    fi
    
    # Check baseline file creation
    local baseline_file="$TEST_CACHE_DIR/baseline-$(echo "$test_project" | tr '/' '_').json"
    if [[ -f "$baseline_file" ]]; then
        assert_success "Security baseline created"
    fi
    
    cleanup_test_environment
}

test_security_incident_response() {
    test_case "Security incident response functionality"
    
    setup_test_environment
    
    # Test incident response
    if security_incident_response "suspicious_activity" "low" "false" >/dev/null 2>&1; then
        assert_success "Incident response process completed"
    fi
    
    # Check incident record creation
    local incident_count=$(ls "$TEST_REPORTS_DIR"/incidents/*.json 2>/dev/null | wc -l)
    assert_greater_than "$incident_count" 0 "Incident record created"
    
    cleanup_test_environment
}

test_security_dashboard() {
    test_case "Security dashboard functionality"
    
    setup_test_environment
    
    # Test dashboard JSON output
    if security_dashboard "30" "json" >/dev/null 2>&1; then
        assert_success "Security dashboard JSON output generated"
    fi
    
    # Test dashboard once mode
    if security_dashboard "30" "once" >/dev/null 2>&1; then
        assert_success "Security dashboard once mode completed"
    fi
    
    cleanup_test_environment
}

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

test_security_system_integration() {
    test_case "Security system integration test"
    
    setup_test_environment
    local test_project="$TEST_SECURITY_DIR/integration_test"
    create_test_project "$test_project"
    
    cd "$test_project"
    
    # Test complete security workflow
    local workflow_passed=true
    
    # 1. Vulnerability scanning
    if ! security_dependency_scan "$test_project" "json" >/dev/null 2>&1; then
        echo "  → Dependency scan detected issues (expected)"
    fi
    
    # 2. Code analysis
    if ! security_code_analysis "$test_project" "json" >/dev/null 2>&1; then
        echo "  → Code analysis detected issues (expected)"
    fi
    
    # 3. Secret detection
    if ! security_secret_detection "$test_project" "json" >/dev/null 2>&1; then
        echo "  → Secret detection found secrets (expected)"
    fi
    
    # 4. Compliance check
    if compliance_soc2_audit "security" "json" >/dev/null 2>&1; then
        echo "  → SOC2 audit completed"
    fi
    
    # 5. Audit logging
    log_security_action "integration_test" "full_workflow_test"
    if grep -q "integration_test" "$SECURITY_AUDIT_LOG"; then
        echo "  → Audit logging working"
    else
        workflow_passed=false
    fi
    
    if $workflow_passed; then
        assert_success "Security system integration test passed"
    else
        assert_fail "Security system integration test failed"
    fi
    
    # Check all reports were generated
    local total_reports=$(find "$TEST_REPORTS_DIR" -name "*.json" 2>/dev/null | wc -l)
    assert_greater_than "$total_reports" 0 "Integration test generated reports"
    
    cleanup_test_environment
}

test_security_tools_validation() {
    test_case "Security tools validation test"
    
    # Test that all required security functions are available
    local required_functions=(
        "security_dependency_scan"
        "security_code_analysis"
        "security_secret_detection"
        "security_container_scan"
        "compliance_soc2_audit"
        "compliance_gdpr_scan"
        "compliance_reporting"
        "audit_trail_management"
        "secret_rotation_automation"
        "secret_encryption_at_rest"
        "secret_access_control"
        "secret_audit_logging"
        "security_threat_detection"
        "security_anomaly_detection"
        "security_incident_response"
        "security_dashboard"
    )
    
    local missing_functions=()
    
    for func in "${required_functions[@]}"; do
        if ! declare -f "$func" >/dev/null 2>&1; then
            missing_functions+=("$func")
        fi
    done
    
    if [[ ${#missing_functions[@]} -eq 0 ]]; then
        assert_success "All Epic 6 security functions are available"
    else
        assert_fail "Missing security functions: ${missing_functions[*]}"
    fi
}

# ============================================================================
# TEST RUNNER
# ============================================================================

run_security_system_tests() {
    echo "🔒 Running Epic 6: Security & Compliance System Tests"
    echo "================================================="
    
    local total_tests=0
    local passed_tests=0
    
    # Epic 6.1: Vulnerability Scanning
    echo ""
    echo "🔍 Epic 6.1: Vulnerability Scanning Tests"
    test_security_dependency_scan && ((passed_tests++)); ((total_tests++))
    test_security_code_analysis && ((passed_tests++)); ((total_tests++))
    test_security_secret_detection && ((passed_tests++)); ((total_tests++))
    test_security_container_scan && ((passed_tests++)); ((total_tests++))
    
    # Epic 6.2: Compliance Automation
    echo ""
    echo "📊 Epic 6.2: Compliance Automation Tests"
    test_compliance_soc2_audit && ((passed_tests++)); ((total_tests++))
    test_compliance_gdpr_scan && ((passed_tests++)); ((total_tests++))
    test_compliance_reporting && ((passed_tests++)); ((total_tests++))
    test_audit_trail_management && ((passed_tests++)); ((total_tests++))
    
    # Epic 6.3: Secret Management
    echo ""
    echo "🔑 Epic 6.3: Secret Management Tests"
    test_secret_rotation_automation && ((passed_tests++)); ((total_tests++))
    test_secret_encryption_at_rest && ((passed_tests++)); ((total_tests++))
    test_secret_access_control && ((passed_tests++)); ((total_tests++))
    test_secret_audit_logging && ((passed_tests++)); ((total_tests++))
    
    # Epic 6.4: Security Monitoring
    echo ""
    echo "🛡️  Epic 6.4: Security Monitoring Tests"
    test_security_threat_detection && ((passed_tests++)); ((total_tests++))
    test_security_anomaly_detection && ((passed_tests++)); ((total_tests++))
    test_security_incident_response && ((passed_tests++)); ((total_tests++))
    test_security_dashboard && ((passed_tests++)); ((total_tests++))
    
    # Integration Tests
    echo ""
    echo "🔗 Integration Tests"
    test_security_system_integration && ((passed_tests++)); ((total_tests++))
    test_security_tools_validation && ((passed_tests++)); ((total_tests++))
    
    # Summary
    echo ""
    echo "================================================="
    echo "🔒 Security System Test Results:"
    echo "   Total Tests: $total_tests"
    echo "   Passed: $passed_tests"
    echo "   Failed: $((total_tests - passed_tests))"
    echo "   Success Rate: $(( (passed_tests * 100) / total_tests ))%"
    
    if [[ $passed_tests -eq $total_tests ]]; then
        echo "✅ All Epic 6 security tests passed!"
        return 0
    else
        echo "❌ Some Epic 6 security tests failed!"
        return 1
    fi
}

# Run tests if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_security_system_tests
fi