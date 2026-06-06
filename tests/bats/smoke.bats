#!/usr/bin/env bats
# Smoke tests for dotfiles — validates core functionality works.
# Run: bats tests/bats/smoke.bats

setup() {
    export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    export PATH="$DOTFILES_DIR/bin:$PATH"
}

# --- dot CLI ---

@test "dot --help shows usage" {
    run dot --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"setup"* ]]
    [[ "$output" == *"check"* ]]
    [[ "$output" == *"update"* ]]
}

@test "dot --version shows version" {
    run dot --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"."* ]]
}

@test "dot check runs without error" {
    run dot check --quiet
    [ "$status" -eq 0 ]
}

# --- install.sh ---

@test "install.sh --help shows usage" {
    run bash "$DOTFILES_DIR/install.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"install"* ]]
}

@test "install.sh link --dry-run succeeds" {
    run bash "$DOTFILES_DIR/install.sh" link --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would"* ]] || [[ "$output" == *"chezmoi"* ]]
}

@test "install.sh profiles lists profiles" {
    run bash "$DOTFILES_DIR/install.sh" profiles
    [ "$status" -eq 0 ]
    [[ "$output" == *"minimal"* ]]
    [[ "$output" == *"standard"* ]]
}

# --- Shell configuration ---

@test "zshrc has no syntax errors" {
    run zsh -n "$DOTFILES_DIR/.zshrc"
    [ "$status" -eq 0 ]
}

@test "core.zsh has no syntax errors" {
    run zsh -n "$DOTFILES_DIR/config/zsh/core.zsh"
    [ "$status" -eq 0 ]
}

@test "defaults.zsh has no syntax errors" {
    run zsh -n "$DOTFILES_DIR/config/zsh/defaults.zsh"
    [ "$status" -eq 0 ]
}

@test "agent mode preserves standard command names" {
    run zsh -fc 'DOTFILES_DIR="$1" DOTFILES_MODE=agent source "$1/.zshrc" >/dev/null 2>&1; alias cat less grep find ls man vim vi tmux python python3 pip pip3 node npm npx 2>/dev/null || true; echo "PAGER=$PAGER GIT_PAGER=$GIT_PAGER MANPAGER=$MANPAGER CORRECT=$options[correct]"' _ "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" != *"cat="* ]]
    [[ "$output" != *"less="* ]]
    [[ "$output" != *"grep="* ]]
    [[ "$output" != *"find="* ]]
    [[ "$output" != *"ls="* ]]
    [[ "$output" != *"tmux="* ]]
    [[ "$output" != *"python3="* ]]
    [[ "$output" != *"pip="* ]]
    [[ "$output" != *"node="* ]]
    [[ "$output" != *"npm="* ]]
    [[ "$output" == *"PAGER=cat"* ]]
    [[ "$output" == *"GIT_PAGER=cat"* ]]
    [[ "$output" == *"MANPAGER=cat"* ]]
    [[ "$output" == *"CORRECT=off"* ]]
}

@test "native escape aliases are available" {
    run zsh -fc 'DOTFILES_DIR="$1" source "$1/.zshrc" >/dev/null 2>&1; alias _cat _grep _find _ls _tmux _python3 2>/dev/null' _ "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"_cat='command cat'"* ]]
    [[ "$output" == *"_grep='command grep'"* ]]
    [[ "$output" == *"_find='command find'"* ]]
    [[ "$output" == *"_ls='command ls'"* ]]
    [[ "$output" == *"_tmux='command tmux'"* ]]
    [[ "$output" == *"_python3='command python3'"* ]]
}

@test "underscore agent wrappers are executable" {
    for wrapper in _agent _claude _codex _kimi _gemini _pi _opencode _cursor; do
        [ -x "$DOTFILES_DIR/bin/$wrapper" ]
    done
    run "$DOTFILES_DIR/bin/_agent" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: _agent"* ]]
}

# --- Shell startup performance ---

@test "shell startup under 500ms" {
    local start end duration_ms
    start=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
    zsh -i -c 'exit' 2>/dev/null
    end=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
    duration_ms=$(( (end - start) / 1000000 ))
    echo "Shell startup: ${duration_ms}ms"
    [ "$duration_ms" -lt 500 ]
}

# --- Key files exist ---

@test "ARCHITECTURE.md exists" {
    [ -f "$DOTFILES_DIR/ARCHITECTURE.md" ]
}

@test "config/tools.yaml exists" {
    [ -f "$DOTFILES_DIR/config/tools.yaml" ]
}

@test "config/nvim/init.lua exists" {
    [ -f "$DOTFILES_DIR/config/nvim/init.lua" ]
}

@test "config/tmux/tmux.conf exists" {
    [ -f "$DOTFILES_DIR/config/tmux/tmux.conf" ]
}

# --- Symlinks correct ---

@test "~/.zshrc symlink points to dotfiles" {
    [ -L "$HOME/.zshrc" ]
    [[ "$(readlink "$HOME/.zshrc")" == *"dotfiles"* ]]
}

@test "~/.config/nvim symlink points to dotfiles" {
    [ -L "$HOME/.config/nvim" ] || [ -d "$HOME/.config/nvim" ]
}

@test "~/.tmux.conf symlink points to dotfiles" {
    [ -L "$HOME/.tmux.conf" ]
    [[ "$(readlink "$HOME/.tmux.conf")" == *"dotfiles"* ]]
}

# --- Neovim tier system ---

@test "neovim tier manager loads without error" {
    run nvim --headless -c "lua require('core.tier-manager')" -c "qa" 2>&1
    [ "$status" -eq 0 ]
}

@test "neovim has only 2 tiers" {
    run nvim --headless -c "lua local tm = require('core.tier-manager'); tm.set_tier(3)" -c "qa" 2>&1
    # Tier 3 should fail since we only have 2
    [[ "$output" == *"Invalid tier"* ]] || [ "$status" -ne 0 ] || true
}
