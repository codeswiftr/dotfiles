#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Security Operations
# Comprehensive security scanning and management
# ============================================================================

# Security management command
dot_security() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "scan")
            security_full_scan "$@"
            ;;
        "deps")
            security_check_dependencies "$@"
            ;;
        "code")
            security_static_analysis "$@"
            ;;
        "secrets")
            security_scan_secrets "$@"
            ;;
        "audit")
            security_audit_system "$@"
            ;;
        "status")
            security_status
            ;;
        "setup")
            security_setup_tools
            ;;
        "-h"|"--help"|"")
            show_security_help
            ;;
        *)
            print_error "Unknown security subcommand: $subcommand"
            echo "Run 'dot security --help' for available commands."
            return 1
            ;;
    esac
}

# Full security scan
security_full_scan() {
    local quiet=false
    local format="table"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet)
                quiet=true
                shift
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    print_info "${LOCK} Running comprehensive security scan..."
    
    local exit_code=0
    local scan_results=()
    
    # Dependency vulnerabilities
    if [[ "$quiet" != "true" ]]; then
        print_info "🔍 Checking dependency vulnerabilities..."
    fi
    
    if security_check_dependencies --quiet; then
        scan_results+=("Dependencies: ✅ Clean")
    else
        scan_results+=("Dependencies: ❌ Vulnerabilities found")
        exit_code=1
    fi
    
    # Static code analysis
    if [[ "$quiet" != "true" ]]; then
        print_info "🔍 Running static code analysis..."
    fi
    
    if security_static_analysis --quiet; then
        scan_results+=("Code Analysis: ✅ Clean")
    else
        scan_results+=("Code Analysis: ⚠️  Issues found")
        exit_code=1
    fi
    
    # Secret scanning
    if [[ "$quiet" != "true" ]]; then
        print_info "🔍 Scanning for secrets..."
    fi
    
    if security_scan_secrets --quiet; then
        scan_results+=("Secret Scan: ✅ Clean")
    else
        scan_results+=("Secret Scan: ❌ Secrets detected")
        exit_code=1
    fi
    
    # Docker security (if applicable)
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        if [[ "$quiet" != "true" ]]; then
            print_info "🔍 Checking Docker security..."
        fi
        
        if security_check_docker --quiet; then
            scan_results+=("Docker: ✅ Secure")
        else
            scan_results+=("Docker: ⚠️  Issues found")
            exit_code=1
        fi
    fi
    
    # Display results
    if [[ "$quiet" != "true" ]]; then
        echo ""
        echo "📋 Security Scan Results:"
        for result in "${scan_results[@]}"; do
            echo "  $result"
        done
        echo ""
        
        if [[ $exit_code -eq 0 ]]; then
            print_success "All security checks passed! ${LOCK}"
        else
            print_error "Security issues detected. Review above results."
            echo "Run individual scans with detailed output for more information."
        fi
    fi
    
    return $exit_code
}

# Check dependency vulnerabilities
security_check_dependencies() {
    local quiet=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet)
                quiet=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local exit_code=0
    
    # Check for package managers and run appropriate vulnerability scans
    if [[ -f "package.json" ]]; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Checking npm/yarn vulnerabilities..."
        fi
        
        if command -v npm >/dev/null 2>&1; then
            if [[ "$quiet" == "true" ]]; then
                npm audit --audit-level=moderate >/dev/null 2>&1 || exit_code=1
            else
                npm audit --audit-level=moderate || exit_code=1
            fi
        fi
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "Pipfile" ]]; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Checking Python vulnerabilities..."
        fi
        
        if command -v safety >/dev/null 2>&1; then
            if [[ "$quiet" == "true" ]]; then
                safety check >/dev/null 2>&1 || exit_code=1
            else
                safety check || exit_code=1
            fi
        elif command -v pip-audit >/dev/null 2>&1; then
            if [[ "$quiet" == "true" ]]; then
                pip-audit >/dev/null 2>&1 || exit_code=1
            else
                pip-audit || exit_code=1
            fi
        else
            if [[ "$quiet" != "true" ]]; then
                print_warning "No Python security scanner found. Install safety or pip-audit."
            fi
        fi
    fi
    
    if [[ -f "Cargo.toml" ]]; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Checking Rust vulnerabilities..."
        fi
        
        if command -v cargo-audit >/dev/null 2>&1; then
            if [[ "$quiet" == "true" ]]; then
                cargo audit >/dev/null 2>&1 || exit_code=1
            else
                cargo audit || exit_code=1
            fi
        else
            if [[ "$quiet" != "true" ]]; then
                print_warning "cargo-audit not found. Install with: cargo install cargo-audit"
            fi
        fi
    fi
    
    if [[ -f "go.mod" ]]; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Checking Go vulnerabilities..."
        fi
        
        if command -v govulncheck >/dev/null 2>&1; then
            if [[ "$quiet" == "true" ]]; then
                govulncheck ./... >/dev/null 2>&1 || exit_code=1
            else
                govulncheck ./... || exit_code=1
            fi
        else
            if [[ "$quiet" != "true" ]]; then
                print_warning "govulncheck not found. Install with: go install golang.org/x/vuln/cmd/govulncheck@latest"
            fi
        fi
    fi
    
    return $exit_code
}

# Static code analysis
security_static_analysis() {
    local quiet=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet)
                quiet=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local exit_code=0
    
    # Semgrep for multi-language static analysis
    if command -v semgrep >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running Semgrep analysis..."
        fi
        
        if [[ "$quiet" == "true" ]]; then
            semgrep --config=auto --quiet --error >/dev/null 2>&1 || exit_code=1
        else
            semgrep --config=auto || exit_code=1
        fi
    else
        if [[ "$quiet" != "true" ]]; then
            print_warning "Semgrep not found. Install with: pip install semgrep"
        fi
    fi
    
    # Language-specific linters with security rules
    if [[ -f "package.json" ]] && command -v eslint >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running ESLint security rules..."
        fi
        
        # Check if security plugin is available
        if npm list eslint-plugin-security >/dev/null 2>&1; then
            if [[ "$quiet" == "true" ]]; then
                eslint . --quiet >/dev/null 2>&1 || exit_code=1
            else
                eslint . || exit_code=1
            fi
        fi
    fi
    
    # Bandit for Python
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] && command -v bandit >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running Bandit Python security analysis..."
        fi
        
        if [[ "$quiet" == "true" ]]; then
            bandit -r . -f json >/dev/null 2>&1 || exit_code=1
        else
            bandit -r . || exit_code=1
        fi
    fi
    
    return $exit_code
}

# Scan for secrets
security_scan_secrets() {
    local quiet=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet)
                quiet=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local exit_code=0
    
    # Use gitleaks if available
    if command -v gitleaks >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running gitleaks secret scan..."
        fi
        
        if [[ "$quiet" == "true" ]]; then
            gitleaks detect --no-git >/dev/null 2>&1 || exit_code=1
        else
            gitleaks detect --no-git || exit_code=1
        fi
    # Fallback to truffleHog
    elif command -v truffleHog >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running truffleHog secret scan..."
        fi
        
        if [[ "$quiet" == "true" ]]; then
            truffleHog . >/dev/null 2>&1 || exit_code=1
        else
            truffleHog . || exit_code=1
        fi
    else
        # Basic pattern matching for common secrets
        if [[ "$quiet" != "true" ]]; then
            print_info "Running basic secret pattern scan..."
        fi
        
        local secret_patterns=(
            "api[_-]?key"
            "secret[_-]?key"
            "access[_-]?token"
            "password"
            "private[_-]?key"
            "-----BEGIN RSA PRIVATE KEY-----"
            "-----BEGIN OPENSSH PRIVATE KEY-----"
            "sk_live_"
            "pk_live_"
            "AKIA[0-9A-Z]{16}"
        )
        
        for pattern in "${secret_patterns[@]}"; do
            if grep -ri "$pattern" . --exclude-dir=.git --exclude-dir=node_modules >/dev/null 2>&1; then
                if [[ "$quiet" != "true" ]]; then
                    print_warning "Potential secret pattern found: $pattern"
                fi
                exit_code=1
            fi
        done
    fi
    
    return $exit_code
}

# Docker security check
security_check_docker() {
    local quiet=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet)
                quiet=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    local exit_code=0
    
    # Check Dockerfile security with hadolint
    if [[ -f "Dockerfile" ]] && command -v hadolint >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running Dockerfile security analysis..."
        fi
        
        if [[ "$quiet" == "true" ]]; then
            hadolint Dockerfile >/dev/null 2>&1 || exit_code=1
        else
            hadolint Dockerfile || exit_code=1
        fi
    fi
    
    # Check for running containers with Docker Bench
    if command -v docker >/dev/null 2>&1 && command -v docker-bench-security >/dev/null 2>&1; then
        if [[ "$quiet" != "true" ]]; then
            print_info "Running Docker Bench security check..."
        fi
        
        if [[ "$quiet" == "true" ]]; then
            docker-bench-security >/dev/null 2>&1 || exit_code=1
        else
            docker-bench-security || exit_code=1
        fi
    fi
    
    return $exit_code
}

# System security audit
security_audit_system() {
    print_info "${LOCK} Running system security audit..."
    
    # Check file permissions
    print_info "Checking critical file permissions..."
    
    local critical_files=(
        "$HOME/.ssh"
        "$HOME/.gnupg"
        "$HOME/.config"
    )
    
    for file in "${critical_files[@]}"; do
        if [[ -e "$file" ]]; then
            local perms=$(stat -f "%A" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
            case "$file" in
                *".ssh")
                    if [[ "$perms" != "700" ]]; then
                        print_warning "SSH directory permissions: $perms (should be 700)"
                    fi
                    ;;
                *".gnupg")
                    if [[ "$perms" != "700" ]]; then
                        print_warning "GPG directory permissions: $perms (should be 700)"
                    fi
                    ;;
            esac
        fi
    done
    
    # Check SSH key security
    if [[ -d "$HOME/.ssh" ]]; then
        print_info "Checking SSH key security..."
        
        for key_file in "$HOME/.ssh"/id_*; do
            if [[ -f "$key_file" ]] && [[ ! "$key_file" == *.pub ]]; then
                local perms=$(stat -f "%A" "$key_file" 2>/dev/null || stat -c "%a" "$key_file" 2>/dev/null)
                if [[ "$perms" != "600" ]]; then
                    print_warning "SSH private key permissions: $key_file ($perms, should be 600)"
                fi
            fi
        done
    fi
    
    # Check for security tools
    print_info "Checking installed security tools..."
    
    local security_tools=(
        "gitleaks:Secret scanning"
        "semgrep:Static analysis"
        "hadolint:Docker security"
        "safety:Python vulnerability scanning"
        "npm-audit:Node.js vulnerability scanning"
    )
    
    for tool_info in "${security_tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info#*:}"
        
        if command -v "$tool" >/dev/null 2>&1; then
            print_success "$tool installed ($description)"
        else
            print_warning "$tool not installed ($description)"
        fi
    done
}

# Security status overview
security_status() {
    echo "🔒 Security Status Overview:"
    echo ""
    
    # Check essential security tools
    local tools_status=""
    
    if command -v gitleaks >/dev/null 2>&1; then
        tools_status+="✅ gitleaks "
    else
        tools_status+="❌ gitleaks "
    fi
    
    if command -v semgrep >/dev/null 2>&1; then
        tools_status+="✅ semgrep "
    else
        tools_status+="❌ semgrep "
    fi
    
    if command -v hadolint >/dev/null 2>&1; then
        tools_status+="✅ hadolint "
    else
        tools_status+="❌ hadolint "
    fi
    
    echo "Security Tools: $tools_status"
    
    # Check recent scans
    local last_scan_file="$HOME/.dotfiles_last_security_scan"
    if [[ -f "$last_scan_file" ]]; then
        local last_scan=$(cat "$last_scan_file")
        echo "Last Scan: $(date -r "$last_scan" 2>/dev/null || echo 'Never')"
    else
        echo "Last Scan: Never"
    fi
    
    # Quick vulnerability count
    echo ""
    echo "Quick Status Check:"
    
    if [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
        local audit_result=$(npm audit --audit-level=high --json 2>/dev/null | jq -r '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo "?")
        echo "  High Severity NPM: $audit_result"
    fi
    
    echo ""
    echo "Run 'dot security scan' for comprehensive analysis"
}

# Setup security tools
security_setup_tools() {
    print_info "${LOCK} Setting up security tools..."
    
    # Install gitleaks
    if ! command -v gitleaks >/dev/null 2>&1; then
        print_info "Installing gitleaks..."
        if command -v brew >/dev/null 2>&1; then
            brew install gitleaks
        else
            print_warning "Please install gitleaks manually: https://github.com/gitleaks/gitleaks"
        fi
    fi
    
    # Install semgrep
    if ! command -v semgrep >/dev/null 2>&1; then
        print_info "Installing semgrep..."
        if command -v pip >/dev/null 2>&1; then
            pip install semgrep
        else
            print_warning "Please install semgrep manually: pip install semgrep"
        fi
    fi
    
    # Install hadolint
    if ! command -v hadolint >/dev/null 2>&1; then
        print_info "Installing hadolint..."
        if command -v brew >/dev/null 2>&1; then
            brew install hadolint
        else
            print_warning "Please install hadolint manually: https://github.com/hadolint/hadolint"
        fi
    fi
    
    print_success "Security tools setup completed!"
}

# Help function
show_security_help() {
    cat << 'EOF'
dot security - Security operations and scanning

USAGE:
    dot security <command> [options]

COMMANDS:
    scan                 Full security scan (deps + code + secrets)
    deps                 Check dependency vulnerabilities
    code                 Static code analysis for security issues
    secrets              Scan for exposed secrets and credentials
    audit                System security audit
    status               Show security tool status
    setup                Install security scanning tools

OPTIONS:
    --quiet              Suppress output, return only exit code
    --format <format>    Output format (table, json, sarif)
    -h, --help           Show this help message

SECURITY TOOLS:
    gitleaks             Secret scanning
    semgrep              Static analysis (multi-language)
    hadolint             Dockerfile security linting
    safety               Python vulnerability scanning
    npm audit            Node.js vulnerability scanning
    cargo audit          Rust vulnerability scanning
    govulncheck          Go vulnerability scanning

EXAMPLES:
    dot security scan              # Full security audit
    dot security deps              # Check dependencies only
    dot security secrets --quiet   # Silent secret scan
    dot security setup             # Install security tools
EOF
}