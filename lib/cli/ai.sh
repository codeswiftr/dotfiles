#!/usr/bin/env bash
# ============================================================================
# DOT CLI - AI Integration
# AI-powered development assistance and automation
# ============================================================================

# Load AI backend (provider detection, API dispatch, security filtering)
source "$DOTFILES_DIR/lib/ai-integration.sh"

# Load install.sh helpers for tool management (yaml queries, verify, install)
_ai_load_install_helpers() {
    if [[ -n "${_AI_HELPERS_LOADED:-}" ]]; then return 0; fi
    local _install_script="$DOTFILES_DIR/install.sh"
    [[ -f "$_install_script" ]] || return 1
    local _old_opts _old_pipefail
    _old_opts=$(set +o)
    _old_pipefail=$(shopt -po pipefail 2>/dev/null || true)
    CONFIG_FILE="${CONFIG_FILE:-$DOTFILES_DIR/config/tools.yaml}"
    source "$_install_script"
    eval "$_old_opts" 2>/dev/null || true
    eval "$_old_pipefail" 2>/dev/null || true
    _AI_HELPERS_LOADED=1
}

# Get tool description from tools.yaml
_yaml_query_tool_description() {
    local tool="$1"
    local config_file="$DOTFILES_DIR/config/tools.yaml"
    if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
        python3 - "$config_file" "$tool" <<'PY'
import sys, yaml
cfg_path, tool = sys.argv[1:3]
with open(cfg_path, 'r') as f:
    data = yaml.safe_load(f)
print((data.get('tools', {}).get(tool, {}) or {}).get('description', '') or '')
PY
    else
        grep -A 2 "^  $tool:" "$config_file" | grep "description:" | head -1 | sed 's/.*description: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/'
    fi
}

# AI command dispatcher
dot_ai() {
    local subcommand="${1:-}"
    shift || true

    case "$subcommand" in
        "review")     ai_code_review "$@" ;;
        "test")       ai_generate_tests "$@" ;;
        "commit")     ai_smart_commit "$@" ;;
        "explain")    ai_explain_code "$@" ;;
        "docs")       ai_generate_docs "$@" ;;
        "fix")        ai_fix_code "$@" ;;
        "refactor")   ai_refactor_code "$@" ;;
        "status")     ai_status ;;
        "setup")      ai_setup ;;
        "install-all"|"sync") ai_sync "$@" ;;
        "debug")      ai_debug_error "$@" ;;
        "compare")    ai_compare_models "$@" ;;
        "-h"|"--help"|"") show_ai_help ;;
        *)
            print_error "Unknown AI subcommand: $subcommand"
            echo "Run 'dot ai --help' for available commands."
            return 1
            ;;
    esac
}

# ============================================================================
# Core AI Commands (all use ai_api_call for unified provider dispatch)
# ============================================================================

ai_code_review() {
    local target="${1:-.}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    local detailed=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider) provider="$2"; shift 2 ;;
            --detailed) detailed=true; shift ;;
            --help) echo "Usage: dot ai review [file/dir] [--provider claude|gemini|openai] [--detailed]"; return 0 ;;
            *) target="$1"; shift ;;
        esac
    done

    if [[ ! -e "$target" ]]; then
        print_error "Target not found: $target"
        return 1
    fi

    print_info "Starting AI code review with $provider..."

    local prompt="Please review this code for:"
    prompt+="\n- Code quality and best practices"
    prompt+="\n- Security vulnerabilities"
    prompt+="\n- Performance optimizations"
    prompt+="\n- Bug detection"
    [[ "$detailed" == "true" ]] && prompt+="\n\nProvide detailed explanations and specific recommendations."

    local content
    if [[ -d "$target" ]]; then
        content=$(find "$target" -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" -o -name "*.go" -o -name "*.rs" 2>/dev/null | head -5 | xargs cat 2>/dev/null)
    else
        content=$(cat "$target")
    fi

    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "$result"
    else
        print_error "Review failed: $result"
        return 1
    fi
}

ai_generate_tests() {
    local target="${1}"
    local framework="${2:-auto}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"

    if [[ -z "$target" ]]; then
        print_error "Please specify a file to generate tests for"
        echo "Usage: dot ai test <file> [framework]"
        return 1
    fi
    if [[ ! -f "$target" ]]; then
        print_error "File not found: $target"
        return 1
    fi

    [[ "$framework" == "auto" ]] && framework=$(_detect_test_framework)

    print_info "Generating tests for $target using $framework..."

    local prompt="Generate comprehensive unit tests for this code using $framework."
    prompt+="\n\nInclude: happy path tests, edge cases, error handling, mock dependencies where appropriate."

    local content
    content=$(cat "$target")
    local test_file
    test_file=$(_generate_test_filename "$target" "$framework")

    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "$result" > "$test_file"
        print_success "Tests generated: $test_file"
    else
        print_error "Test generation failed: $result"
        return 1
    fi
}

ai_smart_commit() {
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    local auto_commit=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)     auto_commit=true; shift ;;
            --provider) provider="$2"; shift 2 ;;
            --help)     echo "Usage: dot ai commit [--auto] [--provider claude|gemini|openai]"; return 0 ;;
            *)          shift ;;
        esac
    done

    if git diff --quiet && git diff --cached --quiet; then
        print_warning "No changes to commit"
        return 0
    fi

    print_info "Generating smart commit message..."

    local diff_content
    diff_content=$(git diff --cached)
    if [[ -z "$diff_content" ]]; then
        git add .
        diff_content=$(git diff --cached)
    fi

    local prompt="Analyze this git diff and generate a concise conventional commit message."
    prompt+="\nFormat: type(scope): description"
    prompt+="\nTypes: feat, fix, docs, style, refactor, test, chore"
    prompt+="\nKeep under 72 characters. Return ONLY the commit message line."

    local commit_message
    commit_message=$(ai_api_call "$provider" "$prompt" "$diff_content" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [[ -n "$commit_message" ]] && [[ "$commit_message" != "Error:"* ]]; then
        echo ""
        echo "Suggested commit message:"
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
                echo "Commit cancelled."
            fi
        fi
    else
        print_error "Failed to generate commit message"
        return 1
    fi
}

ai_explain_code() {
    local target="${1:-.}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"
    local simple=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --simple)   simple=true; shift ;;
            --provider) provider="$2"; shift 2 ;;
            --help)     echo "Usage: dot ai explain [file] [--simple] [--provider claude|gemini|openai]"; return 0 ;;
            *)          target="$1"; shift ;;
        esac
    done

    if [[ ! -e "$target" ]]; then
        print_error "Target not found: $target"
        return 1
    fi

    print_info "Explaining code with $provider..."

    local prompt="Explain this code in clear, understandable terms."
    if [[ "$simple" == "true" ]]; then
        prompt+="\n\nUse simple language suitable for beginners."
    else
        prompt+="\n\nInclude: what the code does, how it works, key patterns used, potential improvements."
    fi

    local content
    content=$(cat "$target")
    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "$result"
    else
        print_error "Explanation failed: $result"
        return 1
    fi
}

ai_generate_docs() {
    local target="${1:-.}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"

    print_info "Generating documentation for $target..."

    local content
    if [[ -d "$target" ]]; then
        content=$(find "$target" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" \) 2>/dev/null | head -10 | while read -r f; do echo "--- $f ---"; head -50 "$f"; echo; done)
    elif [[ -f "$target" ]]; then
        content=$(cat "$target")
    else
        print_error "Target not found: $target"
        return 1
    fi

    local prompt="Generate comprehensive documentation for this code. Include: purpose, API reference, usage examples, and configuration notes."
    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "$result"
    else
        print_error "Documentation generation failed: $result"
        return 1
    fi
}

ai_fix_code() {
    local target_file="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"

    if [[ -z "$target_file" ]]; then
        echo "Usage: dot ai fix <file>"
        return 1
    fi
    if [[ ! -f "$target_file" ]]; then
        print_error "File not found: $target_file"
        return 1
    fi

    print_info "Analyzing code for issues and fixes..."

    local content
    content=$(cat "$target_file")
    local prompt="Analyze this code and provide specific fixes for bugs, security issues, performance problems, and best practice violations. For each issue, provide before/after examples."

    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "Code Fix Analysis for $target_file:"
        echo ""
        echo "$result"
    else
        print_error "Failed to analyze code for fixes"
        return 1
    fi
}

ai_refactor_code() {
    local target_file="$1"
    local focus="${2:-general}"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"

    if [[ -z "$target_file" ]]; then
        echo "Usage: dot ai refactor <file> [focus]"
        echo "Focus options: performance, maintainability, security, general"
        return 1
    fi
    if [[ ! -f "$target_file" ]]; then
        print_error "File not found: $target_file"
        return 1
    fi

    print_info "Generating refactoring suggestions..."

    local content
    content=$(cat "$target_file")
    local prompt="Suggest refactoring improvements for this code with focus on: $focus. Provide specific before/after examples."

    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "Refactoring Suggestions for $target_file (focus: $focus):"
        echo ""
        echo "$result"
    else
        print_error "Failed to generate refactoring suggestions"
        return 1
    fi
}

ai_debug_error() {
    local error_input="$1"
    local provider="${AI_PROVIDER:-$(detect_preferred_provider)}"

    if [[ -z "$error_input" ]]; then
        print_error "Usage: dot ai debug <error_message_or_log_file>"
        return 1
    fi

    print_info "Debugging error with $provider..."

    local content
    if [[ -f "$error_input" ]]; then
        content=$(cat "$error_input")
    else
        content="$error_input"
    fi

    local prompt="Debug this error and provide: root cause, step-by-step solution, and prevention strategy."
    local result
    result=$(ai_api_call "$provider" "$prompt" "$content")
    if [[ -n "$result" ]] && [[ "$result" != "Error:"* ]]; then
        echo "$result"
    else
        print_error "Debug analysis failed"
        return 1
    fi
}

ai_compare_models() {
    local prompt="$1"
    if [[ -z "$prompt" ]]; then
        print_error "Usage: dot ai compare <question>"
        return 1
    fi

    print_warning "This will send your prompt to multiple AI services"
    echo -n "Continue? [y/N]: "
    read -r confirmation
    [[ "$confirmation" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    local available
    available=($(detect_ai_providers))
    for provider in "${available[@]}"; do
        echo ""
        echo "=== ${provider} ==="
        ai_api_call "$provider" "$prompt" "" 2>/dev/null || echo "(unavailable)"
    done
    echo ""
    echo "=== Comparison complete ==="
}

# ============================================================================
# Tool Management (data-driven from config/tools.yaml)
# ============================================================================

ai_status() {
    _ai_load_install_helpers || { print_error "Could not load install helpers"; return 1; }

    echo "AI Tools Status:"
    echo ""

    local tools installed_count=0 total_count=0
    tools=$(yaml_query_group_tools "ai_tools")
    if [[ -z "$tools" ]]; then
        print_error "Could not read ai_tools group from config/tools.yaml"
        return 1
    fi

    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        ((total_count++))
        local desc
        desc=$(_yaml_query_tool_description "$tool")
        if verify_tool "$tool"; then
            printf "  ✅ %-20s %s\n" "$tool" "$desc"
            ((installed_count++))
        else
            printf "  ❌ %-20s %s\n" "$tool" "$desc"
        fi
    done <<< "$tools"

    local missing_count=$((total_count - installed_count))
    echo ""
    echo "Installed: ${installed_count}/${total_count}  |  Missing: ${missing_count}"
    [[ $missing_count -gt 0 ]] && echo "" && echo "Run 'dot ai sync' to install missing tools."
}

ai_sync() {
    _ai_load_install_helpers || { print_error "Could not load install helpers"; return 1; }

    local dry_run=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run|-d) dry_run=true; shift ;;
            --help|-h) echo "Usage: dot ai sync [--dry-run]"; return 0 ;;
            *) shift ;;
        esac
    done

    local tools
    tools=$(yaml_query_group_tools "ai_tools")
    if [[ -z "$tools" ]]; then
        print_error "Could not read ai_tools group from config/tools.yaml"
        return 1
    fi

    local os installed=0 skipped=0 failed=0 attempted=0
    os=$(detect_os)
    local failed_tools=()

    print_info "Syncing AI tools from config/tools.yaml..."
    echo ""

    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        if verify_tool "$tool"; then
            printf "  ✅ %-20s already installed\n" "$tool"
            ((skipped++))
            continue
        fi
        ((attempted++))
        if [[ "$dry_run" == "true" ]]; then
            local install_cmd
            install_cmd=$(get_install_command "$tool" "$os")
            printf "  ⏳ %-20s would install: %s\n" "$tool" "${install_cmd:-<no command for $os>}"
            continue
        fi
        if install_tool "$tool" "$os"; then
            ((installed++))
        else
            ((failed++))
            failed_tools+=("$tool")
        fi
    done <<< "$tools"

    echo ""
    if [[ "$dry_run" == "true" ]]; then
        print_info "Dry run complete. ${attempted} tool(s) would be installed, ${skipped} already present."
    else
        print_success "Sync complete: ${installed} installed, ${skipped} already present, ${failed} failed."
        [[ ${#failed_tools[@]} -gt 0 ]] && print_warning "Failed: ${failed_tools[*]}"
    fi
}

ai_setup() {
    print_info "Setting up AI integrations..."
    echo ""
    echo "Available AI providers:"
    local available
    available=($(detect_ai_providers))
    if [[ ${#available[@]} -eq 0 ]]; then
        echo "  No providers detected."
        echo ""
        echo "Install one of:"
        echo "  npm install -g @anthropic-ai/claude-code    # Claude"
        echo "  npm install -g @anthropic-ai/codex           # Codex"
        echo "  npm install -g @google/gemini-cli             # Gemini"
        echo "  gh extension install github/gh-copilot        # Copilot"
    else
        for p in "${available[@]}"; do
            printf "  ✅ %s\n" "$p"
        done
    fi
    echo ""
    echo "Set your preferred provider: export AI_PROVIDER=claude|gemini|openai"
}

# ============================================================================
# Utilities
# ============================================================================

_detect_test_framework() {
    if [[ -f "package.json" ]]; then
        if grep -q "jest" package.json; then echo "jest"
        elif grep -q "vitest" package.json; then echo "vitest"
        elif grep -q "mocha" package.json; then echo "mocha"
        else echo "jest"
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then echo "pytest"
    elif [[ -f "Cargo.toml" ]]; then echo "rust-test"
    elif [[ -f "go.mod" ]]; then echo "go-test"
    else echo "generic"
    fi
}

_generate_test_filename() {
    local source_file="$1" framework="$2"
    local dir name ext
    dir=$(dirname "$source_file")
    name="${source_file##*/}"; name="${name%.*}"
    ext="${source_file##*.}"
    case "$framework" in
        "jest"|"vitest"|"mocha") echo "${dir}/${name}.test.${ext}" ;;
        "pytest")               echo "${dir}/test_${name}.py" ;;
        "rust-test")            echo "${dir}/${name}_test.rs" ;;
        "go-test")              echo "${dir}/${name}_test.go" ;;
        *)                      echo "${dir}/${name}_test.${ext}" ;;
    esac
}

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
    docs [file/dir]          Generate documentation
    fix <file>               Suggest code fixes
    refactor <file> [focus]  Suggest refactoring (performance|maintainability|security|general)
    debug <error>            Debug errors with AI assistance
    compare <prompt>         Compare responses from multiple AI providers
    status                   Show AI tools install status (from tools.yaml)
    sync [--dry-run]         Install missing AI tools from tools.yaml
    setup                    Show available AI providers

OPTIONS:
    --provider <name>        Use specific AI provider (claude|gemini|openai)
    --detailed               Provide detailed analysis (review)
    --simple                 Use simple explanations (explain)
    --auto                   Auto-apply (commit)
    -h, --help               Show this help message

EXAMPLES:
    dot ai review src/main.py         # Review Python file
    dot ai test utils.js jest         # Generate Jest tests
    dot ai commit --auto              # Auto-commit with AI message
    dot ai explain --simple app.go    # Simple explanation
    dot ai status                     # Check AI tools
    dot ai sync                       # Install missing AI tools
EOF
}
