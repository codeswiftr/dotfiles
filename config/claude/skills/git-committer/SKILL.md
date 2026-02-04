---
name: git-conventional-committer
description: Stage changes, craft conventional commits, and push to the default branch following repository conventions.
---

# Git Conventional Committer

## When to Use
- After implementing a cohesive set of changes ready for version control.
- When preparing a handoff that requires code committed/pushed.

## Workflow
1. Run `git status` and review staged/unstaged files. Clean up any unwanted artifacts (use `.gitignore` if needed).
2. Stage relevant files (`git add <paths>`).
3. Craft a conventional commit message: `type(scope?): summary` (e.g., `feat(codeswiftr): add manual review API`). Types: `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `chore`.
4. Execute `git commit -m "message"`.
5. Pull latest main: `git pull --rebase origin main` (resolve conflicts if any).
6. Push: `git push origin HEAD`.
7. Record the commit hash and summary in `docs/progress.md` or relevant log.

## Guidelines
- Ensure tests/lints pass before committing.
- Avoid committing secrets or large binaries.
- Use multiple commits if work spans unrelated concerns.
