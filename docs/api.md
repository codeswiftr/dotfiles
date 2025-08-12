# 📘 CLI API Reference

The `dot` CLI is the single entry point for user and agent operations.

## Getting Help
```bash
dot --help
# Category help
dot <category> --help
# Command help
dot <category> <command> --help
```

## Categories (by convention)
- `project`: project scaffolding and status
- `ai`: AI workflows (commit, review, analyze)
- `security`: scans and status
- `test`: run and report tests
- `performance`: benchmarking and status
- `plugin`: plugin lifecycle

## File Map
- CLI entry: `bin/dot`
- Commands: `lib/cli/*.sh`
- Shared libs: `lib/*.sh`

## Examples
```bash
# Initialize and check
dot setup
dot check

# AI workflows
dot ai commit
dot ai review --since main

# Security
dot security scan

# Testing
dot test run

# Plugins
dot plugin list
```

Refer to inline `--help` for live, authoritative usage.
