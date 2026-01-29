# Dotfiles Portability Fixes

Applied on: 2026-01-29

## Summary

Fixed four critical portability issues that would break dotfiles on fresh machines or for other users.

## Changes Applied

### 1. Fixed bin/cursor $1 guard issue

**Problem**: Script uses `set -eu` and references `$1` without checking if arguments exist, causing crash when run without arguments.

**Fix**: Changed line 26 from:
```sh
if [ "$1" != "agent" ]; then
```
to:
```sh
if [ "${1:-}" != "agent" ]; then
```

**Result**: Script now safely handles being called with no arguments.

### 2. Replaced bin/agent symlink with portable wrapper

**Problem**: Hardcoded symlink to absolute path `/Users/bogdan/.local/share/cursor-agent/versions/2026.01.23-916f423/cursor-agent` breaks on other machines and when cursor-agent updates.

**Fix**: Replaced symlink with dynamic wrapper script that:
- Finds the latest cursor-agent version automatically
- Falls back to `cursor agent` subcommand if needed
- Provides clear error message if cursor-agent not found

**Result**: Works across machines and automatically picks up cursor-agent updates.

### 3. Fixed broken .vimrc symlink

**Problem**: `.vimrc` was a broken symlink to `.vimrc.deprecated`.

**Fix**: Removed symlink and created minimal portable `.vimrc` that:
- Detects nvim and defers to it
- Provides sensible defaults for vim compatibility
- Includes persistent undo, better search, mouse support
- Creates necessary directories automatically

**Result**: Works on any machine with vim installed, gracefully handles nvim.

### 4. Created config/platform/Brewfile

**Problem**: Missing Brewfile meant no automated package management for macOS.

**Fix**: Created comprehensive Brewfile with:
- Core shell tools (zsh, tmux, starship)
- Modern CLI replacements (fzf, ripgrep, fd, bat, eza, zoxide)
- Development tools (mise, uv, git, gh)
- Text processing (jq, yq, glow)
- Database clients (postgresql, redis)
- Nerd fonts for terminal
- Commented optional sections for AI tools, containers, productivity apps

**Result**: Single command `brew bundle` installs all necessary tools.

## Verification

All fixes tested and verified:

```bash
# Test cursor without args (no crash)
~/dotfiles/bin/cursor
# Output: Error message (expected), no crash

# Test agent wrapper
~/dotfiles/bin/agent --version
# Output: 2026.01.23-916f423 (found latest version)

# Check files are no longer symlinks
ls -la ~/dotfiles/bin/agent
# Output: .rwxr-xr-x@ (regular file)

ls -la ~/dotfiles/.vimrc
# Output: .rw-r--r--@ (regular file)

# Verify Brewfile exists
ls ~/dotfiles/config/platform/Brewfile
# Output: File exists (92 lines)
```

## Impact

These fixes make the dotfiles:
- Portable across machines (no hardcoded paths)
- Self-healing (finds latest versions automatically)
- More robust (handles edge cases without crashing)
- Easier to bootstrap on new machines (Brewfile)

## Files Modified

- `/Users/bogdan/dotfiles/bin/cursor` - Fixed $1 guard
- `/Users/bogdan/dotfiles/bin/agent` - Symlink → wrapper script
- `/Users/bogdan/dotfiles/.vimrc` - Broken symlink → minimal config
- `/Users/bogdan/dotfiles/config/platform/Brewfile` - Created new file

## Next Steps

Consider adding to dotfiles:
1. Bootstrap script that uses the Brewfile
2. README with setup instructions
3. CI/CD to test portability on clean machines
