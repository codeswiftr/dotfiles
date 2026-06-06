# FORGE Node Workflow

FORGE support is loaded from `config/zsh/forge.zsh` on local, non-SSH shells.
It is intended for both human operators and agent terminals working on FORGE
nodes.

## Defaults

```bash
FORGE_ROOT="${FORGE_ROOT:-$HOME/work/forge-mono}"
FORGE_LOCAL_API_URL="${FORGE_LOCAL_API_URL:-http://localhost:8081}"
FORGE_HUB_API_URL="${FORGE_HUB_API_URL:-http://prya:8081}"
```

The dotfiles do not export `FORGE_API_URL` globally. Set it per command, or use
`forge-local`, when you intentionally need a specific control plane:

```bash
forge-local status
FORGE_API_URL=http://localhost:8081 forge task list
FORGE_API_URL=http://prya:8081 forge node list
```

This avoids stale shells silently targeting the wrong daemon after a node or hub
restart.

## First Checks

```bash
forge operator status
forge attention
forge gate status
forge task list
forge agent list
```

For local-node resume, use:

```bash
forge-local operator status
forge-node-up-local
forge-local operator status
```

Aliases:

```bash
fop      # forge operator status
flop     # forge-local operator status
fprime   # operator status + attention + gates + tasks + agents
fup      # forge-local node up --no-pull --skip-build
ftl      # forge task list
fal      # forge agent list
fgate    # forge gate status
```

## Dispatch Rules

Use the current FORGE workflow:

```bash
forge task create --title "..." --description "..."
forge task context-pack <task-id> --path ... --doc ... --command ...
forge dispatch send <agent> --file .forge/dispatches/<brief>.md
forge message send <node> "orchestrator directive"
```

Do not use raw `tmux send-keys` for task delivery. The only dotfiles helper that
sends tmux keys is `forge-restart`, and it is for bootstrap/recovery of an
already-known lead pane.

## Useful Recovery

```bash
forge task verify --write-missing-failures --apply
forge task verify --mark-invalid-failures --apply
forge task reconcile
forge task reconcile --repair-missing-contracts --apply
forge check --fast
```

## Local Overrides

Put machine-local changes in `~/.env.local` or `~/.zshrc.local`, for example:

```bash
export FORGE_ROOT="$HOME/work/forge-mono"
export FORGE_LOCAL_API_URL="http://localhost:8081"
export DOTFILES_FORGE_AUTOSTART_TAILSCALE=1
```
