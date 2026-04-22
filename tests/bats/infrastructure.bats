#!/usr/bin/env bats
# Infrastructure tests — validates dotfiles structure and contracts.
# Migrated from legacy test framework.

setup() {
    export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    export PATH="$DOTFILES_DIR/bin:$PATH"
}

# --- CLI Path Resolution (from test_cli_paths.sh) ---

@test "dot CLI runs from dotfiles root" {
    cd "$DOTFILES_DIR"
    run dot --version
    [ "$status" -eq 0 ]
}

@test "dot CLI runs from nested directory" {
    cd "$DOTFILES_DIR/config"
    run dot --version
    [ "$status" -eq 0 ]
}

@test "dot CLI runs from home directory" {
    cd "$HOME"
    run dot --version
    [ "$status" -eq 0 ]
}

# --- CLI Contracts (from test_cli_contracts.sh) ---

@test "dot --version outputs semantic version" {
    run dot --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"."* ]]
}

@test "dot check --quiet exits 0" {
    run dot check --quiet
    [ "$status" -eq 0 ]
}

# --- Tmux Bindings (from test_tmux_bindings.sh) ---

@test "tmux config has new-window binding" {
    run grep "bind.*c.*new-window" "$DOTFILES_DIR/config/tmux/tmux.conf"
    [ "$status" -eq 0 ]
}

@test "tmux config has detach binding" {
    run grep "bind.*d.*detach" "$DOTFILES_DIR/config/tmux/tmux.conf"
    [ "$status" -eq 0 ]
}

@test "tmux config has split bindings" {
    run grep 'bind.*|.*split' "$DOTFILES_DIR/config/tmux/tmux.conf"
    [ "$status" -eq 0 ]
    run grep 'bind.*-.*split' "$DOTFILES_DIR/config/tmux/tmux.conf"
    [ "$status" -eq 0 ]
}

@test "tmux config has pane navigation" {
    for key in h j k l; do
        run grep "bind.*$key.*select-pane" "$DOTFILES_DIR/config/tmux/tmux.conf"
        [ "$status" -eq 0 ]
    done
}

# --- Neovim Tiers (from test_nvim_tiers.sh) ---

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
    run nvim --headless -c "lua require('core.tier-manager')" -c "qa"
    [ "$status" -eq 0 ]
}

# --- Release (from test_release.sh) ---

@test "release script exists and is executable" {
    [ -f "$DOTFILES_DIR/scripts/release.sh" ]
    [ -x "$DOTFILES_DIR/scripts/release.sh" ]
}

# --- Shell Performance (from test_shell_startup.sh) ---

@test "shell startup under 500ms" {
    local start end duration_ms
    start=$(python3 -c 'import time; print(int(time.time()*1e9))')
    zsh -i -c 'exit' 2>/dev/null
    end=$(python3 -c 'import time; print(int(time.time()*1e9))')
    duration_ms=$(( (end - start) / 1000000 ))
    echo "# Shell startup: ${duration_ms}ms" >&3
    [ "$duration_ms" -lt 500 ]
}

# --- Nvim Keymaps (from test_nvim_keymaps.sh) ---

@test "nvim keymaps-unified.lua exists" {
    [ -f "$DOTFILES_DIR/config/nvim/lua/core/keymaps-unified.lua" ]
}

@test "nvim leader key is space" {
    run grep 'mapleader.*" "' "$DOTFILES_DIR/config/nvim/init.lua"
    [ "$status" -eq 0 ]
}
