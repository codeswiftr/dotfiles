# 🛠️ Technical Debt & Refactoring Guide

This document tracks known technical debt, legacy code/configs, and refactor opportunities in the dotfiles project. Contributors are encouraged to help address these items!

If you find outdated guides, legacy configs, or documentation debt, please open an issue or PR and add them here. See [README.md](../README.md) and [CONTRIBUTING.md](../CONTRIBUTING.md) for more ways to help!

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

## ⚡ Toolchain Consistency

- Some templates/scripts may use older tools (pyenv, nvm, etc.) instead of mise, uv, bun.
- Migration plan: Audit all templates/scripts and update to use only the intended modern toolchain.

## 🧪 Testing & Linting Coverage

- Not all scripts/configs are covered by tests or linting.
- Migration plan: Expand test_runner.sh, add shellcheck/yamllint to CI, and document how contributors can run these locally.

## 🤖 Agentic Workflow Automation

- Gemini CLI review is recommended before every commit, but not enforced.
- Migration plan: Document agentic workflow in CONTRIBUTING.md and encourage referencing Gemini review in PRs.

## 🙌 How Contributors Can Help

- Pick any item above and open a PR to refactor, update, or document.
- If you find new technical debt, add it to this file and open an issue.
- Always run tests and lint before submitting changes.
- See [README.md](../README.md) and [CONTRIBUTING.md](../CONTRIBUTING.md) for onboarding, workflow, and documentation guidelines.
- If you spot documentation debt, legacy configs, or unclear instructions, please help improve them and add to this file!

---

**Thank you for helping keep this project modern, clean, and friendly!**
