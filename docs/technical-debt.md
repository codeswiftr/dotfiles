# Technical debt

Prefer deleting dead code over rewriting it.

## Done recently

| Area | Notes |
|------|--------|
| Multiplexer | tmux retired → Herdr + `just` |
| Fresh install | One curl bootstrap; `./setup` / `./install.sh` after clone |
| Mosh | `networking` group + `.zshenv` PATH for Moshi |
| Legacy CLI | Removed `perf` / `project` / fat `testing` / `template` / broken `platform` arms |
| Orphan trees | Removed `templates/`, `themes/`, `src/--help`, stale docs |

## Still optional

| Item | Priority | Notes |
|------|----------|--------|
| Slim `install.sh` (~1.5k) | Low | Opportunistic while editing |
| Slim `lib/cli/{ai,config,git,security}` | Low | Starve unless used weekly |
| Merge `scripts/health-check.sh` into `dot check` | Low | Duplicate health entry |
| `moshi-hook` on phone hosts | Optional | Live Activities / Watch |
| Age-encrypted secrets | Optional | Not blocking |

## Explicit non-goals

- Multi-shell (fish)
- Rebuilding tmux park / agent-restart
- Growing AI profiles beyond the daily set

## Contributor path

```bash
just smoke
just test
just check
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
