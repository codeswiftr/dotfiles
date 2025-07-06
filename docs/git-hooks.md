# Git Hooks Documentation

This document describes the automated quality gates implemented via Git hooks in the dotfiles repository.

## Overview

Git hooks are scripts that run automatically at specific points in the Git workflow. Our dotfiles include three main hooks that enforce quality standards and prevent common issues:

- **pre-commit**: Quality gates before commits
- **commit-msg**: Commit message validation
- **pre-push**: Comprehensive validation before pushing

## Installation

Git hooks are automatically installed during the dotfiles setup process. To manually install or update hooks:

```bash
# Install all hooks
./scripts/setup-hooks.sh install

# Show hook information
./scripts/setup-hooks.sh info

# Test hooks
./scripts/setup-hooks.sh test

# Uninstall hooks
./scripts/setup-hooks.sh uninstall
```

## Hook Details

### Pre-commit Hook

Runs before each commit to ensure code quality and security.

**Checks performed:**
- **Security**: Scans for sensitive data (passwords, tokens, keys)
- **Syntax**: Validates shell script and YAML syntax
- **Safety**: Detects dangerous commands (rm -rf /, chmod 777, etc.)
- **Permissions**: Ensures shell scripts are executable
- **Structure**: Validates dotfiles directory structure
- **Testing**: Runs quick installation tests
- **Version**: Checks version consistency

**Usage:**
```bash
# Manual execution
./hooks/pre-commit

# Skip for emergency commits
git commit --no-verify
```

### Commit Message Hook

Validates commit message format and encourages best practices.

**Validation rules:**
- Minimum 10 characters
- Maximum 72 characters for first line
- Conventional commit format (optional but recommended)
- Imperative mood usage
- Proper capitalization
- No ending punctuation

**Supported conventional commit types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes
- `revert`: Revert changes

**Examples:**
```bash
# Good commit messages
feat: add automated testing framework
fix: resolve shell startup performance issue
docs: update installation instructions
refactor(cli): simplify command structure

# Messages that will trigger warnings
Added new feature  # Should be: feat: add new feature
Fix bug.          # Should be: fix: resolve specific issue
```

### Pre-push Hook

Comprehensive validation before pushing to remote repository.

**Checks performed:**
- **Testing**: Runs full test suite
- **Installation**: Validates all installation profiles
- **Documentation**: Checks README and documentation
- **Security**: Comprehensive security compliance scan
- **Cross-platform**: Platform compatibility checks
- **Version**: Version consistency validation
- **History**: Commit history analysis
- **Performance**: Repository size and large file detection

**Usage:**
```bash
# Manual execution
./hooks/pre-push origin https://github.com/user/repo.git

# Skip for emergency pushes
git push --no-verify
```

## Configuration

### Disabling Hooks Temporarily

For emergency situations, you can bypass hooks:

```bash
# Skip pre-commit and commit-msg hooks
git commit --no-verify -m "emergency fix"

# Skip pre-push hook
git push --no-verify
```

### Customizing Hook Behavior

Hooks can be customized by editing the files in the `hooks/` directory:

- `hooks/pre-commit`: Pre-commit quality gates
- `hooks/commit-msg`: Commit message validation
- `hooks/pre-push`: Pre-push comprehensive validation

### Hook Configuration

Git hooks directory can be configured:

```bash
# Use custom hooks directory (Git 2.9+)
git config core.hooksPath hooks/

# Reset to default .git/hooks
git config --unset core.hooksPath
```

## Troubleshooting

### Common Issues

1. **Hook fails to execute**
   ```bash
   # Check permissions
   ls -la .git/hooks/
   chmod +x .git/hooks/pre-commit
   ```

2. **Syntax check fails**
   ```bash
   # Check shell script syntax
   bash -n script.sh
   ```

3. **Test failures**
   ```bash
   # Run tests manually
   ./tests/test_runner.sh
   ```

4. **Security warnings**
   ```bash
   # Check for sensitive data
   git secrets --scan
   ```

### Debug Mode

Enable debug output for hooks:

```bash
# Set debug mode
export DEBUG=1

# Run hook with debug output
./hooks/pre-commit
```

### Performance Issues

If hooks are slow:

1. Check repository size: Large repositories may cause timeouts
2. Disable expensive checks temporarily
3. Use `--no-verify` for urgent commits
4. Optimize test suite performance

## Best Practices

### Commit Messages

Follow conventional commit format:

```bash
type(scope): description

[optional body]

[optional footer]
```

### Development Workflow

1. Make changes
2. Run tests locally: `./tests/test_runner.sh`
3. Stage changes: `git add .`
4. Commit with descriptive message: `git commit -m "feat: add feature"`
5. Push changes: `git push`

### Security

- Never commit sensitive data
- Use environment variables for secrets
- Review security warnings from hooks
- Keep hooks updated

## Integration with CI/CD

Hooks complement CI/CD pipelines:

- **Local hooks**: Fast feedback during development
- **CI/CD**: Comprehensive validation on multiple platforms
- **Redundancy**: Catches issues at multiple stages

## Maintenance

### Updating Hooks

```bash
# Pull latest changes
git pull

# Reinstall hooks
./scripts/setup-hooks.sh install
```

### Adding New Checks

1. Edit appropriate hook file in `hooks/`
2. Test the new check
3. Update documentation
4. Commit changes

### Hook Development

When developing new hooks:

1. Follow shell script best practices
2. Include proper error handling
3. Provide clear error messages
4. Test on multiple platforms
5. Document new checks

## References

- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Shell Script Best Practices](https://google.github.io/styleguide/shellguide.html)

---

*For questions or issues with Git hooks, please check the troubleshooting section or open an issue.*