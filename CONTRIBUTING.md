# Contributing

## Getting started

```bash
git clone https://github.com/<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup                 # or: ./install.sh
just smoke
just check
```

Upstream one-liner (this repo):

```bash
curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/main/scripts/bootstrap.sh | bash
```

## Style

- Shell: `shellcheck` / `shfmt`; keep `bin/` scripts-only
- Herdr: prefix `Ctrl-a`; config in `config/herdr/config.toml`
- Neovim: 2 tiers; document keymaps
- Commits: conventional (`feat:`, `fix:`, `docs:`, `chore:`)

See [AGENTS.md](AGENTS.md) and [ARCHITECTURE.md](ARCHITECTURE.md).

## Before you push

```bash
just smoke
just lint          # when shellcheck/yamllint/ruff are installed
just --list   # if you touched the CLI
```

## Docs

Update [README.md](README.md) or [docs/getting-started.md](docs/getting-started.md) when install or daily commands change. Doc hub: [docs/README.md](docs/README.md).

## PRs

Use the PR template. Prefer small diffs that delete dead code over large rewrites.
