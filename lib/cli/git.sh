#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Git Operations
# Commit signing, hooks, and branch management
# ============================================================================

dot_git() {
    local subcommand="${1:-}"
    shift || true

    case "$subcommand" in
        "setup-signing") git_setup_signing "$@" ;;
        "verify")        git_verify_commits "$@" ;;
        "keys")          git_list_keys ;;
        "status")        git_signing_status ;;
        "hooks")         git_setup_hooks "$@" ;;
        "config")        git_enhanced_config "$@" ;;
        "cleanup")       cleanup_merged_branches "$@" ;;
        "-h"|"--help"|"") show_git_help ;;
        *)
            print_error "Unknown git subcommand: $subcommand"
            echo "Run 'dot git --help' for available commands."
            return 1
            ;;
    esac
}

# ============================================================================
# Commit Signing
# ============================================================================

git_setup_signing() {
    local method="${1:-auto}"
    local email="${2:-}"

    print_info "Setting up Git commit signing..."

    case "$method" in
        "auto") method=$(detect_signing_method) ;;
        "gpg"|"ssh") ;;
        *)
            print_error "Unknown signing method: $method (use: auto, gpg, ssh)"
            return 1
            ;;
    esac

    case "$method" in
        "gpg") setup_gpg_signing "$email" ;;
        "ssh") setup_ssh_signing "$email" ;;
    esac

    print_success "Git signing configured with $method"
}

setup_gpg_signing() {
    local email="$1"
    [[ -z "$email" ]] && email=$(git config --global user.email 2>/dev/null)
    [[ -z "$email" ]] && { echo -n "Enter your email: "; read -r email; }

    if ! command -v gpg >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
            brew install gnupg
        else
            print_error "GPG not found. Install it first."
            return 1
        fi
    fi

    local existing_key
    existing_key=$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | grep "sec" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)

    if [[ -z "$existing_key" ]]; then
        print_info "Creating new GPG key..."
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
        existing_key=$(gpg --list-secret-keys --keyid-format=long "$email" | grep "sec" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
    fi

    if [[ -n "$existing_key" ]]; then
        git config --global user.signingkey "$existing_key"
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        print_info "Add this public key to GitHub/GitLab:"
        echo "----------------------------------------"
        gpg --armor --export "$existing_key"
        echo "----------------------------------------"
    else
        print_error "Failed to create or find GPG key"
        return 1
    fi
}

setup_ssh_signing() {
    local email="$1"
    local ssh_key_path="$HOME/.ssh/id_ed25519"

    if [[ ! -f "$ssh_key_path" ]]; then
        [[ -z "$email" ]] && email=$(git config --global user.email 2>/dev/null)
        [[ -z "$email" ]] && { echo -n "Enter your email: "; read -r email; }
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_path" -N ""
    fi

    git config --global gpg.format ssh
    git config --global user.signingkey "$ssh_key_path"
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true

    print_info "Add this SSH key to GitHub/GitLab for signing:"
    echo "----------------------------------------"
    cat "${ssh_key_path}.pub"
    echo "----------------------------------------"
}

detect_signing_method() {
    if command -v ssh-keygen >/dev/null 2>&1 && [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        echo "ssh"
    elif command -v gpg >/dev/null 2>&1; then
        echo "gpg"
    else
        echo "ssh"
    fi
}

git_signing_status() {
    echo "Git Signing Status:"
    echo ""
    local commit_sign=$(git config --global commit.gpgsign 2>/dev/null)
    local format=$(git config --global gpg.format 2>/dev/null || echo "gpg")
    local signing_key=$(git config --global user.signingkey 2>/dev/null)

    echo "  Commit signing: ${commit_sign:-false}"
    echo "  Format: $format"
    echo "  Key: ${signing_key:-not configured}"
    echo ""

    case "$format" in
        "ssh")
            if [[ -n "$signing_key" && -f "$signing_key" ]]; then
                echo "  Key status: OK ($signing_key)"
            else
                echo "  Key status: NOT FOUND"
            fi
            ;;
        *)
            if [[ -n "$signing_key" ]] && gpg --list-secret-keys "$signing_key" >/dev/null 2>&1; then
                echo "  Key status: OK (GPG $signing_key)"
            else
                echo "  Key status: NOT FOUND"
            fi
            ;;
    esac
}

git_list_keys() {
    echo "Signing Keys:"
    echo ""
    local format=$(git config --global gpg.format 2>/dev/null || echo "gpg")
    case "$format" in
        "ssh")
            local key=$(git config --global user.signingkey 2>/dev/null)
            if [[ -n "$key" && -f "$key" ]]; then
                echo "  SSH: $key"
                echo "  Fingerprint: $(ssh-keygen -lf "$key" 2>/dev/null)"
            else
                echo "  No SSH signing key configured"
            fi
            ;;
        *)
            local key=$(git config --global user.signingkey 2>/dev/null)
            if [[ -n "$key" ]]; then
                gpg --list-secret-keys --keyid-format=long "$key" 2>/dev/null || echo "  GPG key not in keyring"
            else
                echo "  No GPG key configured"
            fi
            ;;
    esac
}

# ============================================================================
# Commit Verification
# ============================================================================

git_verify_commits() {
    local range="${1:-HEAD~10..HEAD}"
    local show_details=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --detailed) show_details=true; shift ;;
            --range)    range="$2"; shift 2 ;;
            *)          range="$1"; shift ;;
        esac
    done

    print_info "Verifying commits: $range"
    echo ""

    local verified=0 total=0
    local commits
    commits=$(git rev-list "$range" 2>/dev/null)
    [[ -z "$commits" ]] && { print_error "No commits in range: $range"; return 1; }

    while IFS= read -r commit; do
        ((total++))
        local short=$(echo "$commit" | cut -c1-8)
        local author=$(git show -s --format='%an' "$commit")
        local msg=$(git show -s --format='%s' "$commit" | cut -c1-50)

        if git verify-commit "$commit" &>/dev/null; then
            printf "  SIGNED   %s %s %s\n" "$short" "$author" "$msg"
            ((verified++))
        else
            printf "  UNSIGNED %s %s %s\n" "$short" "$author" "$msg"
        fi
    done <<< "$commits"

    echo ""
    echo "Verified: $verified/$total"
}

# ============================================================================
# Git Hooks
# ============================================================================

git_setup_hooks() {
    local hook_type="${1:-all}"

    local hooks_dir=".git/hooks"
    [[ -d "$hooks_dir" ]] || { print_error "Not in a Git repository"; return 1; }

    case "$hook_type" in
        "all"|"pre-commit") _create_pre_commit_hook ;;
    esac
    case "$hook_type" in
        "all"|"commit-msg") _create_commit_msg_hook ;;
    esac

    print_success "Git hooks configured"
}

_create_pre_commit_hook() {
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
set -e
echo "Running pre-commit checks..."

# Check for large files
git diff --cached --name-only | while read file; do
    if [[ -f "$file" ]]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        if [[ $size -gt 10485760 ]]; then
            echo "FAIL: Large file: $file ($(($size / 1024 / 1024))MB)"
            exit 1
        fi
    fi
done

# Run linting if available
[[ -f "package.json" ]] && command -v npx &>/dev/null && npx --no-install eslint . 2>/dev/null || true
[[ -f "pyproject.toml" ]] && command -v ruff &>/dev/null && ruff check . 2>/dev/null || true

echo "Pre-commit checks passed"
EOF
    chmod +x .git/hooks/pre-commit
}

_create_commit_msg_hook() {
    cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
commit_regex='^(feat|fix|docs|style|refactor|test|chore|ci|build)(\(.+\))?: .{1,72}'
if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit format. Use: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore, ci, build"
    exit 1
fi
EOF
    chmod +x .git/hooks/commit-msg
}

# ============================================================================
# Enhanced Config & Branch Management
# ============================================================================

git_enhanced_config() {
    print_info "Applying enhanced Git configuration..."
    git config --global core.autocrlf input
    git config --global core.editor "nvim"
    git config --global init.defaultBranch main
    git config --global core.preloadindex true
    git config --global diff.algorithm histogram
    git config --global merge.conflictstyle diff3
    git config --global rerere.enabled true
    git config --global push.default simple
    git config --global push.followTags true
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.lg "log --oneline --graph --decorate --all"
    print_success "Enhanced Git configuration applied"
}

cleanup_merged_branches() {
    local dry_run=false
    [[ "${1:-}" == "--dry-run" ]] && dry_run=true

    local main_branch
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@') || main_branch="main"

    local merged
    merged=$(git branch --merged "$main_branch" | grep -v "^\s*\*" | grep -v "$main_branch" | grep -v "develop" | xargs)

    if [[ -z "$merged" ]]; then
        print_success "No merged branches to clean up"
        return 0
    fi

    echo "Merged branches:"
    for b in $merged; do echo "  - $b"; done
    echo ""

    if [[ "$dry_run" == "true" ]]; then
        print_info "Dry run - no branches deleted"
        return 0
    fi

    echo -n "Delete these branches? [y/N]: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] || return 0

    for b in $merged; do
        git branch -d "$b" 2>/dev/null && print_info "Deleted: $b"
    done
    git remote prune origin
    print_success "Branch cleanup completed"
}

# ============================================================================
# Help
# ============================================================================

show_git_help() {
    cat << 'EOF'
dot git - Git signing, hooks, and branch management

USAGE:
    dot git <command> [options]

COMMANDS:
    setup-signing [method]   Configure commit signing (auto|gpg|ssh)
    verify [range]           Verify commit signatures
    keys                     List signing keys
    status                   Show signing configuration
    hooks [type]             Setup hooks (all|pre-commit|commit-msg)
    config                   Apply enhanced Git configuration
    cleanup [--dry-run]      Delete merged branches

EXAMPLES:
    dot git setup-signing ssh       # SSH commit signing
    dot git verify HEAD~5..HEAD     # Verify last 5 commits
    dot git hooks all               # Setup pre-commit + commit-msg
    dot git cleanup --dry-run       # Preview branch cleanup
EOF
}
