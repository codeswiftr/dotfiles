#!/usr/bin/env bash
# =============================================================================
# AI Integration Framework
# Unified AI assistance across all development tools and workflows
# =============================================================================

# AI Configuration
AI_CONFIG_DIR="$HOME/.config/ai"
AI_CACHE_DIR="$HOME/.cache/ai"
AI_LOG_FILE="$AI_CACHE_DIR/ai.log"

# Supported AI providers
AI_PROVIDERS=(
    "claude"
    "openai"
    "gemini"
    "copilot"
    "local"
)

# AI Integration utilities
ai_log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$AI_LOG_FILE"
}

ai_setup_dirs() {
    mkdir -p "$AI_CONFIG_DIR" "$AI_CACHE_DIR"
}

# Provider detection and configuration
detect_ai_providers() {
    local available_providers=()
    
    # Check for Claude CLI
    if command -v claude >/dev/null 2>&1; then
        available_providers+=("claude")
    fi
    
    # Check for OpenAI CLI
    if command -v openai >/dev/null 2>&1 || [[ -n "$OPENAI_API_KEY" ]]; then
        available_providers+=("openai")
    fi
    
    # Check for Gemini CLI
    if command -v gemini >/dev/null 2>&1 || [[ -n "$GEMINI_API_KEY" ]]; then
        available_providers+=("gemini")
    fi
    
    # Check for GitHub Copilot
    if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
        available_providers+=("copilot")
    fi
    
    # Check for local AI (ollama, etc.)
    if command -v ollama >/dev/null 2>&1; then
        available_providers+=("local")
    fi
    
    echo "${available_providers[@]}"
}

# AI-powered commit messages
ai_generate_commit() {
    local staged_files=$(git diff --cached --name-only)
    local diff_content=$(git diff --cached)
    
    if [[ -z "$diff_content" ]]; then
        echo "No staged changes to commit"
        return 1
    fi
    
    ai_log "INFO" "Generating AI commit message"
    
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    case "$provider" in
        "claude")
            ai_commit_claude
            ;;
        "openai")
            ai_commit_openai
            ;;
        "gemini")
            ai_commit_gemini
            ;;
        "copilot")
            ai_commit_copilot
            ;;
        *)
            echo "No AI provider available for commit message generation"
            return 1
            ;;
    esac
}

ai_commit_claude() {
    local diff_content=$(git diff --cached)
    
    if command -v claude >/dev/null 2>&1; then
        local commit_msg=$(echo "$diff_content" | claude \
            "Generate a concise, conventional commit message for this diff. 
            Use format: type(scope): description
            Types: feat, fix, docs, style, refactor, test, chore
            Keep under 72 characters.")
        
        echo "🤖 Suggested commit message:"
        echo "$commit_msg"
        echo ""
        
        read -p "Use this commit message? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git commit -m "$commit_msg"
        else
            echo "Commit cancelled"
        fi
    else
        echo "⚠️ Claude CLI not available"
    fi
}

ai_commit_openai() {
    local diff_content=$(git diff --cached)
    
    if [[ -n "$OPENAI_API_KEY" ]]; then
        local commit_prompt="Generate a concise, conventional commit message for this diff.
Use format: type(scope): description
Types: feat, fix, docs, style, refactor, test, chore
Keep under 72 characters."
        
        local commit_msg=$(openai_provider_implementation "$commit_prompt" "$diff_content" | head -1)
        
        if [[ -n "$commit_msg" ]] && [[ "$commit_msg" != "Error:"* ]]; then
            echo "🤖 Suggested commit message:"
            echo "$commit_msg"
            echo ""
            
            read -p "Use this commit message? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git commit -m "$commit_msg"
            else
                echo "Commit cancelled"
            fi
        else
            echo "⚠️ Failed to generate commit message"
            return 1
        fi
    else
        echo "⚠️ OPENAI_API_KEY not set"
        return 1
    fi
}

ai_commit_gemini() {
    local diff_content=$(git diff --cached)
    
    if [[ -n "$GEMINI_API_KEY" ]]; then
        local commit_prompt="Generate a concise, conventional commit message for this diff.
Use format: type(scope): description
Types: feat, fix, docs, style, refactor, test, chore
Keep under 72 characters."
        
        local commit_msg=$(gemini_provider_implementation "$commit_prompt" "$diff_content" | head -1)
        
        if [[ -n "$commit_msg" ]] && [[ "$commit_msg" != "Error:"* ]]; then
            echo "🤖 Suggested commit message:"
            echo "$commit_msg"
            echo ""
            
            read -p "Use this commit message? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git commit -m "$commit_msg"
            else
                echo "Commit cancelled"
            fi
        else
            echo "⚠️ Failed to generate commit message"
            return 1
        fi
    else
        echo "⚠️ GEMINI_API_KEY not set"
        return 1
    fi
}

ai_commit_copilot() {
    if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
        gh copilot suggest "git commit"
    else
        echo "⚠️ GitHub Copilot CLI not available"
    fi
}

# AI-powered documentation
ai_generate_docs() {
    local target="${1:-.}"
    local doc_type="${2:-readme}"
    
    ai_log "INFO" "Generating documentation for $target type: $doc_type"
    
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    case "$doc_type" in
        "readme")
            ai_generate_readme "$target" "$provider"
            ;;
        "api")
            ai_generate_api_docs "$target" "$provider"
            ;;
        "comments")
            ai_generate_code_comments "$target" "$provider"
            ;;
        *)
            echo "Unknown documentation type: $doc_type"
            return 1
            ;;
    esac
}

ai_generate_readme() {
    local target="$1"
    local provider="$2"
    
    echo "🤖 Generating README.md for $target"
    
    local project_files=$(find "$target" -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" | head -10)
    local package_files=$(find "$target" -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "go.mod")
    
    local context="Project structure:\n"
    context+="$(tree -L 2 "$target" 2>/dev/null || ls -la "$target")\n\n"
    
    if [[ -n "$package_files" ]]; then
        context+="Package files:\n"
        for file in $package_files; do
            context+="--- $file ---\n"
            context+="$(cat "$file")\n\n"
        done
    fi
    
    context+="Sample code files:\n"
    for file in $project_files; do
        context+="--- $file ---\n"
        context+="$(head -50 "$file")\n\n"
    done
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                echo "$context" | claude \
                    "Generate a comprehensive README.md for this project. Include:
                    1. Project title and description
                    2. Installation instructions
                    3. Usage examples
                    4. API documentation if applicable
                    5. Contributing guidelines
                    6. License information
                    
                    Make it professional and easy to follow." > README.md
                echo "✅ README.md generated"
            fi
            ;;
    esac
}

# AI-powered refactoring suggestions
ai_suggest_refactor() {
    local target_file="$1"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    ai_log "INFO" "Generating refactoring suggestions for $target_file"
    
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    local file_content=$(cat "$target_file")
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                echo "🤖 Refactoring suggestions for $target_file:"
                echo "$file_content" | claude \
                    "Analyze this code and suggest refactoring improvements:
                    1. Code structure and organization
                    2. Performance optimizations
                    3. Readability improvements
                    4. Best practices adherence
                    5. Potential bugs or issues
                    
                    Provide specific examples and explanations."
            fi
            ;;
    esac
}

# AI provider preference detection
detect_preferred_provider() {
    local available=($(detect_ai_providers))
    
    # Return first available provider in order of preference
    for provider in "claude" "openai" "gemini" "copilot" "local"; do
        for available_provider in "${available[@]}"; do
            if [[ "$provider" == "$available_provider" ]]; then
                echo "$provider"
                return 0
            fi
        done
    done
    
    echo "none"
}

# AI integration setup
setup_ai_integration() {
    ai_setup_dirs
    
    echo "🤖 Setting up AI integration..."
    
    # Detect available providers
    local providers=($(detect_ai_providers))
    
    echo "Available AI providers:"
    for provider in "${providers[@]}"; do
        echo "  ✅ $provider"
    done
    
    if [[ ${#providers[@]} -eq 0 ]]; then
        echo "No AI providers detected. Install one of:"
        echo "  • claude CLI: pip install claude-cli"
        echo "  • GitHub Copilot: gh extension install github/gh-copilot"
        echo "  • Gemini CLI: pip install google-generativeai"
        echo "  • OpenAI CLI: pip install openai"
        echo "  • Ollama: https://ollama.ai"
    fi
    
    # Create AI configuration
    cat > "$AI_CONFIG_DIR/config.yaml" << EOF
# AI Integration Configuration
default_provider: $(detect_preferred_provider)
providers:
  claude:
    model: claude-3-sonnet-20240229
    temperature: 0.1
  openai:
    model: gpt-4
    temperature: 0.1
  gemini:
    model: gemini-pro
    temperature: 0.1

features:
  code_review: true
  commit_messages: true
  test_generation: true
  documentation: true
  refactoring: true
  
cache:
  enabled: true
  ttl: 3600
  
logging:
  level: INFO
  file: $AI_LOG_FILE
EOF
    
    echo "✅ AI integration configured"
    echo "📁 Config: $AI_CONFIG_DIR/config.yaml"
    echo "📝 Logs: $AI_LOG_FILE"
}

# === EPIC 5.1: AI PROVIDER IMPLEMENTATIONS ===

# Claude API Integration
claude_provider_implementation() {
    local prompt="$1"
    local context="$2"
    local model="${3:-claude-3-sonnet-20240229}"
    
    if [[ -z "$ANTHROPIC_API_KEY" ]]; then
        echo "⚠️ ANTHROPIC_API_KEY not set"
        return 1
    fi
    
    ai_log "INFO" "Making Claude API call with model: $model"
    
    local request_body
    request_body=$(cat <<EOF
{
    "model": "$model",
    "max_tokens": 4096,
    "temperature": 0.1,
    "messages": [
        {
            "role": "user",
            "content": "$prompt\n\n$context"
        }
    ]
}
EOF
)
    
    local response
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$request_body" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        # Extract content from Claude response
        echo "$response" | jq -r '.content[0].text // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "Claude API call failed"
        echo "Error: Failed to communicate with Claude API"
        return 1
    fi
}

# OpenAI API Integration
openai_provider_implementation() {
    local prompt="$1"
    local context="$2"
    local model="${3:-gpt-4}"
    
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "⚠️ OPENAI_API_KEY not set"
        return 1
    fi
    
    ai_log "INFO" "Making OpenAI API call with model: $model"
    
    local request_body
    request_body=$(cat <<EOF
{
    "model": "$model",
    "messages": [
        {
            "role": "user",
            "content": "$prompt\n\n$context"
        }
    ],
    "max_tokens": 4096,
    "temperature": 0.1
}
EOF
)
    
    local response
    response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$request_body" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        # Extract content from OpenAI response
        echo "$response" | jq -r '.choices[0].message.content // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "OpenAI API call failed"
        echo "Error: Failed to communicate with OpenAI API"
        return 1
    fi
}

# Gemini API Integration
gemini_provider_implementation() {
    local prompt="$1"
    local context="$2"
    local model="${3:-gemini-pro}"
    
    if [[ -z "$GEMINI_API_KEY" ]]; then
        echo "⚠️ GEMINI_API_KEY not set"
        return 1
    fi
    
    ai_log "INFO" "Making Gemini API call with model: $model"
    
    local request_body
    request_body=$(cat <<EOF
{
    "contents": [
        {
            "parts": [
                {
                    "text": "$prompt\n\n$context"
                }
            ]
        }
    ],
    "generationConfig": {
        "temperature": 0.1,
        "maxOutputTokens": 4096
    }
}
EOF
)
    
    local response
    response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$request_body" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        # Extract content from Gemini response
        echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "Gemini API call failed"
        echo "Error: Failed to communicate with Gemini API"
        return 1
    fi
}

# Local AI Integration (Ollama)
local_ai_implementation() {
    local prompt="$1"
    local context="$2"
    local model="${3:-llama2}"
    
    if ! command -v ollama >/dev/null 2>&1; then
        echo "⚠️ Ollama not found. Install from: https://ollama.ai"
        return 1
    fi
    
    ai_log "INFO" "Making local AI call with model: $model"
    
    local request_body
    request_body=$(cat <<EOF
{
    "model": "$model",
    "prompt": "$prompt\n\n$context",
    "stream": false,
    "options": {
        "temperature": 0.1,
        "top_p": 0.9
    }
}
EOF
)
    
    local response
    response=$(curl -s -X POST "http://localhost:11434/api/generate" \
        -H "Content-Type: application/json" \
        -d "$request_body" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        # Extract content from Ollama response
        echo "$response" | jq -r '.response // "Error: Invalid response"' 2>/dev/null
    else
        ai_log "ERROR" "Local AI call failed"
        echo "Error: Failed to communicate with local AI (Ollama)"
        return 1
    fi
}

# Unified API call wrapper
ai_api_call() {
    local provider="$1"
    local prompt="$2"
    local context="$3"
    local model="$4"
    
    # Apply security filtering to context
    local filtered_context=$(ai_security_filtering "$context")
    
    # Check cost optimization
    if ! ai_cost_optimization "$provider" "$prompt" "$filtered_context"; then
        return 1
    fi
    
    case "$provider" in
        "claude")
            claude_provider_implementation "$prompt" "$filtered_context" "$model"
            ;;
        "openai")
            openai_provider_implementation "$prompt" "$filtered_context" "$model"
            ;;
        "gemini")
            gemini_provider_implementation "$prompt" "$filtered_context" "$model"
            ;;
        "local"|"ollama")
            local_ai_implementation "$prompt" "$filtered_context" "$model"
            ;;
        *)
            echo "Unknown AI provider: $provider"
            return 1
            ;;
    esac
}

# Convenience wrappers for backward compatibility
openai_api_call() {
    local prompt="$1"
    local context="$2"
    openai_provider_implementation "$prompt" "$context"
}

gemini_api_call() {
    local prompt="$1"
    local context="$2"
    gemini_provider_implementation "$prompt" "$context"
}

ai_security_scan() {
    local target_dir="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    echo "🔒 AI Security Scan for $target_dir"
    
    # Find potentially sensitive files
    local sensitive_files=$(find "$target_dir" -name "*.env*" -o -name "*config*" -o -name "*secret*" -o -name "*key*" 2>/dev/null | head -10)
    
    for file in $sensitive_files; do
        if [[ -f "$file" ]]; then
            echo "🔍 Scanning: $file"
            ai_analyze_security "$file" "$provider"
        fi
    done
}

ai_analyze_security() {
    local file="$1"
    local provider="$2"
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                local content=$(cat "$file")
                echo "$content" | claude \
                    "Analyze this file for security issues:
                    1. Exposed secrets or credentials
                    2. Unsafe configurations
                    3. Potential vulnerabilities
                    4. Best practice violations
                    5. Recommendations for improvement
                    
                    Provide specific actionable advice."
            fi
            ;;
    esac
}

ai_performance_analysis() {
    local target_dir="$1"
    local language="${2:-auto}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    echo "⚡ AI Performance Analysis for $target_dir"
    
    # Find performance-critical files
    local perf_files
    case "$language" in
        "python")
            perf_files=$(find "$target_dir" -name "*.py" | head -5)
            ;;
        "javascript")
            perf_files=$(find "$target_dir" -name "*.js" -o -name "*.ts" | head -5)
            ;;
        "rust")
            perf_files=$(find "$target_dir" -name "*.rs" | head -5)
            ;;
        "go")
            perf_files=$(find "$target_dir" -name "*.go" | head -5)
            ;;
        *)
            perf_files=$(find "$target_dir" -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" | head -5)
            ;;
    esac
    
    for file in $perf_files; do
        if [[ -f "$file" ]]; then
            echo "🎯 Analyzing: $file"
            ai_analyze_performance "$file" "$provider"
        fi
    done
}

ai_analyze_performance() {
    local file="$1"
    local provider="$2"
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                local content=$(cat "$file")
                echo "$content" | claude \
                    "Analyze this code for performance optimizations:
                    1. Time complexity issues
                    2. Memory usage patterns
                    3. I/O efficiency
                    4. Algorithm optimizations
                    5. Caching opportunities
                    6. Specific improvements with code examples
                    
                    Focus on practical, implementable suggestions."
            fi
            ;;
    esac
}

ai_analyze_dependencies() {
    local package_manager="$1"
    local config_file="$2"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                local content=$(cat "$config_file")
                echo "$content" | claude \
                    "Analyze these $package_manager dependencies:
                    1. Security vulnerabilities
                    2. Outdated packages
                    3. Unused dependencies
                    4. Bundle size impact
                    5. Alternative packages
                    6. Best practices for dependency management
                    
                    Provide specific upgrade recommendations."
            fi
            ;;
    esac
}

ai_explain_concept() {
    local topic="$1"
    local context="$2"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                claude "Explain '$topic' in the context of $context development:
                1. Core concepts and principles
                2. When and why to use it
                3. Common patterns and best practices
                4. Code examples with explanations
                5. Common pitfalls and how to avoid them
                6. Related concepts and further reading
                
                Make it educational for a developer."
            fi
            ;;
    esac
}

ai_resolve_error() {
    local error_message="$1"
    local file_context="$2"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    local context_content=""
    if [[ -f "$file_context" ]]; then
        context_content=$(cat "$file_context")
    fi
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                echo "Error: $error_message
                
                File context:
                $context_content" | claude \
                    "Help resolve this error:
                    1. Explain what the error means
                    2. Identify the root cause
                    3. Provide step-by-step solution
                    4. Show corrected code examples
                    5. Suggest prevention strategies
                    6. Related documentation or resources
                    
                    Be specific and actionable."
            fi
            ;;
    esac
}

ai_migrate_code() {
    local from_tech="$1"
    local to_tech="$2"
    local target_file="$3"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    local file_content=$(cat "$target_file")
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                echo "$file_content" | claude \
                    "Migrate this code from $from_tech to $to_tech:
                    1. Convert syntax and idioms
                    2. Update library/framework usage
                    3. Adapt to best practices for $to_tech
                    4. Maintain functionality and logic
                    5. Add comments explaining changes
                    6. Suggest testing strategies for migration
                    
                    Provide complete, working code."
            fi
            ;;
    esac
}

ai_dependency_security_check() {
    local target_dir="$1"
    
    echo "📦 Checking dependency security..."
    
    # Check different package managers
    if [[ -f "$target_dir/package.json" ]]; then
        if command -v npm >/dev/null 2>&1; then
            npm audit || true
        fi
    fi
    
    if [[ -f "$target_dir/requirements.txt" ]] || [[ -f "$target_dir/pyproject.toml" ]]; then
        if command -v safety >/dev/null 2>&1; then
            safety check || true
        fi
    fi
    
    if [[ -f "$target_dir/Cargo.toml" ]]; then
        if command -v cargo-audit >/dev/null 2>&1; then
            cargo audit || true
        fi
    fi
}

ai_config_security_review() {
    local target_dir="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    # Find configuration files
    local config_files=$(find "$target_dir" -name "*.env*" -o -name "config.*" -o -name "*.config.*" 2>/dev/null | head -5)
    
    for file in $config_files; do
        if [[ -f "$file" ]]; then
            echo "⚙️ Reviewing config: $file"
            ai_analyze_config_security "$file" "$provider"
        fi
    done
}

ai_analyze_config_security() {
    local file="$1"
    local provider="$2"
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                local content=$(cat "$file")
                echo "$content" | claude \
                    "Review this configuration file for security:
                    1. Exposed sensitive information
                    2. Insecure default settings
                    3. Missing security headers/options
                    4. Overly permissive permissions
                    5. Best practice recommendations
                    
                    Provide specific fixes and alternatives."
            fi
            ;;
    esac
}

ai_generate_security_report() {
    local target_dir="$1"
    local report_file="$target_dir/security-report.md"
    
    echo "📊 Generating security report: $report_file"
    
    cat > "$report_file" << EOF
# Security Analysis Report

**Generated:** $(date)
**Target:** $target_dir

## Summary

This report contains AI-generated security analysis and recommendations.

## Dependency Security

$(ai_dependency_security_check "$target_dir" 2>&1)

## Configuration Security

$(ai_config_security_review "$target_dir" 2>&1)

## Recommendations

- Keep dependencies updated
- Use environment variables for secrets
- Enable security headers
- Regular security audits
- Code review process

---
*Generated by AI Security Assistant*
EOF
    
    echo "✅ Security report generated: $report_file"
}

ai_generate_project_metrics() {
    local target_dir="$1"
    
    echo "📊 Generating project metrics..."
    
    # Lines of code
    local loc=$(find "$target_dir" -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
    
    # Number of files
    local file_count=$(find "$target_dir" -type f 2>/dev/null | wc -l)
    
    # Git stats if available
    local commit_count="N/A"
    local contributors="N/A"
    if git -C "$target_dir" rev-parse --git-dir >/dev/null 2>&1; then
        commit_count=$(git -C "$target_dir" rev-list --count HEAD 2>/dev/null || echo "N/A")
        contributors=$(git -C "$target_dir" shortlog -sn | wc -l 2>/dev/null || echo "N/A")
    fi
    
    echo "Project Metrics:"
    echo "- Lines of Code: $loc"
    echo "- Files: $file_count"
    echo "- Commits: $commit_count"
    echo "- Contributors: $contributors"
}

# === EPIC 5.2: CODE INTELLIGENCE (Enhanced versions) ===

# Enhanced AI code review with comprehensive analysis
ai_code_review() {
    local files=("$@")
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    if [[ ${#files[@]} -eq 0 ]]; then
        # Auto-detect files to review
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # Review staged or recent changes
            files=($(git diff --name-only --cached 2>/dev/null))
            if [[ ${#files[@]} -eq 0 ]]; then
                files=($(git diff --name-only HEAD~1 2>/dev/null))
            fi
        fi
        
        # Fallback to common source files
        if [[ ${#files[@]} -eq 0 ]]; then
            files=($(find . -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" | head -5))
        fi
    fi
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files found for review"
        return 1
    fi
    
    ai_log "INFO" "Starting comprehensive AI code review with provider: $provider"
    
    echo "🤖 AI Code Review Analysis"
    echo "Provider: $provider"
    echo "Files: ${files[*]}"
    echo ""
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "📁 Reviewing: $file"
            ai_review_file "$file" "$provider"
            echo ""
        fi
    done
}

ai_review_file() {
    local file="$1"
    local provider="$2"
    local file_content=$(cat "$file")
    
    local review_prompt="Please review this code file comprehensively:

FILE: $file

Analysis areas:
1. Security vulnerabilities and potential attack vectors
2. Performance bottlenecks and optimization opportunities
3. Code quality, readability, and maintainability
4. Best practices adherence for the language/framework
5. Potential bugs and edge cases
6. Error handling and resilience
7. Documentation and comments quality
8. Testing considerations

Provide specific, actionable recommendations with code examples where helpful."
    
    local response=$(ai_api_call "$provider" "$review_prompt" "$file_content")
    if [[ -n "$response" ]] && [[ "$response" != "Error:"* ]]; then
        echo "$response"
    else
        echo "⚠️ Failed to get review for $file"
    fi
}

# Enhanced test generation with framework detection
ai_generate_tests() {
    local target_file="$1"
    local test_framework="${2:-auto}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    ai_log "INFO" "Generating comprehensive tests for $target_file"
    
    # Auto-detect test framework
    if [[ "$test_framework" == "auto" ]]; then
        test_framework=$(ai_detect_test_framework "$target_file")
    fi
    
    echo "🧪 Generating tests for $target_file using $test_framework"
    
    local file_content=$(cat "$target_file")
    local test_prompt="Generate comprehensive unit tests for this code using $test_framework.

Requirements:
1. Test all public functions/methods
2. Include happy path scenarios
3. Test edge cases and boundary conditions
4. Test error handling and exceptions
5. Mock external dependencies appropriately
6. Include setup and teardown if needed
7. Use descriptive test names and assertions
8. Follow $test_framework best practices

Provide complete, runnable test code."
    
    local test_file=$(ai_generate_test_filename "$target_file" "$test_framework")
    local tests=$(ai_api_call "$provider" "$test_prompt" "$file_content")
    
    if [[ -n "$tests" ]] && [[ "$tests" != "Error:"* ]]; then
        echo "$tests" > "$test_file"
        echo "✅ Tests generated: $test_file"
        
        # Optionally run the tests to validate
        if command -v "$test_framework" >/dev/null 2>&1; then
            echo "🔍 Running generated tests..."
            case "$test_framework" in
                "pytest")
                    pytest "$test_file" -v || true
                    ;;
                "jest")
                    npx jest "$test_file" || true
                    ;;
                "go")
                    go test "$test_file" || true
                    ;;
            esac
        fi
    else
        echo "⚠️ Failed to generate tests"
        return 1
    fi
}

ai_detect_test_framework() {
    local target_file="$1"
    local file_ext="${target_file##*.}"
    
    case "$file_ext" in
        "py")
            if [[ -f "pyproject.toml" ]] && grep -q "pytest" "pyproject.toml"; then
                echo "pytest"
            elif [[ -f "requirements.txt" ]] && grep -q "pytest" "requirements.txt"; then
                echo "pytest"
            else
                echo "unittest"
            fi
            ;;
        "js"|"ts")
            if [[ -f "package.json" ]]; then
                if grep -q '"jest"' "package.json"; then
                    echo "jest"
                elif grep -q '"vitest"' "package.json"; then
                    echo "vitest"
                elif grep -q '"mocha"' "package.json"; then
                    echo "mocha"
                else
                    echo "jest"  # Default
                fi
            else
                echo "jest"
            fi
            ;;
        "rs")
            echo "rust"
            ;;
        "go")
            echo "go"
            ;;
        *)
            echo "generic"
            ;;
    esac
}

ai_generate_test_filename() {
    local source_file="$1"
    local framework="$2"
    local dir=$(dirname "$source_file")
    local filename=$(basename "$source_file")
    local name="${filename%.*}"
    local ext="${filename##*.}"
    
    case "$framework" in
        "pytest"|"unittest")
            echo "${dir}/test_${name}.py"
            ;;
        "jest"|"vitest"|"mocha")
            echo "${dir}/${name}.test.${ext}"
            ;;
        "rust")
            echo "${dir}/${name}_test.rs"
            ;;
        "go")
            echo "${dir}/${name}_test.go"
            ;;
        *)
            echo "${dir}/${name}_test.${ext}"
            ;;
    esac
}

# Code explanation with context awareness
ai_explain_code() {
    local target_file="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    local detail_level="${2:-normal}"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    ai_log "INFO" "Explaining code in $target_file with detail level: $detail_level"
    
    local file_content=$(cat "$target_file")
    local explain_prompt
    
    case "$detail_level" in
        "simple")
            explain_prompt="Explain this code in simple terms that a beginner programmer could understand. Focus on what it does and why."
            ;;
        "detailed")
            explain_prompt="Provide a detailed technical explanation of this code including:
1. Overall purpose and functionality
2. Key algorithms and data structures used
3. Design patterns and architectural choices
4. Dependencies and integrations
5. Performance characteristics
6. Potential issues or areas for improvement
7. How to extend or modify the code"
            ;;
        *)
            explain_prompt="Explain this code clearly, including:
1. What the code does
2. How it works
3. Key components and their relationships
4. Notable patterns or techniques used
5. Potential considerations for maintenance or extension"
            ;;
    esac
    
    echo "🔍 Code Explanation for $target_file"
    echo "Detail Level: $detail_level"
    echo ""
    
    local explanation=$(ai_api_call "$provider" "$explain_prompt" "$file_content")
    if [[ -n "$explanation" ]] && [[ "$explanation" != "Error:"* ]]; then
        echo "$explanation"
    else
        echo "⚠️ Failed to generate explanation"
        return 1
    fi
}

# Refactoring suggestions with specific improvements
ai_refactor_suggestions() {
    local target_file="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    local focus="${2:-general}"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    ai_log "INFO" "Generating refactoring suggestions for $target_file with focus: $focus"
    
    local file_content=$(cat "$target_file")
    local refactor_prompt
    
    case "$focus" in
        "performance")
            refactor_prompt="Analyze this code for performance optimization opportunities. Suggest specific refactoring improvements for:
1. Time complexity reduction
2. Memory usage optimization
3. I/O efficiency
4. Caching strategies
5. Algorithm improvements
Provide before/after code examples."
            ;;
        "maintainability")
            refactor_prompt="Suggest refactoring improvements to enhance code maintainability:
1. Code organization and structure
2. Function/method extraction
3. Naming improvements
4. Reducing complexity
5. Improving readability
6. Documentation enhancements
Provide specific code examples."
            ;;
        "security")
            refactor_prompt="Review this code for security-focused refactoring:
1. Input validation improvements
2. Error handling enhancements
3. Secure coding practices
4. Vulnerability mitigation
5. Access control improvements
Provide specific security-hardened code examples."
            ;;
        *)
            refactor_prompt="Analyze this code and suggest comprehensive refactoring improvements:
1. Code structure and organization
2. Performance optimizations
3. Readability and maintainability
4. Best practices adherence
5. Error handling improvements
6. Testing considerations
Provide specific examples with before/after code."
            ;;
    esac
    
    echo "🔧 Refactoring Suggestions for $target_file"
    echo "Focus Area: $focus"
    echo ""
    
    local suggestions=$(ai_api_call "$provider" "$refactor_prompt" "$file_content")
    if [[ -n "$suggestions" ]] && [[ "$suggestions" != "Error:"* ]]; then
        echo "$suggestions"
    else
        echo "⚠️ Failed to generate refactoring suggestions"
        return 1
    fi
}

# === EPIC 5.3: WORKFLOW AUTOMATION ===

# Smart commit message generation with context
ai_smart_commit() {
    local auto_stage="${1:-false}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    # Check for unstaged changes
    if git diff --quiet && git diff --cached --quiet; then
        echo "No changes to commit"
        return 0
    fi
    
    # Auto-stage files if requested or if nothing is staged
    if [[ "$auto_stage" == "true" ]] || git diff --cached --quiet; then
        echo "📋 Staging all changes..."
        git add .
    fi
    
    local staged_files=$(git diff --cached --name-only)
    local diff_content=$(git diff --cached)
    
    if [[ -z "$diff_content" ]]; then
        echo "No staged changes to commit"
        return 1
    fi
    
    ai_log "INFO" "Generating smart commit message for files: $staged_files"
    
    echo "🤖 Analyzing changes for smart commit message..."
    echo "Files changed: $(echo "$staged_files" | wc -l)"
    echo ""
    
    # Get git context for better commit messages
    local git_context=""
    git_context+="Branch: $(git branch --show-current)\\n"
    git_context+="Files modified: $staged_files\\n"
    git_context+="Lines added/removed: $(git diff --cached --numstat | awk '{added+=$1; removed+=$2} END {print "Added: " added ", Removed: " removed}')\\n"
    
    local commit_prompt="Generate a concise, conventional commit message for these changes.

Context:
$git_context

Guidelines:
1. Use conventional commit format: type(scope): description
2. Types: feat, fix, docs, style, refactor, test, chore, ci, build
3. Be specific about what changed and why
4. Keep the description under 72 characters
5. Include scope when relevant (e.g., api, ui, auth, db)
6. Focus on the business value or impact

Analyze the diff and provide ONE commit message line."
    
    local commit_message=$(ai_api_call "$provider" "$commit_prompt" "$diff_content" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [[ -n "$commit_message" ]] && [[ "$commit_message" != "Error:"* ]]; then
        echo "📝 Suggested commit message:"
        echo "   $commit_message"
        echo ""
        
        read -p "Use this commit message? [Y/n]: " -r response
        if [[ -z "$response" || "$response" =~ ^[Yy]$ ]]; then
            if git commit -m "$commit_message"; then
                echo "✅ Committed successfully!"
                
                # Offer to push
                if git remote >/dev/null 2>&1; then
                    read -p "Push to remote? [y/N]: " -r push_response
                    if [[ "$push_response" =~ ^[Yy]$ ]]; then
                        git push
                    fi
                fi
            else
                echo "❌ Commit failed"
                return 1
            fi
        else
            echo "Commit cancelled. You can manually commit with:"
            echo "git commit -m \"your message\""
        fi
    else
        echo "⚠️ Failed to generate commit message. Falling back to manual commit."
        git commit
    fi
}

# Security filtering to prevent sensitive data exposure
ai_security_filtering() {
    local content="$1"
    local filtered_content
    
    # Remove potential secrets and sensitive data
    filtered_content=$(echo "$content" | \
        sed -E 's/(password|passwd|pwd|secret|key|token|api_key|apikey)=[^[:space:]]+/\1=***FILTERED***/gi' | \
        sed -E 's/(password|passwd|pwd|secret|key|token|api_key|apikey)[[:space:]]*:[[:space:]]*["'"'"'][^"'"'"']+["'"'"']/\1: "***FILTERED***/gi' | \
        sed -E 's/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/***EMAIL_FILTERED***/g' | \
        sed -E 's/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/***IP_FILTERED***/g' | \
        sed -E 's/\b[0-9]{4}[-\s]?[0-9]{4}[-\s]?[0-9]{4}[-\s]?[0-9]{4}\b/***CARD_FILTERED***/g')
    
    echo "$filtered_content"
}

# Cost optimization for API usage
ai_cost_optimization() {
    local provider="$1"
    local prompt_length=${#2}
    local context_length=${#3}
    
    # Estimate token count (rough approximation: 4 characters per token)
    local estimated_tokens=$((($prompt_length + $context_length) / 4))
    
    # Suggest optimizations based on token count and provider
    case "$provider" in
        "claude")
            if [[ $estimated_tokens -gt 100000 ]]; then
                echo "⚠️ Large context detected (~$estimated_tokens tokens). Consider chunking for Claude."
                return 1
            fi
            ;;
        "openai")
            if [[ $estimated_tokens -gt 8000 ]]; then
                echo "⚠️ Large context detected (~$estimated_tokens tokens). Consider using GPT-4 Turbo or chunking."
                return 1
            fi
            ;;
        "gemini")
            if [[ $estimated_tokens -gt 30000 ]]; then
                echo "⚠️ Large context detected (~$estimated_tokens tokens). Consider chunking for Gemini."
                return 1
            fi
            ;;
    esac
    
    # Log usage for cost tracking
    ai_log "COST" "Provider: $provider, Estimated tokens: $estimated_tokens"
    
    # Integrate with metrics system if available
    if command -v record_ai_usage >/dev/null 2>&1; then
        record_ai_usage "$provider" "$estimated_tokens"
    fi
    
    return 0
}

# Functions are available in current shell session
# Note: export -f is bash-specific and causes output in zsh, so we skip it