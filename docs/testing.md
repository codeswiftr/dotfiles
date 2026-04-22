# Testing Framework

This repository includes a bash-based testing framework in the `tests/` directory. Tests validate dotfile installation, configuration correctness, CLI behavior, security, and performance.

## Running Tests

```bash
# Run the full test suite (all categories)
./tests/test_runner.sh

# Run a specific category
./tests/test_runner.sh --category infrastructure
./tests/test_runner.sh --category unit
./tests/test_runner.sh --category integration
./tests/test_runner.sh --category performance

# Quick mode (skips performance tests)
./tests/test_runner.sh --quick

# Verbose output
./tests/test_runner.sh --verbose

# Legacy mode (infrastructure tests only, no enhanced runner)
./tests/test_runner.sh --legacy
```

## Architecture

The framework has two layers:

- **`test_runner.sh`** -- Entry point. Parses CLI flags, sets up the results directory, and delegates to the enhanced runner. Falls back to legacy mode (infrastructure-only) if the enhanced runner is missing.
- **`enhanced_test_runner.sh`** -- Discovers and executes tests across all categories. Produces a comprehensive Markdown report in `tests/results/`.

### Test Categories

Tests are organized into subdirectories:

| Directory | Purpose |
|-----------|---------|
| `tests/infrastructure/` | Installation, health checks, configuration, linting, CLI, security, tmux |
| `tests/unit/` | Unit tests for individual functions (e.g., CLI core) |
| `tests/integration/` | End-to-end tests (CLI contracts, full install) |
| `tests/performance/` | Shell startup benchmarks and performance regression checks |

Standalone test scripts live at the top level of `tests/` (e.g., `test_security_system.sh`, `test_vim_keymaps_optimization.sh`).

### Dependencies

Required: `shellcheck`, `yamllint`, `python3`.
Optional: `bc` (for performance tests), `PyYAML` (for YAML validation in Python).

Install on macOS:

```bash
brew install shellcheck yamllint bc
```

## Writing Tests

Each test file is a standalone bash script that exits 0 on success and non-zero on failure. The enhanced runner discovers `.sh` files in category subdirectories automatically.

Test scripts should print summary lines so the runner can parse results:

```
Tests Run: 5
Tests Passed: 4
Tests Failed: 1
```

### Infrastructure test example

```bash
#!/bin/bash
set -euo pipefail

PASSED=0 FAILED=0

run_test() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    PASSED=$((PASSED + 1))
  else
    echo "FAIL: $name"
    FAILED=$((FAILED + 1))
  fi
}

run_test "install.sh exists" test -f install.sh
run_test "install.sh is executable" test -x install.sh

TOTAL=$((PASSED + FAILED))
echo "Tests Run: $TOTAL"
echo "Tests Passed: $PASSED"
echo "Tests Failed: $FAILED"
exit "$FAILED"
```

## Results and Reports

All output is written to `tests/results/`:

- **Timestamped log files** (`test_run_YYYYMMDD_HHMMSS.log`) with full output.
- **Markdown summary reports** with pass/fail counts, duration, and recommendations.

Old output files (older than 7 days) are cleaned up automatically.
