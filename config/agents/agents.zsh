# ============================================================================
# AI Agent Integration
# Unified aliases and functions for agentic coding tools
# ============================================================================

# ============================================================================
# QUICK ALIASES
# ============================================================================

# Primary agents
alias c="ai claude"
alias cu="ai cursor"
alias aa="ai aider"
alias oc="ai opencode"

# Agent listing
alias ai-list="ai --list"

# ============================================================================
# AGENT-SPECIFIC SHORTCUTS
# ============================================================================

# Claude Code
alias claude-resume="claude --resume"
alias claude-continue="claude --continue"

# Aider with common configurations
alias aider-gpt4="aider --model gpt-4-turbo"
alias aider-claude="aider --model claude-3-opus-20240229"
alias aider-sonnet="aider --model claude-3-5-sonnet-20241022"
alias aider-watch="aider --watch"

# OpenCode
alias opencode-chat="opencode chat"

# ============================================================================
# PROJECT-AWARE AGENT FUNCTIONS
# ============================================================================

# Launch agent with project context
ai-project() {
    local agent="${1:-claude}"
    shift 2>/dev/null || true
    
    # Detect project type and provide context
    local context=""
    
    if [[ -f "CLAUDE.md" ]]; then
        context="--context CLAUDE.md"
    elif [[ -f "AGENTS.md" ]]; then
        context="--context AGENTS.md"
    elif [[ -f "README.md" ]]; then
        context="--context README.md"
    fi
    
    echo "🤖 Launching $agent in $(basename $(pwd))"
    [[ -n "$context" ]] && echo "   Context: $context"
    
    ai "$agent" $context "$@"
}

# Quick code review with AI
ai-review() {
    local agent="${AI_DEFAULT_AGENT:-claude}"
    local files="${@:-.}"
    
    echo "🔍 Code review with $agent"
    
    case "$agent" in
        claude)
            claude --review "$files"
            ;;
        aider)
            aider --message "Review this code for bugs, security issues, and improvements" "$files"
            ;;
        *)
            ai "$agent" "Review this code" "$files"
            ;;
    esac
}

# Generate documentation
ai-doc() {
    local agent="${AI_DEFAULT_AGENT:-claude}"
    local files="${@:-.}"
    
    echo "📝 Generating documentation with $agent"
    
    case "$agent" in
        claude)
            claude --doc "$files"
            ;;
        aider)
            aider --message "Generate comprehensive documentation for this code" "$files"
            ;;
        *)
            ai "$agent" "Document this code" "$files"
            ;;
    esac
}

# Explain code
ai-explain() {
    local agent="${AI_DEFAULT_AGENT:-claude}"
    local files="${@:-.}"
    
    echo "💡 Explaining code with $agent"
    
    case "$agent" in
        claude)
            claude --explain "$files"
            ;;
        *)
            ai "$agent" "Explain this code in detail" "$files"
            ;;
    esac
}

# ============================================================================
# MULTI-AGENT WORKFLOWS
# ============================================================================

# Compare outputs from multiple agents
ai-compare() {
    local prompt="$1"
    
    if [[ -z "$prompt" ]]; then
        echo "Usage: ai-compare 'your prompt here'"
        return 1
    fi
    
    echo "🔄 Comparing responses from multiple agents..."
    echo "Prompt: $prompt"
    echo ""
    
    # Run agents in background, capture outputs
    local tmpdir=$(mktemp -d)
    
    if command -v claude &>/dev/null; then
        echo "--- Claude ---" > "$tmpdir/claude.txt"
        timeout 60 claude --print "$prompt" >> "$tmpdir/claude.txt" 2>&1 &
    fi
    
    if command -v aider &>/dev/null; then
        echo "--- Aider ---" > "$tmpdir/aider.txt"
        timeout 60 aider --message "$prompt" --yes-always >> "$tmpdir/aider.txt" 2>&1 &
    fi
    
    wait
    
    # Display results
    for f in "$tmpdir"/*.txt; do
        [[ -f "$f" ]] && cat "$f"
        echo ""
    done
    
    rm -rf "$tmpdir"
}

# ============================================================================
# AGENT STATUS & HEALTH
# ============================================================================

# Check agent health and configuration
ai-status() {
    echo "🤖 AI Agent Status"
    echo "=================="
    echo ""
    
    # Default agent
    echo "Default Agent: ${AI_DEFAULT_AGENT:-claude}"
    echo ""
    
    # Check API keys
    echo "API Keys:"
    [[ -n "$ANTHROPIC_API_KEY" ]] && echo "  ✅ ANTHROPIC_API_KEY set" || echo "  ❌ ANTHROPIC_API_KEY missing"
    [[ -n "$OPENAI_API_KEY" ]] && echo "  ✅ OPENAI_API_KEY set" || echo "  ⚠️  OPENAI_API_KEY not set"
    [[ -n "$GEMINI_API_KEY" ]] && echo "  ✅ GEMINI_API_KEY set" || echo "  ⚠️  GEMINI_API_KEY not set"
    echo ""
    
    # List installed agents
    ai --list
}

# ============================================================================
# EXPORTS
# ============================================================================

# Export functions for use in scripts
export -f ai-project ai-review ai-doc ai-explain ai-status 2>/dev/null || true
