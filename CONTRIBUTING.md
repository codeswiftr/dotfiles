# 🤝 Contributing to Modern Dotfiles

Welcome! We're thrilled you're interested in contributing to this project. Our goal is to build the most friendly, high-performance, and agentic dotfiles for modern developers—especially those who love keyboard-centric workflows and cutting-edge stacks.

## 🚀 Getting Started

1. **Fork the repository** on GitHub.
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git
   cd dotfiles
   ```
3. **Install and test locally**:
   ```bash
   ./install.sh install full --dev
   ./tests/test_runner.sh
   ```

## 🎨 Code Style & Configuration Conventions

- **Shell (Zsh):** Use `shellcheck` and `shfmt` for linting/formatting. Prefer explicit, readable options. Document all custom aliases and functions.
- **Tmux:** Use Ctrl-a as prefix, enable true color and mouse support, start windows/panes at 1, keep config modular and well-commented.
- **Neovim (Lua):** Progressive tier system, modular config, language-specific tab/indent settings, document all custom commands/keymaps, provide user feedback.
- **General:** Group/sort imports and config sections, avoid unused imports/options, prefer explicit/documented configuration, keep functions small, document public APIs and user-facing commands.

See [AGENTS.md](AGENTS.md) for full style guidelines and commit conventions.

## 🤖 Agentic Workflow Automation

- **Gemini CLI Review:**  
  Run `gemini review --diff` before every commit to get instant feedback and suggestions.
- **Commit Process:**  
  Use conventional commit messages and always reference Gemini review in your PRs.
- **Test/Lint Hooks:**  
  All commits are validated by automated hooks (security, syntax, structure, commit message, and testing).  
  Run `./tests/test_runner.sh`, `shellcheck`, and `yamllint` before committing.
  - **Install shellcheck and yamllint first:**
    ```bash
    brew install shellcheck yamllint   # macOS
    sudo apt install shellcheck yamllint  # Ubuntu/Debian
    ```
- **Documentation:**  
  See [AGENTS.md](AGENTS.md) for full workflow details and commit conventions.

## 🌍 Accessibility & Internationalization

- All workflows are keyboard-first; mouse/trackpad is optional.
- Shortcuts are designed for US, UK, and most EU layouts. For non-standard layouts, remap keys using Karabiner-Elements (macOS) or xmodmap (Linux).
- High-contrast themes available (see [Theme Guide](docs/themes.md)).
- If you spot accessibility or i18n issues, please open an issue or PR!

## 🧑‍💻 Code Style & Conventions

- **Shell:** Use `shellcheck` and `shfmt` for linting/formatting.
- **Python:** PEP8, explicit imports, type hints, descriptive names.
- **JS/TS:** ES6 imports, camelCase, Prettier.
- **Swift:** `swift-format --lint .`, Apple naming.
- **General:** Keep functions small, document public APIs, avoid unused imports.

See [AGENTS.md](AGENTS.md) for full style guidelines.

## 🧪 Testing & Linting

- Run all tests: `./tests/test_runner.sh`
- Shell lint: `find . -name "*.sh" -exec shellcheck {} \;`
- YAML lint: `find . -name "*.yaml" -o -name "*.yml" | xargs yamllint`
- See [AGENTS.md](AGENTS.md) for more.
- **Test results:**
  - Review summary in `tests/results/` after running the test suite.
  - If tests fail, check troubleshooting guides and open an issue or PR to help improve coverage.

## 📝 Commit & PR Guidelines

- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
  ```
  type(scope): short description
  ```
  Example: `feat(tmux): add streamlined keybindings`
- Always run tests before committing/pushing.
- Reference Gemini CLI review in your PR if possible.

## 🙌 How to Contribute & Friendly Encouragement

- All contributions are welcome—bug fixes, docs, tests, refactors, and new features!
- If you're unsure where to start, open an issue or join a discussion.
- We value clear communication, kindness, and learning together.
- **See [docs/README.md](docs/README.md) for all guides and onboarding.**
- If you find outdated guides, legacy configs, or documentation debt, please open an issue or PR and add them to [docs/technical-debt.md](docs/technical-debt.md)!

**Happy coding! 🚀**

