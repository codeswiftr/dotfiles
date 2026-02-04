.DEFAULT_GOAL := help

.PHONY: help test lint lint-sh lint-yaml lint-py format-py setup install check api-run dev-web build-ios

help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  setup       Install dotfiles with standard profile"
	@echo "  install     Alias for setup"
	@echo "  check       Run health check (dot check)"
	@echo ""
	@echo "Testing & Quality:"
	@echo "  test        Run the full test suite"
	@echo "  lint        Run all linters (shell, yaml, python)"
	@echo "  lint-sh     Run shellcheck on shell scripts"
	@echo "  lint-yaml   Run yamllint on YAML files"
	@echo "  lint-py     Run ruff on Python files"
	@echo "  format-py   Format Python files with ruff"
	@echo ""
	@echo "Development:"
	@echo "  api-run     Start FastAPI/Uvicorn dev server"
	@echo "  dev-web     Start web dev server"
	@echo "  build-ios   iOS build helper"

# =============================================================================
# Setup & Installation
# =============================================================================

setup:
	@./install.sh install standard

install: setup

check:
	@./bin/dot check

# =============================================================================
# Testing & Quality
# =============================================================================

test:
	@./tests/test_runner.sh

lint: lint-sh lint-yaml lint-py
	@echo "✅ All linting complete"

lint-sh:
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find . -name "*.sh" -type f -not -path "./.git/*" -exec shellcheck {} \; ; \
	else \
		echo "⚠️  shellcheck not installed. Install with: brew install shellcheck / apt install shellcheck" ; \
	fi

lint-yaml:
	@echo "Running yamllint..."
	@if command -v yamllint >/dev/null 2>&1; then \
		find . \( -name "*.yaml" -o -name "*.yml" \) -type f -not -path "./.git/*" | xargs yamllint ; \
	else \
		echo "⚠️  yamllint not installed. Install with: brew install yamllint / pip install yamllint" ; \
	fi

lint-py:
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check . ; \
	else \
		echo "⚠️  ruff not found. Install with: uv tool install ruff || pip install ruff" ; \
	fi

format-py:
	@if command -v ruff >/dev/null 2>&1; then \
		ruff format . && ruff check --fix . ; \
	else \
		echo "⚠️  ruff not found. Install with: uv tool install ruff || pip install ruff" ; \
	fi

# =============================================================================
# Development Helpers
# =============================================================================

api-run:
	@./scripts/dev-api.sh

dev-web:
	@./scripts/dev-web.sh

build-ios:
	@./scripts/dev-ios.sh build
