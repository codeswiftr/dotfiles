# Technical debt

Living backlog after the Herdr / just / Moshi cutover. Prefer deleting dead code over rewriting it.

## Done (do not re-open without pain)

| Area | Notes |
|------|--------|
| `bin/` policy | Scripts-only whitelist; real `~/.local/bin` for tools |
| Chezmoi | `home/` source; install fallback fixed |
| Shell modes | `DOTFILES_MODE=full\|minimal\|agent` drives tools + agent-safe |
| Aliases SSOT | `config/zsh/aliases.zsh`; tools modules are init-only |
| Tool ownership | `mise.toml` pins CLIs; `tools.yaml` / Brewfile = platform packages |
| Multiplexer | tmux retired; Herdr + `just` are canonical |
| Fresh install | Herdr + Mosh provisioned via `install.sh` / `networking` |
| CI / hooks | Single `ci.yml`; `hooks/` SSOT |

## Still optional

| Item | Priority | Notes |
|------|----------|--------|
| Delete legacy `lib/cli/{performance,testing,project}.sh` | Medium | Marked legacy in `dot --help`; ~2k lines |
| Slim `install.sh` (~1.5k lines) | Low | Works; cut dead branches only while editing |
| Slim remaining `lib/cli/{ai,config}` surface | Low | Starve unless used weekly |
| `DOT_QUIET` / less emoji on `dot` | Low | Prefer `-m` / plain primary help |
| `moshi-hook` on phone-attach hosts | Optional | Only if Live Activities / Watch matter |
| Age-encrypted secrets | Optional | Not blocking |

## Explicit non-goals

- Multi-shell (fish) support
- Rebuilding tmux park/resume or `agent-restart`
- Perfect multi-chat resume beyond agent native continue flags
- Growing AI profile beyond the daily set (claude, cursor, opencode, pi, kimi, codex)

## Contributor path

```bash
just smoke
just test
just check
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
