#!/usr/bin/env bash
# ============================================================================
# DOT CLI - AI Integration
# AI-powered development assistance and automation
# ============================================================================

# Load AI integration framework
source "$DOTFILES_DIR/lib/ai-integration.sh"

# AI command dispatcher
dot_ai() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "review")
            ai_code_review "$@"
            ;;
        "test")
            ai_generate_tests "$@"
            ;;
        "commit")
            ai_smart_commit "$@"
            ;;
        "explain")
            ai_explain_code "$@"
            ;;
        "docs")
            ai_generate_docs "$@"
            ;;
        "fix")
            ai_fix_code "$@"
            ;;
        "refactor")
            ai_refactor_code "$@"
            ;;
        "status")
            ai_status
            ;;
        "setup")
            ai_setup
            ;;
        "analyze")
            ai_analyze_project "$@"
            ;;
        "debug")
            ai_debug_error "$@"
            ;;
        "compare")
            ai_compare_models "$@"
            ;;
        "context")
            ai_context_helper "$@"
            ;;
        "-h"|"--help"|"")
            show_ai_help
            ;;
        *)
            print_error "Unknown AI subcommand: $subcommand"
            echo "Run 'dot ai --help' for available commands."
            return 1
            ;;
    esac
}

# AI code review
ai_code_review() {
    local target="${1:-.}"
    local provider="${AI_PROVIDER:-claude}"
    local detailed=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider)
                provider="$2"
                shift 2
                ;;
            --detailed)
                detailed=true
                shift
                ;;
            --help)
                echo "Usage: dot ai review [file/dir] [--provider claude|gemini|copilot] [--detailed]"
                return 0
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done
    
    print_info "${AI} Starting AI code review with $provider..."
    
    # Check if target exists
    if [[ ! -e "$target" ]]; then
        print_error "Target not found: $target"
        return 1
    fi
    
    local review_prompt="Please review this code for:"
    review_prompt+="\\n- Code quality and best practices"
    review_prompt+="\\n- Security vulnerabilities"
    review_prompt+="\\n- Performance optimizations"
    review_prompt+="\\n- Bug detection"
    review_prompt+="\\n- Maintainability improvements"
    
    if [[ "$detailed" == "true" ]]; then
        review_prompt+="\\n\\nProvide detailed explanations and specific recommendations."
    fi
    
    case "$provider" in
        "claude")
            ai_review_with_claude "$target" "$review_prompt"
            ;;
        "gemini")
            ai_review_with_gemini "$target" "$review_prompt"
            ;;
        "copilot")
            ai_review_with_copilot "$target" "$review_prompt"
            ;;
        *)
            print_error "Unknown AI provider: $provider"
            echo "Available providers: claude, gemini, copilot"
            return 1
            ;;
    esac
}

# Generate tests with AI
ai_generate_tests() {
    local target="${1}"
    local framework="${2:-auto}"
    local provider="${AI_PROVIDER:-claude}"
    
    if [[ -z "$target" ]]; then
        print_error "Please specify a file to generate tests for"
        echo "Usage: dot ai test <file> [framework]"
        return 1
    fi
    
    if [[ ! -f "$target" ]]; then
        print_error "File not found: $target"
        return 1
    fi
    
    print_info "${AI} Generating tests for $target..."
    
    # Auto-detect test framework if not specified
    if [[ "$framework" == "auto" ]]; then
        framework=$(detect_test_framework)
    fi
    
    local test_prompt="Generate comprehensive unit tests for this code using $framework."
    test_prompt+="\\n\\nInclude:"
    test_prompt+="\\n- Happy path tests"
    test_prompt+="\\n- Edge cases"
    test_prompt+="\\n- Error handling"
    test_prompt+="\\n- Mock dependencies where appropriate"
    test_prompt+="\\n- Clear test descriptions"
    
    local test_file=$(generate_test_filename "$target" "$framework")
    
    case "$provider" in
        "claude")
            ai_generate_with_claude "$target" "$test_prompt" "$test_file"
            ;;
        "gemini")
            ai_generate_with_gemini "$target" "$test_prompt" "$test_file"
            ;;
        *)
            print_error "Test generation not yet supported for provider: $provider"
            return 1
            ;;
    esac
}

# Smart commit message generation
ai_smart_commit() {
    local provider="${AI_PROVIDER:-claude}"
    local auto_commit=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                auto_commit=true
                shift
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --help)
                echo "Usage: dot ai commit [--auto] [--provider claude|gemini]"
                return 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Check if there are changes to commit
    if git diff --quiet && git diff --cached --quiet; then
        print_warning "No changes to commit"
        return 0
    fi
    
    print_info "${AI} Generating smart commit message..."
    
    # Get git diff for context
    local changes=$(git diff --cached --name-only)
    local diff_content=$(git diff --cached)
    
    if [[ -z "$diff_content" ]]; then
        # Stage all changes if nothing is staged
        git add .
        diff_content=$(git diff --cached)
    fi
    
    local commit_prompt="Analyze the following git diff and generate a concise, conventional commit message."
    commit_prompt+="\\n\\nUse the format: type(scope): description"
    commit_prompt+="\\n\\nTypes: feat, fix, docs, style, refactor, test, chore"
    commit_prompt+="\\n\\nBe specific about what changed and why."
    
    local commit_message
    case "$provider" in
        "claude")
            commit_message=$(ai_generate_commit_claude "$diff_content" "$commit_prompt")
            ;;
        "gemini")
            commit_message=$(ai_generate_commit_gemini "$diff_content" "$commit_prompt")
            ;;
        *)
            print_error "Commit generation not supported for provider: $provider"
            return 1
            ;;
    esac
    
    if [[ -n "$commit_message" ]]; then
        echo ""
        echo "📝 Suggested commit message:"
        echo "   $commit_message"
        echo ""
        
        if [[ "$auto_commit" == "true" ]]; then
            git commit -m "$commit_message"
            print_success "Committed with AI-generated message!"
        else
            echo -n "Use this commit message? [Y/n]: "
            read -r response
            if [[ "$response" =~ ^[Yy]$|^$ ]]; then
                git commit -m "$commit_message"
                print_success "Committed with AI-generated message!"
            else
                echo "Commit cancelled. You can manually commit with: git commit -m \"your message\""
            fi
        fi
    else
        print_error "Failed to generate commit message"
        return 1
    fi
}

# Explain code with AI
ai_explain_code() {
    local target="${1:-.}"
    local provider="${AI_PROVIDER:-claude}"
    local simple=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --simple)
                simple=true
                shift
                ;;
            --provider)
                provider="$2"
                shift 2
                ;;
            --help)
                echo "Usage: dot ai explain [file] [--simple] [--provider claude|gemini]"
                return 0
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done
    
    if [[ ! -e "$target" ]]; then
        print_error "Target not found: $target"
        return 1
    fi
    
    print_info "${AI} Explaining code with $provider..."
    
    local explain_prompt="Explain this code in clear, understandable terms."
    
    if [[ "$simple" == "true" ]]; then
        explain_prompt+="\\n\\nUse simple language suitable for beginners."
    else
        explain_prompt+="\\n\\nInclude:"
        explain_prompt+="\\n- What the code does"
        explain_prompt+="\\n- How it works"
        explain_prompt+="\\n- Key algorithms or patterns used"
        explain_prompt+="\\n- Potential improvements"
    fi
    
    case "$provider" in
        "claude")
            ai_explain_with_claude "$target" "$explain_prompt"
            ;;
        "gemini")
            ai_explain_with_gemini "$target" "$explain_prompt"
            ;;
        *)
            print_error "Code explanation not supported for provider: $provider"
            return 1
            ;;
    esac
}

# AI provider implementations
ai_review_with_claude() {
    local target="$1"
    local prompt="$2"
    
    if command -v claude >/dev/null 2>&1; then
        echo "$prompt" | claude --file "$target"
    else
        print_error "Claude CLI not found. Install with: pip install claude-api"
        return 1
    fi
}

ai_review_with_gemini() {
    local target="$1"
    local prompt="$2"
    
    if command -v gemini >/dev/null 2>&1; then
        gemini "$prompt" --file "$target"
    else
        print_error "Gemini CLI not found. Install from: https://github.com/google/generative-ai-cli"
        return 1
    fi
}

ai_generate_commit_claude() {
    local diff_content="$1"
    local prompt="$2"
    
    if command -v claude >/dev/null 2>&1; then
        echo -e "$prompt\\n\\n$diff_content" | claude --brief
    else
        echo ""
    fi
}

ai_generate_commit_gemini() {
    local diff_content="$1"
    local prompt="$2"
    
    if command -v gemini >/dev/null 2>&1; then
        echo -e "$prompt\\n\\n$diff_content" | gemini --brief
    else
        echo ""
    fi
}

# Utility functions
detect_test_framework() {
    if [[ -f "package.json" ]]; then
        if grep -q "jest" package.json; then
            echo "jest"
        elif grep -q "vitest" package.json; then
            echo "vitest"
        elif grep -q "mocha" package.json; then
            echo "mocha"
        else
            echo "jest"  # Default for JS/TS
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        echo "pytest"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust-test"
    elif [[ -f "go.mod" ]]; then
        echo "go-test"
    else
        echo "generic"
    fi
}

generate_test_filename() {
    local source_file="$1"
    local framework="$2"
    local dir=$(dirname "$source_file")
    local filename=$(basename "$source_file")
    local name="${filename%.*}"
    local ext="${filename##*.}"
    
    case "$framework" in
        "jest"|"vitest"|"mocha")
            echo "${dir}/${name}.test.${ext}"
            ;;
        "pytest")
            echo "${dir}/test_${name}.py"
            ;;
        "rust-test")
            echo "${dir}/${name}_test.rs"
            ;;
        "go-test")
            echo "${dir}/${name}_test.go"
            ;;
        *)
            echo "${dir}/${name}_test.${ext}"
            ;;
    esac
}

# AI status and configuration
ai_status() {
    echo "🤖 AI Integration Status:"
    echo ""
    
    # Check available providers
    echo "Available Providers:"
    
    if command -v claude >/dev/null 2>&1; then
        echo "  ✅ Claude CLI"
    else
        echo "  ❌ Claude CLI (install: pip install claude-api)"
    fi
    
    if command -v gemini >/dev/null 2>&1; then
        echo "  ✅ Gemini CLI"
    else
        echo "  ❌ Gemini CLI (install from: https://github.com/google/generative-ai-cli)"
    fi
    
    if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
        echo "  ✅ GitHub Copilot CLI"
    else
        echo "  ❌ GitHub Copilot CLI (install: gh extension install github/gh-copilot)"
    fi
    
    echo ""
    echo "Current Provider: ${AI_PROVIDER:-claude}"
    echo ""
    echo "Configuration:"
    echo "  Set provider: export AI_PROVIDER=claude|gemini|copilot"
    echo "  API keys should be configured per provider's documentation"
}

ai_setup() {
    print_info "${AI} Setting up AI integrations..."
    
    echo "Select AI providers to install:"
    echo "1) Claude CLI"
    echo "2) Gemini CLI" 
    echo "3) GitHub Copilot CLI"
    echo "4) All providers"
    echo -n "Choice [1-4]: "
    read -r choice
    
    case "$choice" in
        1)
            setup_claude_cli
            ;;
        2)
            setup_gemini_cli
            ;;
        3)
            setup_copilot_cli
            ;;
        4)
            setup_claude_cli
            setup_gemini_cli
            setup_copilot_cli
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
    
    print_success "AI setup completed!"
    print_info "Set your preferred provider: export AI_PROVIDER=claude|gemini|copilot"
}

setup_claude_cli() {
    print_info "Setting up Claude CLI..."
    if command -v pip >/dev/null 2>&1; then
        pip install claude-api
    else
        print_warning "pip not found. Please install Claude CLI manually."
    fi
}

setup_gemini_cli() {
    print_info "Setting up Gemini CLI..."
    print_info "Please install from: https://github.com/google/generative-ai-cli"
}

setup_copilot_cli() {
    print_info "Setting up GitHub Copilot CLI..."
    if command -v gh >/dev/null 2>&1; then
        gh extension install github/gh-copilot
    else
        print_warning "GitHub CLI not found. Please install gh first."
    fi
}

# Project analysis with AI (enhanced from zsh version)
ai_analyze_project() {
    local analysis_type="${1:-overview}"
    local provider="${AI_PROVIDER:-claude}"
    
    case "$analysis_type" in
        "overview")
            print_info "${AI} Analyzing project overview..."
            local files=$(find . -name "README*" -o -name "*.md" | head -3)
            files="$files $(find . -name "package.json" -o -name "pyproject.toml" -o -name "requirements.txt" | head -2)"
            
            local prompt="Analyze this project structure and provide an overview of what it does, its architecture, and key components"
            if [[ -n "$files" ]]; then
                case "$provider" in
                    "claude")
                        ai_analyze_with_claude "$files" "$prompt"
                        ;;
                    "gemini")
                        ai_analyze_with_gemini "$files" "$prompt"
                        ;;
                    *)
                        print_error "Analysis not supported for provider: $provider"
                        return 1
                        ;;
                esac
            else
                print_warning "No project files found for analysis"
            fi
            ;;
        "security")
            print_info "${AI} Analyzing project security..."
            local files=$(find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10)
            local prompt="Review this codebase for potential security vulnerabilities and suggest improvements"
            
            if [[ -n "$files" ]]; then
                case "$provider" in
                    "claude")
                        ai_analyze_with_claude "$files" "$prompt"
                        ;;
                    "gemini")
                        ai_analyze_with_gemini "$files" "$prompt"
                        ;;
                    *)
                        print_error "Security analysis not supported for provider: $provider"
                        return 1
                        ;;
                esac
            else
                print_warning "No source code files found for security analysis"
            fi
            ;;
        "performance")
            print_info "${AI} Analyzing project performance..."
            local files=$(find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10)
            local prompt="Review this codebase for performance bottlenecks and optimization opportunities"
            
            if [[ -n "$files" ]]; then
                case "$provider" in
                    "claude")
                        ai_analyze_with_claude "$files" "$prompt"
                        ;;
                    "gemini")
                        ai_analyze_with_gemini "$files" "$prompt"
                        ;;
                    *)
                        print_error "Performance analysis not supported for provider: $provider"
                        return 1
                        ;;
                esac
            else
                print_warning "No source code files found for performance analysis"
            fi
            ;;
        "documentation")
            print_info "${AI} Analyzing project documentation..."
            local files=$(find . -name "README*" -o -name "*.md" -o -name "docs/*" | head -5)
            local prompt="Review this project's documentation and suggest improvements for clarity and completeness"
            
            if [[ -n "$files" ]]; then
                case "$provider" in
                    "claude")
                        ai_analyze_with_claude "$files" "$prompt"
                        ;;
                    "gemini")
                        ai_analyze_with_gemini "$files" "$prompt"
                        ;;
                    *)
                        print_error "Documentation analysis not supported for provider: $provider"
                        return 1
                        ;;
                esac
            else
                print_warning "No documentation files found for analysis"
            fi
            ;;
        *)
            print_error "Unknown analysis type: $analysis_type"
            echo "Available types: overview, security, performance, documentation"
            return 1
            ;;
    esac
}

# Error debugging with AI
ai_debug_error() {
    local error_input="$1"
    local provider="${AI_PROVIDER:-claude}"
    
    if [[ -z "$error_input" ]]; then
        print_error "Usage: dot ai debug <error_message_or_log_file>"
        echo "   or: <command> 2>&1 | dot ai debug"
        return 1
    fi
    
    print_info "${AI} Debugging error with $provider..."
    
    local debug_prompt="Debug this error and provide solutions:"
    
    if [[ -f "$error_input" ]]; then
        print_info "Analyzing error log: $error_input"
        case "$provider" in
            "claude")
                echo "$debug_prompt" | claude --file "$error_input"
                ;;
            "gemini")
                gemini "$debug_prompt" --file "$error_input"
                ;;
            *)
                print_error "Debug not supported for provider: $provider"
                return 1
                ;;
        esac
    elif [[ -p /dev/stdin ]]; then
        print_info "Analyzing piped error output..."
        case "$provider" in
            "claude")
                echo "$debug_prompt" | claude
                ;;
            "gemini")
                echo "$debug_prompt" | gemini
                ;;
            *)
                print_error "Debug not supported for provider: $provider"
                return 1
                ;;
        esac
    else
        print_info "Analyzing error message..."
        case "$provider" in
            "claude")
                echo "$debug_prompt $error_input" | claude
                ;;
            "gemini")
                echo "$debug_prompt $error_input" | gemini
                ;;
            *)
                print_error "Debug not supported for provider: $provider"
                return 1
                ;;
        esac
    fi
}

# Multi-AI comparison for important decisions
ai_compare_models() {
    local prompt="$1"
    local providers="${2:-claude,gemini}"
    
    if [[ -z "$prompt" ]]; then
        print_error "Usage: dot ai compare <question> [providers]"
        echo "Available providers: claude,gemini,copilot"
        return 1
    fi
    
    print_warning "This will send your prompt to multiple AI services"
    echo "Providers: $providers"
    echo "Continue? Type 'YES' to confirm:"
    read -r confirmation
    
    if [[ "$confirmation" != "YES" ]]; then
        print_error "Operation cancelled."
        return 1
    fi
    
    print_info "${AI} Getting opinions from multiple AI models..."
    
    IFS=',' read -ra provider_array <<< "$providers"
    
    for provider in "${provider_array[@]}"; do
        provider=$(echo "$provider" | xargs) # trim whitespace
        echo ""
        echo "=== ${provider^} Response ==="
        
        case "$provider" in
            "claude")
                if command -v claude >/dev/null 2>&1; then
                    echo "$prompt" | claude
                else
                    print_warning "Claude CLI not available"
                fi
                ;;
            "gemini")
                if command -v gemini >/dev/null 2>&1; then
                    echo "$prompt" | gemini
                else
                    print_warning "Gemini CLI not available"
                fi
                ;;
            "copilot")
                if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
                    echo "$prompt" | gh copilot suggest -t shell
                else
                    print_warning "GitHub Copilot CLI not available"
                fi
                ;;
            *)
                print_warning "Unknown provider: $provider"
                ;;
        esac
    done
    
    echo ""
    echo "=== Comparison complete ==="
}

# Context-aware AI helper
ai_context_helper() {
    local prompt="$1"
    local provider="${AI_PROVIDER:-claude}"
    
    if [[ -z "$prompt" ]]; then
        print_error "Usage: dot ai context <prompt>"
        return 1
    fi
    
    print_info "${AI} Analyzing with project context..."
    
    # Auto-detect relevant files based on project type
    local context_files=""
    if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
        context_files=$(find . -name "*.py" -not -path "./.venv/*" -not -path "./venv/*" | head -5)
        print_info "Detected Python project, including .py files"
    elif [[ -f "package.json" ]]; then
        context_files=$(find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -5)
        print_info "Detected Node.js project, including JS/TS files"
    elif [[ -f "Package.swift" ]]; then
        context_files=$(find . -name "*.swift" | head -5)
        print_info "Detected Swift project, including .swift files"
    elif [[ -f "Cargo.toml" ]]; then
        context_files=$(find . -name "*.rs" | head -5)
        print_info "Detected Rust project, including .rs files"
    else
        # shellcheck disable=SC1009,SC1036
        context_files=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.swift" \) | head -3)
        print_info "Auto-detecting relevant source files"
    fi
    
    case "$provider" in
        "claude")
            if [[ -n "$context_files" ]] && command -v claude >/dev/null 2>&1; then
                echo "$prompt" | claude $context_files
            else
                echo "$prompt" | claude
            fi
            ;;
        "gemini")
            if [[ -n "$context_files" ]] && command -v gemini >/dev/null 2>&1; then
                echo "$prompt" | gemini $context_files
            else
                echo "$prompt" | gemini
            fi
            ;;
        *)
            print_error "Context analysis not supported for provider: $provider"
            return 1
            ;;
    esac
}

# Helper functions for AI analysis
ai_analyze_with_claude() {
    local files="$1"
    local prompt="$2"
    
    if command -v claude >/dev/null 2>&1; then
        echo "$prompt" | claude $files
    else
        print_error "Claude CLI not found. Install with: pip install claude-api"
        return 1
    fi
}

ai_analyze_with_gemini() {
    local files="$1"
    local prompt="$2"
    
    if command -v gemini >/dev/null 2>&1; then
        echo "$prompt" | gemini $files
    else
        print_error "Gemini CLI not found. Install from: https://github.com/google/generative-ai-cli"
        return 1
    fi
}

# Help function
show_ai_help() {
    cat << 'EOF'
dot ai - AI-powered development assistance

USAGE:
    dot ai <command> [options]

COMMANDS:
    review [file/dir]        AI code review for quality and security
    test <file> [framework]  Generate comprehensive unit tests
    commit [--auto]          Generate smart commit messages
    explain [file]           Explain code in natural language
    docs <file>              Generate documentation
    fix <file>               Suggest code fixes
    refactor <file>          Suggest refactoring improvements
    analyze [type]           Analyze project (overview|security|performance|documentation)
    debug <error>            Debug errors with AI assistance
    compare <prompt>         Compare responses from multiple AI providers
    context <prompt>         AI assistance with project context
    status                   Show AI integration status
    setup                    Install and configure AI providers

OPTIONS:
    --provider <name>        Use specific AI provider (claude|gemini|copilot)
    --detailed               Provide detailed analysis
    --simple                 Use simple explanations
    --auto                   Auto-apply suggestions (where applicable)
    -h, --help               Show this help message

PROVIDERS:
    claude                   Anthropic Claude (default)
    gemini                   Google Gemini
    copilot                  GitHub Copilot

CONFIGURATION:
    export AI_PROVIDER=claude     Set default provider
    
    Provider API keys should be configured according to each provider's
    documentation (usually via environment variables or config files).

EXAMPLES:
    dot ai review src/main.py         # Review Python file
    dot ai test utils.js jest         # Generate Jest tests
    dot ai commit --auto              # Auto-commit with AI message
    dot ai explain --simple app.go    # Simple explanation
    dot ai analyze security           # Security analysis
    dot ai debug "TypeError: undefined"  # Debug error
    dot ai compare "Best Python web framework"  # Compare AI opinions
    dot ai context "How can I optimize this?"   # Context-aware help
    dot ai status                     # Check AI setup
EOF
}