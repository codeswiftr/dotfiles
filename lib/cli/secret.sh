#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Secret Management
# Secure secret management with multiple provider support
# ============================================================================

# Secret command dispatcher
dot_secret() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "setup")
            secret_setup_provider "$@"
            ;;
        "get")
            secret_get_value "$@"
            ;;
        "set")
            secret_set_value "$@"
            ;;
        "list")
            secret_list_keys "$@"
            ;;
        "exec")
            secret_exec_with_env "$@"
            ;;
        "status")
            secret_status
            ;;
        "provider")
            secret_manage_provider "$@"
            ;;
        "validate")
            secret_validate_config
            ;;
        "-h"|"--help"|"")
            show_secret_help
            ;;
        *)
            print_error "Unknown secret subcommand: $subcommand"
            echo "Run 'dot secret --help' for available commands."
            return 1
            ;;
    esac
}

# Setup secret provider
secret_setup_provider() {
    local provider="${1:-}"
    
    if [[ -z "$provider" ]]; then
        echo "Available secret providers:"
        echo "1) 1Password CLI (op)"
        echo "2) Doppler"
        echo "3) HashiCorp Vault"
        echo "4) AWS Secrets Manager"
        echo "5) Environment files (.env)"
        echo -n "Select provider [1-5]: "
        read -r choice
        
        case "$choice" in
            1) provider="1password" ;;
            2) provider="doppler" ;;
            3) provider="vault" ;;
            4) provider="aws-secrets" ;;
            5) provider="env-file" ;;
            *) print_error "Invalid choice" && return 1 ;;
        esac
    fi
    
    case "$provider" in
        "1password"|"op")
            setup_1password
            ;;
        "doppler")
            setup_doppler
            ;;
        "vault")
            setup_vault
            ;;
        "aws-secrets")
            setup_aws_secrets
            ;;
        "env-file")
            setup_env_file
            ;;
        *)
            print_error "Unknown provider: $provider"
            echo "Supported providers: 1password, doppler, vault, aws-secrets, env-file"
            return 1
            ;;
    esac
}

# Get secret value
secret_get_value() {
    local key="$1"
    local provider="${SECRET_PROVIDER:-}"
    
    if [[ -z "$key" ]]; then
        print_error "Please specify a secret key"
        echo "Usage: dot secret get <key>"
        return 1
    fi
    
    if [[ -z "$provider" ]]; then
        provider=$(detect_secret_provider)
    fi
    
    case "$provider" in
        "1password")
            get_secret_1password "$key"
            ;;
        "doppler")
            get_secret_doppler "$key"
            ;;
        "vault")
            get_secret_vault "$key"
            ;;
        "aws-secrets")
            get_secret_aws "$key"
            ;;
        "env-file")
            get_secret_env_file "$key"
            ;;
        *)
            print_error "No secret provider configured"
            echo "Run 'dot secret setup' to configure a provider"
            return 1
            ;;
    esac
}

# Set secret value
secret_set_value() {
    local key="$1"
    local value="$2"
    local provider="${SECRET_PROVIDER:-}"
    
    if [[ -z "$key" ]]; then
        print_error "Please specify a secret key"
        echo "Usage: dot secret set <key> [value]"
        return 1
    fi
    
    if [[ -z "$value" ]]; then
        echo -n "Enter secret value (hidden): "
        read -rs value
        echo
    fi
    
    if [[ -z "$provider" ]]; then
        provider=$(detect_secret_provider)
    fi
    
    case "$provider" in
        "1password")
            set_secret_1password "$key" "$value"
            ;;
        "doppler")
            set_secret_doppler "$key" "$value"
            ;;
        "vault")
            set_secret_vault "$key" "$value"
            ;;
        "aws-secrets")
            set_secret_aws "$key" "$value"
            ;;
        "env-file")
            set_secret_env_file "$key" "$value"
            ;;
        *)
            print_error "No secret provider configured"
            return 1
            ;;
    esac
}

# Execute command with injected secrets
secret_exec_with_env() {
    local config_file=".secrets.yaml"
    local provider="${SECRET_PROVIDER:-}"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --config)
                config_file="$2"
                shift 2
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done
    
    if [[ $# -eq 0 ]]; then
        print_error "Please specify a command to execute"
        echo "Usage: dot secret exec [--config file] -- <command>"
        return 1
    fi
    
    if [[ ! -f "$config_file" ]]; then
        print_error "Secret configuration file not found: $config_file"
        echo "Create a .secrets.yaml file with your secret mappings"
        return 1
    fi
    
    print_info "${LOCK} Loading secrets and executing command..."
    
    # Load secrets based on configuration
    local env_vars=()
    
    if [[ -z "$provider" ]]; then
        provider=$(detect_secret_provider)
    fi
    
    # Parse YAML config and load secrets
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)[[:space:]]*:[[:space:]]*(.+)$ ]]; then
            local env_var="${BASH_REMATCH[1]}"
            local secret_key="${BASH_REMATCH[2]}"
            
            local secret_value
            case "$provider" in
                "1password")
                    secret_value=$(get_secret_1password "$secret_key")
                    ;;
                "doppler")
                    secret_value=$(get_secret_doppler "$secret_key")
                    ;;
                "vault")
                    secret_value=$(get_secret_vault "$secret_key")
                    ;;
                "aws-secrets")
                    secret_value=$(get_secret_aws "$secret_key")
                    ;;
                "env-file")
                    secret_value=$(get_secret_env_file "$secret_key")
                    ;;
            esac
            
            if [[ -n "$secret_value" ]]; then
                env_vars+=("$env_var=$secret_value")
            else
                print_warning "Could not load secret: $secret_key"
            fi
        fi
    done < "$config_file"
    
    # Execute command with injected environment variables
    if [[ ${#env_vars[@]} -gt 0 ]]; then
        env "${env_vars[@]}" "$@"
    else
        print_warning "No secrets loaded, executing command without injection"
        "$@"
    fi
}

# Provider implementations
setup_1password() {
    print_info "${LOCK} Setting up 1Password CLI integration..."
    
    if ! command -v op >/dev/null 2>&1; then
        print_error "1Password CLI not found"
        echo "Install with: brew install 1password-cli"
        return 1
    fi
    
    # Check if already signed in
    if ! op account list >/dev/null 2>&1; then
        print_info "Please sign in to 1Password:"
        op signin
    fi
    
    # Create config
    mkdir -p "$HOME/.config/dotfiles"
    echo "1password" > "$HOME/.config/dotfiles/secret_provider"
    
    print_success "1Password CLI configured successfully!"
    print_info "Example usage: dot secret get 'op://vault/item/field'"
}

setup_doppler() {
    print_info "${LOCK} Setting up Doppler integration..."
    
    if ! command -v doppler >/dev/null 2>&1; then
        print_error "Doppler CLI not found"
        echo "Install with: brew install dopplerhq/cli/doppler"
        return 1
    fi
    
    print_info "Please authenticate with Doppler:"
    doppler login
    
    echo "doppler" > "$HOME/.config/dotfiles/secret_provider"
    
    print_success "Doppler configured successfully!"
    print_info "Set up your project: doppler setup"
}

setup_env_file() {
    print_info "${LOCK} Setting up environment file integration..."
    
    local env_file="${1:-.env}"
    
    if [[ ! -f "$env_file" ]]; then
        print_info "Creating example .env file..."
        cat > "$env_file" << 'EOF'
# Example environment variables
# DATABASE_URL=postgresql://user:pass@localhost/db
# API_KEY=your-api-key-here
# SECRET_TOKEN=your-secret-token
EOF
        print_info "Created $env_file - please add your secrets"
    fi
    
    echo "env-file" > "$HOME/.config/dotfiles/secret_provider"
    echo "$env_file" > "$HOME/.config/dotfiles/env_file_path"
    
    print_success "Environment file integration configured!"
    print_warning "Remember to add $env_file to .gitignore"
}

# Provider-specific secret retrieval
get_secret_1password() {
    local key="$1"
    op read "$key" 2>/dev/null
}

get_secret_doppler() {
    local key="$1"
    doppler secrets get "$key" --plain 2>/dev/null
}

get_secret_env_file() {
    local key="$1"
    local env_file_path="$HOME/.config/dotfiles/env_file_path"
    local env_file=".env"
    
    if [[ -f "$env_file_path" ]]; then
        env_file=$(cat "$env_file_path")
    fi
    
    if [[ -f "$env_file" ]]; then
        grep "^$key=" "$env_file" | cut -d'=' -f2- | sed 's/^"//;s/"$//'
    fi
}

# Utility functions
detect_secret_provider() {
    local config_file="$HOME/.config/dotfiles/secret_provider"
    
    if [[ -f "$config_file" ]]; then
        cat "$config_file"
    elif command -v op >/dev/null 2>&1 && op account list >/dev/null 2>&1; then
        echo "1password"
    elif command -v doppler >/dev/null 2>&1 && doppler me >/dev/null 2>&1; then
        echo "doppler"
    elif [[ -f ".env" ]]; then
        echo "env-file"
    else
        echo ""
    fi
}

secret_status() {
    echo "🔐 Secret Management Status:"
    echo ""
    
    local provider=$(detect_secret_provider)
    echo "Active Provider: ${provider:-None configured}"
    
    echo ""
    echo "Available Providers:"
    
    # Check 1Password
    if command -v op >/dev/null 2>&1; then
        if op account list >/dev/null 2>&1; then
            echo "  ✅ 1Password CLI (authenticated)"
        else
            echo "  🟡 1Password CLI (not signed in)"
        fi
    else
        echo "  ❌ 1Password CLI (not installed)"
    fi
    
    # Check Doppler
    if command -v doppler >/dev/null 2>&1; then
        if doppler me >/dev/null 2>&1; then
            echo "  ✅ Doppler (authenticated)"
        else
            echo "  🟡 Doppler (not authenticated)"
        fi
    else
        echo "  ❌ Doppler (not installed)"
    fi
    
    # Check Vault
    if command -v vault >/dev/null 2>&1; then
        echo "  ✅ HashiCorp Vault (installed)"
    else
        echo "  ❌ HashiCorp Vault (not installed)"
    fi
    
    # Check AWS CLI
    if command -v aws >/dev/null 2>&1; then
        echo "  ✅ AWS CLI (installed)"
    else
        echo "  ❌ AWS CLI (not installed)"
    fi
    
    # Check env file
    if [[ -f ".env" ]]; then
        echo "  ✅ Environment file (.env exists)"
    else
        echo "  🟡 Environment file (.env not found)"
    fi
    
    echo ""
    echo "Configuration:"
    echo "  Config dir: ~/.config/dotfiles/"
    echo "  Provider file: ~/.config/dotfiles/secret_provider"
    
    if [[ -f ".secrets.yaml" ]]; then
        echo "  Secrets config: .secrets.yaml (found)"
    else
        echo "  Secrets config: .secrets.yaml (not found)"
    fi
}

secret_validate_config() {
    print_info "${LOCK} Validating secret configuration..."
    
    local provider=$(detect_secret_provider)
    local exit_code=0
    
    if [[ -z "$provider" ]]; then
        print_error "No secret provider configured"
        exit_code=1
    else
        print_success "Provider detected: $provider"
    fi
    
    # Validate provider-specific setup
    case "$provider" in
        "1password")
            if ! op account list >/dev/null 2>&1; then
                print_error "1Password not authenticated"
                exit_code=1
            fi
            ;;
        "doppler")
            if ! doppler me >/dev/null 2>&1; then
                print_error "Doppler not authenticated"
                exit_code=1
            fi
            ;;
        "env-file")
            local env_file_path="$HOME/.config/dotfiles/env_file_path"
            local env_file=".env"
            if [[ -f "$env_file_path" ]]; then
                env_file=$(cat "$env_file_path")
            fi
            if [[ ! -f "$env_file" ]]; then
                print_error "Environment file not found: $env_file"
                exit_code=1
            fi
            ;;
    esac
    
    # Check for secrets configuration file
    if [[ -f ".secrets.yaml" ]]; then
        print_success "Secrets configuration found"
        
        # Validate YAML format (basic check)
        if ! grep -q ":" .secrets.yaml; then
            print_warning "Secrets configuration may have invalid format"
        fi
    else
        print_warning "No .secrets.yaml configuration found"
        echo "Create one to define environment variable mappings"
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Secret configuration is valid!"
    else
        print_error "Secret configuration has issues"
    fi
    
    return $exit_code
}

# Help function
show_secret_help() {
    cat << 'EOF'
dot secret - Secure secret management

USAGE:
    dot secret <command> [options]

COMMANDS:
    setup [provider]         Configure secret provider
    get <key>                Retrieve secret value
    set <key> [value]        Store secret value
    list                     List available secrets
    exec [--config file] -- <cmd>  Execute command with injected secrets
    status                   Show secret management status
    validate                 Validate secret configuration

PROVIDERS:
    1password               1Password CLI (op)
    doppler                 Doppler secrets management
    vault                   HashiCorp Vault
    aws-secrets             AWS Secrets Manager
    env-file                Local .env files

SECRET CONFIGURATION:
    Create a .secrets.yaml file to define environment variable mappings:
    
    DATABASE_URL: database-connection-string
    API_KEY: api-key-reference
    JWT_SECRET: jwt-secret-reference

OPTIONS:
    --config <file>         Use specific configuration file
    --provider <name>       Use specific provider
    -h, --help              Show this help message

EXAMPLES:
    dot secret setup 1password              # Setup 1Password integration
    dot secret get API_KEY                  # Get a secret value
    dot secret exec -- npm start           # Run with injected secrets
    dot secret set DATABASE_URL             # Store a secret (prompted)
    
SECURITY NOTES:
    • Secrets are never stored in dotfiles or git
    • Use secure external providers when possible
    • Environment files should be in .gitignore
    • Validate configurations regularly
EOF
}