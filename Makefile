.PHONY: help api-run lint-py format-py dev-web build-ios

help:
	@echo "Available targets:"
	@echo "  api-run     Start FastAPI/Uvicorn dev server (scripts/dev-api.sh)"
	@echo "  lint-py     Run Python lint (ruff)"
	@echo "  format-py   Run Python format (ruff format)"
	@echo "  dev-web     Start web dev server (scripts/dev-web.sh)"
	@echo "  build-ios   iOS build helper (scripts/dev-ios.sh build)"

api-run:
	@./scripts/dev-api.sh

lint-py:
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check . ; \
	else \
		echo "ruff not found. Install with: uv tool install ruff || pip install ruff" ; \
		false ; \
	fi

format-py:
	@if command -v ruff >/dev/null 2>&1; then \
		ruff format . && ruff check --fix . ; \
	else \
		echo "ruff not found. Install with: uv tool install ruff || pip install ruff" ; \
		false ; \
	fi

dev-web:
	@./scripts/dev-web.sh

build-ios:
	@./scripts/dev-ios.sh build

