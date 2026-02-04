---
name: release
description: Prepare a release with changelog, version bump, and tag
arguments: version
---

# Release Preparation: v$ARGUMENTS

Prepare a complete release using the **changelog-generator** and **update-broadcaster** skills.

## Workflow

### 1. Generate Changelog
Use the changelog-generator skill to:
- Gather commits since last tag
- Parse conventional commits
- Group by type (feat, fix, docs, etc.)
- Identify breaking changes

```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --pretty=format:"%h|%s|%an|%ad" --date=short
```

### 2. Update CHANGELOG.md
Prepend new release section:

```markdown
## [v$ARGUMENTS] - $(date +%Y-%m-%d)

### Added
- feat(scope): Description

### Fixed
- fix(scope): Description

### Changed
- refactor(scope): Description

### Breaking Changes
- feat(scope)!: Description
```

### 3. Version Bump
Update version in project files:
- `pyproject.toml` (version = "X.Y.Z")
- `package.json` ("version": "X.Y.Z")
- `Cargo.toml` (version = "X.Y.Z")
- Other version files as needed

### 4. Create Release Commit
```bash
git add CHANGELOG.md [version files]
git commit -m "chore(release): v$ARGUMENTS

- Update CHANGELOG.md
- Bump version to $ARGUMENTS

🤖 Generated with Claude Code"
```

### 5. Create Git Tag
```bash
git tag -a v$ARGUMENTS -m "Release v$ARGUMENTS"
```

### 6. Prepare Release Notes
Use update-broadcaster skill to create:
- GitHub release notes (from changelog)
- Social media announcement (if needed)
- Internal update (for team)

### 7. Output

```markdown
## Release v$ARGUMENTS Ready

### Changelog
[Summary of changes]

### Files Updated
- CHANGELOG.md
- [version files]

### Git Commands
```bash
# Push release
git push origin main --tags

# Create GitHub release (optional)
gh release create v$ARGUMENTS --notes-file RELEASE_NOTES.md
```

### Announcements
[Draft announcements for different audiences]
```

## Pre-Release Checklist
- [ ] All tests passing
- [ ] No uncommitted changes
- [ ] On main/release branch
- [ ] Previous release tagged
- [ ] Breaking changes documented
