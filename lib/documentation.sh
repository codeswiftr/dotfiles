#!/usr/bin/env bash
# =============================================================================
# Documentation CLI — lightweight docs/ helpers
# Hub: docs/README.md (no generated INDEX)
# =============================================================================

DOCS_DIR="${DOTFILES_DIR:-$HOME/dotfiles}/docs"

docs_cli() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        "check")
            if [[ -f "$DOCS_DIR/README.md" && -f "${DOTFILES_DIR:-$HOME/dotfiles}/AGENTS.md" ]]; then
                echo "Docs hub OK: docs/README.md + AGENTS.md"
                return 0
            fi
            echo "Missing docs hub files" >&2
            return 1
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
            local file="${1:-README.md}"
            [[ "$file" != *.md ]] && file="${file}.md"
            if [[ -f "$DOCS_DIR/$file" ]]; then
                ${EDITOR:-nvim} "$DOCS_DIR/$file"
            else
                echo "Not found: $DOCS_DIR/$file"
                return 1
            fi
            ;;
        "help"|*)
            cat << 'EOF'
Documentation Commands

USAGE:
    dot docs <command> [args]

COMMANDS:
    check          Verify docs hub files exist
    search <query> Search all docs for a term
    list           List all documentation files
    open [file]    Open a doc file in $EDITOR (default: README.md)
EOF
            ;;
    esac
}
