#!/usr/bin/env bash
# Debug installer to identify issues

set -x  # Enable debug output

echo "=== DEBUG: Starting installation ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "HOME: $HOME"
echo "Shell: $SHELL"

# Test basic commands
echo "=== DEBUG: Testing commands ==="
command -v curl && echo "curl: OK" || echo "curl: MISSING"
command -v git && echo "git: OK" || echo "git: MISSING"
command -v wget && echo "wget: OK" || echo "wget: MISSING"

# Test network connectivity
echo "=== DEBUG: Testing network ==="
curl -I https://github.com 2>/dev/null && echo "GitHub: OK" || echo "GitHub: FAILED"

# Test git clone
echo "=== DEBUG: Testing git clone ==="
TEMP_DIR="/tmp/dotfiles-test-$$"
mkdir -p "$TEMP_DIR"
if git clone --branch master https://github.com/codeswiftr/dotfiles.git "$TEMP_DIR"; then
    echo "Clone: OK"
    ls -la "$TEMP_DIR"
    if [[ -f "$TEMP_DIR/install.sh" ]]; then
        echo "install.sh: FOUND"
        head -5 "$TEMP_DIR/install.sh"
    else
        echo "install.sh: MISSING"
    fi
    rm -rf "$TEMP_DIR"
else
    echo "Clone: FAILED"
fi

echo "=== DEBUG: Installation test complete ==="