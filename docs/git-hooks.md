# Git hooks

**SSOT:** repo `hooks/` → `~/.config/git/hooks` (chezmoi symlink).
`git config --global core.hooksPath ~/.config/git/hooks` (set by chezmoi
`run_onchange`).

These hooks run for **every** repository on the machine. They resolve the
current repo with `git rev-parse --show-toplevel` (not the dotfiles tree).

## What runs

| Hook | Behavior |
|------|----------|
| `pre-commit` | Fast staged-file secret scan; then `pre-commit` if the repo has `.pre-commit-config.yaml` |
| `commit-msg` | `pre-commit` commit-msg stage if configured; else light conventional-commit check |
| `prepare-commit-msg` | `pre-commit` prepare-commit-msg stage only (no-op otherwise) |
| `pre-push` | `pre-commit` pre-push stage if configured; else light credential-filename check |

Dotfiles quality (shellcheck, shfmt, gitleaks, ruff, …) lives in
[`.pre-commit-config.yaml`](../.pre-commit-config.yaml).

## Skip

```bash
git commit --no-verify
git push --no-verify
```

## Apply / reload

```bash
chezmoi --source ~/dotfiles/home apply
# hooks are already on hooksPath — edit hooks/* and they take effect immediately
```
