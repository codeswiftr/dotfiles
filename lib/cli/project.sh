#!/usr/bin/env bash
# ============================================================================
# DOT CLI - Project Management
# Thin wrappers around upstream scaffolding tools
# ============================================================================

dot_project() {
    local subcommand="${1:-}"
    shift || true

    case "$subcommand" in
        "init")      project_init "$@" ;;
        "switch")    project_switch "$@" ;;
        "list")      project_list_templates ;;
        "-h"|"--help"|"") show_project_help ;;
        *)
            print_error "Unknown project subcommand: $subcommand"
            echo "Run 'dot project --help' for available commands."
            return 1
            ;;
    esac
}

# Initialize new project using upstream scaffolding tools
project_init() {
    local template_type="${1:-}"
    local project_name="${2:-}"

    if [[ -z "$template_type" ]]; then
        project_list_templates
        echo ""
        echo -n "Enter project type: "
        read -r template_type
    fi

    if [[ -z "$project_name" ]]; then
        echo -n "Enter project name: "
        read -r project_name
    fi

    if [[ -z "$project_name" ]]; then
        print_error "Project name is required"
        return 1
    fi

    if [[ -d "$project_name" ]]; then
        print_error "Directory '$project_name' already exists"
        return 1
    fi

    case "$template_type" in
        "fastapi"|"python-api")
            _require_cmd uv || return 1
            uv init "$project_name" --python 3.12
            cd "$project_name" && uv add fastapi uvicorn && uv add --dev pytest ruff
            ;;
        "python")
            _require_cmd uv || return 1
            uv init "$project_name" --python 3.12
            cd "$project_name" && uv add --dev pytest ruff
            ;;
        "react")
            _require_cmd_any bun npm || return 1
            if command -v bun &>/dev/null; then
                bun create react-app "$project_name" --template typescript
            else
                npx create-react-app "$project_name" --template typescript
            fi
            ;;
        "nextjs"|"next")
            _require_cmd_any bun npm || return 1
            if command -v bun &>/dev/null; then
                bun create next-app "$project_name" --typescript --tailwind --app
            else
                npx create-next-app@latest "$project_name" --typescript --tailwind --app
            fi
            ;;
        "node")
            _require_cmd_any bun npm || return 1
            mkdir -p "$project_name" && cd "$project_name"
            if command -v bun &>/dev/null; then
                bun init -y && bun add -d typescript @types/node
            else
                npm init -y && npm install -D typescript @types/node
            fi
            ;;
        "rust")
            _require_cmd cargo || return 1
            cargo new "$project_name"
            ;;
        "go"|"golang")
            _require_cmd go || return 1
            mkdir -p "$project_name" && cd "$project_name" && go mod init "$project_name"
            ;;
        "ios"|"swift")
            _require_cmd swift || return 1
            swift package init --type library --name "$project_name"
            ;;
        *)
            print_error "Unknown template: $template_type"
            echo "Run 'dot project list' to see available templates"
            return 1
            ;;
    esac

    print_success "Project '$project_name' created!"
}

# Switch between projects (zoxide + fzf)
project_switch() {
    if ! command -v fzf >/dev/null 2>&1 || ! command -v zoxide >/dev/null 2>&1; then
        print_error "fzf and zoxide required for project switching"
        print_info "Install with: brew install fzf zoxide"
        return 1
    fi

    local selected_dir
    selected_dir=$(zoxide query --list | fzf --prompt="Select project: " --height=40% --layout=reverse)
    if [[ -n "$selected_dir" ]]; then
        print_info "Switching to: $selected_dir"
        cd "$selected_dir" || return 1
    fi
}

project_list_templates() {
    echo "Available project templates:"
    echo ""
    echo "  fastapi      FastAPI REST API (uv)"
    echo "  python       Python project (uv)"
    echo "  react        React + TypeScript (bun/npm)"
    echo "  nextjs       Next.js + TypeScript (bun/npm)"
    echo "  node         Node.js + TypeScript (bun/npm)"
    echo "  rust         Rust project (cargo)"
    echo "  go           Go project (go mod)"
    echo "  ios          Swift package (swift)"
}

# Helpers
_require_cmd() {
    command -v "$1" &>/dev/null || { print_error "$1 is required but not installed"; return 1; }
}

_require_cmd_any() {
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null && return 0
    done
    print_error "One of $* is required but none are installed"
    return 1
}

show_project_help() {
    cat << 'EOF'
dot project - Project scaffolding

USAGE:
    dot project <command> [options]

COMMANDS:
    init <type> [name]    Create project using upstream tools
    list                  List available templates
    switch                Switch projects (fzf + zoxide)

TEMPLATES:
    fastapi, python, react, nextjs, node, rust, go, ios

EXAMPLES:
    dot project init fastapi my-api
    dot project init nextjs my-app
    dot project switch
EOF
}
