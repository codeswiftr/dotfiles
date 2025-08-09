# 🚀 Roadmap (Next 2–4 Weeks)

## 🎯 Objectives
- Compound productivity gains by stabilizing core workflows, reducing friction, and enabling reliable agentic automation.
- Ensure a delightful default experience on macOS/Linux with consistent installs, titles, and tooling.

## 🔝 Top Priorities (Compounding impact)
1. Lint/Test Stability and Scope
   - Narrow shell lint to true shell scripts (shebang detection). Skip non-shell.
   - Add .shellcheckrc and .yamllint.yml with pragmatic defaults.
   - Rename misclassified files (e.g., AppleScript) or explicitly skip in tests.
   - Outcome: fewer false positives, faster CI, higher signal.

2. Declarative Installer Robustness
   - Replace `parse_yaml` in `install.sh` with Python `yaml.safe_load` helper.
   - Normalize Ubuntu installs (prefer apt over snap for core tools like neovim).
   - Add install dry-run validation and summary table.
   - Outcome: predictable installs across platforms, fewer edge failures.

3. Agent Turnkey Setup
   - `dot ai setup --all`: install/configure aider, Claude/Gemini/Copilot CLIs, optional Ollama.
   - Add token checks and a short cheatsheet printout.
   - Document minimal env vars and local-only option.
   - Outcome: immediate agent usefulness post-install.

4. Project Brain (Local Context Index)
   - Create background indexer (ripgrep + ctags + embeddings optional) per project.
   - Surface through `dot ai context` and nvim bindings.
   - Outcome: higher-quality prompts with local, private context.

5. PR Autopilot
   - `dot pr autopilot`: test → summarize → generate commit → branch → PR via `gh` → AI review notes.
   - Outcome: consistent PR quality, reduced overhead.

## ✅ Recently Shipped
- Terminal titles: tmux now sets tab/window titles automatically to `session:window`.
- Zsh integration defers to tmux inside sessions; keeps non-tmux terminals helpful.

## 📦 Implementation Plan
- Week 1
  - Lint/test scoping; add `.shellcheckrc` and `.yamllint.yml`.
  - Rename/skip non-shell scripts in lint tests; fix obvious parse errors.
  - Replace YAML parsing in `install.sh` with Python.
- Week 2
  - Implement `dot ai setup --all` and docs.
  - Add `Project Brain` minimal index and wire to `dot ai context`.
- Week 3
  - Implement `dot pr autopilot` and PR template generator.
  - Add tmux/nvim keybindings for AI actions (explain, test, review).
- Week 4
  - Harden CI across macOS/Ubuntu; smoke tests; nightly checks.
  - Author a contributor guide for agents and humans; examples.

## 🧹 Supporting Tasks
- Normalize shells: mark zsh-specific files with `#!/usr/bin/env zsh` or remove zshisms from bash scripts.
- Trailing space cleanup and pre-commit hooks for md/yaml/shell.
- Document dynamic terminal titles in README and quick refs (done).

## 📊 Success Metrics
- 90% reduction in false-positive lint failures.
- Fresh macOS/Ubuntu install success > 95%.
- Time to “AI-productive” < 5 minutes after install.
- PR creation time reduced by 50%.

