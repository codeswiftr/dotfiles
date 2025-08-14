#!/usr/bin/env bash
set -euo pipefail

# Idempotent installer for unified global Git hooks via pre-commit
# - Sets core.hooksPath to /Users/bogdan/dotfiles/git/hooks
# - Verifies required tools and prints install hints (non-interactive)
# - Safe to re-run

HOOKS_PATH="/Users/bogdan/dotfiles/git/hooks"
GLOBAL_CONFIG="/Users/bogdan/dotfiles/pre-commit-global.yaml"

log() { printf "%s\n" "$*"; }
info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*"; }
err()  { printf "[ERROR] %s\n" "$*"; }

ensure_dir() {
  [ -d "$1" ] || mkdir -p "$1"
}

main() {
  info "Configuring global Git hooks..."

  ensure_dir "$HOOKS_PATH"

  # Write minimal runners if missing
  if [ ! -f "$HOOKS_PATH/pre-commit" ]; then
    warn "Missing $HOOKS_PATH/pre-commit; creating minimal runner"
    install -m 0755 /dev/stdin "$HOOKS_PATH/pre-commit" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$REPO_ROOT"
if command -v pre-commit >/dev/null 2>&1; then
  if [ -f ".pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yml" ]; then
    PRE_COMMIT_COLOR=always pre-commit run --hook-stage pre-commit --color always
  elif [ -f "/Users/bogdan/dotfiles/pre-commit-global.yaml" ]; then
    PRE_COMMIT_COLOR=always pre-commit run --hook-stage pre-commit --color always --config "/Users/bogdan/dotfiles/pre-commit-global.yaml"
  fi
fi
exit 0
EOF
  fi

  if [ ! -f "$HOOKS_PATH/commit-msg" ]; then
    warn "Missing $HOOKS_PATH/commit-msg; creating minimal runner"
    install -m 0755 /dev/stdin "$HOOKS_PATH/commit-msg" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
COMMIT_MSG_FILE="$1"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$REPO_ROOT"
if command -v cz >/dev/null 2>&1; then
  cz check --commit-msg-file "$COMMIT_MSG_FILE"
  exit $?
fi
if command -v pre-commit >/dev/null 2>&1; then
  if [ -f ".pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yml" ]; then
    PRE_COMMIT_COLOR=always pre-commit run --hook-stage commit-msg --color always
  elif [ -f "/Users/bogdan/dotfiles/pre-commit-global.yaml" ]; then
    PRE_COMMIT_COLOR=always pre-commit run --hook-stage commit-msg --color always --config "/Users/bogdan/dotfiles/pre-commit-global.yaml"
  fi
fi
exit 0
EOF
  fi

  if [ ! -f "$HOOKS_PATH/pre-push" ]; then
    warn "Missing $HOOKS_PATH/pre-push; creating minimal runner"
    install -m 0755 /dev/stdin "$HOOKS_PATH/pre-push" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; cd "$REPO_ROOT"
if command -v pre-commit >/dev/null 2>&1; then
  if [ -f ".pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yml" ]; then
    PRE_COMMIT_COLOR=always pre-commit run --hook-stage pre-push --color always
  elif [ -f "/Users/bogdan/dotfiles/pre-commit-global.yaml" ]; then
    PRE_COMMIT_COLOR=always pre-commit run --hook-stage pre-push --color always --config "/Users/bogdan/dotfiles/pre-commit-global.yaml"
  fi
  exit 0
fi
exit 0
EOF
  fi

  # Set global hooks path
  git config --global core.hooksPath "$HOOKS_PATH"
  info "core.hooksPath set to $HOOKS_PATH"

  # Tooling hints
  if ! command -v pre-commit >/dev/null 2>&1; then
    warn "pre-commit not found. Install suggestions:" 
    log "  pipx install pre-commit    # preferred"
    log "  or: pip install --user pre-commit"
  else
    info "pre-commit: $(pre-commit --version 2>/dev/null || echo present)"
    if [ -f "$GLOBAL_CONFIG" ]; then
      info "Global config present: $GLOBAL_CONFIG"
    fi
  fi

  if command -v cz >/dev/null 2>&1; then
    info "commitizen (cz) available for commit-msg checks"
  else
    warn "commitizen not found. Optional install: pipx install commitizen"
  fi

  info "Done. Hooks will now run via pre-commit where configured."
}

main "$@"


