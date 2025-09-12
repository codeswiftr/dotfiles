# Repository Guidelines

## Project Structure & Module Organization
- `bin/`: primary CLI utilities (e.g., `dot`, helpers)
- `config/`, `lib/`, `plugins/`, `scripts/`: core runtime and setup logic
- `tests/`: shell-based test suites (unit, infrastructure, integration, performance) with runners
- `docs/`: planning and ops docs; keep project plans and prompts here
- Root scripts: `install.sh` (installer), plus repo metadata and configs

## Build, Test, and Development Commands
- Run all tests: `./tests/test_runner.sh` (logs to `tests/results/`)
- Quick runner: `./tests/enhanced_test_runner.sh --quick`
- Shell lint: `find . -name "*.sh" -exec shellcheck {} \;`
- YAML lint: `find . -name "*.yml" -o -name "*.yaml" | xargs yamllint`
- iOS helpers: `ios-quick-build`, `ios-test-run`, `ios-ui-test-run` (if installed)
- FastAPI helpers: `fastapi-test` or `fastapi-test tests/test_users.py`

## Coding Style & Naming Conventions
- Shell: POSIX/Bash; lint with `shellcheck`; format with `shfmt`.
- Python: PEP8, type hints where practical; run `pytest` when present.
- JS/TS: ES modules, `const/let`, Prettier formatting.
- Swift: `swift-format --lint .`; Apple naming; guard/if for errors.
- Naming: kebab-case for scripts, snake_case for shell/Python functions, PascalCase for classes.

## Testing Guidelines
- Framework: shell-based tests with standardized output lines: `Tests Run/Passed/Failed`.
- Conventions: place tests under `tests/{unit,integration,infrastructure,performance}`; name `test_*.sh`.
- Coverage: prioritize critical paths (installer, `bin/dot`, security, performance budget).
- Run locally before PRs; ensure `tests/results/` shows no failures.

## Commit & Pull Request Guidelines
- Conventional Commits: `type(scope): summary` (e.g., `feat(cli): add perf bench`).
- PRs: clear description, linked issues, screenshots or logs for UX/CLI changes, and test evidence.
- Hooks: pre-commit and security gates may run; fix findings before merge.

## Security & Configuration Tips
- Secrets: never commit credentials; `gitleaks` runs via `gitleaks.toml`.
- Keys: use `dot security` helpers where available; prefer `.env.local` patterns.
