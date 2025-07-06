#!/usr/bin/env bash
# Hello World plugin installation script

echo "📦 Installing Hello World plugin..."

# Create plugin data directory
PLUGIN_DATA_DIR="$HOME/.local/share/dotfiles/plugins/hello-world"
mkdir -p "$PLUGIN_DATA_DIR"

# Create a simple configuration file
cat > "$PLUGIN_DATA_DIR/config.json" << EOF
{
  "version": "1.0.0",
  "enabled": true,
  "last_greeting": null,
  "greeting_count": 0
}
EOF

echo "📝 Created plugin configuration at $PLUGIN_DATA_DIR/config.json"

# Add any additional installation logic here
echo "✅ Hello World plugin installation complete!"
echo ""
echo "To use the plugin:"
echo "  dot plugin enable hello-world"
echo "  dot hello"