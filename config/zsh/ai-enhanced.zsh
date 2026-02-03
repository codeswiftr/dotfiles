# =============================================================================
# AI-Enhanced Development Workflow
# Integrates AI assistance into daily development tasks
# =============================================================================

# Load AI integration framework (guarded)
if [[ -n "${DOTFILES_DIR:-}" && -f "$DOTFILES_DIR/lib/ai-integration.sh" ]]; then
    source "$DOTFILES_DIR/lib/ai-integration.sh"
elif [[ -f "$HOME/dotfiles/lib/ai-integration.sh" ]]; then
    source "$HOME/dotfiles/lib/ai-integration.sh"
fi

# AI-enhanced Git workflow
alias gai="ai_generate_commit"
alias grev="ai_code_review"
alias gfix="ai_suggest_fixes"

# AI-enhanced development commands
alias aitest="ai_generate_tests"
alias aidocs="ai_generate_docs"
alias aifix="ai_suggest_refactor"
alias aiexplain="ai_explain_code"

# Smart commit with AI (unalias to allow function definition on reload)
unalias gc 2>/dev/null || true

gc() {
    if [[ $# -eq 0 ]]; then
        # No message provided, use AI
        ai_generate_commit
    else
        # Traditional commit with message
        git commit -m "$*"
    fi
}

# AI-enhanced code review for pull requests
pr-review() {
    local pr_number="$1"
    
    if [[ -n "$pr_number" ]]; then
        # Review specific PR
        gh pr checkout "$pr_number"
        local base_branch=$(gh pr view "$pr_number" --json baseRefName -q .baseRefName)
        local changed_files=$(git diff --name-only "$base_branch"...)
        ai_code_review "${changed_files[@]}"
    else
        # Review current changes
        local changed_files=$(git diff --name-only HEAD~1)
        ai_code_review "${changed_files[@]}"
    fi
}

# AI-powered project analysis
project-analyze() {
    local project_dir="${1:-.}"
    
    echo "🤖 AI Project Analysis for: $project_dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Generate project documentation
    ai_generate_docs "$project_dir" "readme"
    
    # Analyze code quality
    echo "🔍 Code Quality Analysis..."
    find "$project_dir" -name "*.py" -o -name "*.js" -o -name "*.ts" | head -5 | while read -r file; do
        echo "📄 Analyzing: $file"
        ai_suggest_refactor "$file"
        echo ""
    done
    
    # Security analysis
    echo "🔒 Security Analysis..."
    ai_security_scan "$project_dir"
    
    # Performance suggestions
    echo "⚡ Performance Analysis..."
    ai_performance_analysis "$project_dir"
}

# AI-enhanced debugging
debug-ai() {
    local error_file="$1"
    local error_line="$2"
    
    if [[ -f "$error_file" ]]; then
        echo "🐛 AI Debug Assistant for: $error_file:$error_line"
        
        # Get context around error
        local context=$(sed -n "$((error_line-5)),$((error_line+5))p" "$error_file")
        
        # AI analysis of the error
        ai_debug_error "$error_file" "$error_line" "$context"
    else
        echo "❌ File not found: $error_file"
    fi
}

# AI-powered test generation with framework detection
smart-test() {
    local target_file="$1"
    
    if [[ -z "$target_file" ]]; then
        echo "Usage: smart-test <file>"
        return 1
    fi
    
    # Detect project type and generate appropriate tests
    if [[ -f "package.json" ]]; then
        echo "📦 Detected Node.js project"
        ai_generate_tests "$target_file" "jest"
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        echo "🐍 Detected Python project"
        ai_generate_tests "$target_file" "pytest"
    elif [[ -f "Cargo.toml" ]]; then
        echo "🦀 Detected Rust project"
        ai_generate_tests "$target_file" "rust"
    elif [[ -f "go.mod" ]]; then
        echo "🐹 Detected Go project"
        ai_generate_tests "$target_file" "go"
    else
        echo "🤖 Auto-detecting test framework..."
        ai_generate_tests "$target_file" "auto"
    fi
}

# AI-enhanced code formatting and optimization
optimize-code() {
    local target="${1:-.}"
    
    echo "🔧 AI Code Optimization for: $target"
    
    # Find relevant files
    local files=()
    if [[ -f "$target" ]]; then
        files=("$target")
    else
        mapfile -t files < <(find "$target" -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" | head -10)
    fi
    
    for file in "${files[@]}"; do
        echo "🎯 Optimizing: $file"
        
        # AI refactoring suggestions
        ai_suggest_refactor "$file"
        
        # Apply standard formatting
        case "$file" in
            *.py)
                if command -v ruff >/dev/null 2>&1; then
                    ruff format "$file"
                fi
                if command -v isort >/dev/null 2>&1; then
                    isort "$file"
                fi
                ;;
            *.js|*.ts)
                if command -v prettier >/dev/null 2>&1; then
                    prettier --write "$file"
                fi
                ;;
            *.rs)
                if command -v rustfmt >/dev/null 2>&1; then
                    rustfmt "$file"
                fi
                ;;
            *.go)
                if command -v gofmt >/dev/null 2>&1; then
                    gofmt -w "$file"
                fi
                ;;
        esac
        
        echo "✅ Optimized: $file"
        echo ""
    done
}

# AI-powered dependency analysis
deps-analyze() {
    local project_dir="${1:-.}"
    
    echo "📦 AI Dependency Analysis for: $project_dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Analyze different package managers
    if [[ -f "$project_dir/package.json" ]]; then
        echo "📄 Analyzing package.json..."
        ai_analyze_dependencies "npm" "$project_dir/package.json"
    fi
    
    if [[ -f "$project_dir/pyproject.toml" ]]; then
        echo "📄 Analyzing pyproject.toml..."
        ai_analyze_dependencies "python" "$project_dir/pyproject.toml"
    fi
    
    if [[ -f "$project_dir/requirements.txt" ]]; then
        echo "📄 Analyzing requirements.txt..."
        ai_analyze_dependencies "pip" "$project_dir/requirements.txt"
    fi
    
    if [[ -f "$project_dir/Cargo.toml" ]]; then
        echo "📄 Analyzing Cargo.toml..."
        ai_analyze_dependencies "rust" "$project_dir/Cargo.toml"
    fi
    
    if [[ -f "$project_dir/go.mod" ]]; then
        echo "📄 Analyzing go.mod..."
        ai_analyze_dependencies "go" "$project_dir/go.mod"
    fi
}

# AI-enhanced documentation generation
docs-ai() {
    local target="${1:-.}"
    local doc_type="${2:-all}"
    
    echo "📚 AI Documentation Generation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case "$doc_type" in
        "readme"|"all")
            echo "📖 Generating README.md..."
            ai_generate_docs "$target" "readme"
            ;;
        "api"|"all")
            echo "🔗 Generating API documentation..."
            ai_generate_docs "$target" "api"
            ;;
        "comments"|"all")
            echo "💬 Generating code comments..."
            ai_generate_docs "$target" "comments"
            ;;
    esac
    
    if [[ "$doc_type" == "all" ]]; then
        echo "📊 Generating project metrics..."
        ai_generate_project_metrics "$target"
    fi
}

# AI-powered learning assistant
learn() {
    local topic="$1"
    local context="${2:-development}"
    
    if [[ -z "$topic" ]]; then
        echo "Usage: learn <topic> [context]"
        echo "Examples:"
        echo "  learn 'async/await' javascript"
        echo "  learn 'dependency injection' python"
        echo "  learn 'memory management' rust"
        return 1
    fi
    
    echo "🎓 AI Learning Assistant"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📖 Topic: $topic"
    echo "🎯 Context: $context"
    echo ""
    
    ai_explain_concept "$topic" "$context"
}

# AI-enhanced error resolution
fix-error() {
    local error_message="$1"
    local file_context="$2"
    
    if [[ -z "$error_message" ]]; then
        echo "Usage: fix-error '<error_message>' [file]"
        echo "Example: fix-error 'TypeError: Cannot read property' src/main.js"
        return 1
    fi
    
    echo "🔧 AI Error Resolution Assistant"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Error: $error_message"
    if [[ -n "$file_context" ]]; then
        echo "📁 File: $file_context"
    fi
    echo ""
    
    ai_resolve_error "$error_message" "$file_context"
}

# AI-powered code migration assistant
migrate-code() {
    local from_tech="$1"
    local to_tech="$2"
    local target_file="$3"
    
    if [[ -z "$from_tech" ]] || [[ -z "$to_tech" ]] || [[ -z "$target_file" ]]; then
        echo "Usage: migrate-code <from> <to> <file>"
        echo "Examples:"
        echo "  migrate-code javascript typescript src/app.js"
        echo "  migrate-code python3.8 python3.11 src/main.py"
        echo "  migrate-code react vue src/component.jsx"
        return 1
    fi
    
    echo "🔄 AI Code Migration Assistant"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📤 From: $from_tech"
    echo "📥 To: $to_tech"
    echo "📁 File: $target_file"
    echo ""
    
    ai_migrate_code "$from_tech" "$to_tech" "$target_file"
}

# AI-enhanced performance profiling
profile-ai() {
    local target="${1:-.}"
    local language="${2:-auto}"
    
    echo "⚡ AI Performance Profiling"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Auto-detect language if not specified
    if [[ "$language" == "auto" ]]; then
        if [[ -f "package.json" ]]; then
            language="javascript"
        elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
            language="python"
        elif [[ -f "Cargo.toml" ]]; then
            language="rust"
        elif [[ -f "go.mod" ]]; then
            language="go"
        fi
    fi
    
    echo "🎯 Language: $language"
    echo "📁 Target: $target"
    echo ""
    
    ai_performance_analysis "$target" "$language"
}

# AI-powered security audit
security-ai() {
    local target="${1:-.}"
    
    echo "🔒 AI Security Audit"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Static analysis
    echo "🔍 Static Security Analysis..."
    ai_security_scan "$target"
    
    # Dependency vulnerability check
    echo "📦 Dependency Vulnerability Check..."
    ai_dependency_security_check "$target"
    
    # Configuration security
    echo "⚙️ Configuration Security Review..."
    ai_config_security_review "$target"
    
    # Generate security report
    echo "📊 Generating Security Report..."
    ai_generate_security_report "$target"
}

# AI integration status and diagnostics
ai-status() {
    echo "🤖 AI Integration Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check available providers
    local providers=($(detect_ai_providers))
    echo "Available AI Providers:"
    for provider in "${providers[@]}"; do
        echo "  ✅ $provider"
    done
    
    if [[ ${#providers[@]} -eq 0 ]]; then
        echo "  ❌ No AI providers available"
    fi
    
    # Check configuration
    echo ""
    echo "Configuration:"
    if [[ -f "$AI_CONFIG_DIR/config.yaml" ]]; then
        echo "  ✅ AI config found: $AI_CONFIG_DIR/config.yaml"
        echo "  📊 Default provider: $(detect_preferred_provider)"
    else
        echo "  ❌ AI config not found"
        echo "  💡 Run 'setup_ai_integration' to configure"
    fi
    
    # Check recent usage
    echo ""
    echo "Recent Usage:"
    if [[ -f "$AI_LOG_FILE" ]]; then
        echo "  📊 Log entries: $(wc -l < "$AI_LOG_FILE")"
        echo "  📅 Last activity: $(tail -1 "$AI_LOG_FILE" | cut -d']' -f1 | tr -d '[')"
    else
        echo "  📊 No usage logged yet"
    fi
}

# Quick AI setup
ai-setup() {
    echo "🚀 AI Integration Quick Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    setup_ai_integration
    
    echo ""
    echo "🎯 Available AI Commands:"
    echo "  gc                    # AI-powered commit messages"
    echo "  gai                   # Generate commit with AI"
    echo "  grev <files>          # AI code review"
    echo "  smart-test <file>     # Generate tests with AI"
    echo "  optimize-code <path>  # AI code optimization"
    echo "  project-analyze       # Full project AI analysis"
    echo "  learn <topic>         # AI learning assistant"
    echo "  fix-error '<msg>'     # AI error resolution"
    echo "  docs-ai               # AI documentation generation"
    echo "  security-ai           # AI security audit"
    echo ""
    echo "✅ AI integration ready!"
}

# Functions are available in current shell session