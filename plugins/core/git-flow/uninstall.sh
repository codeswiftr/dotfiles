#!/usr/bin/env bash
# Git Flow Plugin Uninstallation Script

echo "🗑️  Uninstalling Git Flow plugin..."

# Clean up git aliases
cleanup_git_aliases() {
    echo "🧹 Cleaning up git aliases..."
    
    # Remove git flow aliases
    git config --global --unset alias.flow 2>/dev/null || true
    git config --global --unset alias.feature 2>/dev/null || true
    git config --global --unset alias.release 2>/dev/null || true
    
    # Remove git flow shortcuts
    git config --global --unset alias.fs 2>/dev/null || true
    git config --global --unset alias.ff 2>/dev/null || true
    git config --global --unset alias.fp 2>/dev/null || true
    git config --global --unset alias.fl 2>/dev/null || true
    
    # Note: We don't remove standard git aliases (co, br, ci, st) as user might want to keep them
    
    echo "✅ Git aliases cleaned up"
}

# Clean up plugin configuration
cleanup_plugin_config() {
    local config_dir="$HOME/.config/dotfiles/plugins/git-flow"
    
    if [[ -d "$config_dir" ]]; then
        echo "🗑️  Removing plugin configuration..."
        rm -rf "$config_dir"
        echo "✅ Plugin configuration removed"
    fi
}

# Clean up git flow defaults (optional)
cleanup_git_flow_defaults() {
    echo "⚠️  Git flow defaults (merge.ff, pull.rebase, etc.) left intact"
    echo "   These may be used by other tools. Remove manually if needed."
}

# Show cleanup information
show_cleanup_info() {
    echo ""
    echo "🧹 Cleanup Information:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Removed: Plugin-specific git aliases"
    echo "✅ Removed: Plugin configuration directory"
    echo "⚠️  Kept: Standard git aliases (co, br, ci, st)"
    echo "⚠️  Kept: Git configuration (merge.ff, pull.rebase)"
    echo ""
    echo "💡 Repository-specific git flow settings (gitflow.branch.*) are preserved"
    echo "   These are per-repository and don't affect other projects"
}

# Main uninstallation
main() {
    echo "🗑️  Git Flow Plugin Uninstallation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Run uninstallation steps
    cleanup_git_aliases
    cleanup_plugin_config
    cleanup_git_flow_defaults
    show_cleanup_info
    
    echo ""
    echo "✅ Git Flow plugin uninstalled successfully!"
}

# Run uninstallation
main "$@"