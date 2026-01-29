# FORGE Workflow

FORGE is an optional, portfolio-focused workflow layer. It is loaded only when
`FORGE_ROOT` exists on disk.

## Setup

1. Create or set a root directory:

```bash
export FORGE_ROOT="$HOME/work/FORGE"
mkdir -p "$FORGE_ROOT"
```

2. Enable secrets locally:

```bash
cp config/zsh/secrets.zsh.example config/zsh/secrets.zsh
```

3. Reload the shell:

```bash
source ~/.zshrc
```

## Commands

```bash
forge                 # Pick a project with fzf
forge api-name         # Jump directly to a project
fdom                   # List domains
fdom my-domain-dev     # Jump to a domain
forge-env .env.local   # Load project env
forge-check-env        # Validate key env vars
forge-api 8000         # Run FastAPI server
forge-web 5173         # Run Vite server
forge-status           # Show project counts
forge-tmux             # Start FORGE tmux layout
ft                     # Alias for forge-tmux
```

## Dependencies

Recommended tools for the best experience:
- `fzf` for interactive project picking
- `fd` for fast directory search (fallbacks available)
- `eza` for previews (optional)
- `uv` for FastAPI projects
- `bun` for Vite projects

If a tool is missing, the functions print a clear install hint.
