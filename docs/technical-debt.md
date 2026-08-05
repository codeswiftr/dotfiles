# Technical debt

Living backlog after the 2026 modernization waves. Prefer deleting dead code over rewriting it.

## Done (do not re-open without pain)

| Area | Notes |
|------|--------|
| `bin/` policy | Scripts-only whitelist; real `~/.local/bin` for tools |
| Chezmoi | `home/` source; install fallback fixed |
| Shell modes | `DOTFILES_MODE=full\|minimal\|agent` drives tools + agent-safe |
| Aliases SSOT | `config/zsh/aliases.zsh`; tools modules are init-only |
| Tool ownership | `mise.toml` pins CLIs; `tools.yaml` / Brewfile = platform packages |
| PATH brew dups | Brew copies of mise-owned CLIs removed on this machine (2026-08-04) |
| Docs hub | `docs/README.md` + `configuration.md`; empty INDEX scaffolds removed |
| Agent restarts | `dot restart prepare\|resume` |

## Still optional

| Item | Priority | Notes |
|------|----------|--------|
| Slim `install.sh` (~1.5k lines) | Low | Works; cut dead branches only if editing |
| Slim `lib/cli/*` (perf/ai/testing) | Low | Starve unused commands; don’t rewrite for sport |
| Unify `hooks/` vs `git/hooks/` | Medium | One tree |
| `DOT_QUIET` / less emoji on `dot` | Low | Agents prefer `-m` / plain text |
| Age-encrypted secrets | Optional | Not blocking |

## Explicit non-goals

- Multi-shell (fish) support  
- Perfect multi-chat resume beyond agent native continue flags  
- Pane scrollback capture in tmux-resurrect  

## Contributor path

```bash
bats tests/bats/*.bats   # or: make test
./bin/dot check
./bin/dot restart status
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
