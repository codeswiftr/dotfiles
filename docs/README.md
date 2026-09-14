# Documentation hub

Start here. Prefer live commands over long guides.

## Essential

| Doc | For |
|-----|-----|
| [../README.md](../README.md) | **Install** (one curl command) + daily commands |
| [../ARCHITECTURE.md](../ARCHITECTURE.md) | Layout, bin/PATH, modes, tool ownership |
| [../AGENTS.md](../AGENTS.md) | Short agent entry |
| [getting-started.md](getting-started.md) | First hour after install |
| [agents.md](agents.md) | Agent-safe shell, wrappers, Moshi |
| [configuration.md](configuration.md) | Where config lives |
| [testing.md](testing.md) | bats / `just test` |
| [troubleshooting.md](troubleshooting.md) | Common issues |
| [technical-debt.md](technical-debt.md) | Cleanup backlog + Phase 0 freeze |

## Topic guides (optional)

| Doc | Topic |
|-----|--------|
| [neovim.md](neovim.md) | Neovim tiers |
| [git-hooks.md](git-hooks.md) | Hooks |
| [forge.md](forge.md) | FORGE notes (probation) |
| [advanced.md](advanced.md) | Advanced usage |

## Live truth

```bash
# Fresh machine
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/main/scripts/bootstrap.sh | bash

# Already cloned
cd ~/dotfiles && ./setup

just --list
just smoke
just check
just --list
```

Do **not** treat historical help snapshots as authoritative.
