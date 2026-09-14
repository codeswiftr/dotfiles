# Dotfiles Management — justfile (modern replacement for Makefile)
# Run `just` without arguments to list available commands.

default:
    @just --list

# =============================================================================
# Setup & Installation
# =============================================================================

# Install dotfiles with standard profile
setup:
    @./install.sh install standard

# Alias for setup
install: setup

# Apply symlinks (via chezmoi or fallback linker)
link:
    @./install.sh link

# Run health check
check *args:
    @./scripts/check.sh {{args}}

# Pull + relink (+ tools unless --self)
update *args:
    @./scripts/update.sh {{args}}

# Reload Herdr config / mise shims
reload:
    @./scripts/reload.sh

# Herdr workspace + agent status
status:
    @command -v herdr >/dev/null && herdr workspace list && herdr agent list || echo "herdr not installed"

# =============================================================================
# Testing & Quality
# =============================================================================

# Run the full test suite (bats)
test:
    @bats tests/bats/*.bats

# Run fast smoke tests only
smoke:
    @bats tests/bats/smoke.bats

# Run all linters (shell, yaml, python)
lint: lint-sh lint-yaml lint-py
    @echo "✅ All linting complete"

# Run shellcheck on active scripts and entrypoints
lint-sh:
    @echo "Running shellcheck..."
    @if command -v shellcheck >/dev/null 2>&1; then \
        shellcheck --rcfile config/shellcheckrc -e SC2034,SC2155,SC2015,SC1094 bin/ai bin/_agent install.sh scripts/check.sh scripts/update.sh scripts/reload.sh scripts/security/*.sh ; \
    else \
        echo "⚠️  shellcheck not installed. Install with: brew install shellcheck" ; \
    fi

# Run yamllint on YAML files
lint-yaml:
    @echo "Running yamllint..."
    @if command -v yamllint >/dev/null 2>&1; then \
        find . \( -name "*.yaml" -o -name "*.yml" \) -type f -not -path "./.git/*" | xargs yamllint --no-warnings -c config/yamllint.yml ; \
    else \
        echo "⚠️  yamllint not installed. Install with: brew install yamllint" ; \
    fi

# Run ruff on Python files
lint-py:
    @if command -v ruff >/dev/null 2>&1; then \
        ruff check . ; \
    else \
        echo "⚠️  ruff not found. Install with: uv tool install ruff || pip install ruff" ; \
    fi

# Format Python files with ruff
format-py:
    @if command -v ruff >/dev/null 2>&1; then \
        ruff format . && ruff check --fix . ; \
    else \
        echo "⚠️  ruff not found. Install with: uv tool install ruff || pip install ruff" ; \
    fi
