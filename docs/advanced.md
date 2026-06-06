# 🛠️ Advanced Configuration

This guide covers expert customization, modular setup, team deployment, and enterprise policies.

## 🔧 Modular Setup {#modular-setup}
- Keep changes in `~/.config` symlinked from this repo.
- Prefer small, focused files. See `config/zsh/*.zsh`, `config/tmux/*.conf`, `config/nvim/lua/**`.
- Use `config/templates.yaml` and `templates/*` for reproducible scaffolding.

## 👥 Team Setup {#team-setup}
- Standardize profiles via `config/tools.yaml` (minimal/standard/full).
- Encourage contributors to use the same `install.sh install <profile>`.
- Configure hooks with `./scripts/setup-hooks.sh install`.

## 🔐 Security Policies {#enterprise-setup}
- Default to balanced mode; enable strict in corp envs.
- Share policy via env vars in `/etc/profile` or company dotfiles.
- See `docs/security.md#enterprise-security` for variables and audit logging.

## ⚡ Performance Tuning {#advanced-tuning}
- Use Fast Mode for CI and short-lived shells.
- Profile startup with `perf-benchmark-startup` and `perf-profile-startup`.
- For Neovim, profile with `:Lazy profile` and `--startuptime`.

## 🧩 Extending Neovim
- Add plugins in `config/nvim/init.lua` using lazy-loading.
- Keep heavy tools in higher tiers; test Tier 1 startup stays <200ms.

## 🧪 Testing at Scale
- Prefer headless runs in CI: `DOTFILES_MODE=agent`. See
  [Agent Guide](agents.md) for alias and pager behavior.
- Aggregate reports with `test-report` (see `docs/testing.md`).

## 📦 Distribution
- Maintain a fork with org defaults; keep personal overrides out of the repo.
- Use `install.sh --dry-run` to validate upgrades.

## ✅ Checklist
- [ ] Team profile defined in `config/tools.yaml`
- [ ] Hooks installed and passing locally
- [ ] Performance baseline recorded
- [ ] Security policy set and documented
- [ ] Testing commands documented in project READMEs
