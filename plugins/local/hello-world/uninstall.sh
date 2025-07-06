#!/usr/bin/env bash
# Hello World plugin uninstallation script

echo "🗑️ Uninstalling Hello World plugin..."

# Remove plugin data directory
PLUGIN_DATA_DIR="$HOME/.local/share/dotfiles/plugins/hello-world"
if [[ -d "$PLUGIN_DATA_DIR" ]]; then
    rm -rf "$PLUGIN_DATA_DIR"
    echo "🧹 Removed plugin data directory: $PLUGIN_DATA_DIR"
fi

# Remove any other plugin-specific files
# Add cleanup logic here

echo "✅ Hello World plugin uninstallation complete!"
echo "👋 Goodbye from Hello World plugin!"