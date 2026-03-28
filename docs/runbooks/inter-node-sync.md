# Inter-Node Synchronization

Keeping configurations and code synchronized across the fleet.

## Sync Types

### 1. Dotfiles Sync

Keep dotfiles consistent across all nodes.

```bash
# On any node - pull latest dotfiles
dot update

# Full sync with reload
dot update && dot reload

# Check for drift
dot check
```

### 2. Repository Sync

Keep FORGE repositories in sync.

```bash
# Sync current repo to latest
git pull --rebase

# Sync across all nodes (via forge)
forge fleet sync

# Force sync (careful!)
forge fleet sync --force
```

### 3. Config Sync

Sync FORGE configurations.

```bash
# Sync forge config
forge config sync

# Sync secrets (via dot secret)
dot secret sync
```

## Sync Workflow

### Regular Sync (Daily)

```bash
# 1. Check status
fleet-status

# 2. Update dotfiles
dot update

# 3. Sync repos
forge fleet sync

# 4. Verify
fleet-health
```

### Before Major Work

```bash
# 1. Pull latest on all relevant repos
git pull --rebase

# 2. Sync fleet
forge fleet sync

# 3. Update tools
dot update

# 4. Check health
fleet-health
```

### After Changes

```bash
# 1. Commit and push
git add -A && git commit -m "feat: your changes"
git push

# 2. Sync to fleet
forge fleet sync

# 3. Verify on other nodes
node-exec <node> "git log -1"
```

## Sync Commands

### Quick Sync

```bash
# Sync everything
fleet-sync() {
    echo "🔄 Syncing fleet..."
    dot update
    forge fleet sync 2>/dev/null
    echo "✅ Sync complete"
    fleet-status
}
```

### Node-to-Node Sync

```bash
# Push to specific node
forge sync push <node>

# Pull from specific node
forge sync pull <node>
```

### Selective Sync

```bash
# Sync only dotfiles
dot update

# Sync only repo
git pull

# Sync only config
forge config sync
```

## Handling Conflicts

### Dotfiles Conflict

```bash
# Check for conflicts
dot check

# Reset to remote
dot reset --hard

# Or manual resolve
cd ~/dotfiles
git status
# Edit conflicting files
git add -A && git commit -m "Resolve conflicts"
```

### Repository Conflict

```bash
# See conflict
git status

# Resolve manually
git diff --name-only --diff-filter=U
# Edit files...

# Or accept one side
git checkout --ours <file>
git checkout --theirs <file>

# Continue
git add -A
git rebase --continue
```

### Forge State Conflict

```bash
# Check state
forge doctor

# Reset to clean state
forge recover --reset-state
```

## Sync Schedule

### Automatic (Recommended)

Add to crontab or use forge patrol:

```bash
# Daily dotfiles sync at 6am
forge patrol add --name "daily-sync" --schedule "0 6 * * *" --command "dot update && dot reload"

# Hourly repo sync during work hours
forge patrol add --name "hourly-sync" --schedule "0 9-17 * * 1-5" --command "git pull --rebase"
```

### Manual Triggers

```bash
# Quick sync before work
alias work-start='fleet-sync && fleet-status'

# End of day sync
alias work-end='git push && forge fleet sync && forge status'
```

## Verification

### After Sync

```bash
# Verify dotfiles
dot check

# Verify repos
git status

# Verify fleet
forge fleet verify
```

### Cross-Node Verification

```bash
# Check version on all nodes
for node in prya sati nova trinity gaea; do
    echo "=== $node ==="
    node-exec $node "git log -1 --oneline"
done
```

## Best Practices

1. **Sync Before Starting**: Always pull latest before beginning work
2. **Sync After Changes**: Push and sync immediately after commits
3. **Avoid Long-Lived Branches**: Merge to main frequently
4. **Check Before Dispatch**: Ensure target node is in sync
5. **Resolve Conflicts Quickly**: Don't let conflicts accumulate

## Troubleshooting

### Sync Fails

```bash
# Check connectivity
tailscale status

# Check git state
git status

# Force reset if needed
git fetch --all
git reset --hard origin/main
```

### Partial Sync

```bash
# Identify failed part
forge fleet sync --verbose

# Retry specific component
dot update  # or
forge fleet sync --retry
```

### Node Out of Sync

```bash
# SSH to node
node-exec <node> "git pull --rebase"

# Or full reset
node-exec <node> "git fetch && git reset --hard origin/main"
```
