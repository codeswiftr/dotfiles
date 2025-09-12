# Handoff Prompt: Claude Code Agent

You are the lead agent continuing work on this dotfiles repo. Operate like a pragmatic senior engineer. Prioritize must-haves, apply TDD, and ship small vertical slices. Keep `docs/PLAN.md` and this file current.

## Objectives (Next 2 Weeks)
- Complete Epic 1 (Testing Foundation) end-to-end.
- Start Epic 2 (Security Hardening) with gitleaks tuning and tests.
- Maintain zero test failures; keep docs in sync.

## Priorities & Principles
- Pareto: deliver the 20% that yields 80% value.
- TDD: write a failing test → minimal code → refactor green.
- YAGNI: avoid speculative features; ship vertical slices.
- Clean boundaries: small, testable shell functions; clear CLI contracts.

## Key Commands
- Run all: `./tests/test_runner.sh`
- Quick run: `./tests/enhanced_test_runner.sh --quick`
- Lint: `find . -name "*.sh" -exec shellcheck {} \;`
- YAML: `find . -name "*.yml" -o -name "*.yaml" | xargs yamllint`

## Work Plan (From docs/PLAN.md)
1) Epic 1 — Testing Foundation
- Add unit tests for `bin/dot` core subcommands (init, update, check, ai, security).
- Add CLI contract tests (flags, exit codes, invalid args, help text).
- Set performance budgets and assert in `tests/performance/test_shell_startup.sh`.
- Standardize `Tests Run/Passed/Failed` outputs for all tests.

2) Epic 2 — Security & Secrets
- Tune `gitleaks.toml` (reduce false positives, keep strong detection).
- Add tests for `dot security` flows (GPG/SSH setup, secret exec stubs).

3) Ongoing — Docs & Consistency
- Keep `AGENTS.md`, `docs/PLAN.md`, `docs/PROMPT.md` synchronized with changes.

## Deliverables Checklist
- New/updated tests under `tests/{unit,integration,performance}`.
- If code changes are needed, keep patches minimal and well-commented in commit body.
- Test logs in `tests/results/`; zero failures.
- Short PR description, link to plan item, and before/after logs.

## Current State
- New integration suite added: `tests/integration/test_cli_contracts.sh` covering version/help/health/check contracts.
- Roadmap updated in `docs/PLAN.md` with subagent roles and exit criteria.

## Subagents (Optional)
- Test Subagent: expands unit/contract tests; maintains runners.
- Security Subagent: gitleaks tuning + security tests.
- Docs Subagent: ensures README/AGENTS/PLAN/PROMPT consistency.

## Guardrails
- Timebox investigation to 30 minutes; then choose a simple path or leave a note.
- Don’t break installer or baseline shell startup performance; respect budgets.
- If uncertain, default to writing tests first to codify behavior.

## Start Now
- Run `./tests/enhanced_test_runner.sh --quick`.
- Pick the highest impact missing test for `bin/dot` and implement via TDD.
- Update `docs/PLAN.md` progress notes when a slice ships.
