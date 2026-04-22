#!/usr/bin/env bash
# =============================================================================
# Documentation CLI
# Lightweight wrapper for docs/ management
# =============================================================================

DOCS_DIR="${DOTFILES_DIR:-$HOME/dotfiles}/docs"

# Documentation CLI interface
docs_cli() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        "check")
            # Verify docs/INDEX.md and docs/index.json are up-to-date
            local before_md after_md before_json after_json
            if [[ -f "$DOCS_DIR/INDEX.md" ]]; then
                before_md=$(shasum "$DOCS_DIR/INDEX.md" 2>/dev/null | awk '{print $1}')
            fi
            if [[ -f "$DOCS_DIR/index.json" ]]; then
                before_json=$(shasum "$DOCS_DIR/index.json" 2>/dev/null | awk '{print $1}')
            fi
            (cd "$DOTFILES_DIR" && bash scripts/generate-index.sh) >/dev/null 2>&1 || true
            if [[ -f "$DOCS_DIR/INDEX.md" ]]; then
                after_md=$(shasum "$DOCS_DIR/INDEX.md" 2>/dev/null | awk '{print $1}')
            fi
            if [[ -f "$DOCS_DIR/index.json" ]]; then
                after_json=$(shasum "$DOCS_DIR/index.json" 2>/dev/null | awk '{print $1}')
            fi
            if [[ "$before_md" != "$after_md" || "$before_json" != "$after_json" ]]; then
                echo "Docs index is stale. Run: scripts/generate-index.sh" >&2
                return 1
            else
                echo "Docs index is up to date."
                return 0
            fi
            ;;
        "search")
            local query="${1:-}"
            if [[ -z "$query" ]]; then
                echo "Usage: dot docs search <query>"
                return 1
            fi
            grep -rin "$query" "$DOCS_DIR"/*.md 2>/dev/null || echo "No results for: $query"
            ;;
        "list")
            echo "Documentation files:"
            ls -1 "$DOCS_DIR"/*.md 2>/dev/null | while read -r f; do
                echo "  $(basename "$f")"
            done
            ;;
        "open")
            local file="${1:-INDEX.md}"
            [[ "$file" != *.md ]] && file="${file}.md"
            if [[ -f "$DOCS_DIR/$file" ]]; then
                ${EDITOR:-nvim} "$DOCS_DIR/$file"
            else
                echo "Not found: $DOCS_DIR/$file"
                return 1
            fi
            ;;
        "index")
            (cd "$DOTFILES_DIR" && bash scripts/generate-index.sh)
            echo "Index regenerated."
            ;;
        "help"|*)
            cat << 'EOF'
Documentation Commands

USAGE:
    dot docs <command> [args]

COMMANDS:
    check          Verify docs index is up to date
    search <query> Search all docs for a term
    list           List all documentation files
    open [file]    Open a doc file in $EDITOR
    index          Regenerate docs/INDEX.md and index.json
EOF
            ;;
    esac
}

export -f docs_cli 2>/dev/null || true
