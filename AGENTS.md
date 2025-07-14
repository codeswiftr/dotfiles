# AGENTS.md

## Build, Lint, and Test Commands
- **Run all tests:** `./tests/test_runner.sh`
- **Shell lint:** `find . -name "*.sh" -exec shellcheck {} \;`
- **YAML lint:** `find . -name "*.yaml" -o -name "*.yml" | xargs yamllint`
- **Python tests:** `pytest` (single test: `pytest path/to/test_file.py::test_func`)
- **JS/TS tests:** `npm test`, `jest`, `playwright`
- **API tests:** `bruno`, `k6`
- **iOS:** `ios-quick-build`, `ios-test-run`, `ios-ui-test-run`
- **FastAPI:** `fastapi-test`, `fastapi-test tests/test_users.py` (single test)
- **Web:** `lit-test`, `lit-test-component MyComponent`

## Code Style Guidelines
- **Shell:** Use `shellcheck` and `shfmt` for linting/formatting.
- **Python:** PEP8, explicit imports, type hints, descriptive names, try/except for errors.
- **JS/TS:** ES6 imports, const/let, camelCase for vars/functions, PascalCase for classes/components, handle errors, use Prettier.
- **Swift:** `swift-format --lint .`, Apple naming, explicit types, guard/if for errors.
- **General:** Group/sort imports, avoid unused imports, prefer explicit, keep functions small, document public APIs, meaningful commits.

## Commit Message Conventions
- Use conventional commit format: `type(scope): description` (max 72 chars first line)
- Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert
- Example: `feat: add new testing framework`

## Git Hooks Integration
- Automated hooks enforce quality gates: security, syntax, structure, commit message, and testing
- Always run tests before commit/push; hooks will validate and block if issues are found

## Agentic Coding
- Always run tests after changes
- Prefer running single tests for fast feedback
- Follow code style and error handling rules above
- Document any new APIs or scripts
