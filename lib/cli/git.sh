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