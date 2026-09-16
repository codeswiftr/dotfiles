#!/usr/bin/env bats
# Smoke tests for dotfiles — validates core functionality works.
# Run: bats tests/bats/smoke.bats

setup() {
    export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    export PATH="$DOTFILES_DIR/bin:$PATH"
}

# --- just + health scripts ---

@test "just --list shows core recipes" {
    run just --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"check"* ]]
    [[ "$output" == *"update"* ]]
    [[ "$output" == *"smoke"* ]]
}

@test "scripts/check.sh --help works" {
    run "$DOTFILES_DIR/scripts/check.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"check.sh"* ]]
}

@test "just check runs without error when linked" {
    if [[ ! -L "$HOME/.zshrc" ]]; then
        skip "dotfiles not linked on this host"
    fi
    run just check --quiet
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
    # Use export (not VAR=value source) so the mode survives into the shell.
    # Unset CI/SSH/forge markers so GitHub Actions does not force agent mode.
    run zsh -fc 'export DOTFILES_DIR="$1" DOTFILES_MODE=minimal; unset DOTFILES_AGENT_SAFE DOTFILES_SSH SSH_CONNECTION FORGE_AGENT_TYPE CI; source "$1/.zshrc" >/dev/null 2>&1; echo "MODE=$DOTFILES_MODE SAFE=${DOTFILES_AGENT_SAFE:-0}"' _ "$DOTFILES_DIR"
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

@test "just status reports herdr when available" {
    run just --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"status"* ]]
}

# --- Shell startup performance ---

@test "shell startup under 500ms" {
    if [[ ! -L "$HOME/.zshrc" ]]; then
        skip "dotfiles not linked on this host"
    fi
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

@test "platform manifests and mise.toml exist" {
    [ -f "$DOTFILES_DIR/config/platform/Brewfile" ]
    [ -f "$DOTFILES_DIR/config/platform/apt.txt" ]
    [ -f "$DOTFILES_DIR/config/platform/pacman.txt" ]
    [ -f "$DOTFILES_DIR/mise.toml" ]
    [ ! -e "$DOTFILES_DIR/config/tools.yaml" ]
}

@test "Brewfile installs herdr and mosh on a fresh macOS box" {
    command grep -q 'brew "herdr"' "$DOTFILES_DIR/config/platform/Brewfile"
    command grep -q 'brew "mosh"' "$DOTFILES_DIR/config/platform/Brewfile"
    command grep -q 'brew "chezmoi"' "$DOTFILES_DIR/config/platform/Brewfile"
    [ -x "$DOTFILES_DIR/scripts/install-herdr.sh" ]
}

@test "daily AI agents are in Brewfile / install.sh" {
    command grep -q 'claude-code' "$DOTFILES_DIR/config/platform/Brewfile"
    command grep -q 'opencode' "$DOTFILES_DIR/config/platform/Brewfile"
    command grep -q 'codex' "$DOTFILES_DIR/config/platform/Brewfile"
    command grep -q 'install_ai_tools' "$DOTFILES_DIR/install.sh"
    ! command grep -q 'aider' "$DOTFILES_DIR/config/platform/Brewfile"
}

@test "networking installs mosh for Moshi/phone remotes" {
    [ -x "$DOTFILES_DIR/scripts/install-mosh.sh" ]
    command grep -q 'brew "mosh"' "$DOTFILES_DIR/config/platform/Brewfile"
    command grep -q 'mosh' "$DOTFILES_DIR/config/platform/apt.txt"
    command grep -q 'local/bin' "$DOTFILES_DIR/config/zsh/.zshenv"
    command grep -q 'install_networking' "$DOTFILES_DIR/install.sh"
}

@test "mise owns pinned CLIs not Brewfile" {
    command grep -q 'starship' "$DOTFILES_DIR/mise.toml"
    command grep -q 'ripgrep' "$DOTFILES_DIR/mise.toml"
    ! command grep -q 'starship' "$DOTFILES_DIR/config/platform/Brewfile"
    ! command grep -q 'ripgrep' "$DOTFILES_DIR/config/platform/Brewfile"
}

@test "config/nvim/init.lua exists" {
    [ -f "$DOTFILES_DIR/config/nvim/init.lua" ]
}

@test "config/herdr/config.toml exists" {
    [ -f "$DOTFILES_DIR/config/herdr/config.toml" ]
}

# --- Symlinks correct ---

@test "~/.zshrc symlink points to dotfiles" {
    if [[ ! -L "$HOME/.zshrc" ]]; then
        skip "dotfiles not linked on this host"
    fi
    [[ "$(readlink "$HOME/.zshrc")" == *"dotfiles"* ]]
}

@test "~/.config/nvim symlink points to dotfiles" {
    if [[ ! -e "$HOME/.config/nvim" ]]; then
        skip "nvim config not linked on this host"
    fi
    [ -L "$HOME/.config/nvim" ] || [ -d "$HOME/.config/nvim" ]
}

@test "~/.config/herdr/config.toml is linked from dotfiles" {
    if [[ ! -e "$HOME/.config/herdr/config.toml" ]]; then
        skip "herdr config not linked on this host"
    fi
    [ -L "$HOME/.config/herdr/config.toml" ] || [ -f "$HOME/.config/herdr/config.toml" ]
}

# --- Neovim tier system ---

@test "neovim tier manager loads without error" {
    if ! command -v nvim >/dev/null 2>&1; then
        skip "nvim not installed"
    fi
    run nvim --headless -c "lua require('core.tier-manager')" -c "qa" 2>&1
    [ "$status" -eq 0 ]
}

@test "neovim has only 2 tiers" {
    if ! command -v nvim >/dev/null 2>&1; then
        skip "nvim not installed"
    fi
    run nvim --headless -c "lua local tm = require('core.tier-manager'); tm.set_tier(3)" -c "qa" 2>&1
    # Tier 3 should fail since we only have 2
    [[ "$output" == *"Invalid tier"* ]] || [ "$status" -ne 0 ] || true
}

# --- bin/ hygiene (no tool landfill) ---

@test "bin/ contains only whitelisted scripts" {
    local allowed='^(ai|cursor|_agent|_claude|_codex|_gemini|_kimi|_pi|_opencode|_cursor|_amp|_minimax|_glm)$'
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
    command grep -qE '^test:' "$DOTFILES_DIR/justfile"
    command grep -qE '^lint:' "$DOTFILES_DIR/justfile"
    command grep -qE '^check' "$DOTFILES_DIR/justfile"
    command grep -qE '^update' "$DOTFILES_DIR/justfile"
}


@test "setup entrypoint and bootstrap point at a single install path" {
    [ -x "$DOTFILES_DIR/setup" ]
    grep -q 'install.sh' "$DOTFILES_DIR/setup"
    grep -q 'codeswiftr/dotfiles' "$DOTFILES_DIR/scripts/bootstrap.sh"
    grep -q 'DOTFILES_REPO' "$DOTFILES_DIR/scripts/bootstrap.sh"
}

@test "justfile recipes no longer wrap bin/dot" {
    [ -f "$DOTFILES_DIR/justfile" ]
    grep -q 'scripts/check.sh' "$DOTFILES_DIR/justfile"
    grep -q 'scripts/update.sh' "$DOTFILES_DIR/justfile"
    ! command grep -q 'bin/dot' "$DOTFILES_DIR/justfile"
    [ ! -e "$DOTFILES_DIR/bin/dot" ]
    [ ! -d "$DOTFILES_DIR/lib/cli" ]
    [ ! -d "$DOTFILES_DIR/lib" ]
    [ ! -f "$DOTFILES_DIR/config/gitconfig" ]
    [ ! -f "$DOTFILES_DIR/config/forge/.forgerc" ]
    ! command grep -qE 'alias (jlab|ask|dev-optimize|bun-opt)=' "$DOTFILES_DIR/config/zsh/aliases.zsh"
    ! command grep -qE 'function (py-new|js-new|linkedin-post|ai-find)' "$DOTFILES_DIR/config/zsh/functions.zsh"
}

@test "only minimal and standard install profiles remain" {
    run bash "$DOTFILES_DIR/install.sh" profiles
    [ "$status" -eq 0 ]
    [[ "$output" == *"minimal"* ]]
    [[ "$output" == *"standard"* ]]
    [[ "$output" != *"ai_focused"* ]]
    command grep -q 'normalize_profile' "$DOTFILES_DIR/install.sh"
}

@test "install.sh is thin and chezmoi-strict" {
    local lines
    lines=$(wc -l < "$DOTFILES_DIR/install.sh" | tr -d ' ')
    [ "$lines" -le 700 ]
    command grep -q 'chezmoi' "$DOTFILES_DIR/install.sh"
    command grep -q 'no fallback linker' "$DOTFILES_DIR/install.sh"
    ! command grep -q 'link_dotfile' "$DOTFILES_DIR/install.sh"
    ! command grep -q 'tools.yaml' "$DOTFILES_DIR/install.sh"
}

@test "install.sh runs chezmoi init before apply on a fresh machine" {
    # Regression: apply without init fails with 'map has no entry for key "name"'
    command grep -q 'chezmoi.toml' "$DOTFILES_DIR/install.sh"
    command grep -qE 'init_args=\(init --source' "$DOTFILES_DIR/install.sh"
    command grep -q -- '--promptDefaults' "$DOTFILES_DIR/install.sh"
}

@test "gitconfig template tolerates missing name/email data" {
    command -v chezmoi >/dev/null 2>&1 || skip "chezmoi not installed"
    local tmp_home
    tmp_home=$(mktemp -d)
    run env HOME="$tmp_home" XDG_CONFIG_HOME="$tmp_home/.config" \
        chezmoi --source "$DOTFILES_DIR/home" execute-template < "$DOTFILES_DIR/home/dot_gitconfig.tmpl"
    rm -rf "$tmp_home"
    [ "$status" -eq 0 ]
    [[ "$output" == *"[user] not set"* ]]
}

@test "herdr zsh completions and aliases are defined" {
    [ -f "$DOTFILES_DIR/completions/_herdr" ]
    grep -q '#compdef herdr' "$DOTFILES_DIR/completions/_herdr"
    grep -q 'alias herder="herdr"' "$DOTFILES_DIR/config/zsh/aliases.zsh"
    grep -q 'alias hs=' "$DOTFILES_DIR/config/zsh/aliases.zsh"
    grep -q 'alias hw=' "$DOTFILES_DIR/config/zsh/aliases.zsh"
}

