# Testing

Tests use [bats-core](https://bats-core.readthedocs.io/) (Bash Automated Testing System).

## Running Tests

```bash
# All tests
bats tests/bats/*.bats

# Smoke tests (CLI, install, shell syntax, symlinks)
bats tests/bats/smoke.bats

# Infrastructure tests (paths, contracts, bindings, tiers, performance)
bats tests/bats/infrastructure.bats

# Verbose output
bats --verbose-run tests/bats/*.bats
```

## Test Suites

| File | Tests | What it covers |
|------|-------|----------------|
| `smoke.bats` | 19 | dot CLI, install.sh dry-run, shell syntax, startup time, file existence, symlinks, nvim tiers |
| `infrastructure.bats` | 17 | CLI path resolution, version contract, tmux bindings, nvim tier files, keymaps, release script, shell performance |

## Requirements

```bash
brew install bats-core    # macOS
# or: npm install -g bats  # via npm
```

## Writing Tests

```bash
@test "description of what's being tested" {
    run some_command
    [ "$status" -eq 0 ]
    [[ "$output" == *"expected"* ]]
}
```

See [bats-core docs](https://bats-core.readthedocs.io/) for `setup`, `teardown`, `run`, and assertions.
