# ============================================================================
# AI Integration Functions
# Security-enhanced AI functions for development workflows
# ============================================================================

# Load AI security functions
if [[ -f "$DOTFILES_DIR/lib/ai-security.sh" ]]; then
    source "$DOTFILES_DIR/lib/ai-security.sh"
fi

# Context-aware Claude Code helper (SECURITY ENHANCED)
function claude-context() {
    local prompt="$1"
    local context_files=""
    
    if [[ -z "$prompt" ]]; then
        echo "Usage: claude-context <prompt>"
        echo "🔒 This function shares local files with Claude Code CLI"
        return 1
    fi
    
    # Auto-detect relevant files based on project type
    if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
        context_files=$(find . -name "*.py" -not -path "./.venv/*" -not -path "./venv/*" | head -5)
    elif [[ -f "package.json" ]]; then
        context_files=$(find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -5)
    elif [[ -f "Package.swift" ]]; then
        context_files=$(find . -name "*.swift" | head -5)
    else
        context_files=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.swift" \) | head -3)
    fi
    
    # Use safe AI call with security checks
    if [[ -n "$context_files" ]]; then
        safe_ai_call claude "$prompt" $context_files
    else
        claude "$prompt"
    fi
}

# Multi-AI comparison for important decisions (SECURITY ENHANCED)
function ai-compare() {
    local prompt="$1"
    if [[ -z "$prompt" ]]; then
        echo "Usage: ai-compare <question>"
        echo "🔒 This function sends prompts to multiple AI services"
        return 1
    fi
    
    if type print_security_warning >/dev/null 2>&1; then
        print_security_warning "send prompt to multiple AI services (Claude & Gemini)"
    else
        echo "⚠️  WARNING: This will send your prompt to multiple AI services"
    fi
    
    echo "Continue? Type 'YES' to confirm:"
    read -r confirmation
    
    if [[ "$confirmation" != "YES" ]]; then
        echo "❌ Operation cancelled."
        return 1
    fi
    
    echo "🤖 Getting opinions from multiple AI models..."
    echo "\n=== Claude Code Response ==="
    claude "$prompt"
    echo "\n=== Gemini Response ==="
    gemini "$prompt"
    echo "\n=== Comparison complete ==="
}

# Project analysis with AI (SECURITY ENHANCED)
function ai-analyze() {
    local analysis_type=${1:-"overview"}
    
    echo "🔒 WARNING: This will send your project files to Claude AI"
    echo "Analysis type: $analysis_type"
    
    case $analysis_type in
        "overview")
            local files=$(find . -name "README*" -o -name "*.md" | head -3) $(find . -name "package.json" -o -name "pyproject.toml" -o -name "requirements.txt" | head -2)
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Analyze this project structure and provide an overview of what it does, its architecture, and key components" $files
            else
                claude "Analyze this project structure and provide an overview"
            fi
            ;;
        "security")
            local files=$(find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10)
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Review this codebase for potential security vulnerabilities and suggest improvements" $files
            else
                echo "❌ Security analysis requires AI security framework to be loaded"
            fi
            ;;
        "performance")
            local files=$(find . -name "*.py" -o -name "*.js" -o -name "*.ts" | head -10)
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Review this codebase for performance bottlenecks and optimization opportunities" $files
            else
                echo "❌ Performance analysis requires AI security framework to be loaded"
            fi
            ;;
        "documentation")
            local files=$(find . -name "README*" -o -name "*.md" -o -name "docs/*" | head -5)
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Review this project's documentation and suggest improvements for clarity and completeness" $files
            else
                claude "Review documentation and suggest improvements"
            fi
            ;;
        *)
            echo "Usage: ai-analyze [overview|security|performance|documentation]"
            echo "🔒 This function shares project files with AI services"
            ;;
    esac
}

# Error debugging with AI
function ai-debug() {
    local error_log="$1"
    if [[ -z "$error_log" ]]; then
        echo "Usage: ai-debug <error_message_or_log_file>"
        echo "   or: <command> 2>&1 | ai-debug"
        return 1
    fi
    
    if [[ -f "$error_log" ]]; then
        echo "🔍 Analyzing error log: $error_log"
        claude "Debug this error log and provide solutions:" < "$error_log"
    elif [[ -p /dev/stdin ]]; then
        echo "🔍 Analyzing piped error output..."
        claude "Debug this error and provide solutions:"
    else
        echo "🔍 Analyzing error message..."
        claude "Debug this error and provide solutions: $error_log"
    fi
}

# Code refactoring suggestions
function ai-refactor() {
    local file="$1"
    local focus="${2:-general}"
    
    if [[ -z "$file" ]]; then
        echo "Usage: ai-refactor <file> [performance|readability|testing|general]"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    case $focus in
        "performance")
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Review this code for performance improvements and optimizations:" "$file"
            else
                claude "Review this code for performance improvements:" < "$file"
            fi
            ;;
        "readability")
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Review this code for readability and maintainability improvements:" "$file"
            else
                claude "Review this code for readability improvements:" < "$file"
            fi
            ;;
        "testing")
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Suggest testing strategies and improvements for this code:" "$file"
            else
                claude "Suggest testing strategies for this code:" < "$file"
            fi
            ;;
        *)
            if type safe_ai_call >/dev/null 2>&1; then
                safe_ai_call claude "Review this code and suggest general improvements:" "$file"
            else
                claude "Review this code and suggest improvements:" < "$file"
            fi
            ;;
    esac
}

# Explain code functionality
function explain() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "Usage: explain <file>"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    echo "🔍 Explaining code in: $file"
    if type safe_ai_call >/dev/null 2>&1; then
        safe_ai_call claude "Explain what this code does, how it works, and its key components:" "$file"
    else
        claude "Explain what this code does:" < "$file"
    fi
}

# AI-powered commit message generation
function ai-commit() {
    if [[ -z "$(git diff --cached)" ]]; then
        echo "❌ No staged changes found. Stage your changes first with 'git add'."
        return 1
    fi
    
    echo "🔍 Analyzing staged changes..."
    local diff_output=$(git diff --cached)
    
    if type safe_ai_call >/dev/null 2>&1; then
        echo "🔒 This will send your git diff to Claude AI for commit message generation"
        if type print_security_warning >/dev/null 2>&1; then
            print_security_warning "send git diff to AI for commit message generation"
        fi
        echo "Continue? Type 'YES' to confirm:"
        read -r confirmation
        
        if [[ "$confirmation" != "YES" ]]; then
            echo "❌ Operation cancelled."
            return 1
        fi
    fi
    
    echo "🤖 Generating commit message..."
    local commit_msg=$(echo "$diff_output" | claude "Generate a concise, conventional commit message for these changes. Format: type(scope): description. Be specific about what changed.")
    
    echo "📝 Suggested commit message:"
    echo "$commit_msg"
    echo ""
    echo "Use this commit message? (y/N):"
    read -r use_message
    
    if [[ "$use_message" =~ ^[Yy]$ ]]; then
        git commit -m "$commit_msg"
        echo "✅ Committed with AI-generated message!"
    else
        echo "💡 You can copy the message above and use it manually with 'git commit -m \"message\"'"
    fi
}

# AI-powered branch review
function ai-review-branch() {
    local base_branch="${1:-main}"
    local current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "$base_branch" ]]; then
        echo "❌ You're on the base branch ($base_branch). Switch to a feature branch first."
        return 1
    fi
    
    echo "🔍 Reviewing changes from $base_branch to $current_branch..."
    local diff_output=$(git diff "$base_branch"..."$current_branch")
    
    if [[ -z "$diff_output" ]]; then
        echo "❌ No differences found between $base_branch and $current_branch"
        return 1
    fi
    
    if type safe_ai_call >/dev/null 2>&1; then
        echo "🔒 This will send your branch diff to Claude AI for code review"
        if type print_security_warning >/dev/null 2>&1; then
            print_security_warning "send branch diff to AI for code review"
        fi
        echo "Continue? Type 'YES' to confirm:"
        read -r confirmation
        
        if [[ "$confirmation" != "YES" ]]; then
            echo "❌ Operation cancelled."
            return 1
        fi
    fi
    
    echo "🤖 AI reviewing your branch changes..."
    echo "$diff_output" | claude "Review this code diff for potential issues, improvements, and provide feedback on the changes. Focus on code quality, potential bugs, and best practices."
}