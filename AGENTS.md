# Repository Guidelines

## Project Structure & Module Organization
- `bin/` ships the `dot` CLI and bundled helper scripts; keep entrypoints self-contained.
- `config/`, `lib/`, `scripts/` host runtime modules, installer assets, and automation hooks.
- `src/`, `templates/`, `themes/` cover user-facing assets for shell, web, and theming experiments.
- `tests/` holds shell harnesses under `unit`, `integration`, `infrastructure`, `performance`; artifacts land in `tests/results/`.
- `docs/` stores planning notes; long-form prompts belong here, not in root.

## Build, Test, and Development Commands
- `./tests/test_runner.sh` runs the full shell suite and writes logs to `tests/results/`.
- `./tests/enhanced_test_runner.sh --quick` gives a fast smoke pass before commits.
- `make api-run` boots the FastAPI/Uvicorn dev server via `scripts/dev-api.sh`.
- `make dev-web` launches the web harness; `make build-ios` wraps `scripts/dev-ios.sh build`.
- `find . -name "*.sh" -exec shellcheck {} \;` and `shfmt -w` keep shell scripts consistent; pair with `find . -name "*.yml" -o -name "*.yaml" | xargs yamllint`.

## Coding Style & Naming Conventions
- Shell scripts stay POSIX/Bash; prefer snake_case functions and kebab-case filenames.
- Python follows PEP8 with type hints; lint using `make lint-py` (`ruff check`) and format via `make format-py`.
- JavaScript/TypeScript use ES modules, `const`/`let`, and Prettier; Swift code uses `swift-format --lint .`.
- Keep configuration keys lowercase with hyphen separators; classes stay PascalCase.

## Testing Guidelines
- Place new tests in the matching `tests/<suite>/test_*.sh`; echo `Tests Run/Passed/Failed` per harness.
- Critical coverage targets: `install.sh`, `bin/dot`, security flows, and performance budgets.
- Capture command outputs in `tests/results/`; attach logs to PRs when failures occur.

## Commit & Pull Request Guidelines
- Use Conventional Commits (`feat(cli):…`, `fix(tests):…`); reference issues in the body.
- PRs should outline intent, link issues, include screenshots or terminal logs, and confirm tests.
- Expect pre-commit and security gates (e.g., `gitleaks`); resolve before review.

## Security & Configuration Tips
- Do not commit secrets; rely on `.env.local` patterns and `dot security` helpers.
- Prefer reproducible scripts over manual steps; document new env vars in `docs/`.

## Agent-Specific Instructions
- Follow the minimal-diff principle: change only what is required and mirror existing style.
- Reach for `rg` to explore the repo; avoid `git reset` or reverting user-owned changes.
- When unsure, run the quick test suite before proposing large edits.
