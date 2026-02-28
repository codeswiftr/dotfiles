# FORGE Node Lead Setup Runbook

This runbook covers setting up a machine as a FORGE node lead orchestrator.

## Prerequisites

- macOS or Linux
- dotfiles repository installed
- Node.js (for QMD)
- Go (for Forge CLI)

## Quick Setup

```bash
# 1. Create FORGE root directory
export FORGE_ROOT="$HOME/work/FORGE"
mkdir -p "$FORGE_ROOT"

# 2. Clone FORGE portfolio (if not already)
git clone <forge-repo-url> "$FORGE_ROOT"

# 3. Create user config
cp ~/dotfiles/config/forge/.forgerc ~/.forgerc
```

## Configuration

Edit `~/.forgerc`:

```bash
# FORGE repository root
FORGE_ROOT="$HOME/work/FORGE"

# Node identifier (auto-detected from hostname if not set)
FORGE_NODE="gaea"  # or "trinity", "oracle", etc.

# Command Center URL (for xnode operations)
# FORGE_CC_URL="http://100.70.79.45:8080"

# Webhook token (set here or in secrets)
# FORGE_WEBHOOK_TOKEN=""
```

## Tool Installation

### Forge CLI

```bash
# Install via Go
go install github.com/forge-portfolio/forge@latest

# Or download binary to ~/.local/bin
mkdir -p ~/.local/bin
# Place forge binary there
```

### QMD (Documentation Search)

```bash
npm install -g @forge/qmd
```

## Verification

Run the built-in check:

```bash
forge-ready
```

Expected output:

```
🔧 FORGE Environment Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ FORGE_ROOT: /Users/you/work/FORGE
✅ QMD: x.y.z
✅ Forge CLI: forge, version 2.0.0
✅ FORGE_NODE: gaea

✅ Ready for FORGE development!
```

## Node Identification

Nodes are identified by hostname or `FORGE_NODE` env var:

| Node | Role | Description |
|------|------|-------------|
| gaea | Lead | Primary orchestrator |
| trinity | Worker | Compute node |
| oracle | Worker | Data processing |

## Common Operations

### Fleet Management

```bash
forge fleet status     # Check fleet health
forge dispatch <task>  # Dispatch task to fleet
```

### Documentation Search

```bash
qs "topic"           # Quick BM25 search
qf "pattern"         # Find files by name
qv "complex query"   # Vector search
qu                   # Update index
```

### Development

```bash
forge                # Pick project with fzf
forge api-name       # Jump to project
forge-status         # Show project counts
forge-tmux           # Start FORGE tmux layout
```

## Troubleshooting

### FORGE_NODE not detected

```bash
# Set explicitly in ~/.forgerc
echo 'FORGE_NODE="gaea"' >> ~/.forgerc
source ~/.zshrc
```

### Forge CLI not found

```bash
# Check PATH
echo $PATH | tr ':' '\n' | grep local

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

### QMD not working

```bash
# Check npm global bin
npm config get prefix

# Reinstall if needed
npm install -g @forge/qmd
```

## Related Files

- `config/forge/.forgerc` - Default configuration template
- `config/zsh/forge-tools.zsh` - Shell integration
- `config/zsh/forge.zsh` - FORGE aliases and functions
- `docs/forge.md` - FORGE workflow documentation
