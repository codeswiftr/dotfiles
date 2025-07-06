 # PLAN: Enhanced Terminal Setup for FastAPI, Lit PWA & SwiftUI Development

 ## Product Requirements Document (PRD)

 ### 1. Overview
Provide a unified terminal environment tailored to a full‑stack developer working with:
- Python (FastAPI, Uvicorn, Ruff)
- JavaScript/TypeScript (Lit‑based PWAs)
- Swift (SwiftUI)
The setup should streamline toolchain management, in‑editor LSP support, automation of common workflows, and maintain code quality.

### 2. Goals
- Seamless management of Python, Node.js, and Swift toolchains per project
- Fast, context‑aware shell (Zsh) with advanced completion and prompt
- Rich LSP integration in Vim for Python, JS/TS, and Swift
- One‑command workflows for spinning up API servers, frontend builds, and iOS previews
- Consistent linting and formatting enforced on every commit
- Preserved tmux workspaces and layouts across sessions

### 3. Success Metrics
- <10s to launch a tmux workspace with API, PWA, and iOS panes
- Real‑time linting & autocomplete for FastAPI, Lit components, and SwiftUI in Vim
- 90% reduction in manual dev commands via aliases/scripts/Makefile
- 0 style violations detected by pre‑commit hooks on merge

### 4. Stakeholders
- Primary: Full‑stack developer (FastAPI, Lit, SwiftUI)
- Secondary: Onboarding engineers, DevOps team

### 5. Assumptions & Constraints
- Supported OS: macOS (Homebrew) and Linux (apt)
- Editor: Vim with vim‑plug; multiplexer: tmux; shell: Zsh
- No changes to existing CI/CD pipelines in this phase

## Main Tasks

### Epic 1: Version & Toolchain Management
1. Integrate `asdf` for Python, Node.js, and Swift toolchains
2. Install respective plugins and document per‑project `.tool-versions`

### Epic 2: Shell & Prompt Enhancements
1. Migrate to `fast-syntax-highlighting` for Zsh
2. Add `zsh-autocomplete` (or equivalent fuzzy completion)
3. Evaluate/adopt the `starship` prompt for language and Git context

### Epic 3: Vim LSP & Plugin Configuration
1. Configure `coc-pyright` and `coc-ruff` (or ALE) for Python
2. Configure `coc-tsserver`, `coc-prettier`, `coc-eslint` for Lit PWAs
3. Add HTTP testing plugin (`rest.nvim` or `vim-http-client`)
4. Integrate `coc-sourcekit` (SourceKit‑LSP) for SwiftUI support

### Epic 4: Aliases & Development Scripts
1. Define common aliases in `.zshrc`: e.g., `uv`, `ruff`, `pyfmt`, `pwa`, `swiftui`
2. Create helper scripts:
   - `scripts/dev-api.sh`: launch Uvicorn + open docs
   - `scripts/dev-web.sh`: run Lit development server
   - `scripts/dev-ios.sh`: build/run SwiftUI preview or Simulator

### Epic 5: Makefile Enhancements
1. Add targets:
   - `make api-run` → Uvicorn with reload
   - `make lint-py` → Ruff checks
   - `make format-py` → Black & isort
   - `make dev-web` → PWA dev server
   - `make build-ios` → Xcode build for SwiftUI

### Epic 6: Tmux Workspace Automation
1. Define a `tmuxinator` (or plain tmux) session file to open panes for API, PWA, and iOS
2. Install and configure `tmux-continuum` for auto-save/restore
3. Extend `status-right`/scripts to display active Python/Node/Swift versions

### Epic 7: Code Quality Hooks
1. Add `pre-commit-config.yaml` with hooks for:
   - `ruff`, `black`, `isort` (Python)
   - `prettier`, `eslint` (JS/TS)
   - `swiftformat`, `swiftlint` (Swift)
2. Document installation and usage of `pre-commit`

### Epic 8: Editor Snippets & Templates
1. Provide snippet collections (UltiSnips or `coc-snippets`) for:
   - FastAPI endpoint boilerplate
   - Lit component scaffolding
   - SwiftUI View templates

---
_This PLAN.md outlines the PRD and the key workstreams needed to level up our terminal environment for multi‑language development._