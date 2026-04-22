#!/usr/bin/env bash
# ============================================================================
# AI Security Helper
# Security warnings and status for AI tool integrations
# ============================================================================

AI_SECURITY_ENABLED=${AI_SECURITY_ENABLED:-true}
AI_ALLOW_CODE_SHARING=${AI_ALLOW_CODE_SHARING:-false}
AI_ALLOW_GIT_DATA=${AI_ALLOW_GIT_DATA:-false}
AI_WARN_ON_SENSITIVE=${AI_WARN_ON_SENSITIVE:-true}

print_security_warning() {
    local action="$1"
    echo ""
    echo "SECURITY WARNING"
    echo "You're about to $action"
    echo "This will send your code/data to external AI services."
    echo ""
    echo "Risks: code transmitted to third-party servers, sensitive data could leak"
    echo "Alternatives: use local LLMs (Ollama), review code manually"
    echo ""
}

ai-security-status() {
    echo "AI Security Configuration:"
    echo "  Security Enabled: $AI_SECURITY_ENABLED"
    echo "  Allow Code Sharing: $AI_ALLOW_CODE_SHARING"
    echo "  Allow Git Data: $AI_ALLOW_GIT_DATA"
    echo "  Warn on Sensitive: $AI_WARN_ON_SENSITIVE"
    echo ""
    echo "Set these env vars to modify: AI_SECURITY_ENABLED, AI_ALLOW_CODE_SHARING, AI_ALLOW_GIT_DATA, AI_WARN_ON_SENSITIVE"
}
