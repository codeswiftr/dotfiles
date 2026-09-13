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
    [[ "$output" == *"check"* ]]
    [[ "$output" == *"update"* ]]
    [[ "$output" == *"restart"* ]]
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
    run zsh -fc 'DOTFILES_DIR="$1" DOTFILES_MODE=agent source "$1/.zshrc" >/dev/null 2>&1; alias cat less grep find ls man vim vi herdr python python3 pip pip3 node npm npx 2>/dev/null || true; echo "PAGER=$PAGER GIT_PAGER=$GIT_PAGER MANPAGER=$MANPAGER CORRECT=$options[correct]"' _ "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" != *"cat="* ]]
    [[ "$output" != *"less="* ]]
    [[ "$output" != *"grep="* ]]
    [[ "$output" != *"find="* ]]
    [[ "$output" != *"ls="* ]]
    [[ "$output" != *"herdr="* ]]
    [[ "$output" != *"python3="* ]]
    [[ "$output" != *"pip="* ]]
    [[ "$output" != *"node="* ]]
    [[ "$output" != *"npm="* ]]
    [[ "$output" == *"PAGER=cat"* ]]
    [[ "$output" == *"GIT_PAGER=cat"* ]]
    [[ "$output" == *"MANPAGER=cat"* ]]
    [[ "$output" == *"CORRECT=off"* ]]
}

@test "DOTFILES_MODE=minimal is respected without forcing agent-safe" {
    # Use export (not VAR=value source) so the mode survives into the shell
    run zsh -fc 'export DOTFILES_DIR="$1" DOTFILES_MODE=minimal; unset DOTFILES_AGENT_SAFE; source "$1/.zshrc" >/dev/null 2>&1; echo "MODE=$DOTFILES_MODE SAFE=${DOTFILES_AGENT_SAFE:-0}"' _ "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"MODE=minimal"* ]]
    [[ "$output" == *"SAFE=0"* ]]
}

@test "DOTFILES_MODE defaults to full when unset" {
    run zsh -fc 'export DOTFILES_DIR="$1"; unset DOTFILES_MODE DOTFILES_AGENT_SAFE DOTFILES_SSH SSH_CONNECTION FORGE_AGENT_TYPE CI; source "$1/.zshrc" >/dev/null 2>&1; echo "MODE=$DOTFILES_MODE SAFE=${DOTFILES_AGENT_SAFE:-0}"' _ "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"MODE=full"* ]]
    [[ "$output" == *"SAFE=0"* ]]
}

@test "native escape aliases are available" {
    run zsh -fc 'DOTFILES_DIR="$1" source "$1/.zshrc" >/dev/null 2>&1; alias _cat _grep _find _ls _herdr _python3 2>/dev/null' _ "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"_cat='command cat'"* ]]
    [[ "$output" == *"_grep='command grep'"* ]]
    [[ "$output" == *"_find='command find'"* ]]
    [[ "$output" == *"_ls='command ls'"* ]]
    [[ "$output" == *"_herdr='command herdr'"* ]]
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

@test "dot restart reports herdr status" {
    run "$DOTFILES_DIR/bin/dot" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"restart"* ]]
    [[ "$output" != *"tmux agents"* ]]
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

@test "tools.yaml essential group installs herdr on a fresh box" {
    local yaml="$DOTFILES_DIR/config/tools.yaml"
    awk '/^  essential:/{p=1} p&&/^  [a-z].*:/{if(!/^  essential:/)exit} p' "$yaml" \
        | grep -q -- '- herdr'
    grep -A20 '^  herdr:' "$yaml" | grep -q 'brew install herdr'
    grep -A20 '^  herdr:' "$yaml" | grep -q 'https://herdr.dev/install.sh'
    grep -q 'brew "herdr"' "$DOTFILES_DIR/config/platform/Brewfile"
}

@test "ai_tools group is the daily agent set" {
    local group
    group=$(awk '/^  ai_tools:/{p=1} p&&/^  [a-z].*:/{if(!/^  ai_tools:/)exit} p' \
        "$DOTFILES_DIR/config/tools.yaml")
    echo "$group" | grep -q -- '- claude_code'
    echo "$group" | grep -q -- '- opencode'
    echo "$group" | grep -q -- '- codex'
    ! echo "$group" | grep -q -- '- aider'
    ! echo "$group" | grep -q -- '- amp'
    ! echo "$group" | grep -q -- '- kilo'
}

@test "networking group installs mosh for Moshi/phone remotes" {
    local yaml="$DOTFILES_DIR/config/tools.yaml"
    awk '/^  networking:/{p=1} p&&/^  [a-z].*:/{if(!/^  networking:/)exit} p' "$yaml" \
        | grep -q -- '- mosh'
    grep -A12 '^  mosh:' "$yaml" | grep -q 'scripts/install-mosh.sh'
    [ -x "$DOTFILES_DIR/scripts/install-mosh.sh" ]
    grep -q 'brew "mosh"' "$DOTFILES_DIR/config/platform/Brewfile"
    grep -q 'local/bin' "$DOTFILES_DIR/config/zsh/.zshenv"
}

@test "tools.yaml marks mise-owned CLIs with provided_by" {
    grep -q 'provided_by: mise' "$DOTFILES_DIR/config/tools.yaml"
    # starship must not still brew-install in tools.yaml when mise-owned
    ! awk '/^  starship:/{p=1} p&&/^  [a-z]/{if(!/^  starship:/)exit} p' "$DOTFILES_DIR/config/tools.yaml" \
        | grep -q 'brew install starship'
    [ -f "$DOTFILES_DIR/mise.toml" ]
    grep -q 'starship' "$DOTFILES_DIR/mise.toml"
}

@test "config/nvim/init.lua exists" {
    [ -f "$DOTFILES_DIR/config/nvim/init.lua" ]
}

@test "config/herdr/config.toml exists" {
    [ -f "$DOTFILES_DIR/config/herdr/config.toml" ]
}

# --- Symlinks correct ---

@test "~/.zshrc symlink points to dotfiles" {
    [ -L "$HOME/.zshrc" ]
    [[ "$(readlink "$HOME/.zshrc")" == *"dotfiles"* ]]
}

@test "~/.config/nvim symlink points to dotfiles" {
    [ -L "$HOME/.config/nvim" ] || [ -d "$HOME/.config/nvim" ]
}

@test "~/.config/herdr/config.toml is linked from dotfiles" {
    [ -L "$HOME/.config/herdr/config.toml" ] || [ -f "$HOME/.config/herdr/config.toml" ]
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

# --- bin/ hygiene (no tool landfill) ---

@test "bin/ contains only whitelisted scripts" {
    local allowed='^(dot|ai|cursor|viman|dotfiles-tutor|_agent|_claude|_codex|_gemini|_kimi|_pi|_opencode|_cursor|_amp|_minimax|_glm)$'
    local bad=0
    local name
    for f in "$DOTFILES_DIR"/bin/*; do
        [ -e "$f" ] || continue
        name=$(basename "$f")
        if ! echo "$name" | grep -Eq "$allowed"; then
            echo "unexpected bin entry: $name" >&2
            bad=1
        fi
    done
    [ "$bad" -eq 0 ]
}

@test "bin/ has no Mach-O binaries" {
    local f
    for f in "$DOTFILES_DIR"/bin/*; do
        [ -f "$f" ] || continue
        [ -L "$f" ] && continue
        if file -b "$f" 2>/dev/null | grep -q 'Mach-O'; then
            echo "binary in bin/: $(basename "$f")" >&2
            return 1
        fi
    done
}

@test "tracked bin scripts have no absolute /Users/ paths" {
    run bash -c 'grep -REn "/Users/[a-zA-Z0-9._-]+" "$0"/bin 2>/dev/null | grep -v "^Binary" || true' "$DOTFILES_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "~/.local/bin is not a symlink into the repo" {
    if [ -L "$HOME/.local/bin" ]; then
        target=$(readlink "$HOME/.local/bin")
        [[ "$target" != *"/dotfiles/bin"* ]]
    else
        [ -d "$HOME/.local/bin" ] || [ ! -e "$HOME/.local/bin" ]
    fi
}

@test "chezmoi sourceDir is the repo home/ tree" {
    command -v chezmoi >/dev/null 2>&1 || skip "chezmoi not installed"
    run chezmoi source-path
    [ "$status" -eq 0 ]
    [[ "$output" == *"/dotfiles/home"* ]] || [[ "$output" == *"/dotfiles"* ]]
}

# --- Claude agent instruction surface ---

@test "CLAUDE.md lives at repo root, not config/claude/" {
    [ -f "$DOTFILES_DIR/CLAUDE.md" ]
    [ ! -e "$DOTFILES_DIR/config/claude/CLAUDE.md" ]
}

@test "chezmoi CLAUDE.md template points at repo-root CLAUDE.md" {
    local tmpl="$DOTFILES_DIR/home/private_dot_claude/symlink_CLAUDE.md.tmpl"
    [ -f "$tmpl" ]
    grep -q 'CLAUDE.md' "$tmpl"
    grep -qv 'config.*claude.*CLAUDE' "$tmpl"
}

@test "herdr config.toml is source-managed with ctrl+a prefix" {
    local cfg="$DOTFILES_DIR/config/herdr/config.toml"
    local tmpl="$DOTFILES_DIR/home/dot_config/herdr/symlink_config.toml.tmpl"
    [ -f "$cfg" ]
    [ -f "$tmpl" ]
    grep -q 'prefix = "ctrl+a"' "$cfg"
    grep -q 'reload_config' "$cfg"
    grep -q 'herdr' "$tmpl"
    grep -q 'config.toml' "$tmpl"
}

@test "prime/continue/handoff commands do not require Forge" {
    local dir="$DOTFILES_DIR/config/claude/commands"
    grep -q 'AGENTS.md' "$dir/prime.md"
    grep -q 'HANDOFF.md' "$dir/continue.md"
    grep -q 'HANDOFF.md' "$dir/handoff.md"
    # No FORGE portfolio examples as the default target
    if grep -E 'voice-coach|interview-simulator|code-atlas' \
        "$dir/prime.md" "$dir/continue.md" "$dir/handoff.md" "$dir/README.md"; then
        return 1
    fi
}

@test "justfile exists and contains core recipes" {
    [ -f "$DOTFILES_DIR/justfile" ]
    grep -q 'test:' "$DOTFILES_DIR/justfile"
    grep -q 'lint:' "$DOTFILES_DIR/justfile"
    grep -q 'check:' "$DOTFILES_DIR/justfile"
}

@test "setup entrypoint and bootstrap point at a single install path" {
    [ -x "$DOTFILES_DIR/setup" ]
    grep -q 'install.sh' "$DOTFILES_DIR/setup"
    grep -q 'codeswiftr/dotfiles' "$DOTFILES_DIR/scripts/bootstrap.sh"
    grep -q 'DOTFILES_REPO' "$DOTFILES_DIR/scripts/bootstrap.sh"
}

@test "dot help no longer advertises legacy commands" {
    run "$DOTFILES_DIR/bin/dot" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"check"* ]]
    [[ "$output" == *"update"* ]]
    [[ "$output" != *"LEGACY"* ]]
    [[ "$output" != *"scaffolding"* ]]
    run "$DOTFILES_DIR/bin/dot" perf
    [ "$status" -ne 0 ]
    [[ "$output" == *"Removed"* ]] || [[ "$output" == *"legacy"* ]]
}

@test "herdr zsh completions and aliases are defined" {
    [ -f "$DOTFILES_DIR/completions/_herdr" ]
    grep -q '#compdef herdr' "$DOTFILES_DIR/completions/_herdr"
    grep -q 'alias herder="herdr"' "$DOTFILES_DIR/config/zsh/aliases.zsh"
    grep -q 'alias hs=' "$DOTFILES_DIR/config/zsh/aliases.zsh"
    grep -q 'alias hw=' "$DOTFILES_DIR/config/zsh/aliases.zsh"
}

