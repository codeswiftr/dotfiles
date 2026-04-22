#!/usr/bin/env bash
# =============================================================================
# AI Integration Backend
# Provider detection, API dispatch, and security filtering
# =============================================================================

# AI Configuration
AI_CONFIG_DIR="$HOME/.config/ai"
AI_CACHE_DIR="$HOME/.cache/ai"
AI_LOG_FILE="$AI_CACHE_DIR/ai.log"

ai_log() {
    local level="$1"
    shift
    [[ -d "$AI_CACHE_DIR" ]] || mkdir -p "$AI_CACHE_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$AI_LOG_FILE"
}

# Provider detection
detect_ai_providers() {
    local available_providers=()
    command -v claude >/dev/null 2>&1 && available_providers+=("claude")
    command -v openai >/dev/null 2>&1 || [[ -n "$OPENAI_API_KEY" ]] && available_providers+=("openai")
    command -v gemini >/dev/null 2>&1 || [[ -n "$GEMINI_API_KEY" ]] && available_providers+=("gemini")
    command -v gh >/dev/null 2>&1 && gh extension list 2>/dev/null | grep -q copilot && available_providers+=("copilot")
    command -v ollama >/dev/null 2>&1 && available_providers+=("local")
    echo "${available_providers[@]}"
}

detect_preferred_provider() {
    local available
    available=($(detect_ai_providers))
    for provider in "claude" "openai" "gemini" "copilot" "local"; do
        for avail in "${available[@]}"; do
            if [[ "$provider" == "$avail" ]]; then
                echo "$provider"
                return 0
            fi
        done
    done
    echo "none"
}

# Provider implementations (API-level calls)
claude_provider_implementation() {
    local prompt="$1" context="$2" model="${3:-claude-sonnet-4-20250514}"
    if [[ -z "$ANTHROPIC_API_KEY" ]]; then
        echo "Error: ANTHROPIC_API_KEY not set"
        return 1
    fi
    ai_log "INFO" "Claude API call with model: $model"
    local response
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$(jq -n --arg model "$model" --arg content "$prompt\n\n$context" \
            '{model: $model, max_tokens: 4096, temperature: 0.1, messages: [{role: "user", content: $content}]}')" 2>/dev/null)
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        echo "$response" | jq -r '.content[0].text // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "Claude API call failed"
        echo "Error: Failed to communicate with Claude API"
        return 1
    fi
}

openai_provider_implementation() {
    local prompt="$1" context="$2" model="${3:-gpt-4}"
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "Error: OPENAI_API_KEY not set"
        return 1
    fi
    ai_log "INFO" "OpenAI API call with model: $model"
    local response
    response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$(jq -n --arg model "$model" --arg content "$prompt\n\n$context" \
            '{model: $model, messages: [{role: "user", content: $content}], max_tokens: 4096, temperature: 0.1}')" 2>/dev/null)
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        echo "$response" | jq -r '.choices[0].message.content // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "OpenAI API call failed"
        echo "Error: Failed to communicate with OpenAI API"
        return 1
    fi
}

gemini_provider_implementation() {
    local prompt="$1" context="$2" model="${3:-gemini-pro}"
    if [[ -z "$GEMINI_API_KEY" ]]; then
        echo "Error: GEMINI_API_KEY not set"
        return 1
    fi
    ai_log "INFO" "Gemini API call with model: $model"
    local response
    response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg content "$prompt\n\n$context" \
            '{contents: [{parts: [{text: $content}]}], generationConfig: {temperature: 0.1, maxOutputTokens: 4096}}')" 2>/dev/null)
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "Gemini API call failed"
        echo "Error: Failed to communicate with Gemini API"
        return 1
    fi
}

local_ai_implementation() {
    local prompt="$1" context="$2" model="${3:-llama2}"
    if ! command -v ollama >/dev/null 2>&1; then
        echo "Error: Ollama not found. Install from: https://ollama.ai"
        return 1
    fi
    ai_log "INFO" "Local AI call with model: $model"
    local response
    response=$(curl -s -X POST "http://localhost:11434/api/generate" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg model "$model" --arg prompt "$prompt\n\n$context" \
            '{model: $model, prompt: $prompt, stream: false, options: {temperature: 0.1, top_p: 0.9}}')" 2>/dev/null)
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        echo "$response" | jq -r '.response // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "Local AI call failed"
        echo "Error: Failed to communicate with local AI (Ollama)"
        return 1
    fi
}

# Unified API dispatch
ai_api_call() {
    local provider="$1" prompt="$2" context="$3" model="$4"
    local filtered_context
    filtered_context=$(ai_security_filtering "$context")
    case "$provider" in
        "claude")  claude_provider_implementation "$prompt" "$filtered_context" "$model" ;;
        "openai")  openai_provider_implementation "$prompt" "$filtered_context" "$model" ;;
        "gemini")  gemini_provider_implementation "$prompt" "$filtered_context" "$model" ;;
        "local"|"ollama") local_ai_implementation "$prompt" "$filtered_context" "$model" ;;
        *)
            echo "Unknown AI provider: $provider"
            return 1
            ;;
    esac
}

# Security filtering to prevent sensitive data exposure
ai_security_filtering() {
    local content="$1"
    echo "$content" | \
        sed -E 's/(password|passwd|pwd|secret|key|token|api_key|apikey)=[^[:space:]]+/\1=***FILTERED***/gi' | \
        sed -E 's/(password|passwd|pwd|secret|key|token|api_key|apikey)[[:space:]]*:[[:space:]]*["'"'"'][^"'"'"']+["'"'"']/\1: "***FILTERED***/gi'
}
