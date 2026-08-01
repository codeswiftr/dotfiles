# 🛠️ Technical Debt & Refactoring Guide

This document tracks known technical debt, legacy code/configs, and refactor opportunities in the dotfiles project. Contributors are encouraged to help address these items!

If you find outdated guides, legacy configs, or documentation debt, please open an issue or PR and add them here. See [README.md](../README.md) and [CONTRIBUTING.md](../CONTRIBUTING.md) for more ways to help!

## ✅ Phase 1 modernization (2026-07-30)

- Restored real `~/.local/bin` (was symlink to repo `bin/` landfill)
- Repo `bin/` is whitelist scripts only; bats enforces no Mach-O / no absolute `/Users/` paths
- Chezmoi `sourceDir` → `~/dotfiles/home`; install.sh chezmoi fallback now actually runs manual linker
- Tracked `.zshrc` is a thin loader; host bits in `config/zsh/nova.zsh`; fleet in `config/profiles/fleet/`
- AGENTS.md / CLAUDE.md / ARCHITECTURE.md / Makefile aligned with bats

## ✅ Phase 2a/2b (2026-08-01)

- Tools branch driven only by `DOTFILES_MODE` (`full` → optimized; `minimal`/`agent` → minimal)
- Modern aliases SSOT in `aliases.zsh`; tools modules are init-only
- `dot test` / docs / hooks point at bats (no `test_runner.sh`)

## ✅ Phase 2c + Phase 3 (2026-08-01)

- `mise.toml` owns pinned CLIs; `tools.yaml` uses `provided_by: mise` + platform packages only
- Docs hub rewritten; empty docs scaffolds / INDEX / help snapshots / reviews pruned
- `docs/configuration.md` aligned with real tree

## Next (optional)

- PATH dedupe (mise vs brew vs `~/.local/bin` duplicates)
- Slim `install.sh` / large `lib/cli/*` modules
- Age encryption for secrets (optional)

## 🚨 Legacy Scripts & Configs

- **Legacy install logic:**
  - scripts/bootstrap.sh and install.sh contain legacy code paths for older platforms and tools.
  - Migration plan: Refactor to use only modern toolchain (mise, uv, bun, etc.), remove deprecated logic.

- **Neovim config paths:**
  - Some legacy configs in config/nvim/lua/core/ and docs/legacy-backup-20250714/.
  - Migration plan: Consolidate to streamlined init-streamlined.lua and modular Lua configs.

- **Tmux mouse mode:**
  - Enabled by default; some users prefer it off for pure keyboard workflows.
  - Migration plan: Make mouse mode opt-in, document in README and troubleshooting.

## 📝 Documentation Debt

- Some guides (legacy-backup-20250714/*) are outdated or duplicated.
- Migration plan: Archive legacy docs, update cross-links, and ensure all new docs are discoverable from docs/README.md.

### Deletion candidates (post-merge)
- `docs/legacy-backup-20250714/**` — content superseded by consolidated docs. Action: fold any remaining unique details into current guides, then remove folder.
- `src/--help/` — empty placeholder. Action: populate with CLI examples or remove.
- Generated artifacts: `tests/results/**`, `.pytest_cache/**`. Action: exclude from index, add cleanup script (e.g., `scripts/cleanup-artifacts.sh`).

#### New candidates
- `docs/shell-performance-guide.md` — content duplicated in `docs/performance.md`. Action: merge any remaining unique tips, then delete.

### Consolidation tasks
- Merge `docs/shell-performance-guide.md` into `docs/performance.md` (single comprehensive performance guide).
- Fold `docs/nvim-quick-reference.md` into `docs/neovim.md` as a Quick Reference section.
- Review `docs/navigation.md` versus Neovim/tmux quick refs to remove duplication and cross-link.

## ⚡ Toolchain Consistency

- Some templates/scripts may use older tools (pyenv, nvm, etc.) instead of mise, uv, bun.
- Migration plan: Audit all templates/scripts and update to use only the intended modern toolchain.

## 🧪 Testing & Linting Coverage

- Not all scripts/configs are covered by tests or linting.
- Migration plan: Keep bats (`make test`) as SSOT; expand coverage; keep shellcheck/yamllint in CI/local docs.

## 🤖 Agentic Workflow Automation

- Gemini CLI review is recommended before every commit, but not enforced.
- Migration plan: Document agentic workflow in CONTRIBUTING.md and encourage referencing Gemini review in PRs.

## 🙌 How Contributors Can Help

- Pick any item above and open a PR to refactor, update, or document.
- If you find new technical debt, add it to this file and open an issue.
- Always run tests and lint before submitting changes.
- See [README.md](../README.md) and [CONTRIBUTING.md](../CONTRIBUTING.md) for onboarding, workflow, and documentation guidelines.
- If you spot documentation debt, legacy configs, or unclear instructions, please help improve them and add to this file!

## ✅ Recent Improvements Completed (September 2025)

### Critical Fixes
- **✅ Syntax Errors**: Fixed bash syntax errors in `lib/performance-monitor.sh` and `lib/documentation.sh`
- **✅ Test Infrastructure**: Stabilized `test_docs.sh` and CLI contract tests  
- **✅ Tmux Configuration**: Reduced from 111 to 24 essential bindings, restored standard behavior
- **✅ Epic 1 Testing Foundation**: CLI contracts passing, test runners stabilized

### Configuration Improvements  
- **Tmux**: `config/tmux/tmux.conf` now loads `tmux-minimal.conf` (24 bindings)
- **Complex Config**: Preserved as `config/tmux/tmux-complex.conf` for advanced users
- **Testing**: Fixed test framework inconsistencies and timeouts

### Implementation Quality
- **Performance Monitor**: Fixed zsh glob compatibility issues
- **Documentation System**: Resolved nested HERE document syntax errors
- **CLI Reliability**: All basic `dot` commands now function correctly

---

**Thank you for helping keep this project modern, clean, and friendly!**

---

## 🔧 Configuration and UX Debt (New)

### Tmux keybinding conflicts ✅ **RESOLVED**
- ~~Analysis files (`config/tmux/tmux-analysis.md`, `config/tmux/tmux-dx-plan.md`) identify critical overrides (e.g., `Ctrl-a c/d`).~~
- **✅ COMPLETED**: Restored defaults for `c` (new-window) and `d` (detach). Created `tmux-minimal.conf` with only 24 essential bindings.
- **Configuration**: `config/tmux/tmux.conf` now uses streamlined config. Complex config preserved as `tmux-complex.conf`.

### Neovim tier enforcement
- Ensure Tier 1 stays <200ms; reduce plugin count and verify `config/nvim/lua/tiers/*` reflect intended sets.
- Action: Audit actual plugin set vs docs; align and document in `docs/neovim.md`.

### Installer docs drift
- `INSTALL-DECLARATIVE.md` now references `./install.sh`. Keep in sync with script flags and profiles.
- Action: Add a short “sync checklist” in PR template for installer changes.
