#!/usr/bin/env bash
# =============================================================================
# Git Flow Plugin - Enhanced git workflow management
# =============================================================================

# Plugin initialization
git_flow_init() {
    echo "🔀 Git Flow plugin initialized"
    
    # Set up git flow configuration
    setup_git_flow_config
    
    # Create git aliases
    setup_git_flow_aliases
}

# Plugin cleanup
git_flow_cleanup() {
    echo "🔀 Git Flow plugin cleaned up"
}

# Main git flow command
git_flow_main() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        "init"|"initialize")
            git_flow_init_repo "$@"
            ;;
        "feature")
            git_flow_feature "$@"
            ;;
        "release")
            git_flow_release "$@"
            ;;
        "hotfix")
            git_flow_hotfix "$@"
            ;;
        "status"|"st")
            git_flow_status
            ;;
        "config")
            git_flow_config "$@"
            ;;
        "help"|"-h"|"--help"|"")
            git_flow_help
            ;;
        *)
            echo "❌ Unknown git flow command: $subcommand"
            echo "Run 'dot flow help' for available commands"
            return 1
            ;;
    esac
}

# Initialize git flow in repository
git_flow_init_repo() {
    echo "🚀 Initializing Git Flow in repository..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    # Set up branch structure
    local main_branch="${1:-main}"
    local develop_branch="${2:-develop}"
    
    echo "📋 Git Flow Configuration:"
    echo "  Main branch: $main_branch"
    echo "  Develop branch: $develop_branch"
    echo "  Feature prefix: feature/"
    echo "  Release prefix: release/"
    echo "  Hotfix prefix: hotfix/"
    
    # Create develop branch if it doesn't exist
    if ! git show-ref --quiet refs/heads/"$develop_branch"; then
        echo "🌿 Creating develop branch..."
        git checkout -b "$develop_branch" "$main_branch"
        git push -u origin "$develop_branch" 2>/dev/null || true
    fi
    
    # Set git flow configuration
    git config gitflow.branch.main "$main_branch"
    git config gitflow.branch.develop "$develop_branch"
    git config gitflow.prefix.feature "feature/"
    git config gitflow.prefix.release "release/"
    git config gitflow.prefix.hotfix "hotfix/"
    
    echo "✅ Git Flow initialized successfully"
}

# Feature branch management
git_flow_feature() {
    local action="${1:-help}"
    local feature_name="$2"
    
    case "$action" in
        "start"|"new")
            git_flow_feature_start "$feature_name"
            ;;
        "finish"|"done")
            git_flow_feature_finish "$feature_name"
            ;;
        "publish"|"push")
            git_flow_feature_publish "$feature_name"
            ;;
        "list"|"ls")
            git_flow_feature_list
            ;;
        "delete"|"rm")
            git_flow_feature_delete "$feature_name"
            ;;
        "help"|"-h"|"--help"|"")
            git_flow_feature_help
            ;;
        *)
            echo "❌ Unknown feature command: $action"
            echo "Run 'dot feature help' for available commands"
            return 1
            ;;
    esac
}

# Start feature branch
git_flow_feature_start() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "❌ Feature name required"
        echo "Usage: dot feature start <name>"
        return 1
    fi
    
    local develop_branch
    develop_branch=$(git config gitflow.branch.develop 2>/dev/null || echo "develop")
    local feature_branch="feature/$feature_name"
    
    echo "🌿 Starting feature: $feature_name"
    
    # Switch to develop and pull latest
    git checkout "$develop_branch"
    git pull origin "$develop_branch" 2>/dev/null || true
    
    # Create feature branch
    git checkout -b "$feature_branch" "$develop_branch"
    
    echo "✅ Feature branch created: $feature_branch"
    echo "💡 When ready, use: dot feature finish $feature_name"
}

# Finish feature branch
git_flow_feature_finish() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        # Try to detect current feature branch
        local current_branch
        current_branch=$(git branch --show-current)
        if [[ "$current_branch" =~ ^feature/ ]]; then
            feature_name="${current_branch#feature/}"
        else
            echo "❌ Feature name required or run from feature branch"
            echo "Usage: dot feature finish <name>"
            return 1
        fi
    fi
    
    local develop_branch
    develop_branch=$(git config gitflow.branch.develop 2>/dev/null || echo "develop")
    local feature_branch="feature/$feature_name"
    
    echo "🔀 Finishing feature: $feature_name"
    
    # Check if feature branch exists
    if ! git show-ref --quiet refs/heads/"$feature_branch"; then
        echo "❌ Feature branch doesn't exist: $feature_branch"
        return 1
    fi
    
    # Switch to feature branch and push latest changes
    git checkout "$feature_branch"
    git push origin "$feature_branch" 2>/dev/null || true
    
    # Switch to develop and merge
    git checkout "$develop_branch"
    git pull origin "$develop_branch" 2>/dev/null || true
    
    # Merge feature with no-ff to preserve history
    if git merge --no-ff "$feature_branch" -m "Merge feature '$feature_name' into develop"; then
        echo "✅ Feature merged into develop"
        
        # Push develop
        git push origin "$develop_branch" 2>/dev/null || true
        
        # Delete feature branch
        git branch -d "$feature_branch"
        git push origin --delete "$feature_branch" 2>/dev/null || true
        
        echo "✅ Feature branch cleaned up"
        echo "🎉 Feature '$feature_name' completed successfully"
    else
        echo "❌ Merge failed - resolve conflicts and try again"
        return 1
    fi
}

# Publish feature branch
git_flow_feature_publish() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        local current_branch
        current_branch=$(git branch --show-current)
        if [[ "$current_branch" =~ ^feature/ ]]; then
            feature_name="${current_branch#feature/}"
        else
            echo "❌ Feature name required or run from feature branch"
            return 1
        fi
    fi
    
    local feature_branch="feature/$feature_name"
    
    echo "📤 Publishing feature: $feature_name"
    
    git checkout "$feature_branch"
    git push -u origin "$feature_branch"
    
    echo "✅ Feature published: $feature_branch"
}

# List feature branches
git_flow_feature_list() {
    echo "🌿 Feature Branches:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local current_branch
    current_branch=$(git branch --show-current)
    
    git branch --list "feature/*" | while read -r branch; do
        branch=$(echo "$branch" | sed 's/^[* ] *//')
        local feature_name="${branch#feature/}"
        
        if [[ "$branch" == "$current_branch" ]]; then
            echo "  ▶ $feature_name (current)"
        else
            echo "  • $feature_name"
        fi
    done
    
    # Show remote feature branches
    echo ""
    echo "Remote Feature Branches:"
    git branch -r --list "origin/feature/*" 2>/dev/null | while read -r branch; do
        branch=$(echo "$branch" | sed 's/^[* ] *//')
        local feature_name="${branch#origin/feature/}"
        echo "  🌐 $feature_name"
    done || true
}

# Delete feature branch
git_flow_feature_delete() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "❌ Feature name required"
        echo "Usage: dot feature delete <name>"
        return 1
    fi
    
    local feature_branch="feature/$feature_name"
    
    echo "🗑️  Deleting feature: $feature_name"
    
    # Check if feature branch exists
    if ! git show-ref --quiet refs/heads/"$feature_branch"; then
        echo "❌ Feature branch doesn't exist: $feature_branch"
        return 1
    fi
    
    # Don't delete if we're currently on this branch
    local current_branch
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" == "$feature_branch" ]]; then
        echo "❌ Cannot delete current branch. Switch to another branch first."
        return 1
    fi
    
    # Force delete the branch
    git branch -D "$feature_branch"
    git push origin --delete "$feature_branch" 2>/dev/null || true
    
    echo "✅ Feature branch deleted: $feature_branch"
}

# Release management (simplified version)
git_flow_release() {
    local action="${1:-help}"
    local version="$2"
    
    case "$action" in
        "start"|"new")
            git_flow_release_start "$version"
            ;;
        "finish"|"done")
            git_flow_release_finish "$version"
            ;;
        "help"|"-h"|"--help"|"")
            echo "Release Management:"
            echo "  start <version>    Start a new release branch"
            echo "  finish <version>   Finish release and merge to main"
            ;;
        *)
            echo "❌ Unknown release command: $action"
            ;;
    esac
}

# Start release branch
git_flow_release_start() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        echo "❌ Version required"
        echo "Usage: dot release start <version>"
        return 1
    fi
    
    local develop_branch
    develop_branch=$(git config gitflow.branch.develop 2>/dev/null || echo "develop")
    local release_branch="release/$version"
    
    echo "🚀 Starting release: $version"
    
    git checkout "$develop_branch"
    git pull origin "$develop_branch" 2>/dev/null || true
    git checkout -b "$release_branch" "$develop_branch"
    
    echo "✅ Release branch created: $release_branch"
}

# Finish release branch
git_flow_release_finish() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        echo "❌ Version required"
        return 1
    fi
    
    local main_branch develop_branch
    main_branch=$(git config gitflow.branch.main 2>/dev/null || echo "main")
    develop_branch=$(git config gitflow.branch.develop 2>/dev/null || echo "develop")
    local release_branch="release/$version"
    
    echo "🎯 Finishing release: $version"
    
    # Merge to main
    git checkout "$main_branch"
    git pull origin "$main_branch" 2>/dev/null || true
    git merge --no-ff "$release_branch" -m "Release $version"
    
    # Create tag
    git tag -a "v$version" -m "Version $version"
    
    # Merge back to develop
    git checkout "$develop_branch"
    git pull origin "$develop_branch" 2>/dev/null || true
    git merge --no-ff "$release_branch" -m "Merge release $version back to develop"
    
    # Clean up
    git branch -d "$release_branch"
    
    # Push everything
    git checkout "$main_branch"
    git push origin "$main_branch" 2>/dev/null || true
    git push origin "v$version" 2>/dev/null || true
    git checkout "$develop_branch"
    git push origin "$develop_branch" 2>/dev/null || true
    
    echo "✅ Release $version completed successfully"
}

# Hotfix management (simplified version)
git_flow_hotfix() {
    echo "🔥 Hotfix management coming soon..."
    echo "For now, create hotfix branches manually from main"
}

# Show git flow status
git_flow_status() {
    echo "📊 Git Flow Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if git flow is initialized
    if ! git config gitflow.branch.main >/dev/null 2>&1; then
        echo "❌ Git Flow not initialized in this repository"
        echo "Run: dot flow init"
        return 1
    fi
    
    local main_branch develop_branch
    main_branch=$(git config gitflow.branch.main)
    develop_branch=$(git config gitflow.branch.develop)
    
    echo "Configuration:"
    echo "  Main branch: $main_branch"
    echo "  Develop branch: $develop_branch"
    echo ""
    
    echo "Current branch: $(git branch --show-current)"
    echo ""
    
    # Show feature branches
    local feature_count
    feature_count=$(git branch --list "feature/*" | wc -l | tr -d ' ')
    echo "Feature branches: $feature_count"
    if [[ $feature_count -gt 0 ]]; then
        git branch --list "feature/*" | sed 's/^/  /'
    fi
    
    # Show release branches
    local release_count
    release_count=$(git branch --list "release/*" | wc -l | tr -d ' ')
    echo "Release branches: $release_count"
    if [[ $release_count -gt 0 ]]; then
        git branch --list "release/*" | sed 's/^/  /'
    fi
    
    # Show recent tags
    echo ""
    echo "Recent tags:"
    git tag --sort=-version:refname | head -5 | sed 's/^/  /' || echo "  No tags"
}

# Configure git flow
git_flow_config() {
    echo "⚙️  Git Flow Configuration:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local main_branch develop_branch
    main_branch=$(git config gitflow.branch.main 2>/dev/null || echo "not set")
    develop_branch=$(git config gitflow.branch.develop 2>/dev/null || echo "not set")
    
    echo "Main branch: $main_branch"
    echo "Develop branch: $develop_branch"
    echo "Feature prefix: $(git config gitflow.prefix.feature 2>/dev/null || echo 'feature/')"
    echo "Release prefix: $(git config gitflow.prefix.release 2>/dev/null || echo 'release/')"
    echo "Hotfix prefix: $(git config gitflow.prefix.hotfix 2>/dev/null || echo 'hotfix/')"
}

# Set up git flow configuration
setup_git_flow_config() {
    # Set default git flow preferences
    git config --global core.editor "${EDITOR:-vim}"
    git config --global pull.rebase false
    git config --global merge.tool "vimdiff"
}

# Set up git aliases for flow
setup_git_flow_aliases() {
    # Only set up if not already configured
    if ! git config alias.flow >/dev/null 2>&1; then
        git config --global alias.flow "!dot flow"
        git config --global alias.feature "!dot feature"
        git config --global alias.release "!dot release"
    fi
}

# Git flow help
git_flow_help() {
    cat << 'EOF'
🔀 Git Flow - Enhanced Workflow Management

USAGE:
    dot flow <command> [options]

COMMANDS:
    init [main] [develop]     Initialize git flow (default: main/develop)
    status                   Show git flow status
    config                   Show git flow configuration
    
    feature <action>         Feature branch management
      start <name>             Start new feature branch
      finish [name]            Finish feature (merge to develop)
      publish [name]           Publish feature to remote
      list                     List feature branches
      delete <name>            Delete feature branch
    
    release <action>         Release branch management  
      start <version>          Start release branch
      finish <version>         Finish release (merge to main)
    
    hotfix <action>          Hotfix branch management (coming soon)

EXAMPLES:
    # Initialize git flow
    dot flow init main develop
    
    # Feature workflow
    dot flow feature start user-auth
    # ... work on feature ...
    dot flow feature publish user-auth
    dot flow feature finish user-auth
    
    # Release workflow
    dot flow release start 1.2.0
    dot flow release finish 1.2.0
    
    # Status and management
    dot flow status
    dot flow feature list

WORKFLOW:
    1. Initialize: dot flow init
    2. Features: branch from develop, merge back to develop
    3. Releases: branch from develop, merge to main and back to develop
    4. Hotfixes: branch from main, merge to main and develop

BRANCH STRUCTURE:
    main       Production-ready code
    develop    Integration branch for features
    feature/*  Feature development branches
    release/*  Release preparation branches
    hotfix/*   Emergency fixes for production

Git Aliases (automatically configured):
    git flow     → dot flow
    git feature  → dot feature  
    git release  → dot release

For more information: https://docs.dotfiles.dev/plugins/git-flow
EOF
}

# Feature help
git_flow_feature_help() {
    cat << 'EOF'
🌿 Feature Branch Management

USAGE:
    dot feature <action> [name]

ACTIONS:
    start <name>      Start new feature branch from develop
    finish [name]     Finish feature (merge to develop and cleanup)
    publish [name]    Publish feature branch to remote
    list              List all feature branches (local and remote)
    delete <name>     Delete feature branch (local and remote)

EXAMPLES:
    dot feature start user-authentication
    dot feature publish user-authentication
    dot feature finish user-authentication
    dot feature list
    dot feature delete old-feature

WORKFLOW:
    1. Start: Creates feature/name from develop
    2. Work: Make commits on feature branch
    3. Publish: Push to remote for collaboration
    4. Finish: Merge to develop with --no-ff and cleanup

NOTE:
    • Feature branches are created from and merged back to develop
    • Use meaningful names: user-auth, api-refactor, bug-fix-login
    • Finish command can auto-detect feature name if run from feature branch
EOF
}

# Export functions for plugin system
export -f git_flow_init git_flow_cleanup git_flow_main
export -f git_flow_feature git_flow_release git_flow_hotfix