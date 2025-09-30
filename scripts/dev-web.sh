#!/usr/bin/env bash

# Web PWA/Lit/Vite development helper
set -euo pipefail

print_help() {
  cat <<'EOF'
Usage: dev-web.sh [--open] [--port <port>]

Starts a web dev server using the detected package manager:
- Prefers pnpm, then bun, then npm, then yarn
- Runs `run dev` or `vite` if available

Options:
  --open         Attempt to open browser (default: off)
  --port <port>  Port to use (env PORT also respected)
  -h, --help     Show help

Requirements:
- A `package.json` with a `dev` script or Vite installed locally
EOF
}

OPEN_BROWSER="false"
PORT="${PORT:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --open) OPEN_BROWSER="true"; shift;;
    --port) PORT="$2"; shift 2;;
    -h|--help) print_help; exit 0;;
    *) echo "Unknown argument: $1" >&2; print_help; exit 1;;
  esac
done

if [[ ! -f package.json ]]; then
  cat <<'EON'
💡 No package.json found. This script expects a JS/TS project.
   In a web project root, try:
     pnpm create vite myapp --template lit-ts
     cd myapp && pnpm install && pnpm run dev
EON
  exit 0
fi

maybe_open() {
  local url="http://localhost:${PORT:-5173}"
  if [[ "$OPEN_BROWSER" != "true" ]]; then
    echo "ℹ️  Dev server likely at: $url"
    return 0
  fi
  if command -v open >/dev/null 2>&1; then
    (sleep 1; open "$url") &
  elif command -v xdg-open >/dev/null 2>&1; then
    (sleep 1; xdg-open "$url") &
  else
    echo "ℹ️  Dev server likely at: $url"
  fi
}

export BROWSER=${BROWSER:-none}
[[ -n "$PORT" ]] && export PORT

maybe_open

# Prefer pnpm, then bun, npm, yarn
if command -v pnpm >/dev/null 2>&1; then
  exec pnpm run dev
fi

if command -v bun >/dev/null 2>&1; then
  exec bun run dev
fi

if command -v npm >/dev/null 2>&1; then
  exec npm run dev --silent
fi

if command -v yarn >/dev/null 2>&1; then
  exec yarn dev
fi

# Last resort: vite directly if present in node_modules
if [[ -x node_modules/.bin/vite ]]; then
  exec node_modules/.bin/vite
fi

cat <<'EOI'
⚠️  No supported package manager found (pnpm/bun/npm/yarn).
   Install one (e.g., `brew install pnpm`), then try again.
EOI
exit 0

