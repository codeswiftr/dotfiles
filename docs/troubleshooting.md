# 🔧 Troubleshooting Guide

Comprehensive guide to resolving common issues with the dotfiles environment.

## 🚨 Quick Diagnostics

```bash
# Run comprehensive system check
dot check

# Quick health assessment
dot doctor

# Performance diagnostics
perf-status

# Check specific components
tmux-diagnostic
nvim-diagnostic
zsh-diagnostic
```

## 🐚 Shell Issues

### Zsh Not Loading Properly

**Symptoms:**
- Commands not found
- Aliases not working
- Slow startup times

**Solutions:**

```bash
# 1. Reload configuration
source ~/.zshrc

# 2. Check for syntax errors
zsh -n ~/.zshrc

# 3. Enable debug mode
export DOTFILES_DEBUG=true
exec zsh

# 4. Reset to minimal config
export DOTFILES_FAST_MODE=true
exec zsh

# 5. Complete reload
dot reload
```

### Fish-like Autosuggestions Not Working

**Symptoms:**
- No command suggestions appear
- Suggestions are incorrect
- Performance issues

**Solutions:**

```bash
# 1. Check if plugin is loaded
echo $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE

# 2. Clear suggestion cache
rm -rf ~/.zsh/cache/autosuggestions

# 3. Rebuild history database
atuin import auto

# 4. Restart with fresh config
unset ZSH_AUTOSUGGEST_USE_ASYNC
source ~/.zshrc

# 5. Reset autosuggestions
unset ZSH_AUTOSUGGEST_STRATEGY
source config/zsh/history-enhanced.zsh
```

### Slow Shell Startup

**Symptoms:**
- Shell takes >2 seconds to load
- Lag when opening new terminals

**Solutions:**

```bash
# 1. Enable performance timing
export DOTFILES_PERF_TIMING=true
exec zsh

# 2. Use fast mode
export DOTFILES_FAST_MODE=true
exec zsh

# 3. Profile startup time
perf-benchmark-startup

# 4. Disable non-essential features
export DOTFILES_MINIMAL=true
exec zsh

# 5. Check for problematic plugins
zsh-plugin-diagnosis
```

## 🖥️ Tmux Issues

### Keybindings Not Working

**Symptoms:**
- Ctrl-a+c opens Claude instead of creating window
- Ctrl-a+d opens Docker instead of detaching
- Split navigation not working

**Solutions:**

```bash
# 1. Check tmux configuration
tmux show-options -g

# 2. Reload tmux config
tmux source-file ~/.tmux.conf

# 3. Check for conflicting bindings
tmux list-keys | grep -E "(C-a c|C-a d)"

# 4. Reset to default config
cp .tmux.conf .tmux.conf.backup
tmux kill-server
tmux

# 5. Verify prefix key
tmux show-options -g prefix
```

### Copy/Paste Not Working

**Symptoms:**
- Cannot copy text with mouse
- Paste doesn't work
- System clipboard not integrated

**Solutions:**

```bash
# 1. Check mouse support
tmux show-options -g mouse

# 2. Test copy mode
tmux copy-mode
# Press 'v' to start selection, 'y' to copy

# 3. Check system clipboard integration
echo "test" | pbcopy
pbpaste

# 4. Reset copy mode bindings
tmux unbind -T copy-mode-vi y
tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

# 5. Check terminal compatibility
echo $TERM
```

### Terminal Titles Not Updating

**Symptoms:**
- Terminal window title doesn't change
- Shows wrong session information
- Manual title setting not working

**Solutions:**

```bash
# 1. Test title functionality
scripts/test-terminal-title.sh

# 2. Check terminal preferences
# Terminal.app: Preferences > Profiles > Window > Title

# 3. Manually set title
title "Test Title"

# 4. Check tmux title settings
tmux show-options -g set-titles
tmux show-options -g set-titles-string

# 5. Reload title integration
source config/zsh/tmux-title.zsh
update_terminal_title
```

## 📝 Neovim Issues

### Split Navigation Not Working

**Symptoms:**
- s+hjkl doesn't navigate splits
- Error about unknown command
- Keybindings conflict

**Solutions:**

```bash
# 1. Check if keybindings are loaded
nvim -c ":map sh"

# 2. Verify config location
ls -la ~/.config/nvim/init.lua

# 3. Test in clean environment
nvim --clean

# 4. Check for conflicts
nvim -c ":verbose map s"

# 5. Reload configuration
nvim -c ":source ~/.config/nvim/init.lua"
```

### Plugins Not Loading

**Symptoms:**
- Error messages on startup
- Missing functionality
- Plugin commands not found

**Solutions:**

```bash
# 1. Check plugin manager
nvim -c ":Lazy"

# 2. Update plugins
nvim -c ":Lazy sync"

# 3. Check for errors
nvim -c ":checkhealth"

# 4. Clear plugin cache
rm -rf ~/.local/share/nvim/lazy

# 5. Reinstall plugins
nvim -c ":Lazy clean" -c ":Lazy install"
```

## 🍎 iOS Development Issues

### Xcode Command Line Tools Missing

**Symptoms:**
- xcodebuild command not found
- Build failures
- Simulator not available

**Solutions:**

```bash
# 1. Install command line tools
xcode-select --install

# 2. Check installation
xcode-select -p

# 3. Reset developer directory
sudo xcode-select --reset

# 4. Accept license
sudo xcodebuild -license accept

# 5. Verify installation
xcrun --find xcodebuild
```

### iOS Simulator Issues

**Symptoms:**
- Simulator doesn't start
- App doesn't install
- Performance problems

**Solutions:**

```bash
# 1. Reset simulator
xcrun simctl erase all

# 2. Restart simulator service
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService

# 3. Check available devices
xcrun simctl list devices

# 4. Install app manually
xcrun simctl install booted path/to/app.app

# 5. Check simulator logs
tail -f ~/Library/Logs/CoreSimulator/*/system.log
```

### Swift Build Failures

**Symptoms:**
- Compilation errors
- Missing dependencies
- Code signing issues

**Solutions:**

```bash
# 1. Clean build folder
xcodebuild clean

# 2. Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# 3. Reset package cache
xcodebuild -resolvePackageDependencies

# 4. Check code signing
codesign --verify --verbose path/to/app.app

# 5. Update certificates
security find-identity -v -p codesigning
```

## 🌐 Web Development Issues

### FastAPI Server Not Starting

**Symptoms:**
- Port already in use
- Import errors
- Configuration issues

**Solutions:**

```bash
# 1. Check port availability
lsof -i :8000

# 2. Kill existing processes
pkill -f uvicorn

# 3. Check Python environment
python3 -c "import fastapi; print('FastAPI OK')"

# 4. Use different port
fastapi-dev --port 8001

# 5. Check dependencies
pip list | grep -E "(fastapi|uvicorn)"
```

### Node/Bun Package Issues

**Symptoms:**
- Module not found errors
- Version conflicts
- Build failures

**Solutions:**

```bash
# 1. Clear package cache
npm cache clean --force
# or
rm -rf ~/.bun/install/cache

# 2. Delete node_modules
rm -rf node_modules package-lock.json
npm install

# 3. Check Node version
node --version
nvm use stable

# 4. Verify package.json
npm ls

# 5. Use fresh environment
npx create-vite@latest test-project
```

### PWA Features Not Working

**Symptoms:**
- Service worker not registering
- Manifest not loading
- Offline functionality broken

**Solutions:**

```bash
# 1. Check service worker registration
# Open browser dev tools > Application > Service Workers

# 2. Validate manifest
# Dev tools > Application > Manifest

# 3. Test offline mode
# Dev tools > Network > Offline

# 4. Clear browser cache
# Dev tools > Storage > Clear storage

# 5. Check HTTPS requirement
# PWAs require HTTPS in production
```

## 🤖 AI Tools Issues

### Claude CLI Not Working

**Symptoms:**
- Authentication errors
- API key issues
- Command not found

**Solutions:**

```bash
# 1. Check installation
which claude

# 2. Verify API key
claude auth status

# 3. Re-authenticate
claude auth login

# 4. Check permissions
claude auth whoami

# 5. Update CLI
pip install --upgrade claude-cli
```

### Gemini CLI Issues

**Symptoms:**
- Quota exceeded
- Authentication failures
- Connection timeouts

**Solutions:**

```bash
# 1. Check quota status
gemini quota status

# 2. Check API key
gemini auth status

# 3. Re-authenticate
gemini auth login

# 4. Check network connectivity
curl -I https://generativelanguage.googleapis.com

# 5. Use different model
gemini chat --model gemini-pro
```

## 🔧 Tool-Specific Issues

### Git Integration Problems

**Symptoms:**
- Commit signing failures
- Authentication issues
- Remote access denied

**Solutions:**

```bash
# 1. Check Git configuration
git config --list

# 2. Test SSH key
ssh -T git@github.com

# 3. Check GPG signing
git config --get user.signingkey
gpg --list-secret-keys

# 4. Reset credentials
git config --global --unset credential.helper

# 5. Re-setup authentication
dot security setup-ssh
```

### Docker Issues

**Symptoms:**
- Docker daemon not running
- Permission denied
- Container build failures

**Solutions:**

```bash
# 1. Start Docker daemon
sudo systemctl start docker

# 2. Check Docker status
docker info

# 3. Add user to docker group
sudo usermod -aG docker $USER

# 4. Clean Docker cache
docker system prune

# 5. Reset Docker
docker system reset
```

### Performance Issues

**Symptoms:**
- Slow command execution
- High memory usage
- System lag

**Solutions:**

```bash
# 1. Check system resources
htop

# 2. Profile shell performance
perf-benchmark-startup

# 3. Enable fast mode
export DOTFILES_FAST_MODE=true

# 4. Disable heavy features
export DOTFILES_MINIMAL=true

# 5. Clean up caches
find ~ -name "*.cache" -type d -exec rm -rf {} +
```

## 🆘 Emergency Recovery

### Complete System Reset

If everything is broken:

```bash
# 1. Backup current state
tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/dotfiles ~/.zshrc ~/.tmux.conf

# 2. Reset to clean state
cd ~/dotfiles
git stash
git reset --hard HEAD

# 3. Reinstall everything
./install.sh install standard

# 4. Restore personal configurations
# (manually merge from backup)
```

### Rollback to Previous Version

```bash
# 1. Check git history
git log --oneline -10

# 2. Rollback to specific commit
git reset --hard <commit-hash>

# 3. Force reload configurations
source ~/.zshrc
tmux source-file ~/.tmux.conf

# 4. Verify functionality
dot check
```

## 📞 Getting Additional Help

### Diagnostic Information

When reporting issues, include:

```bash
# System information
uname -a
echo $SHELL
echo $TERM

# Dotfiles version
cat ~/dotfiles/VERSION

# Tool versions
tmux -V
nvim --version
git --version

# Configuration status
dot check 2>&1 | head -20
```

### Log Files

Check these log files for errors:

```bash
# Installation logs
tail -50 ~/dotfiles-install.log

# Shell history with errors
history | grep -E "(error|failed|permission)"

# System logs (macOS)
tail -50 /var/log/system.log

# tmux logs
tmux list-sessions -F "#{session_name}: #{session_created}"
```

### Community Support

- **GitHub Issues**: [Create an issue](https://github.com/codeswiftr/dotfiles/issues)
- **Discussions**: [Join discussions](https://github.com/codeswiftr/dotfiles/discussions)
- **Documentation**: Check the docs/ directory
- **Stack Overflow**: Tag questions with `dotfiles`

---

Most issues can be resolved by following this guide. If you're still stuck, don't hesitate to ask for help! 🤝