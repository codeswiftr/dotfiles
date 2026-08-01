# Documentation hub

Start here. Prefer live commands and layout docs over old narrative guides.

## Essential

| Doc | For |
|-----|-----|
| [../README.md](../README.md) | Install, features, profiles |
| [../ARCHITECTURE.md](../ARCHITECTURE.md) | Layout, bin/PATH, modes, tool ownership |
| [../AGENTS.md](../AGENTS.md) | Short agent entry (commands + conventions) |
| [agents.md](agents.md) | Agent-safe shell, wrappers (`_claude`, `ai`) |
| [configuration.md](configuration.md) | Where config files live |
| [testing.md](testing.md) | bats suite |
| [getting-started.md](getting-started.md) | First steps |
| [troubleshooting.md](troubleshooting.md) | Common issues |
| [technical-debt.md](technical-debt.md) | Known debt / cleanup backlog |

## Topic guides

| Doc | Topic |
|-----|--------|
| [security.md](security.md) | Secrets, scanners, AI exposure |
| [performance.md](performance.md) | Shell / editor speed |
| [neovim.md](neovim.md) | Neovim tiers and keys |
| [tmux-quick-reference.md](tmux-quick-reference.md) | Tmux bindings |
| [git-hooks.md](git-hooks.md) | Pre-commit / hooks |
| [themes.md](themes.md) | Appearance |
| [ai-workflows.md](ai-workflows.md) | AI tooling (may lag `ai` CLI — prefer `ai --help`) |
| [forge.md](forge.md) | FORGE operator notes |
| [ios-development.md](ios-development.md) | iOS helpers |
| [web-development.md](web-development.md) | Web helpers |
| [advanced.md](advanced.md) | Advanced usage |

## CLI truth

```bash
./bin/dot --help          # live help (SSOT)
bats tests/bats/*.bats    # tests
make test
chezmoi apply             # links (source: home/)
```

Do **not** treat historical help snapshots as authoritative.

## Contributing

See [../CONTRIBUTING.md](../CONTRIBUTING.md). Before commits: `bats tests/bats/*.bats`, `shellcheck`, `yamllint` when available.
