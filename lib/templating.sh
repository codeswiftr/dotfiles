#!/usr/bin/env bash
# =============================================================================
# Advanced Configuration Templating System
# Dynamic configuration generation with context-aware templating
# =============================================================================

# Templating configuration
TEMPLATE_DIR="$DOTFILES_DIR/templates"
TEMPLATE_CACHE_DIR="$HOME/.cache/dotfiles/templates"
TEMPLATE_CONFIG_FILE="$DOTFILES_DIR/config/templates.yaml"

# Template variables
declare -A TEMPLATE_VARS

# Initialize templating system
init_templating() {
    mkdir -p "$TEMPLATE_CACHE_DIR"
    load_template_variables
}

# Load template variables from various sources
load_template_variables() {
    # System information
    TEMPLATE_VARS[OS]="$PLATFORM_OS"
    TEMPLATE_VARS[DISTRO]="$PLATFORM_DISTRO"
    TEMPLATE_VARS[ARCH]="$PLATFORM_ARCH"
    TEMPLATE_VARS[SHELL]="$PLATFORM_SHELL"
    TEMPLATE_VARS[PACKAGE_MANAGER]="$PLATFORM_PACKAGE_MANAGER"
    
    # User information
    TEMPLATE_VARS[USER]="$USER"
    TEMPLATE_VARS[HOME]="$HOME"
    TEMPLATE_VARS[HOSTNAME]="$(hostname)"
    
    # Dotfiles information
    TEMPLATE_VARS[DOTFILES_DIR]="$DOTFILES_DIR"
    TEMPLATE_VARS[CONFIG_DIR]="$(get_config_dir)"
    TEMPLATE_VARS[CACHE_DIR]="$(get_cache_dir)"
    TEMPLATE_VARS[DATA_DIR]="$(get_data_dir)"
    TEMPLATE_VARS[BIN_DIR]="$(get_bin_dir)"
    
    # Git information (if available)
    if git config user.name >/dev/null 2>&1; then
        TEMPLATE_VARS[GIT_NAME]="$(git config user.name)"
        TEMPLATE_VARS[GIT_EMAIL]="$(git config user.email)"
    fi
    
    # Development tools
    TEMPLATE_VARS[EDITOR]="${EDITOR:-vim}"
    TEMPLATE_VARS[BROWSER]="${BROWSER:-firefox}"
    TEMPLATE_VARS[TERMINAL]="${TERM:-xterm-256color}"
    
    # Timestamps
    TEMPLATE_VARS[DATE]="$(date +'%Y-%m-%d')"
    TEMPLATE_VARS[DATETIME]="$(date +'%Y-%m-%d %H:%M:%S')"
    TEMPLATE_VARS[TIMESTAMP]="$(date +%s)"
    
    # Load custom variables from config file
    load_custom_template_vars
}

# Load custom variables from YAML config
load_custom_template_vars() {
    if [[ -f "$TEMPLATE_CONFIG_FILE" ]]; then
        # Parse YAML for custom variables (basic parsing)
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([^:]+):[[:space:]]*(.+)$ ]]; then
                local key="${BASH_REMATCH[1]// /}"
                local value="${BASH_REMATCH[2]}"
                value="${value#\"}"  # Remove leading quote
                value="${value%\"}"  # Remove trailing quote
                TEMPLATE_VARS["$key"]="$value"
            fi
        done < <(grep -E "^[[:space:]]*[^#:].*:" "$TEMPLATE_CONFIG_FILE" 2>/dev/null || true)
    fi
}

# Template processing function
process_template() {
    local template_file="$1"
    local output_file="$2"
    local context="${3:-default}"
    
    if [[ ! -f "$template_file" ]]; then
        echo "Template file not found: $template_file"
        return 1
    fi
    
    echo "🔧 Processing template: $(basename "$template_file")"
    
    # Read template content
    local content
    content=$(cat "$template_file")
    
    # Apply template variables
    content=$(apply_template_variables "$content" "$context")
    
    # Apply conditional blocks
    content=$(process_conditional_blocks "$content")
    
    # Apply loops
    content=$(process_loop_blocks "$content")
    
    # Apply includes
    content=$(process_include_blocks "$content" "$context")
    
    # Create output directory if needed
    mkdir -p "$(dirname "$output_file")"
    
    # Write processed content
    echo "$content" > "$output_file"
    
    echo "✅ Generated: $output_file"
}

# Apply template variables
apply_template_variables() {
    local content="$1"
    local context="$2"
    
    # Replace {{VAR}} patterns
    for var in "${!TEMPLATE_VARS[@]}"; do
        local value="${TEMPLATE_VARS[$var]}"
        content="${content//\{\{$var\}\}/$value}"
        content="${content//\{\{ $var \}\}/$value}"
    done
    
    # Replace environment variables
    content=$(envsubst <<< "$content")
    
    echo "$content"
}

# Process conditional blocks
process_conditional_blocks() {
    local content="$1"
    
    # Process {{#if condition}} blocks
    while [[ "$content" =~ \{\{#if[[:space:]]+([^}]+)\}\}(.*?)\{\{/if\}\} ]]; do
        local condition="${BASH_REMATCH[1]}"
        local block_content="${BASH_REMATCH[2]}"
        local full_match="${BASH_REMATCH[0]}"
        
        if evaluate_condition "$condition"; then
            content="${content/$full_match/$block_content}"
        else
            content="${content/$full_match/}"
        fi
    done
    
    # Process {{#unless condition}} blocks
    while [[ "$content" =~ \{\{#unless[[:space:]]+([^}]+)\}\}(.*?)\{\{/unless\}\} ]]; do
        local condition="${BASH_REMATCH[1]}"
        local block_content="${BASH_REMATCH[2]}"
        local full_match="${BASH_REMATCH[0]}"
        
        if ! evaluate_condition "$condition"; then
            content="${content/$full_match/$block_content}"
        else
            content="${content/$full_match/}"
        fi
    done
    
    echo "$content"
}

# Evaluate template conditions
evaluate_condition() {
    local condition="$1"
    
    # Simple condition evaluation
    case "$condition" in
        "OS == macos"|"OS == 'macos'")
            [[ "$PLATFORM_OS" == "macos" ]]
            ;;
        "OS == linux"|"OS == 'linux'")
            [[ "$PLATFORM_OS" == "linux" ]]
            ;;
        "OS == windows"|"OS == 'windows'")
            [[ "$PLATFORM_OS" == "windows" ]]
            ;;
        "ARCH == x64"|"ARCH == 'x64'")
            [[ "$PLATFORM_ARCH" == "x64" ]]
            ;;
        "ARCH == arm64"|"ARCH == 'arm64'")
            [[ "$PLATFORM_ARCH" == "arm64" ]]
            ;;
        "SHELL == zsh"|"SHELL == 'zsh'")
            [[ "$PLATFORM_SHELL" == "zsh" ]]
            ;;
        "SHELL == bash"|"SHELL == 'bash'")
            [[ "$PLATFORM_SHELL" == "bash" ]]
            ;;
        *)
            # Fallback to shell evaluation for complex conditions
            eval "[[ $condition ]]" 2>/dev/null || false
            ;;
    esac
}

# Process loop blocks
process_loop_blocks() {
    local content="$1"
    
    # Process {{#each array}} blocks
    while [[ "$content" =~ \{\{#each[[:space:]]+([^}]+)\}\}(.*?)\{\{/each\}\} ]]; do
        local array_name="${BASH_REMATCH[1]}"
        local loop_content="${BASH_REMATCH[2]}"
        local full_match="${BASH_REMATCH[0]}"
        
        local result=""
        local array_ref="${array_name}[@]"
        
        if [[ -n "${!array_ref:-}" ]]; then
            for item in "${!array_ref}"; do
                local item_content="$loop_content"
                item_content="${item_content//\{\{this\}\}/$item}"
                item_content="${item_content//\{\{ this \}\}/$item}"
                result+="$item_content"
            done
        fi
        
        content="${content/$full_match/$result}"
    done
    
    echo "$content"
}

# Process include blocks
process_include_blocks() {
    local content="$1"
    local context="$2"
    
    # Process {{>partial}} includes
    while [[ "$content" =~ \{\{>[[:space:]]*([^}]+)\}\} ]]; do
        local partial_name
        partial_name="${BASH_REMATCH[1]// /}"
        local full_match
        full_match="${BASH_REMATCH[0]}"
        
        local partial_file="$TEMPLATE_DIR/partials/$partial_name"
        if [[ ! "$partial_name" =~ \. ]]; then
            partial_file="$partial_file.template"
        fi
        
        if [[ -f "$partial_file" ]]; then
            local partial_content
            partial_content=$(cat "$partial_file")
            partial_content=$(apply_template_variables "$partial_content" "$context")
            content="${content/$full_match/$partial_content}"
        else
            echo "Warning: Partial not found: $partial_file"
            content="${content/$full_match/}"
        fi
    done
    
    echo "$content"
}

# Generate configuration from template
generate_config() {
    local template_name="$1"
    local output_path="$2"
    local context="${3:-default}"
    
    local template_file="$TEMPLATE_DIR/$template_name"
    if [[ ! "$template_name" =~ \. ]]; then
        template_file="$template_file.template"
    fi
    
    if [[ ! -f "$template_file" ]]; then
        echo "Template not found: $template_file"
        return 1
    fi
    
    process_template "$template_file" "$output_path" "$context"
}

# Batch template processing
process_templates() {
    local profile="${1:-default}"
    
    echo "🔧 Processing templates for profile: $profile"
    
    # Process templates based on configuration
    if [[ -f "$TEMPLATE_CONFIG_FILE" ]]; then
        process_templates_from_config "$profile"
    else
        process_templates_from_directory "$profile"
    fi
}

# Process templates from configuration file
process_templates_from_config() {
    local profile="$1"
    
    # This would parse the YAML config and process templates accordingly
    # For now, we'll use a simple approach
    if [[ -d "$TEMPLATE_DIR" ]]; then
        for template in "$TEMPLATE_DIR"/*.template; do
            if [[ -f "$template" ]]; then
                local basename=$(basename "$template" .template)
                local output_file="$HOME/.$basename"
                process_template "$template" "$output_file" "$profile"
            fi
        done
    fi
}

# Process templates from directory structure
process_templates_from_directory() {
    local profile="$1"
    
    if [[ ! -d "$TEMPLATE_DIR" ]]; then
        echo "Template directory not found: $TEMPLATE_DIR"
        return 1
    fi
    
    # Process main templates
    for template in "$TEMPLATE_DIR"/*.template; do
        if [[ -f "$template" ]]; then
            local basename=$(basename "$template" .template)
            local output_file="$HOME/.$basename"
            process_template "$template" "$output_file" "$profile"
        fi
    done
    
    # Process platform-specific templates
    local platform_dir="$TEMPLATE_DIR/$PLATFORM_OS"
    if [[ -d "$platform_dir" ]]; then
        for template in "$platform_dir"/*.template; do
            if [[ -f "$template" ]]; then
                local basename=$(basename "$template" .template)
                local output_file="$HOME/.$basename"
                process_template "$template" "$output_file" "$profile"
            fi
        done
    fi
    
    # Process profile-specific templates
    local profile_dir="$TEMPLATE_DIR/profiles/$profile"
    if [[ -d "$profile_dir" ]]; then
        for template in "$profile_dir"/*.template; do
            if [[ -f "$template" ]]; then
                local basename=$(basename "$template" .template)
                local output_file="$HOME/.$basename"
                process_template "$template" "$output_file" "$profile"
            fi
        done
    fi
}

# Create template from existing config
create_template() {
    local source_file="$1"
    local template_name="$2"
    local template_file="$TEMPLATE_DIR/$template_name.template"
    
    if [[ ! -f "$source_file" ]]; then
        echo "Source file not found: $source_file"
        return 1
    fi
    
    echo "🔧 Creating template from: $source_file"
    
    # Create template directory if needed
    mkdir -p "$TEMPLATE_DIR"
    
    # Copy source file and add template markers
    cp "$source_file" "$template_file"
    
    # Add template header
    local temp_content
    temp_content=$(cat "$template_file")
    
    cat > "$template_file" << EOF
# =============================================================================
# Template: $template_name
# Generated from: $source_file
# Generated on: $(date)
# =============================================================================

$temp_content
EOF
    
    echo "✅ Template created: $template_file"
    echo "💡 Edit the template to add variables like {{USER}}, {{HOME}}, etc."
}

# Validate templates
validate_templates() {
    local template_dir="${1:-$TEMPLATE_DIR}"
    local errors=0
    
    echo "🔍 Validating templates in: $template_dir"
    
    if [[ ! -d "$template_dir" ]]; then
        echo "Template directory not found: $template_dir"
        return 1
    fi
    
    for template in "$template_dir"/*.template; do
        if [[ -f "$template" ]]; then
            echo "Validating: $(basename "$template")"
            
            # Check for unclosed template blocks
            local content
            content=$(cat "$template")
            
            # Check for unmatched if blocks
            local if_count=$(grep -o "{{#if" "$template" | wc -l)
            local endif_count=$(grep -o "{{/if}}" "$template" | wc -l)
            if [[ $if_count -ne $endif_count ]]; then
                echo "  ❌ Unmatched {{#if}} blocks"
                ((errors++))
            fi
            
            # Check for unmatched unless blocks
            local unless_count=$(grep -o "{{#unless" "$template" | wc -l)
            local endunless_count=$(grep -o "{{/unless}}" "$template" | wc -l)
            if [[ $unless_count -ne $endunless_count ]]; then
                echo "  ❌ Unmatched {{#unless}} blocks"
                ((errors++))
            fi
            
            # Check for unmatched each blocks
            local each_count=$(grep -o "{{#each" "$template" | wc -l)
            local endeach_count=$(grep -o "{{/each}}" "$template" | wc -l)
            if [[ $each_count -ne $endeach_count ]]; then
                echo "  ❌ Unmatched {{#each}} blocks"
                ((errors++))
            fi
            
            # Check for undefined variables
            local undefined_vars
            undefined_vars=$(grep -o "{{[^#/>][^}]*}}" "$template" | sort -u)
            while IFS= read -r var; do
                local var_name
                var_name=$(echo "$var" | sed 's/{{//g' | sed 's/}}//g' | tr -d ' ')
                if [[ -n "$var_name" ]] && [[ -z "${TEMPLATE_VARS[$var_name]:-}" ]]; then
                    echo "  ⚠️ Undefined variable: $var"
                fi
            done <<< "$undefined_vars"
            
            if [[ $errors -eq 0 ]]; then
                echo "  ✅ Valid"
            fi
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ All templates are valid"
        return 0
    else
        echo "❌ Found $errors validation errors"
        return 1
    fi
}

# List available templates
list_templates() {
    echo "📋 Available Templates"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ ! -d "$TEMPLATE_DIR" ]]; then
        echo "No templates directory found: $TEMPLATE_DIR"
        return 1
    fi
    
    echo "Main Templates:"
    for template in "$TEMPLATE_DIR"/*.template; do
        if [[ -f "$template" ]]; then
            local name=$(basename "$template" .template)
            local size=$(wc -l < "$template")
            echo "  📄 $name ($size lines)"
        fi
    done
    
    echo -e "\nPlatform-specific Templates:"
    for platform_dir in "$TEMPLATE_DIR"/{macos,linux,windows}; do
        if [[ -d "$platform_dir" ]]; then
            local platform=$(basename "$platform_dir")
            echo "  🖥️ $platform:"
            for template in "$platform_dir"/*.template; do
                if [[ -f "$template" ]]; then
                    local name=$(basename "$template" .template)
                    echo "    📄 $name"
                fi
            done
        fi
    done
    
    echo -e "\nPartials:"
    if [[ -d "$TEMPLATE_DIR/partials" ]]; then
        for partial in "$TEMPLATE_DIR/partials"/*.template; do
            if [[ -f "$partial" ]]; then
                local name=$(basename "$partial" .template)
                echo "  🧩 $name"
            fi
        done
    fi
}

# Template CLI interface
template_cli() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "generate"|"gen")
            local template_name="$1"
            local output_path="$2"
            local context="${3:-default}"
            generate_config "$template_name" "$output_path" "$context"
            ;;
        "process")
            local profile="${1:-default}"
            process_templates "$profile"
            ;;
        "create")
            local source_file="$1"
            local template_name="$2"
            create_template "$source_file" "$template_name"
            ;;
        "validate")
            validate_templates "$@"
            ;;
        "list")
            list_templates
            ;;
        "init")
            init_templating
            echo "✅ Templating system initialized"
            ;;
        "vars")
            echo "🔧 Template Variables:"
            for var in "${!TEMPLATE_VARS[@]}"; do
                echo "  $var = ${TEMPLATE_VARS[$var]}"
            done | sort
            ;;
        "help"|*)
            cat << 'EOF'
🔧 Templating System Commands

USAGE:
    template <command> [options]

COMMANDS:
    generate <template> <output>  Generate config from template
    process [profile]             Process all templates for profile
    create <source> <name>        Create template from existing file
    validate [dir]                Validate template syntax
    list                          List available templates
    init                          Initialize templating system
    vars                          Show available template variables

EXAMPLES:
    template generate zshrc ~/.zshrc
    template process development
    template create ~/.gitconfig gitconfig
    template validate
    template list

EOF
            ;;
    esac
}

# Initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_templating
fi

# Export functions
export -f process_template generate_config process_templates create_template
export -f validate_templates list_templates template_cli init_templating