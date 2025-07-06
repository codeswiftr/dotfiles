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

# AI-powered code review
ai_code_review() {
    local files=("$@")
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    ai_log "INFO" "Starting AI code review with provider: $provider"
    
    case "$provider" in
        "claude")
            ai_code_review_claude "${files[@]}"
            ;;
        "openai")
            ai_code_review_openai "${files[@]}"
            ;;
        "gemini")
            ai_code_review_gemini "${files[@]}"
            ;;
        "copilot")
            ai_code_review_copilot "${files[@]}"
            ;;
        *)
            echo "No AI provider available for code review"
            return 1
            ;;
    esac
}

ai_code_review_claude() {
    local files=("$@")
    
    if [[ ${#files[@]} -eq 0 ]]; then
        files=($(git diff --name-only HEAD~1 2>/dev/null || find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -5))
    fi
    
    local context=""
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            context+="\n\n--- $file ---\n"
            context+="$(cat "$file")"
        fi
    done
    
    echo "🤖 Claude Code Review for ${files[*]}"
    echo "📁 Analyzing files..."
    
    # Use claude CLI if available
    if command -v claude >/dev/null 2>&1; then
        echo "$context" | claude --model claude-3-sonnet-20240229 \
            "Please review this code for:
            1. Security vulnerabilities
            2. Performance issues
            3. Code quality and best practices
            4. Potential bugs
            5. Suggestions for improvement
            
            Provide specific, actionable feedback with examples."
    else
        echo "⚠️ Claude CLI not available. Install with: pip install claude-cli"
    fi
}

ai_code_review_gemini() {
    local files=("$@")
    
    if command -v gemini >/dev/null 2>&1; then
        local file_list=$(IFS=','; echo "${files[*]}")
        gemini --files "$file_list" \
            "Review this code for security, performance, and best practices. Provide specific suggestions."
    else
        echo "⚠️ Gemini CLI not available"
    fi
}

ai_code_review_copilot() {
    local files=("$@")
    
    if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
        for file in "${files[@]}"; do
            if [[ -f "$file" ]]; then
                echo "🤖 Copilot review for $file:"
                gh copilot explain "$file"
                echo ""
            fi
        done
    else
        echo "⚠️ GitHub Copilot CLI not available"
    fi
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

ai_commit_copilot() {
    if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
        gh copilot suggest "git commit"
    else
        echo "⚠️ GitHub Copilot CLI not available"
    fi
}

# AI-powered test generation
ai_generate_tests() {
    local target_file="$1"
    local test_framework="${2:-auto}"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    ai_log "INFO" "Generating tests for $target_file with framework: $test_framework"
    
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    case "$provider" in
        "claude")
            ai_tests_claude "$target_file" "$test_framework"
            ;;
        "openai")
            ai_tests_openai "$target_file" "$test_framework"
            ;;
        "copilot")
            ai_tests_copilot "$target_file" "$test_framework"
            ;;
        *)
            echo "No AI provider available for test generation"
            return 1
            ;;
    esac
}

ai_tests_claude() {
    local target_file="$1"
    local test_framework="$2"
    local file_content=$(cat "$target_file")
    
    # Detect framework if auto
    if [[ "$test_framework" == "auto" ]]; then
        if [[ "$target_file" =~ \.py$ ]]; then
            test_framework="pytest"
        elif [[ "$target_file" =~ \.(js|ts)$ ]]; then
            test_framework="jest"
        elif [[ "$target_file" =~ \.rs$ ]]; then
            test_framework="rust"
        elif [[ "$target_file" =~ \.go$ ]]; then
            test_framework="go"
        fi
    fi
    
    if command -v claude >/dev/null 2>&1; then
        local test_file="${target_file%.*}.test.${target_file##*.}"
        
        echo "🤖 Generating tests for $target_file using $test_framework"
        
        local tests=$(echo "$file_content" | claude \
            "Generate comprehensive unit tests for this code using $test_framework.
            Include:
            1. Happy path tests
            2. Edge cases
            3. Error handling
            4. Mock dependencies if needed
            5. Setup and teardown if needed
            
            Make tests readable and maintainable.")
        
        echo "$tests" > "$test_file"
        echo "✅ Tests generated: $test_file"
    else
        echo "⚠️ Claude CLI not available"
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

# Additional AI integration functions
ai_explain_code() {
    local target_file="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    
    if [[ ! -f "$target_file" ]]; then
        echo "File not found: $target_file"
        return 1
    fi
    
    local file_content=$(cat "$target_file")
    
    case "$provider" in
        "claude")
            if command -v claude >/dev/null 2>&1; then
                echo "🤖 Code Explanation for $target_file:"
                echo "$file_content" | claude \
                    "Explain this code in detail. Include:
                    1. What the code does
                    2. How it works
                    3. Key algorithms or patterns used
                    4. Dependencies and integrations
                    5. Potential improvements or considerations
                    
                    Make it educational and easy to understand."
            fi
            ;;
    esac
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

# Export all functions for use in other scripts
export -f ai_code_review ai_generate_commit ai_generate_tests ai_generate_docs ai_suggest_refactor setup_ai_integration
export -f ai_explain_code ai_security_scan ai_analyze_security ai_performance_analysis ai_analyze_performance
export -f ai_analyze_dependencies ai_explain_concept ai_resolve_error ai_migrate_code ai_dependency_security_check
export -f ai_config_security_review ai_analyze_config_security ai_generate_security_report ai_generate_project_metrics