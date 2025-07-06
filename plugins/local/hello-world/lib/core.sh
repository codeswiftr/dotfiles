#!/usr/bin/env bash
# Hello World plugin core functionality

# Plugin initialization
hello_world_init() {
    echo "🔌 Hello World plugin initialized!"
}

# Plugin cleanup
hello_world_cleanup() {
    echo "🔌 Hello World plugin cleaned up!"
}

# Main plugin function
hello_world_main() {
    local name="${1:-World}"
    echo "👋 Hello, $name! This message is from the Hello World plugin."
    echo "📅 Current time: $(date)"
    echo "💻 System: $(uname -s) $(uname -m)"
    echo "🎯 Plugin version: 1.0.0"
}

# Additional plugin functions
hello_world_status() {
    echo "Hello World plugin is running!"
}

hello_world_config() {
    echo "Hello World plugin configuration:"
    echo "  Version: 1.0.0"
    echo "  Type: example"
    echo "  Category: demo"
}

# Export functions
export -f hello_world_init hello_world_cleanup hello_world_main
export -f hello_world_status hello_world_config