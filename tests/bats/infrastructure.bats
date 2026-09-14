#!/usr/bin/env bats
# Infrastructure tests — validates dotfiles structure and contracts.

setup() {
    export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    export PATH="$DOTFILES_DIR/bin:$PATH"
}

# --- Task interface ---

@test "just check script is executable" {
    [ -x "$DOTFILES_DIR/scripts/check.sh" ]
    [ -x "$DOTFILES_DIR/scripts/update.sh" ]
    [ -x "$DOTFILES_DIR/scripts/reload.sh" ]
}

@test "just check --quiet exits 0 when linked" {
    if [[ ! -L "$HOME/.zshrc" ]]; then
        skip "dotfiles not linked on this host"
    fi
    run just check --quiet
    [ "$status" -eq 0 ]
}

# --- Herdr config ---

@test "herdr config keeps tmux-compatible workspace and pane shortcuts" {
    local cfg="$DOTFILES_DIR/config/herdr/config.toml"
    [ -f "$cfg" ]
    for setting in \
        'prefix = "ctrl+a"' \
        'split_vertical' \
        'split_horizontal' \
        'new_tab' \
        'rename_tab' \
        'workspace_picker' \
        'switch_tab' \
        'switch_workspace' \
        'close_pane' \
        'focus_pane_left' \
        'focus_pane_right' \
        'zoom'; do
        run grep -F "$setting" "$cfg"
        [ "$status" -eq 0 ]
    done
}

# --- Neovim Tiers ---

@test "nvim tier1.lua exists and has plugins" {
    [ -f "$DOTFILES_DIR/config/nvim/lua/tiers/tier1.lua" ]
    run grep "return" "$DOTFILES_DIR/config/nvim/lua/tiers/tier1.lua"
    [ "$status" -eq 0 ]
}

@test "nvim tier2.lua exists and has plugins" {
    [ -f "$DOTFILES_DIR/config/nvim/lua/tiers/tier2.lua" ]
    run grep "return" "$DOTFILES_DIR/config/nvim/lua/tiers/tier2.lua"
    [ "$status" -eq 0 ]
}

@test "nvim tier3.lua does not exist (consolidated to 2 tiers)" {
    [ ! -f "$DOTFILES_DIR/config/nvim/lua/tiers/tier3.lua" ]
}

@test "nvim tier-manager.lua loads without error" {
    if ! command -v nvim >/dev/null 2>&1; then
        skip "nvim not installed"
    fi
    run nvim --headless -c "lua require('core.tier-manager')" -c "qa"
    [ "$status" -eq 0 ]
}

# --- Release ---

@test "release script exists and is executable" {
    [ -f "$DOTFILES_DIR/scripts/release.sh" ]
    [ -x "$DOTFILES_DIR/scripts/release.sh" ]
}

# --- Shell Performance ---

@test "shell startup under 500ms" {
    if [[ ! -L "$HOME/.zshrc" ]]; then
        skip "dotfiles not linked on this host"
    fi
    local start end duration_ms
    start=$(python3 -c 'import time; print(int(time.time()*1e9))')
    zsh -i -c 'exit' 2>/dev/null
    end=$(python3 -c 'import time; print(int(time.time()*1e9))')
    duration_ms=$(( (end - start) / 1000000 ))
    echo "# Shell startup: ${duration_ms}ms" >&3
    [ "$duration_ms" -lt 500 ]
}

# --- Nvim Keymaps ---

@test "nvim keymaps-unified.lua exists" {
    [ -f "$DOTFILES_DIR/config/nvim/lua/core/keymaps-unified.lua" ]
}

@test "nvim leader key is space" {
    run grep 'mapleader.*" "' "$DOTFILES_DIR/config/nvim/init.lua"
    [ "$status" -eq 0 ]
}
