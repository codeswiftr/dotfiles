# Git Flow Plugin

Enhanced git workflow management with branch conventions, automation, and productivity features.

## 🚀 Features

- **Git Flow Workflow**: Industry-standard branching model implementation
- **Branch Management**: Streamlined feature, release, and hotfix workflows  
- **Git Aliases**: Productivity-focused shortcuts and commands
- **Workflow Automation**: Automated merging, tagging, and cleanup
- **Status Monitoring**: Clear visibility into branch states and workflow status
- **Cross-Platform**: Works on macOS, Linux, and WSL

## 📦 Installation

```bash
# Install the plugin
dot plugin install git-flow

# Enable the plugin
dot plugin enable git-flow
```

## 🔧 Quick Start

### 1. Initialize Git Flow in Repository

```bash
# Navigate to your git repository
cd my-project

# Initialize git flow (creates develop branch if needed)
dot flow init

# Or specify custom branch names
dot flow init main develop
```

### 2. Feature Development Workflow

```bash
# Start a new feature
dot feature start user-authentication

# Work on your feature...
git add .
git commit -m "Add login functionality"

# Publish feature for collaboration (optional)
dot feature publish user-authentication

# Finish feature (merges to develop and cleans up)
dot feature finish user-authentication
```

### 3. Release Management

```bash
# Start a release
dot release start 1.2.0

# Prepare release (update version, changelog, etc.)
# ...

# Finish release (merges to main, tags, merges back to develop)
dot release finish 1.2.0
```

### 4. Status and Management

```bash
# Check git flow status
dot flow status

# List feature branches
dot feature list

# View configuration
dot flow config
```

## 📚 Complete Command Reference

### Flow Commands

| Command | Description |
|---------|-------------|
| `dot flow init [main] [develop]` | Initialize git flow in repository |
| `dot flow status` | Show current git flow status |
| `dot flow config` | Display git flow configuration |
| `dot flow help` | Show complete help documentation |

### Feature Commands

| Command | Description |
|---------|-------------|
| `dot feature start <name>` | Start new feature branch from develop |
| `dot feature finish [name]` | Finish feature and merge to develop |
| `dot feature publish [name]` | Publish feature branch to remote |
| `dot feature list` | List all feature branches |
| `dot feature delete <name>` | Delete feature branch |

### Release Commands

| Command | Description |
|---------|-------------|
| `dot release start <version>` | Start release branch from develop |
| `dot release finish <version>` | Finish release, merge to main, create tag |

### Git Aliases (Automatically Configured)

| Alias | Command | Description |
|-------|---------|-------------|
| `git flow` | `dot flow` | Git flow commands |
| `git feature` | `dot feature` | Feature management |
| `git release` | `dot release` | Release management |
| `git fs` | `dot feature start` | Quick feature start |
| `git ff` | `dot feature finish` | Quick feature finish |
| `git fp` | `dot feature publish` | Quick feature publish |
| `git fl` | `dot feature list` | Quick feature list |

## 🌳 Workflow Overview

### Branch Structure

```
main           Production-ready code
├─ v1.0.0      Release tags
├─ v1.1.0      
└─ v1.2.0      

develop        Integration branch
├─ feature/user-auth     Feature branches
├─ feature/api-refactor  
└─ release/1.3.0         Release branches

hotfix/        Emergency fixes (future)
└─ hotfix/security-patch
```

### Feature Workflow

1. **Start**: `dot feature start <name>` creates `feature/<name>` from `develop`
2. **Develop**: Work on feature branch, commit changes
3. **Publish**: `dot feature publish` pushes to remote for collaboration
4. **Finish**: `dot feature finish` merges to `develop` with `--no-ff` and cleans up

### Release Workflow

1. **Start**: `dot release start <version>` creates `release/<version>` from `develop`
2. **Prepare**: Update version numbers, changelog, final bug fixes
3. **Finish**: `dot release finish` merges to `main`, creates tag, merges back to `develop`

## ⚙️ Configuration

Plugin configuration is stored in `~/.config/dotfiles/plugins/git-flow/config.yaml`:

```yaml
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
```

## 🔍 Examples

### Complete Feature Development

```bash
# Start working on user authentication
dot feature start user-auth

# Make commits
git add src/auth/
git commit -m "Add JWT token generation"

git add tests/auth/
git commit -m "Add authentication tests"

# Publish for code review
dot feature publish user-auth

# After review, finish the feature
dot feature finish user-auth
```

### Release Preparation

```bash
# Start release preparation
dot release start 1.2.0

# Update version in package.json, README, etc.
git add .
git commit -m "Bump version to 1.2.0"

# Final testing, bug fixes...
git add .
git commit -m "Fix release blocker bug"

# Release to production
dot release finish 1.2.0
```

### Project Status Check

```bash
# Check overall git flow status
dot flow status

# Output:
# 📊 Git Flow Status
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configuration:
#   Main branch: main
#   Develop branch: develop
# 
# Current branch: feature/user-auth
# 
# Feature branches: 2
#   * feature/user-auth (current)
#     feature/api-refactor
# 
# Release branches: 0
# 
# Recent tags:
#   v1.1.0
#   v1.0.0
```

## 🔧 Advanced Usage

### Custom Branch Naming

```bash
# Initialize with custom branch names
dot flow init master development

# This sets:
# - Main branch: master
# - Develop branch: development
```

### Working with Remote Teams

```bash
# Publish feature for collaboration
dot feature start team-feature
# ... make initial commits ...
dot feature publish team-feature

# Team members can now:
git checkout feature/team-feature
# ... collaborate ...

# Finish when ready
dot feature finish team-feature
```

### Multiple Features

```bash
# Work on multiple features simultaneously
dot feature start feature-a
dot feature start feature-b

# Switch between them
git checkout feature/feature-a
# ... work ...
git checkout feature/feature-b  
# ... work ...

# Finish them independently
dot feature finish feature-a
dot feature finish feature-b
```

## 🛠️ Troubleshooting

### Common Issues

**Q: "Plugin not found" error**
```bash
# Ensure plugin is installed and enabled
dot plugin list installed
dot plugin enable git-flow
```

**Q: Git flow not initialized**
```bash
# Initialize git flow in your repository
dot flow init
```

**Q: Merge conflicts during feature finish**
```bash
# Git flow will pause on conflicts
# Resolve conflicts manually, then:
git add .
git commit
# Continue with: dot feature finish <name>
```

**Q: Feature branch doesn't exist**
```bash
# Check existing branches
dot feature list
# Or create new feature
dot feature start <name>
```

### Reset Git Flow

If you need to reset git flow configuration:

```bash
# Remove all git flow config
git config --remove-section gitflow 2>/dev/null || true

# Re-initialize
dot flow init
```

## 🤝 Integration

### GitHub Integration

The plugin works seamlessly with GitHub workflows:

```bash
# Feature development
dot feature start github-integration
# ... develop ...
dot feature publish github-integration
# Create PR on GitHub: feature/github-integration -> develop

# After PR approval
dot feature finish github-integration
```

### CI/CD Compatibility

Git flow branches work well with CI/CD:

- **Features**: CI runs on `feature/*` branches
- **Develop**: Integration testing on `develop` branch
- **Main**: Production deployment from `main` branch
- **Releases**: Release testing on `release/*` branches

## 📄 License

MIT License - see plugin.yaml for details

## 🙋‍♂️ Support

- **Documentation**: Run `dot flow help` for complete command reference
- **Plugin Info**: `dot plugin info git-flow`
- **Issues**: Report via dotfiles repository issue tracker
- **Community**: Join dotfiles community discussions

---

*Part of the Modern Dotfiles Framework Plugin Ecosystem*