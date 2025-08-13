You are a senior engineer continuing work on the codeswiftr/dotfiles repository. Context and constraints:

- The repo already consolidated a unified CLI (`bin/dot`), performance-tiered Neovim setup, extensive infra tests, GitHub Actions, and security hardening.
- CI was stabilized. Lint/test failures fixed. Concurrency and pip caching added. Tests now green locally via `./tests/test_runner.sh --category infrastructure`.
- Pre-push hooks enforce tests and docs index freshness (`scripts/generate-index.sh`).

Your mandate (next 4 epics):

1) Documentation System Split & Integrity
- Make `lib/documentation.sh` portable and robust (no zsh-only or bash-4-only features).
- Ensure `dot docs check` passes reliably on macOS and Ubuntu CI.
- Tests to cover: index generation (`scripts/generate-index.sh`), `dot docs check`, and help.
- Keep heredocs single-quoted around markdown/code fences to avoid ShellCheck parse errors.
- Restore `tests/infrastructure/test_docs.sh` into the runner once stable (was temporarily removed from `INFRASTRUCTURE_TESTS`).

2) Platform Robustness & Shell Portability
- Remove associative arrays where not strictly needed; provide fallbacks.
- Eliminate reliance on hard-coded paths (`/opt/homebrew`, `/usr/local/bin`, `/home/`) in scripts. Use detection helpers (HOMEBREW_PREFIX, detect_os/distro).
- Expand CLI path tests: ensure `bin/dot` resolves `DOTFILES_DIR` correctly from nested directories (test exists in `tests/infrastructure/test_cli_paths.sh`, but currently not in runner).

3) CI Performance Resilience & Determinism
- CI file: `.github/workflows/test.yml` has concurrency and pip cache. Consider adding npm cache region (guard if npm present).
- Add job timeouts where missing; keep overall runtime < 10m.
- Avoid flaky network-dependent tests. Seed generators; export `LC_ALL=C` where sorting is used.

4) Release & Traceability
- Script `scripts/release.sh` exists with dry-run. Harden and fully test.
- Add a `release` GitHub workflow: on tag push, build, run tests, and create a draft GitHub Release with artifacts (docs index, test summary). Keep minimal and fast.

Non-negotiables:
- TDD: add failing test first, implement minimal fix, refactor.
- Conventional commits.
- Keep `./tests/test_runner.sh` green and fast. Prefer to run individual tests during development.

Where to start (proposed order):
- Epic A slice 1: Refactor `lib/documentation.sh` to remove associative arrays completely. Replace category map with simple list + function to resolve labels. Fix the file’s lingering mismatched heredocs (there is a known parse error near development docs region). Re-enable `test_docs.sh` in the runner and make it green.
- Epic B slice 1: In `install.sh` and `bin/dot`, centralize path detection (e.g., compute brew prefix dynamically when needed). Add/enable `test_cli_paths.sh` in runner.
- Epic C slice 1: Add `LC_ALL=C` to `scripts/generate-index.sh` and ensure deterministic sorting; consider npm cache in GH Actions.
- Epic D slice 1: Add a minimal `release.yml` workflow that triggers on tags and uploads docs index + tests summary, without publishing (draft only).

Helpful commands:
- Run tests: `./tests/test_runner.sh --category infrastructure`
- Lint locally: `find . -name "*.sh" -exec shellcheck {} \;`
- Regenerate docs index: `scripts/generate-index.sh`
- CI logs: `gh run list -R codeswiftr/dotfiles` and `gh run view <id> -R codeswiftr/dotfiles --log`

Deliverables for you:
- Fix `lib/documentation.sh` parsing (there are still mismatched EOFs). Replace assoc arrays. Re-enable and pass `test_docs.sh`.
- Re-enable `test_cli_paths.sh` and `test_release.sh` once stable.
- Commit incrementally with clear, conventional messages.
- Keep CI green; don’t regress infra tests.
