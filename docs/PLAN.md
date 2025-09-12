# Delivery Plan: Next 4 Epics

This plan consolidates current capabilities and defines the next high‑impact steps. Strategy: test bottom‑up (units → integrations → contracts → CLI/API → iOS/PWA), ship vertical slices, keep docs and tests in lock‑step.

## First Principles
- Work must improve developer outcomes measurably (tests green, faster startup, clearer UX).
- Truth source is behavior: tests define contracts; code conforms to tests.
- Prefer minimal change sets that deliver full user value end‑to‑end.

## Audit Summary
- Tests: mature shell framework + results under `tests/results/`; performance budgets present.
- Tooling: `gitleaks`, hooks, `shellcheck`, `yamllint`; robust `bin/dot` with modular `lib/cli/*`.
- Gaps: missing CLI contract coverage for `bin/dot` (version/help/json outputs), limited security flows tests, limited doc drift checks.

## Epic 1 — Testing Foundation Consolidation
- Goals: stabilize runners, raise coverage of core commands, enforce performance budgets.
- Tasks:
  - CLI contracts: add tests for `dot --version`, `dot version`, `dot init --json`, `dot health --json`, `dot check --quiet` exit codes.
  - Unit gaps: extend `lib/cli/core.sh` tests for error branches and quiet/detailed modes.
  - Standardize all tests to emit `Tests Run/Passed/Failed` via framework.
  - Keep `tests/performance/test_shell_startup.sh` thresholds as guardrails; add regression assertion notes to summary.
- Exit criteria: 0 failures; new integration suite `tests/integration/test_cli_contracts.sh` passes locally and via runner.

## Epic 2 — Security & Secrets Hardening
- Goals: tighten scanning and validate security workflows.
- Tasks:
  - Tune `gitleaks.toml` (reduce false positives); add a test corpus under `tests/utils/fixtures/secrets/` to assert rules.
  - Add tests for `dot security scan|deps|code` and `secret exec -- echo $FOO` (stubbed env).
  - Document rotation and `.env.local` conventions in README; add check in infra tests for doc mention.
- Exit criteria: security tests pass; docs updated; zero false positives on repo snapshot.

## Epic 3 — DX: CLI & Installer UX
- Goals: frictionless onboarding and diagnose.
- Tasks:
  - Implement `dot diagnose` (dependency checks: shellcheck, yamllint, bc, python3, PyYAML) with clear exit codes.
  - Add idempotency tests for `install.sh` (install → re‑run → no‑op/upgrade).
  - Improve `dot --help` grouping; add snapshot test capturing help text.
- Exit criteria: green diagnose + idempotency tests; help snapshot stable.

## Epic 4 — Docs & CI Consistency
- Goals: prevent docs drift and ensure contributor flow.
- Tasks:
  - Add doc checks to ensure README commands exist in repo (`rg` assertions).
  - Keep `AGENTS.md`, this `docs/PLAN.md`, and `docs/PROMPT.md` synchronized with changes (lint in PR template).
  - Optional: script `scripts/docs-validate.sh` used by hooks.
- Exit criteria: doc checks pass; contributor guide and handoff prompt current.

## Subagent Delegation
- Test Subagent: Epic 1 ownership; maintain runners; build CLI contracts.
- Security Subagent: Epic 2 tuning + tests.
- DX Subagent: Epic 3 CLI diagnose + help UX.
- Docs Subagent: Epic 4 drift checks + keep docs synced.

## Execution Notes
- TDD: write failing tests first; implement minimal code; refactor with tests green.
- Prioritization: complete Epic 1 before 2–4; ship small, frequent PRs.
