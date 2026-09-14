# Technical debt

Prefer deleting dead code over rewriting it.

## Phase status

| Phase | Status | Notes |
|-------|--------|-------|
| 0 | Done | Cheap deletes + CI clean-room |
| 1 | Done | `just` owns tasks; 2 profiles |
| 2 | Done | mise + Brewfile/apt; chezmoi-strict; `install.sh` ~487 lines |
| Skills/rules audit | Done | Dropped scaffolds + dead agent surface; Cursor has no in-repo rules |

## Package contract (SSOT)

| Layer | Owns |
|-------|------|
| `mise.toml` | Pinned CLIs / runtimes |
| `config/platform/Brewfile` | macOS platform + AI casks |
| `config/platform/apt.txt` / `pacman.txt` | Linux platform |
| `scripts/install-*.sh` | herdr, mosh helpers |
| chezmoi (`home/`) | `$HOME` — required |

## Agent surface (kept lean)

| Keep | Dropped |
|------|---------|
| `config/claude/{commands,skills,agents}` (generic) | `api-service-scaffold` skill |
| `bin/ai` + `_agent` wrappers | dead `config/agents/agents.zsh` + examples |
| `docs/forge.md` + `forge.zsh` (live on nova) | `project-orchestrator` / `index-analyzer` agents |
| fleet profile (probation) | app-scaffold / fleet-dashboard cosplay |

## Still optional

| Item | Priority | Notes |
|------|----------|--------|
| Fleet profile | Medium | Delete by **2026-12-14** if `claw-relay` / OpenClaw extras unused |
| Move `forge.zsh` → forge-mono | Low | When public tree should not carry FORGE |
| `moshi-hook` | Optional | Phone Live Activities |

## Explicit non-goals

- Multi-shell (fish)
- tmux park / agent-restart
- App scaffolds in user-global skills
- Bespoke CLI frameworks / tools.yaml
- In-repo `.cursor/rules` (use `AGENTS.md` + Cursor user rules)

## Contributor path

```bash
just smoke
just test
just check
```

See [AGENTS.md](../AGENTS.md) and [ARCHITECTURE.md](../ARCHITECTURE.md).
