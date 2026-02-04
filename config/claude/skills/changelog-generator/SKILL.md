---
name: changelog-generator
description: Auto-generate changelogs from git commits using conventional commit format, grouping by type and version.
---

# Changelog Generator

## When to Use
- Before a release to document changes.
- After a sprint to summarize work.
- When preparing release notes for users.

## Workflow
1. **Gather Commits**
   ```bash
   # Get commits since last tag
   git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --pretty=format:"%h|%s|%an|%ad" --date=short
   ```

2. **Parse Conventional Commits**
   Format: `type(scope): description`

   | Type | Section |
   |------|---------|
   | feat | Features |
   | fix | Bug Fixes |
   | docs | Documentation |
   | style | Styles |
   | refactor | Code Refactoring |
   | perf | Performance |
   | test | Tests |
   | build | Build System |
   | ci | CI/CD |
   | chore | Chores |
   | revert | Reverts |
   | BREAKING CHANGE | Breaking Changes |

3. **Generate Changelog**
   Group commits by type, add dates and authors.

4. **Update CHANGELOG.md**
   Prepend new section, following Keep a Changelog format.

## Output Format
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- feat(auth): Add OAuth2 support (#123)
- feat(api): New endpoint for bulk operations

### Fixed
- fix(db): Resolve connection pool exhaustion (#456)

### Changed
- refactor(core): Simplify error handling

### Breaking Changes
- feat(api)!: Change response format for /users endpoint

## [1.2.0] - 2024-01-15

### Added
- ...
```

## Commands
```bash
# Generate changelog for unreleased commits
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s" | sort

# Get breaking changes
git log --grep="BREAKING CHANGE" --pretty=format:"- %s"

# Count commits by type
git log --oneline | grep -E "^[a-f0-9]+ (feat|fix|docs):" | cut -d: -f1 | sort | uniq -c
```

## Tips
- Link to PRs/issues where available.
- Highlight breaking changes prominently.
- Include migration guides for breaking changes.
- Keep descriptions user-focused, not implementation-focused.
