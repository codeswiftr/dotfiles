# Technical debt

Prefer deleting dead code over rewriting it.

## Phase 0 freeze (2026-09-14)

Until Phase 1/2 strategy work lands, **do not grow**:

| Surface | Rule |
|---------|------|
| `install.sh` | No new flags, profiles, or install paths |
| `config/tools.yaml` | No new tools/groups; freeze now, delete in Phase 2 |
| Profiles | No new profiles; target remains `standard` + `minimal` |

North star: `curl \| bash` → agent-safe Herdr shell. Net-negative LOC this quarter.

Baseline note: local Docker clean-room timing was blocked by host disk; CI `cleanroom` job is the measured gate.

## Done recently

| Area | Notes |
|------|--------|
| Multiplexer | tmux retired → Herdr + `just` |
| Fresh install | One curl bootstrap; `./setup` / `./install.sh` after clone |
| Mosh | `networking` group + `.zshenv` PATH for Moshi |
| Legacy CLI | Removed `perf` / `project` / fat `testing` / `template` / broken `platform` arms |
| Orphan trees | Removed `templates/`, `themes/`, `src/--help`, stale docs |
| Phase 0 deletes | `dev-{api,web,ios}`, dual `health-check`, tutor/viman, zsh examples, topic docs |

## Still optional (Phase 1–2)

| Item | Priority | Notes |
|------|----------|--------|
| Kill `bin/dot` → `just` only | High | Keep check logic; drop Graphviz collision |
| Slim/delete `lib/cli/{ai,config,git,security}` | High | Starve with Phase 1 |
| Slim `install.sh` (~1.5k → ≤700) | High | After deletes; two-tier mise + Brewfile/apt |
| Delete `tools.yaml` + parser | High | Phase 2; freeze until then |
| Profiles 4→2 | Medium | Collapse `full` / `ai_focused` into `standard` |
| Fleet profile probation | Medium | Delete by 2026-12-14 if unused |
| `moshi-hook` on phone hosts | Optional | Live Activities / Watch |
| Age-encrypted secrets | Optional | Not blocking |

## Explicit non-goals

- Multi-shell (fish)
- Rebuilding tmux park / agent-restart
- Growing AI profiles beyond the daily set
- App scaffolds / security-suite cosplay in this repo

## Contributor path

```bash
just smoke
just test
just check
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
