#!/bin/bash
# ============================================================================
# FORGE Development Layout
# Tmux session for FORGE MVP portfolio development
# Usage: forge-layout.sh [project-name] [domain]
# ============================================================================

set -e

PROJECT="${1:-interview-simulator}"
DOMAIN="${2:-my-domain}"
FORGE_ROOT="${FORGE_ROOT:-$HOME/work/FORGE}"
SESSION="forge-${PROJECT}"

# Resolve project path
if [[ -d "$FORGE_ROOT/$DOMAIN/$PROJECT" ]]; then
    PROJECT_ROOT="$FORGE_ROOT/$DOMAIN/$PROJECT"
elif [[ -d "$FORGE_ROOT/$PROJECT" ]]; then
    PROJECT_ROOT="$FORGE_ROOT/$PROJECT"
else
    # Try to find it
    PROJECT_ROOT=$(find "$FORGE_ROOT" -maxdepth 3 -type d -name "$PROJECT" | head -1)
    if [[ -z "$PROJECT_ROOT" ]]; then
        echo "❌ Project not found: $PROJECT"
        echo "Usage: forge-layout.sh [project-name] [domain]"
        echo "Example: forge-layout.sh my-project my-domain"
        exit 1
    fi
fi

BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

echo "🚀 Starting FORGE session: $SESSION"
echo "   Project: $PROJECT_ROOT"

# Kill existing session if it exists
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Create new session with FORGE root as starting point
tmux new-session -d -s "$SESSION" -c "$FORGE_ROOT"

# ============================================================================
# Window 1: Backend (FastAPI)
# ============================================================================
tmux rename-window -t "$SESSION:1" 'backend'

if [[ -d "$BACKEND_DIR" ]]; then
    tmux send-keys -t "$SESSION:1" "cd $BACKEND_DIR" C-m
    tmux send-keys -t "$SESSION:1" "echo '🐍 Backend: $BACKEND_DIR'" C-m

    # Check if venv needs activation
    if [[ -f "$BACKEND_DIR/pyproject.toml" ]]; then
        tmux send-keys -t "$SESSION:1" "uv sync 2>/dev/null || true" C-m
        tmux send-keys -t "$SESSION:1" "echo ''" C-m
        tmux send-keys -t "$SESSION:1" "echo '▶ Run: uv run fastapi dev'" C-m
    fi
else
    tmux send-keys -t "$SESSION:1" "cd $PROJECT_ROOT" C-m
    tmux send-keys -t "$SESSION:1" "echo '⚠️  No backend directory found'" C-m
fi

# ============================================================================
# Window 2: Frontend (Vite/React/Lit)
# ============================================================================
tmux new-window -t "$SESSION" -n 'frontend'

if [[ -d "$FRONTEND_DIR" ]]; then
    tmux send-keys -t "$SESSION:2" "cd $FRONTEND_DIR" C-m
    tmux send-keys -t "$SESSION:2" "echo '📦 Frontend: $FRONTEND_DIR'" C-m

    if [[ -f "$FRONTEND_DIR/package.json" ]]; then
        tmux send-keys -t "$SESSION:2" "bun install 2>/dev/null || npm install 2>/dev/null || true" C-m
        tmux send-keys -t "$SESSION:2" "echo ''" C-m
        tmux send-keys -t "$SESSION:2" "echo '▶ Run: bun run dev'" C-m
    fi
else
    tmux send-keys -t "$SESSION:2" "cd $PROJECT_ROOT" C-m
    tmux send-keys -t "$SESSION:2" "echo '⚠️  No frontend directory found'" C-m
fi

# ============================================================================
# Window 3: Tests
# ============================================================================
tmux new-window -t "$SESSION" -n 'tests'

if [[ -d "$BACKEND_DIR" ]]; then
    tmux send-keys -t "$SESSION:3" "cd $BACKEND_DIR" C-m
    tmux send-keys -t "$SESSION:3" "echo '🧪 Tests: $BACKEND_DIR'" C-m
    tmux send-keys -t "$SESSION:3" "echo ''" C-m
    tmux send-keys -t "$SESSION:3" "echo '▶ Run: uv run pytest -v'" C-m
    tmux send-keys -t "$SESSION:3" "echo '▶ Watch: uv run pytest-watch'" C-m
else
    tmux send-keys -t "$SESSION:3" "cd $PROJECT_ROOT" C-m
fi

# ============================================================================
# Window 4: Claude Code / AI
# ============================================================================
tmux new-window -t "$SESSION" -n 'claude'
tmux send-keys -t "$SESSION:4" "cd $PROJECT_ROOT" C-m
tmux send-keys -t "$SESSION:4" "echo '🤖 Claude Code: $PROJECT_ROOT'" C-m
tmux send-keys -t "$SESSION:4" "echo ''" C-m
tmux send-keys -t "$SESSION:4" "echo '▶ Run: claude'" C-m

# ============================================================================
# Window 5: Git/Docs
# ============================================================================
tmux new-window -t "$SESSION" -n 'docs'
tmux send-keys -t "$SESSION:5" "cd $FORGE_ROOT" C-m
tmux send-keys -t "$SESSION:5" "echo '📚 Docs & Git: $FORGE_ROOT'" C-m
tmux send-keys -t "$SESSION:5" "echo ''" C-m
tmux send-keys -t "$SESSION:5" "git status" C-m

# ============================================================================
# Window 6: Deploy (Railway + Cloudflare)
# ============================================================================
tmux new-window -t "$SESSION" -n 'deploy'
tmux send-keys -t "$SESSION:6" "cd $PROJECT_ROOT" C-m
tmux send-keys -t "$SESSION:6" "echo '🚀 Deploy: $PROJECT_ROOT'" C-m
tmux send-keys -t "$SESSION:6" "echo ''" C-m
tmux send-keys -t "$SESSION:6" "echo '▶ Backend:  railway up'" C-m
tmux send-keys -t "$SESSION:6" "echo '▶ Frontend: wrangler pages deploy dist'" C-m
tmux send-keys -t "$SESSION:6" "echo '▶ Logs:     railway logs'" C-m

# ============================================================================
# Select first window and attach
# ============================================================================
tmux select-window -t "$SESSION:1"

echo "✅ Session ready: $SESSION"
echo ""
echo "Windows:"
echo "  1. backend   - FastAPI development"
echo "  2. frontend  - Vite/React/Lit development"
echo "  3. tests     - pytest runner"
echo "  4. claude    - AI assistance"
echo "  5. docs      - Git & documentation"
echo "  6. deploy    - Railway & Cloudflare"
echo ""

# Attach to session
tmux attach-session -t "$SESSION"
