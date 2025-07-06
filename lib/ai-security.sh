#!/usr/bin/env bash
# ============================================================================
# AI Security Helper Functions
# Provides security warnings and controls for AI tool integrations
# ============================================================================

# Security configuration
AI_SECURITY_ENABLED=${AI_SECURITY_ENABLED:-true}
AI_ALLOW_CODE_SHARING=${AI_ALLOW_CODE_SHARING:-false}
AI_ALLOW_GIT_DATA=${AI_ALLOW_GIT_DATA:-false}
AI_WARN_ON_SENSITIVE=${AI_WARN_ON_SENSITIVE:-true}

# Sensitive file patterns (add more as needed)
SENSITIVE_PATTERNS=(
    "*.key"
    "*.pem" 
    "*.p12"
    "*.env"
    ".env*"
    "*secret*"
    "*password*"
    "*token*"
    "*api_key*"
    "id_rsa*"
    "*.pfx"
    "config.json"
    "credentials*"
)

# Sensitive content patterns
SENSITIVE_CONTENT_PATTERNS=(
    "password\s*[:=]"
    "secret\s*[:=]"
    "token\s*[:=]"
    "api_key\s*[:=]"
    "private_key"
    "-----BEGIN.*PRIVATE KEY-----"
    "ssh-rsa"
    "ecdsa-sha2"
    "BEGIN PGP"
    "client_secret"
    "access_token"
)

# Print security warning
print_security_warning() {
    local action="$1"
    echo ""
    echo "🔒 ⚠️  SECURITY WARNING ⚠️ 🔒"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "You're about to $action"
    echo "This will send your code/data to external AI services."
    echo ""
    echo "🚨 RISKS:"
    echo "  • Your code will be transmitted to third-party servers"
    echo "  • Proprietary/confidential code may be exposed"
    echo "  • Sensitive data (keys, passwords) could be leaked"
    echo "  • Company policies may prohibit this action"
    echo ""
    echo "💡 SAFER ALTERNATIVES:"
    echo "  • Use local LLMs (Ollama, LM Studio)"
    echo "  • Review code manually"
    echo "  • Use offline tools"
    echo ""
}

# Check if content contains sensitive data
check_sensitive_content() {
    local content="$1"
    local found_sensitive=false
    
    for pattern in "${SENSITIVE_CONTENT_PATTERNS[@]}"; do
        if echo "$content" | grep -iE "$pattern" >/dev/null 2>&1; then
            echo "🚨 SENSITIVE DATA DETECTED: Pattern '$pattern' found"
            found_sensitive=true
        fi
    done
    
    return $found_sensitive
}

# Check if file is potentially sensitive
check_sensitive_file() {
    local file="$1"
    
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if [[ "$file" == $pattern ]]; then
            echo "🚨 SENSITIVE FILE: $file matches pattern '$pattern'"
            return 0
        fi
    done
    return 1
}

# Security prompt for user confirmation
security_prompt() {
    local action="$1"
    local files="$2"
    
    if [[ "$AI_SECURITY_ENABLED" != "true" ]]; then
        return 0
    fi
    
    print_security_warning "$action"
    
    if [[ -n "$files" ]]; then
        echo "📁 FILES TO BE SENT:"
        echo "$files" | tr ' ' '\n' | sed 's/^/  • /'
        echo ""
        
        # Check for sensitive files
        local has_sensitive=false
        for file in $files; do
            if check_sensitive_file "$file"; then
                has_sensitive=true
            fi
        done
        
        if [[ "$has_sensitive" == "true" ]]; then
            echo "🔥 CRITICAL: Sensitive files detected!"
            echo "❌ Operation blocked for security."
            return 1
        fi
    fi
    
    echo "Continue? Type 'YES' to confirm (anything else cancels):"
    read -r confirmation
    
    if [[ "$confirmation" != "YES" ]]; then
        echo "❌ Operation cancelled by user."
        return 1
    fi
    
    echo "✅ Proceeding with AI request..."
    return 0
}

# Safe AI wrapper function
safe_ai_call() {
    local ai_tool="$1"
    local prompt="$2"
    shift 2
    local files="$@"
    
    local action="send code to $ai_tool"
    [[ -n "$files" ]] && action="$action with files: $files"
    
    if ! security_prompt "$action" "$files"; then
        return 1
    fi
    
    # Execute the AI call
    if [[ -n "$files" ]]; then
        "$ai_tool" "$prompt" $files
    else
        "$ai_tool" "$prompt"
    fi
}

# Configuration commands
ai-security-status() {
    echo "🔒 AI Security Configuration:"
    echo "  Security Enabled: $AI_SECURITY_ENABLED"
    echo "  Allow Code Sharing: $AI_ALLOW_CODE_SHARING"
    echo "  Allow Git Data: $AI_ALLOW_GIT_DATA"
    echo "  Warn on Sensitive: $AI_WARN_ON_SENSITIVE"
    echo ""
    echo "💡 To modify settings, set these environment variables:"
    echo "  export AI_SECURITY_ENABLED=false    # Disable all security checks"
    echo "  export AI_ALLOW_CODE_SHARING=true   # Allow code sharing without prompts"
    echo "  export AI_ALLOW_GIT_DATA=true       # Allow git data sharing"
    echo "  export AI_WARN_ON_SENSITIVE=false   # Disable sensitive content warnings"
}

ai-security-enable() {
    export AI_SECURITY_ENABLED=true
    echo "✅ AI security checks enabled"
}

ai-security-disable() {
    export AI_SECURITY_ENABLED=false
    echo "⚠️  AI security checks disabled"
}

ai-security-strict() {
    export AI_SECURITY_ENABLED=true
    export AI_ALLOW_CODE_SHARING=false
    export AI_ALLOW_GIT_DATA=false
    export AI_WARN_ON_SENSITIVE=true
    echo "🔒 AI security set to STRICT mode"
}

ai-security-permissive() {
    export AI_ALLOW_CODE_SHARING=true
    export AI_ALLOW_GIT_DATA=true
    export AI_WARN_ON_SENSITIVE=false
    echo "🔓 AI security set to PERMISSIVE mode"
}