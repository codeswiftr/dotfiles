#!/usr/bin/env bash

# FastAPI/Uvicorn development helper
set -euo pipefail

print_help() {
  cat <<'EOF'
Usage: dev-api.sh [--app <module_or_file>] [--host <host>] [--port <port>] [--no-open]

Starts a FastAPI/Uvicorn dev server using the best available toolchain:
- Prefers `fastapi dev` (uses `uv run` if available and pyproject present)
- Falls back to `uvicorn --reload`

Options:
  --app <value>   Module or file entry (e.g., app/main.py or app.main:app)
  --host <host>   Host to bind (default: 127.0.0.1)
  --port <port>   Port to bind (default: 8000)
  --no-open       Do not open browser to /docs
  -h, --help      Show help

Auto-detection:
- If --app not provided, tries: app/main.py, main.py, api/main.py
  For uvicorn, module syntax will be app.main:app when possible.

EOF
}

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8000}"
ENTRY=""
NO_OPEN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)
      ENTRY="$2"; shift 2;;
    --host)
      HOST="$2"; shift 2;;
    --port)
      PORT="$2"; shift 2;;
    --no-open)
      NO_OPEN="true"; shift;;
    -h|--help)
      print_help; exit 0;;
    *)
      echo "Unknown argument: $1" >&2; print_help; exit 1;;
  esac
done

detect_entry() {
  local cand
  for cand in "app/main.py" "api/main.py" "main.py"; do
    if [[ -f "$cand" ]]; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

to_module_syntax() {
  # Convert path like app/main.py -> app.main:app
  local path="$1"
  local base
  base="${path%.py}"
  base="${base//\//.}"
  echo "$base:app"
}

open_docs() {
  local url="http://${HOST}:${PORT}/docs"
  if [[ "$NO_OPEN" == "true" ]]; then
    echo "ℹ️  Docs available at: $url"
    return 0
  fi
  if command -v open >/dev/null 2>&1; then
    (sleep 1; open "$url") &
  elif command -v xdg-open >/dev/null 2>&1; then
    (sleep 1; xdg-open "$url") &
  else
    echo "ℹ️  Docs available at: $url"
  fi
}

# Resolve entry
if [[ -z "$ENTRY" ]]; then
  if ENTRY=$(detect_entry); then :; else
    cat <<'EON'
💡 Could not detect a FastAPI entrypoint.
   Provide one with --app <app/main.py or module:app>.
   Examples:
     ./scripts/dev-api.sh --app app/main.py
     ./scripts/dev-api.sh --app app.main:app
EON
    exit 0
  fi
fi

RUNNER=""
if [[ -f "pyproject.toml" ]] && command -v uv >/dev/null 2>&1; then
  RUNNER="uv run"
fi

open_docs

if command -v fastapi >/dev/null 2>&1; then
  # fastapi dev accepts file path entries
  if [[ "$ENTRY" == *.py ]] || [[ -f "$ENTRY" ]]; then
    exec ${RUNNER:-} fastapi dev "$ENTRY" --host "$HOST" --port "$PORT"
  else
    # If module syntax provided, convert to file if possible
    if [[ "$ENTRY" == *:* ]]; then
      # Try uvicorn instead for module syntax
      exec ${RUNNER:-} uvicorn "$ENTRY" --reload --host "$HOST" --port "$PORT"
    fi
    echo "❌ Unsupported --app format for fastapi dev: $ENTRY" >&2
    exit 1
  fi
fi

if command -v uvicorn >/dev/null 2>&1; then
  if [[ "$ENTRY" == *.py ]] || [[ -f "$ENTRY" ]]; then
    ENTRY=$(to_module_syntax "$ENTRY")
  fi
  exec ${RUNNER:-} uvicorn "$ENTRY" --reload --host "$HOST" --port "$PORT"
fi

cat <<'EOI'
⚠️  Neither `fastapi` nor `uvicorn` found.
   Tips:
     uv add fastapi uvicorn[standard]
     or pip install fastapi uvicorn[standard]
EOI
exit 0

