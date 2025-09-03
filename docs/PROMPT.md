# 🤖 Claude Code Agent Handoff Prompt (Updated Sept 2025)

## Mission
Deliver business value fast by completing the next four epics with disciplined, test-driven vertical slices while preserving performance, cross-platform support, and developer trust.

Fundamental principles (first-principles mindset):
- Keep it simple. Copy what already works. Do boring, proven things that make money.
- Minimize cognitive load; prefer conventional, obvious interfaces.
- Sub-350ms shell startup is sacrosanct; never regress core user journeys.
- Safety > cleverness: tests first, smallest viable changes, continuous validation.

Mindset anchors (repeat daily):
- I will copy what works; I will not reinvent the wheel; I will keep it simple.
- I will do boring things that are proven to make money.
- I am grateful for the discipline to keep exercising even when I don't feel like it.

## Strategic Plan (Next 4 Epics)
1) Epic 4: Backup & Recovery — data safety and trust
2) Epic 5: AI Integration — productivity leverage
3) Epic 6: Security & Compliance — enterprise readiness
4) Epic 8: CI Reliability & Self‑Healing — green pipelines, no drift

Reference: docs/PLAN.md (kept current). Execute epics in that order.

## Constraints and Quality Bars
- TDD is non-negotiable:
  1) Write a failing test that defines expected behavior
  2) Implement the minimal code to pass
  3) Refactor while keeping tests green
- Coverage: 90%+ for all new code. Prefer unit tests; add high-signal integration tests.
- Performance: shell startup < 350ms; no blocking work at startup; lazy load where possible.
- Cross-platform: macOS + Ubuntu + WSL; prefer POSIX sh/bash; guard OS branches.
- Security: no secrets in repo; redaction in logs; least-privilege defaults.
- YAGNI: do not build what we do not need this week.

## Immediate Next Steps (Epic 4: Backup & Recovery)
Week 1 priorities (vertical slices, smallest wins first):
1) Lock Backup Engine Contracts (tests first)
   - Create: tests/unit/backup/test_create_full_backup.sh
   - Create: tests/unit/backup/test_create_incremental_backup.sh
   - Create: tests/unit/backup/test_backup_validation.sh
   - Create: tests/unit/backup/test_backup_compression.sh
   - Integration smoke: tests/integration/backup/test_dot_backup_cli.sh
2) Implement minimal code to pass tests in lib/backup-restore.sh
   - Only implement the lines the tests require; keep functions small and explicit
3) Restore + permissions
   - Implement restore_full_system, restore_selective_config, restore_validation (basic path)
   - Add permission fixes for SSH/GPG/shell configs; validate via tests
4) Scheduling & retention (thin slice)
   - cron/systemd-user helpers (mocked); implement retention policy with tests using fake timestamps

Definition of done (Epic 4):
- Green unit + integration tests on both Linux and macOS; CI passes
- Full backup includes manifest, checksums, index; validation passes; restore round-trips
- Retention keeps windows; scheduling idempotent; docs updated

## After Epic 4
- Epic 5 (AI Integration):
  - Implement provider adapters in lib/ai-integration.sh for Claude and OpenAI first
  - Add ai_code_review, ai_generate_tests with mocked HTTP; gate any network behind env flags
- Epic 6 (Security & Compliance):
  - Start with ripgrep-based secret detection and dependency checks; produce markdown reports
- Epic 8 (CI Reliability):
  - Add ci/bootstrap.sh to normalize env (chmod scripts, ensure bash)
  - Optional monitor job that comments status on PRs; enforce v4 artifact actions (done)

## Subagents and Delegation (avoid context rot)
Spin up subagents with focused scopes and short-lived context windows; each produces tests + code + docs for its slice.

- Subagent A (Backup Engine):
  - Owner: tests/unit/backup/* + lib/backup-restore.sh (create_* + validation + compression)
  - Deliverables: passing unit tests, updated docs/backup section
- Subagent B (Restore & Permissions):
  - Owner: restore_* functions + permission fixers; integration tests
- Subagent C (Scheduling & Retention):
  - Owner: cron/systemd helpers, retention policy, tests with mocked time/cron
- Subagent D (CI Reliability):
  - Owner: ci/bootstrap.sh, workflow hardening, flake tracking and retries where safe
- Subagent E (AI Providers, next epic):
  - Owner: provider adapters (Claude/OpenAI), mocked tests, redaction and cost guards

Each subagent:
- Starts by reading relevant files + docs/PLAN.md sections
- Writes failing tests, then minimal implementation, then refactors
- Updates docs succinctly; keeps commits small and descriptive

## Operating Procedures
- Branching: feature/<epic>-<slice>, PRs small (<300 lines diff) unless mechanical
- Commits: conventional commits; each references epic and slice
- CI: run ./tests/test_runner.sh locally before push; ensure no startup regressions
- Artifacts: upload reports (performance, security) via actions/upload-artifact@v4
- Docs: update docs/PLAN.md and this prompt when scope changes materially

## Key Files
- bin/dot — main CLI (entry + dispatch)
- lib/backup-restore.sh — backup engine + restore
- lib/cli/backup.sh — user-facing backup CLI
- lib/ai-integration.sh — AI provider adapters (to implement)
- lib/cli/security.sh, lib/security-system.sh — security system stubs
- tests/test_runner.sh, tests/enhanced_test_runner.sh — test harness
- docs/PLAN.md — authoritative plan; keep current

## First-Principles Review Checklist (use before/after each slice)
- What is the core user outcome? Is this the smallest change that delivers it?
- Is there a test proving behavior and guarding against regressions?
- Does this change keep shell startup < 350ms? (no work on hot path)
- Is it cross-platform and safe? Are error cases explicit and logged?

## Progress Reporting
- After each deliverable: run tests; refactor; commit; update docs/PLAN.md and this file’s status line
- Status to include: what changed, why, tests added, perf/security notes

Current status: start Epic 4, write unit tests for backup engine and implement minimal code to pass; keep CI green.
