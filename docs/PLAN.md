# Next 4 Epics: Outcome-Driven Plan (90-day horizon)

This plan applies Pareto, TDD, and vertical slices. Each epic ends with a green CI, docs, and a tagged release candidate.

## Epic A: Documentation System Split & Integrity

Goal: Make docs generation robust, portable, and verifiable across shells and CI.

Outcomes:
- Decouple docs generation from shell-specific features (associative arrays, zsh-only syntax)
- Provide `dot docs` subcommands: `init`, `generate`, `check`, `build`, `serve`, fully tested
- Enforce index freshness and link check in CI (non-flaky)

Scope (vertical slices):
1) Stabilize `lib/documentation.sh`
- Remove shell pitfalls (POSIX loops for categories)
- Use single-quoted heredocs for code fences
- Add smoke tests for `dot docs check` and `scripts/generate-index.sh`

2) CLI UX & Help
- `dot docs --help` structure + examples
- Snapshots for `dot docs` in `src/--help/`

3) CI gates
- New `docs` job running `dot docs check` and `generate-index.sh`
- Cache and timeouts to keep it fast

4) Link check (optional if fast)
- Use `lychee` or `markdown-link-check` (guarded behind env var)

Deliverables:
- Passing tests: `tests/infrastructure/test_docs.sh`
- Green CI across macOS/Ubuntu

Risks/mitigation:
- Flakiness → deterministic ordering + seed; retries off by default

## Epic B: Platform Robustness & Shell Portability

Goal: Make core scripts run consistently on bash 3.2+ (macOS) and bash 5+ (Linux). Reduce hard-coded paths.

Outcomes:
- Remove bash 4+ only constructs or provide fallbacks
- Replace hard-coded platform paths with `detect_os`/`detect_distro`/`HOMEBREW_PREFIX` probes
- Add portability tests for key scripts (`install.sh`, `bin/dot`, `scripts/health-check.sh`)

Scope:
1) Audit and fix
- ban associative arrays in shared libs; introduce small helpers for maps if required
- guard arrays and `set -u` usage with defaults

2) Path normalization
- `which brew` → derive prefix, avoid `/opt/homebrew`/`/usr/local` where not needed

3) Tests
- Extend infra tests: nested invocations, POSIX shells (dash) smoke

Deliverables:
- New tests: `tests/infrastructure/test_cli_paths.sh` (nested), `test_portability.sh`
- CI job matrix toggling bash versions (where feasible)

## Epic C: CI Performance Resilience & Determinism

Goal: Keep CI < 10m total with deterministic outcomes.

Outcomes:
- Concurrency cancellation and cache in place (pip, optional npm)
- Timeouts and retries strategy
- Split jobs to fail fast; artifacts uploaded for inspection

Scope:
1) Caching layers
- pip cache already added; optionally add npm cache if JS tools enabled

2) Timeouts & fail-fast
- job and step-level timeouts
- concurrency group per ref

3) Deterministic steps
- Seeded sorting in generators (index), fixed locale
- Avoid network uncertainty in tests

Deliverables:
- CI green; wall-clock metrics recorded in job summary

## Epic D: Release & Traceability

Goal: One-command release with version bump, tag, and changelog, traceable in CI.

Outcomes:
- `scripts/release.sh --dry-run|major|minor|patch` fully tested
- CI: when tag pushed, create GitHub Release draft + changelog stub

Scope:
1) Harden `scripts/release.sh`
- Validate input; support calendar versioning and semver
- TDD for dry-run and no-file-change guarantees

2) CI release pipeline
- New `release` workflow triggered on tags
- Attach artifacts (test results summary, docs index)

3) Documentation
- `docs/release.md` with step-by-step release instructions

Deliverables:
- Passing tests: `tests/infrastructure/test_release.sh`
- Tag push triggers release draft in CI

---

# Execution Protocol

- Always TDD: write failing infra test → minimal implementation → refactor
- Commit small, descriptive messages; conventional commits
- Keep pre-push hooks green locally before pushing

# Immediate Next Steps (Week 1)

1) Epic A slice 1
- Fix `lib/documentation.sh` portability: remove assoc arrays; single-quote heredocs
- Reinstate `tests/infrastructure/test_docs.sh`; ensure green locally and in CI

2) Epic B slice 1
- Replace hard-coded platform paths with detection helpers; add a unit in infra tests to verify

3) Epic C slice 1
- Add npm cache block (guarded if npm present); export locale `LC_ALL=C` at start of generators

4) Epic D slice 1
- Add release workflow skeleton; ensure it is no-op until tag

# Definition of Done (per epic)
- New/updated tests pass locally and in CI (macOS + Ubuntu)
- CI completes under agreed budget
- Docs updated; `dot docs check` clean
- If applicable, a tag+draft release pipeline verified on a test tag
