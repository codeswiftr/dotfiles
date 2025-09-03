#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Git Operations
# Enhanced git operations with signing and security
# ============================================================================

# Git command dispatcher
dot_git() {
    local subcommand="${1:-}"
    shift || true
    
    case "$subcommand" in
        "setup-signing")
            git_setup_signing "$@"
            ;;
        "verify")
            git_verify_commits "$@"
            ;;
        "sign")
            git_sign_commits "$@"
            ;;
        "keys")
            git_manage_keys "$@"
            ;;
        "status")
            git_signing_status
            ;;
        "hooks")
            git_setup_hooks "$@"
            ;;
        "config")
            git_enhanced_config "$@"
            ;;
        "workflow")
            git_workflow_automation "$@"
            ;;
        "branch")
            git_branch_management "$@"
            ;;
        "commit-template")
            git_commit_templates "$@"
            ;;
        "team")
            git_team_collaboration "$@"
            ;;
        "-h"|"--help"|"")
            show_git_help
            ;;
        *)
            print_error "Unknown git subcommand: $subcommand"
            echo "Run 'dot git --help' for available commands."
            return 1
            ;;
    esac
}

# Setup commit signing
git_setup_signing() {
    local method="${1:-auto}"
    local email="${2:-}"
    
    print_info "🔐 Setting up Git commit signing..."
    
    case "$method" in
        "auto")
            method=$(detect_signing_method)
            ;;
        "gpg")
            setup_gpg_signing "$email"
            ;;
        "ssh")
            setup_ssh_signing "$email"
            ;;
        *)
            print_error "Unknown signing method: $method"
            echo "Available methods: auto, gpg, ssh"
            return 1
            ;;
    esac
    
    print_success "Git signing configured with $method!"
    print_info "All future commits will be signed automatically"
}

# Setup GPG signing
setup_gpg_signing() {
    local email="$1"
    
    if [[ -z "$email" ]]; then
        email=$(git config --global user.email 2>/dev/null)
        if [[ -z "$email" ]]; then
            echo -n "Enter your email address: "
            read -r email
        fi
    fi
    
    print_info "Setting up GPG signing for: $email"
    
    # Check if GPG is installed
    if ! command -v gpg >/dev/null 2>&1; then
        print_error "GPG not found. Installing..."
        if command -v brew >/dev/null 2>&1; then
            brew install gnupg
        else
            print_error "Please install GPG manually"
            return 1
        fi
    fi
    
    # Check for existing GPG key
    local existing_key=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "sec" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
    
    if [[ -z "$existing_key" ]]; then
        print_info "No existing GPG key found. Creating new key..."
        
        # Generate GPG key
        cat > /tmp/gpg_batch << EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $(git config --global user.name)
Name-Email: $email
Expire-Date: 2y
%commit
%echo done
EOF
        
        gpg --batch --generate-key /tmp/gpg_batch
        rm /tmp/gpg_batch
        
        # Get the new key ID
        existing_key=$(gpg --list-secret-keys --keyid-format=long "$email" | grep "sec" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
    fi
    
    if [[ -n "$existing_key" ]]; then
        print_info "Using GPG key: $existing_key"
        
        # Configure Git to use GPG key
        git config --global user.signingkey "$existing_key"
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        
        # Show public key for GitHub/GitLab
        print_info "Add this public key to your GitHub/GitLab account:"
        echo "----------------------------------------"
        gpg --armor --export "$existing_key"
        echo "----------------------------------------"
        
        print_success "GPG signing configured successfully!"
    else
        print_error "Failed to create or find GPG key"
        return 1
    fi
}

# Setup SSH signing
setup_ssh_signing() {
    local email="$1"
    
    print_info "Setting up SSH signing..."
    
    # Check for existing SSH key
    local ssh_key_path="$HOME/.ssh/id_ed25519"
    
    if [[ ! -f "$ssh_key_path" ]]; then
        print_info "No SSH key found. Creating new key..."
        
        if [[ -z "$email" ]]; then
            email=$(git config --global user.email 2>/dev/null)
            if [[ -z "$email" ]]; then
                echo -n "Enter your email address: "
                read -r email
            fi
        fi
        
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""
        
        print_info "SSH key created at: $ssh_key_path"
    fi
    
    # Configure Git to use SSH signing
    git config --global gpg.format ssh
    git config --global user.signingkey "$ssh_key_path"
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    
    # Show public key for GitHub/GitLab
    print_info "Add this SSH key to your GitHub/GitLab account for signing:"
    echo "----------------------------------------"
    cat "${ssh_key_path}.pub"
    echo "----------------------------------------"
    
    print_success "SSH signing configured successfully!"
}

# Verify commits
git_verify_commits() {
    local range="${1:-HEAD~10..HEAD}"
    local show_details=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --detailed)
                show_details=true
                shift
                ;;
            --range)
                range="$2"
                shift 2
                ;;
            *)
                range="$1"
                shift
                ;;
        esac
    done
    
    print_info "🔍 Verifying commits in range: $range"
    echo ""
    
    local verified_count=0
    local total_count=0
    
    # Get commit list
    local commits=$(git rev-list "$range" 2>/dev/null)
    
    if [[ -z "$commits" ]]; then
        print_error "No commits found in range: $range"
        return 1
    fi
    
    echo "Signature Status | Commit | Author | Message"
    echo "----------------|---------|--------|----------"
    
    while IFS= read -r commit; do
        ((total_count++))
        
        local verification=$(git verify-commit "$commit" 2>&1)
        local short_commit=$(echo "$commit" | cut -c1-8)
        local author=$(git show -s --format='%an' "$commit")
        local message=$(git show -s --format='%s' "$commit" | cut -c1-50)
        
        if [[ $? -eq 0 ]]; then
            echo "✅ VERIFIED      | $short_commit | $author | $message"
            ((verified_count++))
        else
            echo "❌ NOT SIGNED    | $short_commit | $author | $message"
            
            if [[ "$show_details" == "true" ]]; then
                echo "   Details: $verification"
            fi
        fi
    done <<< "$commits"
    
    echo ""
    echo "📊 Summary:"
    echo "  Verified: $verified_count/$total_count commits"
    
    if [[ $verified_count -eq $total_count ]]; then
        print_success "All commits are properly signed!"
    else
        local unsigned=$((total_count - verified_count))
        print_warning "$unsigned commits are not signed"
    fi
}

# Sign existing commits
git_sign_commits() {
    local range="${1:-HEAD~5..HEAD}"
    local force=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force=true
                shift
                ;;
            --range)
                range="$2"
                shift 2
                ;;
            *)
                range="$1"
                shift
                ;;
        esac
    done
    
    print_warning "This will rewrite commit history! Make sure you have a backup."
    
    if [[ "$force" != "true" ]]; then
        echo -n "Continue with signing commits in range $range? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled"
            return 0
        fi
    fi
    
    print_info "🔐 Signing commits in range: $range"
    
    # Use git filter-branch to sign commits
    git filter-branch --commit-filter '
        if [ "$GIT_COMMIT" = "$(git rev-list --max-count=1 '"$range"')" ]; then
            git commit-tree -S "$@"
        else
            git commit-tree "$@"
        fi
    ' -- "$range"
    
    print_success "Commits signed successfully!"
    print_warning "Remember to force push if these commits were already pushed: git push --force-with-lease"
}

# Key management
git_manage_keys() {
    local action="${1:-list}"
    
    case "$action" in
        "list"|"ls")
            git_list_keys
            ;;
        "backup")
            git_backup_keys
            ;;
        "import")
            git_import_keys "$2"
            ;;
        "export")
            git_export_keys "$2"
            ;;
        *)
            print_error "Unknown key action: $action"
            echo "Available actions: list, backup, import, export"
            return 1
            ;;
    esac
}

git_list_keys() {
    echo "🔑 Signing Keys:"
    echo ""
    
    local signing_format=$(git config --global gpg.format 2>/dev/null || echo "gpg")
    
    case "$signing_format" in
        "ssh")
            echo "SSH Signing Keys:"
            local ssh_key=$(git config --global user.signingkey 2>/dev/null)
            if [[ -n "$ssh_key" && -f "$ssh_key" ]]; then
                echo "  Active: $ssh_key"
                echo "  Fingerprint: $(ssh-keygen -lf "$ssh_key" 2>/dev/null || echo 'Unknown')"
            else
                echo "  No SSH signing key configured"
            fi
            ;;
        *)
            echo "GPG Keys:"
            local gpg_key=$(git config --global user.signingkey 2>/dev/null)
            if [[ -n "$gpg_key" ]]; then
                echo "  Active: $gpg_key"
                gpg --list-secret-keys --keyid-format=long "$gpg_key" 2>/dev/null || echo "  Key not found in keyring"
            else
                echo "  No GPG signing key configured"
            fi
            
            echo ""
            echo "All GPG keys:"
            gpg --list-secret-keys --keyid-format=long 2>/dev/null || echo "  No GPG keys found"
            ;;
    esac
}

# Git hooks setup
git_setup_hooks() {
    local hook_type="${1:-all}"
    
    print_info "🪝 Setting up Git hooks..."
    
    local hooks_dir=".git/hooks"
    if [[ ! -d "$hooks_dir" ]]; then
        print_error "Not in a Git repository"
        return 1
    fi
    
    case "$hook_type" in
        "all"|"pre-commit")
            create_pre_commit_hook
            ;;
        "commit-msg")
            create_commit_msg_hook
            ;;
        "pre-push")
            create_pre_push_hook
            ;;
        *)
            print_error "Unknown hook type: $hook_type"
            echo "Available types: all, pre-commit, commit-msg, pre-push"
            return 1
            ;;
    esac
    
    print_success "Git hooks configured!"
}

create_pre_commit_hook() {
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for code quality and security

set -e

echo "🔍 Running pre-commit checks..."

# Check for security issues if dot CLI is available
if command -v dot >/dev/null 2>&1; then
    echo "Running security scan..."
    if ! dot security scan --quiet; then
        echo "❌ Security issues found. Commit blocked."
        exit 1
    fi
fi

# Run linting if available
if [[ -f "package.json" ]] && npm list eslint >/dev/null 2>&1; then
    echo "Running ESLint..."
    npm run lint --if-present
fi

if [[ -f "pyproject.toml" ]] && command -v ruff >/dev/null 2>&1; then
    echo "Running Python linting..."
    ruff check .
fi

# Check for large files
echo "Checking for large files..."
git diff --cached --name-only | while read file; do
    if [[ -f "$file" ]]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        if [[ $size -gt 10485760 ]]; then # 10MB
            echo "❌ Large file detected: $file ($(($size / 1024 / 1024))MB)"
            echo "Consider using Git LFS for large files"
            exit 1
        fi
    fi
done

echo "✅ Pre-commit checks passed!"
EOF

    chmod +x .git/hooks/pre-commit
}

create_commit_msg_hook() {
    cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
# Commit message validation hook

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add user authentication"
    echo ""
    echo "Your message:"
    cat "$1"
    exit 1
fi

echo "✅ Commit message format is valid"
EOF

    chmod +x .git/hooks/commit-msg
}

# Enhanced Git configuration
git_enhanced_config() {
    print_info "⚙️ Setting up enhanced Git configuration..."
    
    # Core settings
    git config --global core.autocrlf input
    git config --global core.safecrlf true
    git config --global core.editor "nvim"
    git config --global init.defaultBranch main
    
    # Performance settings
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global gc.auto 256
    
    # Security settings
    git config --global transfer.fsckobjects true
    git config --global fetch.fsckobjects true
    git config --global receive.fsckObjects true
    
    # Diff and merge settings
    git config --global diff.algorithm histogram
    git config --global merge.conflictstyle diff3
    git config --global rerere.enabled true
    
    # Branch settings
    git config --global branch.autosetupmerge always
    git config --global branch.autosetuprebase always
    
    # Push settings
    git config --global push.default simple
    git config --global push.followTags true
    
    # Useful aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.cm commit
    git config --global alias.lg "log --oneline --graph --decorate --all"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual "!gitk"
    
    print_success "Enhanced Git configuration applied!"
}

# Utility functions
detect_signing_method() {
    # Prefer SSH signing on newer Git versions
    local git_version=$(git --version | cut -d' ' -f3)
    
    if command -v ssh-keygen >/dev/null 2>&1 && [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        echo "ssh"
    elif command -v gpg >/dev/null 2>&1; then
        echo "gpg"
    else
        echo "ssh"  # Default to SSH, will create key if needed
    fi
}

git_signing_status() {
    echo "🔐 Git Signing Status:"
    echo ""
    
    # Check if signing is enabled
    local commit_sign=$(git config --global commit.gpgsign 2>/dev/null)
    local tag_sign=$(git config --global tag.gpgsign 2>/dev/null)
    local format=$(git config --global gpg.format 2>/dev/null || echo "gpg")
    local signing_key=$(git config --global user.signingkey 2>/dev/null)
    
    echo "Configuration:"
    echo "  Commit signing: ${commit_sign:-false}"
    echo "  Tag signing: ${tag_sign:-false}"
    echo "  Format: $format"
    echo "  Signing key: ${signing_key:-not configured}"
    
    echo ""
    echo "Key Status:"
    
    case "$format" in
        "ssh")
            if [[ -n "$signing_key" && -f "$signing_key" ]]; then
                echo "  ✅ SSH key exists: $signing_key"
            else
                echo "  ❌ SSH key not found"
            fi
            ;;
        *)
            if [[ -n "$signing_key" ]]; then
                if gpg --list-secret-keys "$signing_key" >/dev/null 2>&1; then
                    echo "  ✅ GPG key exists: $signing_key"
                else
                    echo "  ❌ GPG key not found in keyring"
                fi
            else
                echo "  ❌ No GPG key configured"
            fi
            ;;
    esac
    
    # Test signing
    echo ""
    echo "Test Signing:"
    if echo "test" | git hash-object -w --stdin >/dev/null 2>&1; then
        echo "  ✅ Git is functional"
    else
        echo "  ❌ Git signing test failed"
    fi
}

# ============================================================================
# Epic 7.2: Advanced Git Integration Features
# Automated git workflows, branch management, and team collaboration
# ============================================================================

# Git workflow automation
git_workflow_automation() {
    local workflow_type="${1:-}"
    shift || true
    
    case "$workflow_type" in
        "gitflow")
            setup_gitflow_workflow "$@"
            ;;
        "github")
            setup_github_workflow "$@"
            ;;
        "feature")
            automate_feature_workflow "$@"
            ;;
        "hotfix")
            automate_hotfix_workflow "$@"
            ;;
        "release")
            automate_release_workflow "$@"
            ;;
        "status")
            show_workflow_status
            ;;
        "init")
            init_automated_workflow "$@"
            ;;
        *)
            show_workflow_help
            ;;
    esac
}

# Setup Git Flow workflow
setup_gitflow_workflow() {
    local action="${1:-init}"
    
    case "$action" in
        "init")
            print_info "🌱 Initializing Git Flow workflow..."
            
            # Check if git-flow is available
            if ! command -v git-flow >/dev/null 2>&1; then
                print_info "Installing git-flow..."
                case "$OSTYPE" in
                    darwin*)
                        brew install git-flow-avh
                        ;;
                    linux*)
                        if command -v apt >/dev/null 2>&1; then
                            sudo apt install -y git-flow
                        elif command -v pacman >/dev/null 2>&1; then
                            sudo pacman -S git-flow
                        fi
                        ;;
                esac
            fi
            
            # Initialize git-flow
            git flow init -d
            
            # Set up automated hooks
            create_gitflow_hooks
            
            print_success "Git Flow workflow initialized!"
            print_info "Use 'dot git workflow gitflow feature start <name>' to begin"
            ;;
        "feature")
            git_flow_feature_workflow "$@"
            ;;
        "hotfix")
            git_flow_hotfix_workflow "$@"
            ;;
        "release")
            git_flow_release_workflow "$@"
            ;;
    esac
}

# Git Flow feature workflow
git_flow_feature_workflow() {
    local action="$1"
    local feature_name="$2"
    
    case "$action" in
        "start")
            if [[ -z "$feature_name" ]]; then
                echo -n "Enter feature name: "
                read -r feature_name
            fi
            
            print_info "🚀 Starting feature: $feature_name"
            git flow feature start "$feature_name"
            
            # Set up feature-specific configuration
            git config branch."feature/$feature_name".description "Feature: $feature_name"
            
            # Create initial commit with template
            if [[ -f ".github/FEATURE_TEMPLATE.md" ]]; then
                cp ".github/FEATURE_TEMPLATE.md" "FEATURE_$feature_name.md"
                git add "FEATURE_$feature_name.md"
                git commit -m "feat: initialize feature $feature_name

- Add feature specification
- Set up development structure

Ref: feature/$feature_name"
            fi
            ;;
        "finish")
            if [[ -z "$feature_name" ]]; then
                # Auto-detect current feature branch
                feature_name=$(git rev-parse --abbrev-ref HEAD | sed 's/feature\///')
            fi
            
            print_info "✅ Finishing feature: $feature_name"
            
            # Run pre-finish checks
            if ! run_feature_checks "$feature_name"; then
                print_error "Feature checks failed. Fix issues before finishing."
                return 1
            fi
            
            # Finish feature with automatic merge
            git flow feature finish "$feature_name"
            
            # Clean up feature artifacts
            rm -f "FEATURE_$feature_name.md"
            
            print_success "Feature $feature_name completed and merged!"
            ;;
        "publish")
            git flow feature publish "$feature_name"
            print_info "Feature $feature_name published to origin"
            ;;
    esac
}

# GitHub workflow setup
setup_github_workflow() {
    local action="${1:-init}"
    
    case "$action" in
        "init")
            print_info "🐙 Setting up GitHub workflow..."
            
            # Create GitHub workflow directories
            mkdir -p .github/workflows
            mkdir -p .github/ISSUE_TEMPLATE
            mkdir -p .github/PULL_REQUEST_TEMPLATE
            
            # Create CI/CD workflow
            create_github_ci_workflow
            
            # Create issue templates
            create_github_issue_templates
            
            # Create PR template
            create_github_pr_template
            
            # Set up branch protection if gh CLI is available
            if command -v gh >/dev/null 2>&1; then
                setup_github_branch_protection
            fi
            
            print_success "GitHub workflow configured!"
            ;;
        "pr")
            create_automated_pr "$@"
            ;;
        "issue")
            create_automated_issue "$@"
            ;;
    esac
}

# Automated feature workflow
automate_feature_workflow() {
    local feature_name="$1"
    local feature_type="${2:-feat}"
    
    if [[ -z "$feature_name" ]]; then
        echo -n "Enter feature name: "
        read -r feature_name
    fi
    
    print_info "🛠️ Automating feature workflow: $feature_name"
    
    # Create and switch to feature branch
    local branch_name="$feature_type/$feature_name"
    git checkout -b "$branch_name"
    
    # Set branch description
    git config "branch.$branch_name.description" "$feature_type: $feature_name"
    
    # Create feature tracking file
    cat > ".feature-$feature_name.md" << EOF
# Feature: $feature_name

**Type**: $feature_type
**Branch**: $branch_name
**Started**: $(date -Iseconds)
**Status**: In Development

## Description

<!-- Add feature description here -->

## Tasks

- [ ] Design phase
- [ ] Implementation
- [ ] Testing
- [ ] Documentation
- [ ] Code review

## Notes

<!-- Add development notes here -->
EOF
    
    # Initial commit
    git add ".feature-$feature_name.md"
    git commit -m "$feature_type: initialize $feature_name

- Add feature tracking
- Set up development branch
- Define initial requirements"
    
    # Set up automated push
    git push -u origin "$branch_name"
    
    print_success "Feature workflow automated!"
    print_info "Track progress in: .feature-$feature_name.md"
    print_info "Use 'dot git workflow feature finish' when ready"
}

# Automated hotfix workflow
automate_hotfix_workflow() {
    local issue_description="$1"
    local severity="${2:-high}"
    
    if [[ -z "$issue_description" ]]; then
        echo -n "Describe the hotfix issue: "
        read -r issue_description
    fi
    
    local hotfix_name=$(echo "$issue_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
    local branch_name="hotfix/$hotfix_name"
    
    print_info "🚑 Creating emergency hotfix: $hotfix_name"
    
    # Create hotfix branch from main/master
    local main_branch=$(git_get_main_branch)
    git checkout "$main_branch"
    git pull origin "$main_branch"
    git checkout -b "$branch_name"
    
    # Create hotfix tracking
    cat > ".hotfix-$hotfix_name.md" << EOF
# Hotfix: $issue_description

**Severity**: $severity
**Branch**: $branch_name
**Created**: $(date -Iseconds)
**Status**: In Progress

## Issue Description

$issue_description

## Fix Strategy

<!-- Describe the fix approach -->

## Testing Checklist

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Regression testing
- [ ] Performance impact verified

## Rollback Plan

<!-- Describe rollback procedure if needed -->
EOF
    
    # Initial commit
    git add ".hotfix-$hotfix_name.md"
    git commit -m "hotfix: initialize fix for $issue_description

Severity: $severity
Branch: $branch_name

- Add hotfix tracking
- Set up emergency fix branch
- Define testing requirements"
    
    git push -u origin "$branch_name"
    
    print_success "Hotfix branch created: $branch_name"
    print_warning "Remember to follow emergency change procedures!"
}

# Automated release workflow
automate_release_workflow() {
    local version="$1"
    local release_type="${2:-minor}"
    
    if [[ -z "$version" ]]; then
        # Auto-generate version based on type
        local current_version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0.0.0")
        version=$(generate_next_version "$current_version" "$release_type")
        print_info "Generated version: $version"
    fi
    
    print_info "🎆 Starting release workflow: v$version"
    
    # Create release branch
    local main_branch=$(git_get_main_branch)
    git checkout "$main_branch"
    git pull origin "$main_branch"
    
    local release_branch="release/v$version"
    git checkout -b "$release_branch"
    
    # Create release notes
    generate_release_notes "$version" > "RELEASE_NOTES_$version.md"
    
    # Update version files if they exist
    update_version_files "$version"
    
    # Create release commit
    git add .
    git commit -m "release: prepare v$version

- Update version to $version
- Generate release notes
- Prepare for release

Type: $release_type"
    
    git push -u origin "$release_branch"
    
    # Create release PR if gh CLI is available
    if command -v gh >/dev/null 2>&1; then
        gh pr create --title "Release v$version" \
                     --body "$(cat "RELEASE_NOTES_$version.md")" \
                     --base "$main_branch" \
                     --head "$release_branch"
    fi
    
    print_success "Release v$version prepared!"
    print_info "Review changes and merge the release PR"
}

# Advanced branch management
git_branch_management() {
    local action="${1:-list}"
    shift || true
    
    case "$action" in
        "smart-create")
            create_smart_branch "$@"
            ;;
        "cleanup")
            cleanup_merged_branches "$@"
            ;;
        "sync")
            sync_all_branches "$@"
            ;;
        "analyze")
            analyze_branch_health "$@"
            ;;
        "protect")
            protect_important_branches "$@"
            ;;
        "list")
            list_enhanced_branches "$@"
            ;;
        "strategy")
            set_branching_strategy "$@"
            ;;
        *)
            show_branch_help
            ;;
    esac
}

# Smart branch creation with naming conventions
create_smart_branch() {
    local branch_type="$1"
    local branch_description="$2"
    local issue_number="$3"
    
    if [[ -z "$branch_type" ]]; then
        echo "Select branch type:"
        echo "1) feature - New functionality"
        echo "2) bugfix - Bug fixes"
        echo "3) hotfix - Emergency fixes"
        echo "4) chore - Maintenance tasks"
        echo "5) docs - Documentation updates"
        echo -n "Choice (1-5): "
        read -r choice
        
        case "$choice" in
            1) branch_type="feature" ;;
            2) branch_type="bugfix" ;;
            3) branch_type="hotfix" ;;
            4) branch_type="chore" ;;
            5) branch_type="docs" ;;
            *) print_error "Invalid choice"; return 1 ;;
        esac
    fi
    
    if [[ -z "$branch_description" ]]; then
        echo -n "Enter branch description: "
        read -r branch_description
    fi
    
    # Generate branch name
    local clean_description=$(echo "$branch_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
    local branch_name="$branch_type/$clean_description"
    
    # Add issue number if provided
    if [[ -n "$issue_number" ]]; then
        branch_name="$branch_type/$issue_number-$clean_description"
    fi
    
    print_info "🌱 Creating smart branch: $branch_name"
    
    # Create and switch to branch
    git checkout -b "$branch_name"
    
    # Set branch metadata
    git config "branch.$branch_name.description" "$branch_description"
    git config "branch.$branch_name.type" "$branch_type"
    if [[ -n "$issue_number" ]]; then
        git config "branch.$branch_name.issue" "$issue_number"
    fi
    
    # Create initial commit based on type
    create_branch_initial_commit "$branch_type" "$branch_description" "$issue_number"
    
    # Set up tracking
    git push -u origin "$branch_name"
    
    print_success "Smart branch created: $branch_name"
}

# Create initial commit for branch
create_branch_initial_commit() {
    local branch_type="$1"
    local description="$2"
    local issue_number="$3"
    
    local commit_message="$branch_type: initialize $description"
    
    if [[ -n "$issue_number" ]]; then
        commit_message="$commit_message\n\nRef: #$issue_number"
    fi
    
    # Create type-specific files
    case "$branch_type" in
        "feature")
            echo "# Feature: $description" > "FEATURE.md"
            echo "" >> "FEATURE.md"
            echo "## Implementation Plan" >> "FEATURE.md"
            echo "- [ ] Design" >> "FEATURE.md"
            echo "- [ ] Implementation" >> "FEATURE.md"
            echo "- [ ] Testing" >> "FEATURE.md"
            git add "FEATURE.md"
            ;;
        "bugfix")
            echo "# Bug Fix: $description" > "BUGFIX.md"
            echo "" >> "BUGFIX.md"
            echo "## Root Cause Analysis" >> "BUGFIX.md"
            echo "<!-- Describe the root cause -->" >> "BUGFIX.md"
            echo "" >> "BUGFIX.md"
            echo "## Fix Strategy" >> "BUGFIX.md"
            echo "<!-- Describe the fix approach -->" >> "BUGFIX.md"
            git add "BUGFIX.md"
            ;;
    esac
    
    git commit -m "$commit_message"
}

# Cleanup merged branches
cleanup_merged_branches() {
    local dry_run="${1:-false}"
    local force="${2:-false}"
    
    print_info "🧼 Cleaning up merged branches..."
    
    local main_branch=$(git_get_main_branch)
    git checkout "$main_branch"
    git pull origin "$main_branch"
    
    # Get merged branches
    local merged_branches=()
    while IFS= read -r branch; do
        merged_branches+=("$branch")
    done < <(git branch --merged | grep -v "^\s*\*" | grep -v "$main_branch" | grep -v "develop" | xargs -n1)
    
    if [[ ${#merged_branches[@]} -eq 0 ]]; then
        print_success "No merged branches to clean up!"
        return 0
    fi
    
    echo "Merged branches to delete:"
    for branch in "${merged_branches[@]}"; do
        echo "  - $branch"
    done
    echo ""
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Dry run mode - no branches will be deleted"
        return 0
    fi
    
    if [[ "$force" != "true" ]]; then
        echo -n "Delete these branches? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Branch cleanup cancelled"
            return 0
        fi
    fi
    
    # Delete local branches
    for branch in "${merged_branches[@]}"; do
        git branch -d "$branch" 2>/dev/null && print_info "Deleted local: $branch"
    done
    
    # Delete remote tracking branches
    git remote prune origin
    
    print_success "Branch cleanup completed!"
}

# Git commit templates
git_commit_templates() {
    local action="${1:-list}"
    shift || true
    
    case "$action" in
        "setup")
            setup_commit_templates "$@"
            ;;
        "use")
            use_commit_template "$@"
            ;;
        "smart")
            smart_commit "$@"
            ;;
        "validate")
            validate_commit_message "$@"
            ;;
        "list")
            list_commit_templates
            ;;
        *)
            show_commit_template_help
            ;;
    esac
}

# Setup commit templates
setup_commit_templates() {
    local template_dir="$DOTFILES_DIR/config/git/templates"
    mkdir -p "$template_dir"
    
    print_info "📝 Setting up commit templates..."
    
    # Create conventional commit template
    cat > "$template_dir/conventional.txt" << 'EOF'
# <type>[optional scope]: <description>
#
# [optional body]
#
# [optional footer(s)]
#
# Types:
#   feat:     A new feature
#   fix:      A bug fix
#   docs:     Documentation only changes
#   style:    Changes that do not affect the meaning of the code
#   refactor: A code change that neither fixes a bug nor adds a feature
#   perf:     A code change that improves performance
#   test:     Adding missing tests or correcting existing tests
#   chore:    Changes to the build process or auxiliary tools
#
# Examples:
#   feat(auth): add user authentication
#   fix: resolve memory leak in parser
#   docs: update API documentation
EOF
    
    # Create feature template
    cat > "$template_dir/feature.txt" << 'EOF'
feat: <brief description>

# What this feature does:
# 

# Why this feature is needed:
# 

# How to test this feature:
# 

# Related issues:
# Closes #
EOF
    
    # Create bugfix template
    cat > "$template_dir/bugfix.txt" << 'EOF'
fix: <brief description>

# What was the bug:
# 

# Root cause:
# 

# How it's fixed:
# 

# How to verify the fix:
# 

# Related issues:
# Fixes #
EOF
    
    # Set default template
    git config --global commit.template "$template_dir/conventional.txt"
    
    # Create template selector script
    create_commit_template_selector
    
    print_success "Commit templates configured!"
    print_info "Use 'git commit' to use templates, or 'dot git commit-template smart' for AI assistance"
}

# Smart commit with AI assistance (placeholder for future AI integration)
smart_commit() {
    local staged_files=$(git diff --cached --name-only)
    
    if [[ -z "$staged_files" ]]; then
        print_error "No staged changes found. Stage changes with 'git add' first."
        return 1
    fi
    
    print_info "🤖 Generating smart commit message..."
    
    # Analyze staged changes
    local diff_summary=$(git diff --cached --stat)
    local added_files=$(git diff --cached --name-status | grep "^A" | wc -l | tr -d ' ')
    local modified_files=$(git diff --cached --name-status | grep "^M" | wc -l | tr -d ' ')
    local deleted_files=$(git diff --cached --name-status | grep "^D" | wc -l | tr -d ' ')
    
    # Determine commit type based on changes
    local commit_type="chore"
    if [[ $added_files -gt 0 ]] && [[ $modified_files -eq 0 ]] && [[ $deleted_files -eq 0 ]]; then
        commit_type="feat"
    elif [[ $deleted_files -gt 0 ]]; then
        commit_type="refactor"
    elif [[ $modified_files -gt 0 ]]; then
        commit_type="fix"
    fi
    
    # Generate commit message
    local commit_message="$commit_type: update files"
    
    # Add more context based on file types
    if echo "$staged_files" | grep -q "\.md$"; then
        commit_type="docs"
        commit_message="$commit_type: update documentation"
    elif echo "$staged_files" | grep -qE "\.(test|spec)\."; then
        commit_type="test"
        commit_message="$commit_type: update tests"
    elif echo "$staged_files" | grep -qE "\.(json|yaml|yml|toml)$"; then
        commit_type="config"
        commit_message="$commit_type: update configuration"
    fi
    
    echo ""
    echo "Suggested commit message:"
    echo "  $commit_message"
    echo ""
    echo "Files to commit:"
    echo "$staged_files" | sed 's/^/  - /'
    echo ""
    
    echo -n "Use this message? [Y/n/e(dit)]: "
    read -r response
    
    case "$response" in
        "n"|"N")
            print_info "Commit cancelled"
            return 0
            ;;
        "e"|"E")
            echo -n "Enter custom commit message: "
            read -r commit_message
            ;;
    esac
    
    git commit -m "$commit_message"
    print_success "Smart commit completed!"
}

# Team collaboration features
git_team_collaboration() {
    local action="${1:-status}"
    shift || true
    
    case "$action" in
        "setup")
            setup_team_collaboration "$@"
            ;;
        "sync-hooks")
            sync_team_hooks "$@"
            ;;
        "shared-config")
            setup_shared_config "$@"
            ;;
        "review")
            setup_code_review "$@"
            ;;
        "conventions")
            enforce_team_conventions "$@"
            ;;
        "status")
            show_team_status
            ;;
        *)
            show_team_help
            ;;
    esac
}

# Setup team collaboration
setup_team_collaboration() {
    print_info "👥 Setting up team collaboration features..."
    
    # Create shared hooks directory
    local hooks_dir=".githooks"
    mkdir -p "$hooks_dir"
    
    # Create shared pre-commit hook
    create_shared_pre_commit_hook "$hooks_dir"
    
    # Create shared commit-msg hook
    create_shared_commit_msg_hook "$hooks_dir"
    
    # Set up git hooks path
    git config core.hooksPath "$hooks_dir"
    
    # Create team configuration
    setup_team_git_config
    
    # Create code review templates
    setup_code_review_templates
    
    print_success "Team collaboration configured!"
    print_info "All team members should run: git config core.hooksPath .githooks"
}

# Utility functions
git_get_main_branch() {
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
}

generate_next_version() {
    local current="$1"
    local type="$2"
    
    local major minor patch
    IFS='.' read -r major minor patch <<< "$current"
    
    case "$type" in
        "major")
            echo "$((major + 1)).0.0"
            ;;
        "minor")
            echo "$major.$((minor + 1)).0"
            ;;
        "patch")
            echo "$major.$minor.$((patch + 1))"
            ;;
    esac
}

generate_release_notes() {
    local version="$1"
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    echo "# Release Notes v$version"
    echo ""
    echo "**Release Date**: $(date +'%Y-%m-%d')"
    echo ""
    
    if [[ -n "$last_tag" ]]; then
        echo "## Changes since $last_tag"
        echo ""
        
        # Group commits by type
        echo "### Features"
        git log "$last_tag"..HEAD --grep="^feat" --pretty=format:"- %s" | head -20
        echo ""
        
        echo "### Bug Fixes"
        git log "$last_tag"..HEAD --grep="^fix" --pretty=format:"- %s" | head -20
        echo ""
        
        echo "### Other Changes"
        git log "$last_tag"..HEAD --grep="^(chore|docs|style|refactor|perf|test)" --pretty=format:"- %s" | head -10
    else
        echo "## Initial Release"
        echo ""
        echo "First release of the project."
    fi
    
    echo ""
    echo "**Full Changelog**: https://github.com/$(git config remote.origin.url | sed 's/.*github.com[\/:]\([^.]*\).*/\1/')/compare/$last_tag...v$version"
}

run_feature_checks() {
    local feature_name="$1"
    
    print_info "Running pre-finish checks for feature: $feature_name"
    
    local checks_passed=true
    
    # Check if tests exist and pass
    if [[ -d "test" ]] || [[ -d "tests" ]] || [[ -f "package.json" ]]; then
        if ! npm test 2>/dev/null && ! python -m pytest 2>/dev/null && ! cargo test 2>/dev/null; then
            print_error "Tests failed or not found"
            checks_passed=false
        fi
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_error "Uncommitted changes detected"
        checks_passed=false
    fi
    
    # Check for untracked files
    if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        print_warning "Untracked files detected - consider adding to .gitignore"
    fi
    
    # Check branch is up to date with remote
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse "@{u}" 2>/dev/null || echo "")
    
    if [[ -n "$remote_commit" ]] && [[ "$local_commit" != "$remote_commit" ]]; then
        print_error "Branch is not up to date with remote"
        checks_passed=false
    fi
    
    if [[ "$checks_passed" == "true" ]]; then
        print_success "All feature checks passed!"
        return 0
    else
        return 1
    fi
}

# Help function
show_git_help() {
    cat << 'EOF'
dot git - Enhanced Git operations and commit signing

USAGE:
    dot git <command> [options]

COMMANDS:
    setup-signing [method]   Configure commit signing (auto|gpg|ssh)
    verify [range]           Verify commit signatures
    sign [range]             Sign existing commits (rewrites history!)
    keys <action>            Manage signing keys (list|backup|export|import)
    status                   Show Git signing configuration status
    hooks [type]             Setup Git hooks (all|pre-commit|commit-msg|pre-push)
    config                   Apply enhanced Git configuration
    workflow <type>          Automated git workflows (gitflow|github|feature|hotfix|release)
    branch <action>          Advanced branch management
    commit-template <action> Smart commit templates and validation
    team <action>            Team collaboration features

SIGNING METHODS:
    auto                     Auto-detect best method (SSH preferred)
    gpg                      Use GPG keys for signing
    ssh                      Use SSH keys for signing (Git 2.34+)

KEY MANAGEMENT:
    list                     List all signing keys
    backup                   Backup signing keys
    export <file>            Export keys to file
    import <file>            Import keys from file

GIT HOOKS:
    pre-commit               Security scan, linting, large file check
    commit-msg               Conventional commit format validation
    pre-push                 Additional security and quality checks

OPTIONS:
    --detailed               Show detailed verification information
    --force                  Force operation without confirmation
    --range <range>          Specify commit range (default: HEAD~10..HEAD)
    -h, --help               Show this help message

EXAMPLES:
    dot git setup-signing ssh          # Setup SSH commit signing
    dot git verify HEAD~5..HEAD        # Verify last 5 commits
    dot git keys list                  # List all signing keys
    dot git hooks all                  # Setup all Git hooks
    dot git status                     # Show signing status

SECURITY FEATURES:
    • Automatic commit and tag signing
    • Commit signature verification
    • Security scanning in pre-commit hooks
    • Large file detection
    • Conventional commit format enforcement
    • Enhanced Git security configuration
EOF
}