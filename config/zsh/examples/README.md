# ZSH Configuration Examples

These files are **templates and examples** — not loaded automatically. They show how
to extend the dotfiles for specific machines or workflows. Copy and adapt them to fit
your own setup.

## Files

| File | Purpose |
|------|---------|
| `node-macos-template.zsh` | Example config for a macOS node (aliases, project dirs, node-specific tools) |
| `node-linux-template.zsh` | Example config for a Linux node with agent resource limits |
| `fleet-dashboard.zsh` | Multi-node fleet visibility functions (requires Tailscale) |
| `task-router.zsh` | Route tasks to specific nodes by type (heavy/ios/docs/etc.) |
| `forge-tools.zsh` | Project portfolio management aliases |
| `forge-portfolio.zsh` | Directory navigation for a multi-project portfolio |

## How to use

1. Copy the template file to `config/zsh/<your-node-name>.zsh`
2. Customize the variables at the top (node name, RAM, roles, paths)
3. It will be sourced automatically by `.zshrc` based on hostname:
   ```zsh
   # .zshrc sources config/zsh/<hostname>.zsh automatically
   _DOTFILES_NODE="${$(hostname -s)#code-}"
   [[ -f "$ZSH_CONFIG_DIR/${_DOTFILES_NODE}.zsh" ]] && source "$ZSH_CONFIG_DIR/${_DOTFILES_NODE}.zsh"
   ```

## Fleet setup

For multi-machine fleet features (`fleet-dashboard.zsh`, `task-router.zsh`):

- All nodes must be on the same Tailscale network
- Set `DOTFILES_FLEET_NODES` in `~/.env.local` with your node names
- Each node should have its own `config/zsh/<hostname>.zsh`
- See `docs/forge.md` for fleet setup documentation
