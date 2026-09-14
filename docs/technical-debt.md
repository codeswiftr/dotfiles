# Technical debt

Prefer deleting dead code over rewriting it.

## Phase status

| Phase | Status | Notes |
|-------|--------|-------|
| 0 | Done | Cheap deletes + CI clean-room + freeze |
| 1 | Done | `just` owns tasks; `bin/dot` + `lib/cli` gone; 2 profiles |
| 2 | Done | `tools.yaml` gone; mise + Brewfile/apt; chezmoi-strict; `install.sh` ~484 lines |

## Package contract (SSOT)

| Layer | Owns |
|-------|------|
| `mise.toml` | Pinned CLIs / runtimes |
| `config/platform/Brewfile` | macOS platform pkgs + AI casks |
| `config/platform/apt.txt` / `pacman.txt` | Linux platform pkgs |
| `scripts/install-*.sh` | herdr, mosh, and other cross-OS helpers |
| `chezmoi` (`home/`) | `$HOME` state — required, no fallback linker |

## Done recently

| Area | Notes |
|------|--------|
| Multiplexer | tmux → Herdr |
| Phase 0–1 | App scaffolds, `bin/dot`, AI bash middleware, 2 profiles |
| Phase 2 | Kill yaml parser; slim installer; strict chezmoi |

## Still optional

| Item | Priority | Notes |
|------|----------|--------|
| Fleet profile probation | Medium | Delete by 2026-12-14 if unused |
| Further install.sh trim | Low | Already ≤700 |
| `moshi-hook` on phone hosts | Optional | Live Activities / Watch |

## Explicit non-goals

- Multi-shell (fish)
- Rebuilding tmux park / agent-restart
- Growing AI profiles beyond the daily set
- App scaffolds / security-suite cosplay / bespoke CLI frameworks
- New tools.yaml / custom package routers

## Contributor path

```bash
just smoke
just test
just check
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
