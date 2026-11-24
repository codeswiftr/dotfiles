#!/usr/bin/env bats
# Merge-only chezmoi modify entries for Claude settings and Codex config.
# Read-only: uses `chezmoi cat` against a scratch --destination, never apply.
# Run: bats tests/bats/chezmoi-allowlists.bats

setup() {
    command -v chezmoi >/dev/null 2>&1 || skip "chezmoi not installed"
    command -v jq >/dev/null 2>&1 || skip "jq not installed"
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    D="$BATS_TEST_TMPDIR/home"
    mkdir -p "$D/.claude" "$D/.codex"
    # run from a neutral dir so mise shims do not read the repo's mise.toml
    cd "$BATS_TEST_TMPDIR"
}

render() { chezmoi --source "$REPO/home" --destination "$D" cat "$D/$1"; }

# --- Claude ---

@test "claude: fresh machine gets required allow and ask rules" {
    run render .claude/settings.json
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '
      (.permissions.allow | index("Bash(git status)") and index("Bash(pnpm test:*)") and index("Bash(pytest:*)")) and
      (.permissions.ask | index("Bash(gh pr merge:*)") and index("Bash(wrangler deploy:*)") and index("Bash(git push --force:*)")) and
      (.permissions.allow | index("Bash(gh pr merge:*)") | not) and
      (.model == "opus")' >/dev/null
}

@test "claude: live-only settings, extra rules and deny block survive" {
    cat >"$D/.claude/settings.json" <<'EOF'
{
  "model": "sonnet",
  "hooks": {"SessionStart": [{"matcher": "x", "hooks": []}]},
  "advisorModel": "fable",
  "enabledPlugins": {"extra@market": true},
  "permissions": {
    "allow": ["Bash(ls:*)", "Bash(git status)"],
    "ask": ["Bash(rm:*)"],
    "deny": ["Bash(rm -rf /:*)"]
  }
}
EOF
    run render .claude/settings.json
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '
      .hooks.SessionStart[0].matcher == "x" and
      .advisorModel == "fable" and
      .enabledPlugins["extra@market"] == true and
      .enabledPlugins["context7@claude-plugins-official"] == true and
      .model == "opus" and
      .permissions.deny == ["Bash(rm -rf /:*)"] and
      .permissions.allow[0] == "Bash(ls:*)" and
      (.permissions.allow | index("Bash(pytest:*)")) and
      (.permissions.ask | index("Bash(rm:*)")) and
      (.permissions.ask | index("Bash(git push --force:*)")) and
      (.permissions.allow | map(select(. == "Bash(git status)")) | length) == 1' >/dev/null
}

@test "claude: permissions block with only deny is kept and extended" {
    printf '{"permissions": {"deny": ["Bash(curl:*)"]}}' >"$D/.claude/settings.json"
    run render .claude/settings.json
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '
      .permissions.deny == ["Bash(curl:*)"] and
      (.permissions.allow | index("Bash(git diff:*)")) and
      (.permissions.ask | index("Bash(wrangler secret:*)"))' >/dev/null
}

@test "claude: render is idempotent" {
    render .claude/settings.json >"$D/.claude/settings.json"
    run render .claude/settings.json
    [ "$status" -eq 0 ]
    [ "$output" = "$(cat "$D/.claude/settings.json")" ]
}

# --- Codex ---

@test "codex: file with both keys already set is emitted byte for byte" {
    printf 'model = "x"\napproval_policy = "on-request" # keep me\nsandbox_mode = "workspace-write"\n\n[tui]\nfoo = 1' >"$D/.codex/config.toml"
    render .codex/config.toml >"$BATS_TEST_TMPDIR/out.toml"
    cmp "$D/.codex/config.toml" "$BATS_TEST_TMPDIR/out.toml"
}

@test "codex: wrong top-level values are replaced, tables and other keys untouched" {
    cat >"$D/.codex/config.toml" <<'EOF'
model = "x"
approval_policy = "never"
sandbox_mode = "danger-full-access"

[profiles.ci]
approval_policy = "never"
sandbox_mode = "read-only"
EOF
    run render .codex/config.toml
    [ "$status" -eq 0 ]
    [[ "$output" == *$'model = "x"\napproval_policy = "on-request"\nsandbox_mode = "workspace-write"\n\n[profiles.ci]\napproval_policy = "never"\nsandbox_mode = "read-only"'* ]]
}

@test "codex: missing keys are inserted before the first table" {
    printf 'model = "x"\n\n[tui]\nfoo = 1\n' >"$D/.codex/config.toml"
    run render .codex/config.toml
    [ "$status" -eq 0 ]
    [ "$output" = $'model = "x"\napproval_policy = "on-request"\nsandbox_mode = "workspace-write"\n\n[tui]\nfoo = 1' ]
}

@test "codex: empty or missing file yields just the two keys" {
    run render .codex/config.toml
    [ "$status" -eq 0 ]
    [ "$output" = $'approval_policy = "on-request"\nsandbox_mode = "workspace-write"' ]
}

@test "codex: render is idempotent" {
    printf 'model = "x"\n\n[tui]\nfoo = 1\n' >"$D/.codex/config.toml"
    render .codex/config.toml >"$BATS_TEST_TMPDIR/once.toml"
    cp "$BATS_TEST_TMPDIR/once.toml" "$D/.codex/config.toml"
    render .codex/config.toml >"$BATS_TEST_TMPDIR/twice.toml"
    cmp "$BATS_TEST_TMPDIR/once.toml" "$BATS_TEST_TMPDIR/twice.toml"
}
