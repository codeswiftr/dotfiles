# Technical debt

Prefer deleting dead code over rewriting it.

## Phase status

| Phase | Status | Notes |
|-------|--------|-------|
| 0 | Done | Cheap deletes + CI clean-room + freeze |
| 1 | Done | `just` owns tasks; `bin/dot` + `lib/cli` gone; 2 profiles |
| 2 | Next | Kill `tools.yaml` parser; slim `install.sh`; chezmoi-strict |

## Freeze still in effect for installer growth

| Surface | Rule |
|---------|------|
| `install.sh` | Shrink only — no new flags/paths |
| `config/tools.yaml` | No new tools/groups; delete in Phase 2 |
| Profiles | `minimal` + `standard` only (`full`/`ai_focused` map → `standard`) |

## Done recently

| Area | Notes |
|------|--------|
| Multiplexer | tmux retired → Herdr + `just` |
| Fresh install | One curl bootstrap; `./setup` |
| Phase 0 | App scaffolds, dual health, tutor/viman, topic docs |
| Phase 1 | `scripts/{check,update,reload}.sh`; deleted `bin/dot` + `lib/cli` + AI bash middleware |

## Still optional (Phase 2)

| Item | Priority | Notes |
|------|----------|--------|
| Slim `install.sh` (~1.5k → ≤700) | High | Two-tier mise + Brewfile/apt |
| Delete `tools.yaml` + parser | High | Freeze until then |
| Drop chezmoi fallback linker | High | After measured chezmoi always installs |
| Fleet profile probation | Medium | Delete by 2026-12-14 if unused |
| `moshi-hook` on phone hosts | Optional | Live Activities / Watch |

## Explicit non-goals

- Multi-shell (fish)
- Rebuilding tmux park / agent-restart
- Growing AI profiles beyond the daily set
- App scaffolds / security-suite cosplay / bespoke CLI frameworks

## Contributor path

```bash
just smoke
just test
just check
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
