#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Security Operations
# Security scanning: dependencies, code analysis, secrets, containers
# ============================================================================

dot_security() {
    local subcommand="${1:-}"
    shift || true

    case "$subcommand" in
        "scan")    security_full_scan "$@" ;;
        "deps")    security_check_dependencies "$@" ;;
        "code")    security_static_analysis "$@" ;;
        "secrets") security_scan_secrets "$@" ;;
        "container") security_check_docker "$@" ;;
        "audit")   security_audit_system "$@" ;;
        "status")  security_status ;;
        "setup")   security_setup_tools ;;
        "-h"|"--help"|"") show_security_help ;;
        *)
            print_error "Unknown security subcommand: $subcommand"
            echo "Run 'dot security --help' for available commands."
            return 1
            ;;
    esac
}

# Full security scan
security_full_scan() {
    local quiet=false format="table"
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quiet) quiet=true; shift ;;
            --format) format="$2"; shift 2 ;;
            --json) format="json"; quiet=true; shift ;;
            *) break ;;
        esac
    done

    [[ "$quiet" != "true" ]] && print_info "Running comprehensive security scan..."

    local exit_code=0
    local scan_results=()

    [[ "$quiet" != "true" ]] && print_info "Checking dependency vulnerabilities..."
    if security_check_dependencies --quiet; then
        scan_results+=("Dependencies: CLEAN")
    else
        scan_results+=("Dependencies: VULNERABILITIES FOUND")
        exit_code=1
    fi

    [[ "$quiet" != "true" ]] && print_info "Running static code analysis..."
    if security_static_analysis --quiet; then
        scan_results+=("Code Analysis: CLEAN")
    else
        scan_results+=("Code Analysis: ISSUES FOUND")
        exit_code=1
    fi

    [[ "$quiet" != "true" ]] && print_info "Scanning for secrets..."
    if security_scan_secrets --quiet; then
        scan_results+=("Secret Scan: CLEAN")
    else
        scan_results+=("Secret Scan: SECRETS DETECTED")
        exit_code=1
    fi

    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]]; then
        [[ "$quiet" != "true" ]] && print_info "Checking Docker security..."
        if security_check_docker --quiet; then
            scan_results+=("Docker: SECURE")
        else
            scan_results+=("Docker: ISSUES FOUND")
            exit_code=1
        fi
    fi

    if [[ "$format" == "json" ]]; then
        printf '{"results":['; local first=true
        for r in "${scan_results[@]}"; do
            [[ "$first" != "true" ]] && printf ','
            printf '"%s"' "$r"; first=false
        done
        printf '],"exit_code":%d}\n' "$exit_code"
    elif [[ "$quiet" != "true" ]]; then
        echo ""
        echo "Security Scan Results:"
        for result in "${scan_results[@]}"; do echo "  $result"; done
        echo ""
        [[ $exit_code -eq 0 ]] && print_success "All security checks passed!" || print_error "Security issues detected."
    fi

    return $exit_code
}

# Dependency vulnerability scanning
security_check_dependencies() {
    local quiet=false
    [[ "${1:-}" == "--quiet" ]] && quiet=true
    local exit_code=0

    if [[ -f "package.json" ]] && command -v npm &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Checking npm vulnerabilities..."
        if [[ "$quiet" == "true" ]]; then
            npm audit --audit-level=moderate &>/dev/null || exit_code=1
        else
            npm audit --audit-level=moderate || exit_code=1
        fi
    fi

    if { [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; }; then
        if command -v safety &>/dev/null; then
            [[ "$quiet" != "true" ]] && print_info "Checking Python vulnerabilities..."
            safety check $([[ "$quiet" == "true" ]] && echo ">/dev/null 2>&1") || exit_code=1
        elif command -v pip-audit &>/dev/null; then
            [[ "$quiet" != "true" ]] && print_info "Checking Python vulnerabilities..."
            pip-audit $([[ "$quiet" == "true" ]] && echo ">/dev/null 2>&1") || exit_code=1
        fi
    fi

    if [[ -f "Cargo.toml" ]] && command -v cargo-audit &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Checking Rust vulnerabilities..."
        if [[ "$quiet" == "true" ]]; then
            cargo audit &>/dev/null || exit_code=1
        else
            cargo audit || exit_code=1
        fi
    fi

    if [[ -f "go.mod" ]] && command -v govulncheck &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Checking Go vulnerabilities..."
        if [[ "$quiet" == "true" ]]; then
            govulncheck ./... &>/dev/null || exit_code=1
        else
            govulncheck ./... || exit_code=1
        fi
    fi

    return $exit_code
}

# Static code analysis
security_static_analysis() {
    local quiet=false
    [[ "${1:-}" == "--quiet" ]] && quiet=true
    local exit_code=0

    if command -v semgrep &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Running Semgrep analysis..."
        if [[ "$quiet" == "true" ]]; then
            semgrep --config=auto --quiet --error &>/dev/null || exit_code=1
        else
            semgrep --config=auto || exit_code=1
        fi
    fi

    if [[ -f "package.json" ]] && command -v eslint &>/dev/null && npm list eslint-plugin-security &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Running ESLint security rules..."
        if [[ "$quiet" == "true" ]]; then
            eslint . --quiet &>/dev/null || exit_code=1
        else
            eslint . || exit_code=1
        fi
    fi

    if { [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; } && command -v bandit &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Running Bandit Python analysis..."
        if [[ "$quiet" == "true" ]]; then
            bandit -r . &>/dev/null || exit_code=1
        else
            bandit -r . || exit_code=1
        fi
    fi

    return $exit_code
}

# Secret scanning
security_scan_secrets() {
    local quiet=false
    [[ "${1:-}" == "--quiet" ]] && quiet=true
    local exit_code=0

    if command -v gitleaks &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Running gitleaks secret scan..."
        local config_flag=()
        [[ -f "$DOTFILES_DIR/gitleaks.toml" ]] && config_flag=("--config" "$DOTFILES_DIR/gitleaks.toml")
        if [[ "$quiet" == "true" ]]; then
            gitleaks detect "${config_flag[@]}" --no-git &>/dev/null || exit_code=1
        else
            gitleaks detect "${config_flag[@]}" --no-git || exit_code=1
        fi
    elif command -v truffleHog &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Running truffleHog..."
        if [[ "$quiet" == "true" ]]; then
            truffleHog . &>/dev/null || exit_code=1
        else
            truffleHog . || exit_code=1
        fi
    else
        # Basic pattern matching fallback
        [[ "$quiet" != "true" ]] && print_info "Running basic secret pattern scan..."
        local patterns=("AKIA[0-9A-Z]{16}" "-----BEGIN.*PRIVATE KEY-----" "sk_live_" "pk_live_")
        for pattern in "${patterns[@]}"; do
            if grep -rIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=tests "$pattern" . &>/dev/null; then
                exit_code=1
                [[ "$quiet" != "true" ]] && print_warning "Potential secret pattern: $pattern"
            fi
        done
    fi

    return $exit_code
}

# Docker security check
security_check_docker() {
    local quiet=false
    [[ "${1:-}" == "--quiet" ]] && quiet=true
    local exit_code=0

    if [[ -f "Dockerfile" ]] && command -v hadolint &>/dev/null; then
        [[ "$quiet" != "true" ]] && print_info "Running Dockerfile analysis..."
        if [[ "$quiet" == "true" ]]; then
            hadolint Dockerfile &>/dev/null || exit_code=1
        else
            hadolint Dockerfile || exit_code=1
        fi
    fi

    return $exit_code
}

# System security audit
security_audit_system() {
    print_info "Running system security audit..."

    # Check SSH permissions
    if [[ -d "$HOME/.ssh" ]]; then
        local perms
        perms=$(stat -f "%A" "$HOME/.ssh" 2>/dev/null || stat -c "%a" "$HOME/.ssh" 2>/dev/null)
        [[ "$perms" != "700" ]] && print_warning "SSH dir permissions: $perms (should be 700)"

        for key_file in "$HOME/.ssh"/id_*; do
            if [[ -f "$key_file" ]] && [[ ! "$key_file" == *.pub ]]; then
                perms=$(stat -f "%A" "$key_file" 2>/dev/null || stat -c "%a" "$key_file" 2>/dev/null)
                [[ "$perms" != "600" ]] && print_warning "SSH key $key_file: $perms (should be 600)"
            fi
        done
    fi

    # Check GPG permissions
    if [[ -d "$HOME/.gnupg" ]]; then
        local perms
        perms=$(stat -f "%A" "$HOME/.gnupg" 2>/dev/null || stat -c "%a" "$HOME/.gnupg" 2>/dev/null)
        [[ "$perms" != "700" ]] && print_warning "GPG dir permissions: $perms (should be 700)"
    fi

    # Check security tools
    print_info "Security tools:"
    for tool in gitleaks semgrep hadolint; do
        if command -v "$tool" &>/dev/null; then
            printf "  INSTALLED  %s\n" "$tool"
        else
            printf "  MISSING    %s\n" "$tool"
        fi
    done
}

# Security status
security_status() {
    echo "Security Status:"
    echo ""
    for tool in gitleaks semgrep hadolint safety; do
        if command -v "$tool" &>/dev/null; then
            printf "  INSTALLED  %s\n" "$tool"
        else
            printf "  MISSING    %s\n" "$tool"
        fi
    done
    echo ""
    echo "Run 'dot security scan' for comprehensive analysis"
    echo "Run 'dot security setup' to install missing tools"
}

# Install security tools
security_setup_tools() {
    print_info "Setting up security tools..."

    for tool_info in "gitleaks:brew install gitleaks" "semgrep:pip install semgrep" "hadolint:brew install hadolint"; do
        local tool="${tool_info%%:*}"
        local install_cmd="${tool_info#*:}"
        if ! command -v "$tool" &>/dev/null; then
            print_info "Installing $tool..."
            eval "$install_cmd" 2>/dev/null || print_warning "Failed to install $tool: $install_cmd"
        else
            print_success "$tool already installed"
        fi
    done
}

show_security_help() {
    cat << 'EOF'
dot security - Security scanning and auditing

USAGE:
    dot security <command> [options]

COMMANDS:
    scan                 Full security scan (deps + code + secrets + containers)
    deps                 Dependency vulnerability scanning
    code                 Static code analysis
    secrets              Secret detection (gitleaks/truffleHog)
    container            Docker security analysis
    audit                System security audit (permissions, keys)
    status               Show installed security tools
    setup                Install security scanning tools

OPTIONS:
    --quiet              Suppress output, return only exit code
    --json               Machine-readable JSON output

EXAMPLES:
    dot security scan              # Full scan
    dot security scan --json       # Machine-readable output
    dot security secrets           # Check for exposed secrets
    dot security audit             # Check file permissions
    dot security setup             # Install gitleaks/semgrep/hadolint
EOF
}
