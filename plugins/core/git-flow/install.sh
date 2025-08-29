#!/usr/bin/env bash
# Git Flow Plugin Installation Script

echo "🔀 Installing Git Flow plugin..."

# Check dependencies
check_git_config() {
    echo "🔍 Checking git configuration..."
    
    if ! command -v git >/dev/null 2>&1; then
        echo "❌ Git is required but not installed"
        return 1
    fi
    
    # Check for basic git configuration
    if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
        echo "⚠️  Git user.name not configured globally"
        echo "💡 Run: git config --global user.name 'Your Name'"
    fi
    
    if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
        echo "⚠️  Git user.email not configured globally"
        echo "💡 Run: git config --global user.email 'your.email@example.com'"
    fi
    
    echo "✅ Git dependency check completed"
}

# Set up git aliases for enhanced workflow
setup_git_aliases() {
    echo "⚙️  Setting up git aliases..."
    
    # Git flow aliases
    git config --global alias.flow "!dot flow"
    git config --global alias.feature "!dot feature"  
    git config --global alias.release "!dot release"
    
    # Enhanced git aliases for productivity
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.st "status"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual "!gitk"
    
    # Git flow specific shortcuts
    git config --global alias.fs "!dot feature start"
    git config --global alias.ff "!dot feature finish"
    git config --global alias.fp "!dot feature publish"
    git config --global alias.fl "!dot feature list"
    
    echo "✅ Git aliases configured successfully"
}

# Set up git flow defaults
setup_git_flow_defaults() {
    echo "⚙️  Setting up git flow defaults..."
    
    # Configure merge behavior for git flow
    git config --global merge.ff false
    git config --global merge.tool "vimdiff"
    git config --global pull.rebase false
    
    # Configure branch cleanup
    git config --global branch.autosetupmerge always
    git config --global branch.autosetuprebase always
    
    echo "✅ Git flow defaults configured"
}

# Create configuration directory
create_plugin_config() {
    local config_dir="$HOME/.config/dotfiles/plugins/git-flow"
    mkdir -p "$config_dir"
    
    # Create default configuration
    cat > "$config_dir/config.yaml" << 'EOF'
# Git Flow Plugin Configuration
git_flow:
  # Default branch names
  main_branch: "main"
  develop_branch: "develop"
  
  # Branch prefixes
  feature_prefix: "feature/"
  release_prefix: "release/"
  hotfix_prefix: "hotfix/"
  
  # Workflow settings
  auto_push: true
  auto_cleanup: true
  require_pull_request: false
  
  # Integration settings
  github_integration: true
  commit_templates: true
EOF
    
    echo "✅ Plugin configuration created at $config_dir"
}

# Main installation
main() {
    echo "📦 Git Flow Plugin Installation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run installation steps
    check_git_config
    setup_git_aliases
    setup_git_flow_defaults
    create_plugin_config
    
    echo ""
    echo "✅ Git Flow plugin installed successfully!"
    echo ""
    echo "🚀 Quick Start:"
    echo "  1. Navigate to a git repository"
    echo "  2. Run: dot flow init"
    echo "  3. Start a feature: dot feature start my-feature"
    echo "  4. Check status: dot flow status"
    echo ""
    echo "💡 Use 'dot flow help' for complete documentation"
}

# Run installation
main "$@"