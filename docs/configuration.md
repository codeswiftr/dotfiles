# ⚙️ Configuration Reference

Overview of configurable areas and where to change them.

## Shell (Zsh)
- Files: `config/zsh/*.zsh`
- Entry points: `config/zsh/core.zsh`, `config/zsh/environment.zsh`
- Performance: `config/zsh/performance.zsh`, `config/zsh/tools-optimized.zsh`
- AI/Agent: `config/zsh/ai*.zsh`

## Tmux
- Files: `config/tmux/*.conf`
- Main: `config/tmux/core.conf` (or `core-simple.conf`)
- Theme: `config/tmux/theme.conf`
- Plugins: `config/tmux/plugins.conf`

## Neovim (Lua)
- Entrypoints: `config/nvim/init.lua` or `init-streamlined.lua`
- Tiers: `config/nvim/lua/tiers/tier{1,2,3}.lua`
- Core: `config/nvim/lua/core/*.lua`
- Languages: `config/nvim/lua/languages/*.lua`

## Tools and Profiles
- Declarative tools config: `config/tools.yaml`
- Templates: `config/templates.yaml` and `templates/**`
- Install: `./install.sh install <profile>`

## Git Hooks
- Scripts: `hooks/*`, installer: `scripts/setup-hooks.sh`
- Docs: `docs/git-hooks.md`

## Themes
- Zsh prompt via Starship (user-level config), tmux themes under `config/tmux/`, Neovim theme in `init.lua`.

## Platform Overrides
- macOS/Linux: `config/platform/*.zsh`

## Environment Variables (selected)
- `DOTFILES_FAST_MODE=1` — ultra-fast shell
- `DOTFILES_PERF_TIMING=true` — startup timing
- `AI_SECURITY_*` — see `docs/security.md`

## FAQ
- Prefer editing files under `config/**` over dotfiles in `$HOME`; installer symlinks appropriately.
