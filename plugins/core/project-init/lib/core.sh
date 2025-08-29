#!/usr/bin/env bash
# =============================================================================
# Project Init Plugin - Rapid project setup with templates and tooling
# =============================================================================

# Plugin configuration
PROJECT_INIT_TEMPLATES_DIR="${HOME}/.local/share/dotfiles/plugins/project-init/templates"
PROJECT_INIT_CONFIG_DIR="${HOME}/.config/dotfiles/plugins/project-init"

# Plugin initialization
project_init_init() {
    echo "🚀 Project Init plugin initialized"
    
    # Create directories
    mkdir -p "$PROJECT_INIT_TEMPLATES_DIR" "$PROJECT_INIT_CONFIG_DIR"
    
    # Set up default templates
    setup_default_templates
}

# Plugin cleanup
project_init_cleanup() {
    echo "🚀 Project Init plugin cleaned up"
}

# Main project init command
project_init_main() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        "new"|"create")
            project_init_new "$@"
            ;;
        "template"|"templates")
            project_templates_main "$@"
            ;;
        "scaffold")
            project_scaffold_main "$@"
            ;;
        "list"|"ls")
            project_init_list
            ;;
        "config")
            project_init_config "$@"
            ;;
        "help"|"-h"|"--help"|"")
            project_init_help
            ;;
        *)
            echo "❌ Unknown project init command: $subcommand"
            echo "Run 'dot init help' for available commands"
            return 1
            ;;
    esac
}

# Create new project
project_init_new() {
    local template_type="${1:-basic}"
    local project_name="${2}"
    local project_path="${3:-$project_name}"
    
    if [[ -z "$project_name" ]]; then
        echo "❌ Project name required"
        echo "Usage: dot init new <template> <name> [path]"
        return 1
    fi
    
    echo "🚀 Creating new project: $project_name"
    echo "📋 Template: $template_type"
    echo "📁 Path: $project_path"
    echo ""
    
    # Check if directory already exists
    if [[ -d "$project_path" ]]; then
        echo "❌ Directory already exists: $project_path"
        return 1
    fi
    
    # Create project from template
    if ! create_project_from_template "$template_type" "$project_name" "$project_path"; then
        echo "❌ Failed to create project from template: $template_type"
        return 1
    fi
    
    # Initialize git if requested
    if ask_yes_no "Initialize git repository?"; then
        cd "$project_path" || return 1
        git init
        
        # Set up initial commit
        if ask_yes_no "Create initial commit?"; then
            git add .
            git commit -m "Initial commit: $project_name project setup

Created with dotfiles project-init plugin using $template_type template.

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
        fi
        
        cd - >/dev/null || return 1
    fi
    
    echo ""
    echo "✅ Project created successfully!"
    echo "📁 Location: $project_path"
    echo ""
    echo "🚀 Next steps:"
    echo "  cd $project_path"
    echo "  # Start developing your project"
    
    # Show template-specific next steps
    show_template_next_steps "$template_type" "$project_path"
}

# Create project from template
create_project_from_template() {
    local template_type="$1"
    local project_name="$2" 
    local project_path="$3"
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/$template_type"
    
    # Check if template exists
    if [[ ! -d "$template_dir" ]]; then
        echo "❌ Template not found: $template_type"
        echo "Available templates:"
        list_available_templates
        return 1
    fi
    
    echo "📋 Using template: $template_type"
    
    # Create project directory
    mkdir -p "$project_path"
    
    # Copy template files
    if [[ -d "$template_dir" ]]; then
        cp -r "$template_dir"/. "$project_path/"
    fi
    
    # Process template variables
    process_template_variables "$project_path" "$project_name"
    
    # Run template-specific setup
    if [[ -f "$project_path/.template/setup.sh" ]]; then
        echo "🔧 Running template setup..."
        cd "$project_path" || return 1
        bash ".template/setup.sh" "$project_name"
        
        # Clean up template files
        rm -rf ".template"
        cd - >/dev/null || return 1
    fi
    
    return 0
}

# Process template variables in files
process_template_variables() {
    local project_path="$1"
    local project_name="$2"
    local current_date
    current_date=$(date +"%Y-%m-%d")
    local current_year
    current_year=$(date +"%Y")
    
    # Find all template files (exclude binary files and .git)
    find "$project_path" -type f -not -path "*/\.git/*" -not -name "*.png" -not -name "*.jpg" -not -name "*.gif" -print0 | \
    while IFS= read -r -d '' file; do
        # Skip binary files
        if file "$file" | grep -q "text"; then
            # Replace template variables
            sed -i.bak \
                -e "s/{{PROJECT_NAME}}/$project_name/g" \
                -e "s/{{PROJECT_NAME_UPPER}}/${project_name^^}/g" \
                -e "s/{{PROJECT_NAME_LOWER}}/${project_name,,}/g" \
                -e "s/{{DATE}}/$current_date/g" \
                -e "s/{{YEAR}}/$current_year/g" \
                -e "s/{{AUTHOR}}/${USER}/g" \
                "$file" 2>/dev/null || true
                
            # Remove backup file
            rm -f "$file.bak" 2>/dev/null || true
        fi
    done
}

# Show template-specific next steps
show_template_next_steps() {
    local template_type="$1"
    local project_path="$2"
    
    case "$template_type" in
        "node"|"nodejs"|"javascript")
            echo "  npm install           # Install dependencies"
            echo "  npm run dev           # Start development server"
            echo "  npm test              # Run tests"
            ;;
        "python")
            echo "  python -m venv venv   # Create virtual environment"
            echo "  source venv/bin/activate  # Activate environment"
            echo "  pip install -r requirements.txt  # Install dependencies"
            echo "  python -m pytest     # Run tests"
            ;;
        "go"|"golang")
            echo "  go mod tidy           # Download dependencies"
            echo "  go run main.go        # Run the application"
            echo "  go test ./...         # Run tests"
            ;;
        "rust")
            echo "  cargo build           # Build the project"
            echo "  cargo run             # Run the application"
            echo "  cargo test            # Run tests"
            ;;
        "react")
            echo "  npm install           # Install dependencies"
            echo "  npm start             # Start development server"
            echo "  npm run build         # Build for production"
            ;;
        "vue")
            echo "  npm install           # Install dependencies"
            echo "  npm run serve         # Start development server"
            echo "  npm run build         # Build for production"
            ;;
    esac
}

# List available templates
list_available_templates() {
    echo "📋 Available Templates:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$PROJECT_INIT_TEMPLATES_DIR" ]]; then
        echo "  No templates found"
        return
    fi
    
    for template_dir in "$PROJECT_INIT_TEMPLATES_DIR"/*; do
        if [[ -d "$template_dir" ]]; then
            local template_name
            template_name=$(basename "$template_dir")
            local description=""
            
            # Try to get description from template
            if [[ -f "$template_dir/.template/description.txt" ]]; then
                description=$(cat "$template_dir/.template/description.txt" 2>/dev/null || echo "")
            fi
            
            if [[ -n "$description" ]]; then
                echo "  📄 $template_name - $description"
            else
                echo "  📄 $template_name"
            fi
        fi
    done
}

# Project scaffolding
project_scaffold_main() {
    local structure_type="${1:-basic}"
    
    echo "🏗️  Scaffolding project structure: $structure_type"
    
    case "$structure_type" in
        "basic")
            scaffold_basic_structure
            ;;
        "web")
            scaffold_web_structure
            ;;
        "api")
            scaffold_api_structure
            ;;
        "library")
            scaffold_library_structure
            ;;
        "cli")
            scaffold_cli_structure
            ;;
        *)
            echo "❌ Unknown structure type: $structure_type"
            echo "Available types: basic, web, api, library, cli"
            return 1
            ;;
    esac
}

# Scaffold basic structure
scaffold_basic_structure() {
    echo "📁 Creating basic project structure..."
    
    mkdir -p {src,docs,tests,config,scripts}
    
    # Create basic files
    cat > README.md << 'EOF'
# {{PROJECT_NAME}}

Project description goes here.

## Getting Started

Instructions for getting started with the project.

## Usage

How to use the project.

## Contributing

Guidelines for contributing to the project.

## License

MIT
EOF
    
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
vendor/
venv/
env/

# Build outputs
dist/
build/
target/
*.exe
*.dll
*.so
*.dylib

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment
.env
.env.local
.env.*.local

# Cache
.cache/
*.cache
EOF
    
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) {{YEAR}} {{AUTHOR}}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    
    echo "✅ Basic structure created"
}

# Template management
project_templates_main() {
    local action="${1:-list}"
    shift || true
    
    case "$action" in
        "list"|"ls")
            list_available_templates
            ;;
        "add"|"install")
            project_template_add "$@"
            ;;
        "remove"|"rm"|"delete")
            project_template_remove "$@"
            ;;
        "create"|"new")
            project_template_create "$@"
            ;;
        "help"|"-h"|"--help")
            project_templates_help
            ;;
        *)
            echo "❌ Unknown template command: $action"
            echo "Run 'dot templates help' for available commands"
            return 1
            ;;
    esac
}

# Add/install template
project_template_add() {
    local template_source="$1"
    local template_name="$2"
    
    if [[ -z "$template_source" ]]; then
        echo "❌ Template source required"
        echo "Usage: dot templates add <source> [name]"
        return 1
    fi
    
    echo "📥 Installing template from: $template_source"
    
    # Handle different source types
    if [[ "$template_source" =~ ^https?:// ]] || [[ "$template_source" =~ ^git@ ]]; then
        # Git repository
        install_template_from_git "$template_source" "$template_name"
    elif [[ -d "$template_source" ]]; then
        # Local directory
        install_template_from_directory "$template_source" "$template_name"
    else
        echo "❌ Unsupported template source: $template_source"
        return 1
    fi
}

# Install template from git
install_template_from_git() {
    local git_url="$1"
    local template_name="$2"
    
    if [[ -z "$template_name" ]]; then
        template_name=$(basename "$git_url" .git)
    fi
    
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/$template_name"
    
    echo "📦 Installing template: $template_name"
    
    if [[ -d "$template_dir" ]]; then
        echo "❌ Template already exists: $template_name"
        return 1
    fi
    
    git clone "$git_url" "$template_dir"
    
    # Clean up git history
    rm -rf "$template_dir/.git"
    
    echo "✅ Template installed: $template_name"
}

# Install template from directory
install_template_from_directory() {
    local source_dir="$1"
    local template_name="$2"
    
    if [[ -z "$template_name" ]]; then
        template_name=$(basename "$source_dir")
    fi
    
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/$template_name"
    
    echo "📂 Installing template: $template_name"
    
    if [[ -d "$template_dir" ]]; then
        echo "❌ Template already exists: $template_name"
        return 1
    fi
    
    cp -r "$source_dir" "$template_dir"
    
    echo "✅ Template installed: $template_name"
}

# Remove template
project_template_remove() {
    local template_name="$1"
    
    if [[ -z "$template_name" ]]; then
        echo "❌ Template name required"
        echo "Usage: dot templates remove <name>"
        return 1
    fi
    
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/$template_name"
    
    if [[ ! -d "$template_dir" ]]; then
        echo "❌ Template not found: $template_name"
        return 1
    fi
    
    echo "🗑️  Removing template: $template_name"
    rm -rf "$template_dir"
    echo "✅ Template removed: $template_name"
}

# Setup default templates
setup_default_templates() {
    if [[ -d "$PROJECT_INIT_TEMPLATES_DIR" ]] && [[ "$(ls -A "$PROJECT_INIT_TEMPLATES_DIR" 2>/dev/null)" ]]; then
        return 0  # Templates already exist
    fi
    
    echo "📋 Setting up default templates..."
    
    # Create basic template
    create_basic_template
    
    # Create Node.js template
    create_nodejs_template
    
    # Create Python template
    create_python_template
    
    echo "✅ Default templates created"
}

# Create basic template
create_basic_template() {
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/basic"
    mkdir -p "$template_dir/.template"
    
    cat > "$template_dir/.template/description.txt" << 'EOF'
Basic project template with standard structure
EOF
    
    cat > "$template_dir/.template/setup.sh" << 'EOF'
#!/bin/bash
echo "Setting up basic project: $1"
# Additional setup steps can go here
EOF
    chmod +x "$template_dir/.template/setup.sh"
    
    # Create template structure
    mkdir -p "$template_dir"/{src,docs,tests,config}
    
    cat > "$template_dir/README.md" << 'EOF'
# {{PROJECT_NAME}}

A new project created with the dotfiles project-init plugin.

## Description

Brief description of your project.

## Getting Started

### Prerequisites

List any dependencies or requirements.

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd {{PROJECT_NAME_LOWER}}

# Install dependencies
# Add your installation commands here
```

## Usage

Explain how to use your project.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Created with dotfiles project-init plugin on {{DATE}}*
EOF
}

# Create Node.js template
create_nodejs_template() {
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/nodejs"
    mkdir -p "$template_dir/.template"
    
    cat > "$template_dir/.template/description.txt" << 'EOF'
Node.js project template with modern tooling
EOF
    
    cat > "$template_dir/package.json" << 'EOF'
{
  "name": "{{PROJECT_NAME_LOWER}}",
  "version": "1.0.0",
  "description": "{{PROJECT_NAME}} - A Node.js project",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  },
  "keywords": [],
  "author": "{{AUTHOR}}",
  "license": "MIT",
  "devDependencies": {
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "nodemon": "^2.0.0"
  },
  "dependencies": {}
}
EOF
    
    mkdir -p "$template_dir/src" "$template_dir/tests"
    
    cat > "$template_dir/src/index.js" << 'EOF'
/**
 * {{PROJECT_NAME}} - Main Entry Point
 * Created: {{DATE}}
 * Author: {{AUTHOR}}
 */

console.log('Hello from {{PROJECT_NAME}}!');

module.exports = {
  // Export your functions here
};
EOF

    cat > "$template_dir/tests/index.test.js" << 'EOF'
/**
 * {{PROJECT_NAME}} - Tests
 */

describe('{{PROJECT_NAME}}', () => {
  test('should work', () => {
    expect(true).toBe(true);
  });
});
EOF
}

# Create Python template
create_python_template() {
    local template_dir="$PROJECT_INIT_TEMPLATES_DIR/python"
    mkdir -p "$template_dir/.template"
    
    cat > "$template_dir/.template/description.txt" << 'EOF'
Python project template with virtual environment and testing
EOF
    
    cat > "$template_dir/requirements.txt" << 'EOF'
# Production dependencies

# Development dependencies (install with: pip install -r requirements-dev.txt)
EOF

    cat > "$template_dir/requirements-dev.txt" << 'EOF'
# Development dependencies
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
mypy>=0.900
EOF

    cat > "$template_dir/setup.py" << 'EOF'
from setuptools import setup, find_packages

setup(
    name="{{PROJECT_NAME_LOWER}}",
    version="0.1.0",
    description="{{PROJECT_NAME}} - A Python project",
    author="{{AUTHOR}}",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        # Add your dependencies here
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "black>=22.0.0",
            "flake8>=4.0.0",
            "mypy>=0.900",
        ]
    },
)
EOF

    mkdir -p "$template_dir/src/{{PROJECT_NAME_LOWER}}" "$template_dir/tests"
    
    cat > "$template_dir/src/{{PROJECT_NAME_LOWER}}/__init__.py" << 'EOF'
"""
{{PROJECT_NAME}} - A Python project

Created: {{DATE}}
Author: {{AUTHOR}}
"""

__version__ = "0.1.0"
EOF

    cat > "$template_dir/src/{{PROJECT_NAME_LOWER}}/main.py" << 'EOF'
"""
{{PROJECT_NAME}} - Main Module
"""


def main():
    """Main entry point."""
    print("Hello from {{PROJECT_NAME}}!")


if __name__ == "__main__":
    main()
EOF

    cat > "$template_dir/tests/test_main.py" << 'EOF'
"""
{{PROJECT_NAME}} - Tests
"""

import pytest
from src.{{PROJECT_NAME_LOWER}}.main import main


def test_main():
    """Test main function."""
    # Your tests here
    assert True
EOF

    cat > "$template_dir/pyproject.toml" << 'EOF'
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[tool.black]
line-length = 88
target-version = ['py38']

[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-ra -q"
testpaths = ["tests"]

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
EOF
}

# List projects
project_init_list() {
    echo "📋 Recent Projects:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # This would maintain a list of created projects
    # For now, just show current directory projects
    
    echo "🚧 Project listing feature coming soon"
    echo "💡 For now, use: ls -la to see local projects"
}

# Configuration
project_init_config() {
    echo "⚙️  Project Init Configuration:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Templates Directory: $PROJECT_INIT_TEMPLATES_DIR"
    echo "Config Directory: $PROJECT_INIT_CONFIG_DIR"
    echo ""
    echo "Available Templates:"
    list_available_templates
}

# Help functions
project_init_help() {
    cat << 'EOF'
🚀 Project Init - Rapid Project Setup

USAGE:
    dot init <command> [options]

COMMANDS:
    new <template> <name> [path]    Create new project from template
    scaffold <type>                 Scaffold project structure
    list                           List recent projects
    templates <action>             Manage templates
    config                         Show configuration
    
TEMPLATES:
    basic                          Basic project structure
    nodejs                         Node.js project with modern tooling
    python                         Python project with virtual env
    
SCAFFOLD TYPES:
    basic                          Basic directory structure
    web                            Web application structure
    api                            API/backend structure
    library                        Library/package structure
    cli                            CLI application structure

EXAMPLES:
    # Create new projects
    dot init new basic my-project
    dot init new nodejs my-node-app
    dot init new python my-python-lib ./projects/my-lib
    
    # Scaffold structure in existing directory
    dot init scaffold web
    
    # Template management
    dot init templates list
    dot init templates add https://github.com/user/my-template.git
    dot init templates remove my-template
    
    # Configuration
    dot init config

PROJECT STRUCTURE:
    my-project/
    ├── src/                       Source code
    ├── tests/                     Test files
    ├── docs/                      Documentation
    ├── config/                    Configuration files
    ├── scripts/                   Build/deployment scripts
    ├── README.md                  Project documentation
    ├── LICENSE                    License file
    └── .gitignore                Git ignore rules

TEMPLATE VARIABLES:
    {{PROJECT_NAME}}               Project name as provided
    {{PROJECT_NAME_UPPER}}         Project name in uppercase
    {{PROJECT_NAME_LOWER}}         Project name in lowercase
    {{DATE}}                       Current date (YYYY-MM-DD)
    {{YEAR}}                       Current year
    {{AUTHOR}}                     Current user

For more information: https://docs.dotfiles.dev/plugins/project-init
EOF
}

# Template help
project_templates_help() {
    cat << 'EOF'
📋 Template Management

USAGE:
    dot templates <action> [options]

ACTIONS:
    list                           List available templates
    add <source> [name]           Install template from source
    remove <name>                 Remove installed template
    create <name>                 Create new custom template

SOURCES:
    • Git repository URL
    • Local directory path

EXAMPLES:
    dot templates list
    dot templates add https://github.com/user/react-template.git
    dot templates add ./my-template custom-name
    dot templates remove react-template
    dot templates create my-custom-template

CREATING TEMPLATES:
    Templates are directories containing:
    • Project files and structure
    • .template/ directory (optional) with:
      - description.txt (template description)
      - setup.sh (post-creation setup script)
    
    Use template variables like {{PROJECT_NAME}} in files
    which will be replaced during project creation.

For more information: https://docs.dotfiles.dev/plugins/project-init/templates
EOF
}

# Utility function
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        read -p "$question [Y/n]: " -r response
        [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
    else
        read -p "$question [y/N]: " -r response
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Export functions for plugin system
export -f project_init_init project_init_cleanup project_init_main
export -f project_scaffold_main project_templates_main