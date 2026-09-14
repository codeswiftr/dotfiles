# FORGE

Operator shell helpers live in **forge-mono**, not this public repo:

| What | Where |
|------|--------|
| Shell helpers | `$FORGE_ROOT/shell/forge.zsh` (default `~/work/forge-mono/shell/forge.zsh`) |
| Docs | `docs/OPERATOR_SHELL.md` in forge-mono |

Dotfiles only auto-sources that file on non-SSH shells when the tree exists
(`config/zsh/forge.zsh` is a thin loader). Override `FORGE_ROOT` in `~/.env.local`
if needed.
